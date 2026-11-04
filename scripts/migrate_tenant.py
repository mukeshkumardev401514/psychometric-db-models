#!/usr/bin/env python3

import hashlib
import os
import re
import subprocess
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
except ImportError:
    print("ERROR: python-dotenv is not installed.")
    print("Run: pip install python-dotenv")
    sys.exit(1)


BASE_DIR = Path(__file__).resolve().parent.parent
TENANT_MIGRATION_DIR = BASE_DIR / "tenant"

load_dotenv(BASE_DIR / ".env")


POSTGRES_ADMIN_USER = os.getenv("POSTGRES_ADMIN_USER", "postgres")
POSTGRES_ADMIN_PASSWORD = os.getenv("POSTGRES_ADMIN_PASSWORD")

DB_HOST = os.getenv("TENANT_DB_HOST", "localhost")
DB_PORT = os.getenv("TENANT_DB_PORT", "5432")
TENANT_DB_USER = os.getenv("TENANT_DB_USER", "psych_tenant_app")
TENANT_DB_PASSWORD = os.getenv("TENANT_DB_PASSWORD")


def fail(message):
    print(f"ERROR: {message}")
    sys.exit(1)


def validate_config():
    if not POSTGRES_ADMIN_PASSWORD:
        fail("POSTGRES_ADMIN_PASSWORD is missing in .env")

    if not TENANT_DB_PASSWORD:
        fail("TENANT_DB_PASSWORD is missing in .env")


def validate_db_name(db_name):
    """
    PostgreSQL database name validation.
    Only lowercase letters, numbers and underscore are allowed.
    """
    if not re.fullmatch(r"[a-z][a-z0-9_]{2,62}", db_name):
        fail(
            f"Invalid database name: {db_name}. "
            "Use lowercase letters, numbers and underscore only."
        )


def run_psql(database, sql, username, password):
    env = os.environ.copy()
    env["PGPASSWORD"] = password

    result = subprocess.run(
        [
            "psql",
            "-h",
            DB_HOST,
            "-p",
            DB_PORT,
            "-U",
            username,
            "-d",
            database,
            "-v",
            "ON_ERROR_STOP=1",
            "-c",
            sql,
        ],
        env=env,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr)
        fail("PostgreSQL command failed.")

    return result.stdout.strip()


def database_exists(db_name):
    sql = f"""
        SELECT EXISTS (
            SELECT 1
            FROM pg_database
            WHERE datname = '{db_name}'
        );
    """

    env = os.environ.copy()
    env["PGPASSWORD"] = POSTGRES_ADMIN_PASSWORD

    result = subprocess.run(
        [
            "psql",
            "-h", DB_HOST,
            "-p", DB_PORT,
            "-U", POSTGRES_ADMIN_USER,
            "-d", "postgres",
            "-t",
            "-A",
            "-v", "ON_ERROR_STOP=1",
            "-c", sql,
        ],
        env=env,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stderr)
        fail("Unable to check database existence.")

    return result.stdout.strip().lower() == "t"


def create_database(db_name):
    if database_exists(db_name):
        print(f"Database already exists: {db_name}")
        return

    print(f"Creating database: {db_name}")

    # Safe because db_name was validated above.
    sql = f'CREATE DATABASE "{db_name}" OWNER "{TENANT_DB_USER}";'

    run_psql(
        "postgres",
        sql,
        POSTGRES_ADMIN_USER,
        POSTGRES_ADMIN_PASSWORD,
    )

    print("Database created successfully.")


def run_sql_file(db_name, file_path):
    print(f"Running migration: {file_path.name}")

    env = os.environ.copy()
    env["PGPASSWORD"] = TENANT_DB_PASSWORD

    result = subprocess.run(
        [
            "psql",
            "-h",
            DB_HOST,
            "-p",
            DB_PORT,
            "-U",
            TENANT_DB_USER,
            "-d",
            db_name,
            "-v",
            "ON_ERROR_STOP=1",
            "-f",
            str(file_path),
        ],
        env=env,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr)
        fail(f"Migration failed: {file_path.name}")

    print(f"SUCCESS: {file_path.name}")


def calculate_checksum(file_path):
    sha256 = hashlib.sha256()

    with open(file_path, "rb") as file:
        for chunk in iter(lambda: file.read(8192), b""):
            sha256.update(chunk)

    return sha256.hexdigest()


def get_migration_files():
    files = sorted(
        TENANT_MIGRATION_DIR.glob("V*.sql"),
        key=lambda path: int(
            re.match(r"V(\d+)", path.name).group(1)
        ),
    )

    return files


def ensure_migration_history(db_name):
    history_file = TENANT_MIGRATION_DIR / "V000__migration_history.sql"

    if not history_file.exists():
        fail(
            "tenant/V000__migration_history.sql not found."
        )

    run_sql_file(db_name, history_file)

def get_applied_migrations(db_name):
    sql = """
        SELECT
            version,
            filename,
            checksum
        FROM schema_migrations
        ORDER BY version;
    """

    env = os.environ.copy()
    env["PGPASSWORD"] = TENANT_DB_PASSWORD

    result = subprocess.run(
        [
            "psql",
            "-h",
            DB_HOST,
            "-p",
            DB_PORT,
            "-U",
            TENANT_DB_USER,
            "-d",
            db_name,
            "-v",
            "ON_ERROR_STOP=1",
            "-t",
            "-A",
            "-F",
            "|",
            "-c",
            sql,
        ],
        env=env,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stdout)
        print(result.stderr)
        fail("Failed to read schema_migrations.")

    migrations = {}

    for line in result.stdout.splitlines():
        line = line.strip()

        # Empty line ignore karo
        if not line:
            continue

        parts = line.split("|")

        # Invalid line ignore karo
        if len(parts) != 3:
            print(
                f"WARNING: Ignoring invalid migration history row: {line}"
            )
            continue

        version, filename, checksum = parts

        migrations[version] = {
            "filename": filename,
            "checksum": checksum,
        }

    return migrations

def apply_migrations(db_name):
    migration_files = get_migration_files()

    if not migration_files:
        fail("No tenant migration files found.")

    applied = get_applied_migrations(db_name)

    for migration_file in migration_files:

        version_match = re.match(
            r"(V\d+)_",
            migration_file.name
        )

        if not version_match:
            print(
                f"WARNING: Skipping invalid migration filename: "
                f"{migration_file.name}"
            )
            continue

        version = version_match.group(1)

        # V000 only creates migration history table.
        if version == "V000":
            continue

        checksum = calculate_checksum(migration_file)

        if version in applied:

            old_checksum = applied[version]["checksum"]

            if old_checksum != checksum:
                fail(
                    f"CHECKSUM MISMATCH for {migration_file.name}\n"
                    f"Expected: {old_checksum}\n"
                    f"Current : {checksum}\n"
                    "Do not modify an already executed migration."
                )

            print(
                f"SKIP: {migration_file.name} "
                f"(already applied)"
            )
            continue

        run_sql_file(db_name, migration_file)

        insert_sql = f"""
            INSERT INTO schema_migrations (
                version,
                filename,
                checksum
            )
            VALUES (
                '{version}',
                '{migration_file.name}',
                '{checksum}'
            );
        """

        run_psql(
            db_name,
            insert_sql,
            TENANT_DB_USER,
            TENANT_DB_PASSWORD,
        )

        print(
            f"Recorded migration: {migration_file.name}"
        )


def main():
    print("----------------------------------------")
    print("Tenant Database Migration Runner")
    print("----------------------------------------")

    validate_config()

    if len(sys.argv) != 2:
        print(
            "Usage:\n"
            "  python3 scripts/migrate_tenant.py <database_name>\n\n"
            "Example:\n"
            "  python3 scripts/migrate_tenant.py psych_mvw"
        )
        sys.exit(1)

    db_name = sys.argv[1]

    validate_db_name(db_name)

    print(f"Target database: {db_name}")
    print(f"DB host        : {DB_HOST}")
    print(f"DB port        : {DB_PORT}")
    print(f"DB user        : {TENANT_DB_USER}")

    create_database(db_name)

    ensure_migration_history(db_name)

    apply_migrations(db_name)

    print("----------------------------------------")
    print("Tenant migration completed successfully.")
    print("----------------------------------------")


if __name__ == "__main__":
    main()