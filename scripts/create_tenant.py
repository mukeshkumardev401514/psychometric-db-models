#!/usr/bin/env python3

import argparse
import os
import re
import subprocess
import sys
import uuid
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


# =========================================================
# PATH / ENV
# =========================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")


# =========================================================
# PLATFORM DB
# =========================================================

PLATFORM_DB_HOST = os.getenv("PLATFORM_DB_HOST", "localhost")
PLATFORM_DB_PORT = os.getenv("PLATFORM_DB_PORT", "5432")
PLATFORM_DB_NAME = os.getenv(
    "PLATFORM_DB_NAME",
    "psychometric_platform",
)
PLATFORM_DB_USER = os.getenv("PLATFORM_DB_USER")
PLATFORM_DB_PASSWORD = os.getenv("PLATFORM_DB_PASSWORD")


# =========================================================
# TENANT DB
# =========================================================

TENANT_DB_HOST = os.getenv("TENANT_DB_HOST", "localhost")
TENANT_DB_PORT = os.getenv("TENANT_DB_PORT", "5432")
TENANT_DB_USER = os.getenv(
    "TENANT_DB_USER",
    "psych_tenant_app",
)


# =========================================================
# HELPERS
# =========================================================

def fail(message):
    print(f"\nERROR: {message}")
    sys.exit(1)


def validate_config():

    required = {
        "PLATFORM_DB_USER": PLATFORM_DB_USER,
        "PLATFORM_DB_PASSWORD": PLATFORM_DB_PASSWORD,
        "TENANT_DB_USER": TENANT_DB_USER,
    }

    missing = [
        key
        for key, value in required.items()
        if not value
    ]

    if missing:
        fail(
            "Missing environment variables:\n"
            + "\n".join(
                f"  - {item}"
                for item in missing
            )
        )


def validate_tenant_code(tenant_code):

    if not re.fullmatch(
        r"[A-Z][A-Z0-9_]{2,30}",
        tenant_code,
    ):
        fail(
            f"Invalid tenant code: {tenant_code}\n"
            "Example: TEST01"
        )


def validate_domain(domain):

    if not re.fullmatch(
        r"[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?",
        domain,
    ):
        fail(
            f"Invalid domain: {domain}"
        )


# =========================================================
# PLATFORM CONNECTION
# =========================================================

def get_platform_connection():

    try:

        return psycopg2.connect(
            host=PLATFORM_DB_HOST,
            port=PLATFORM_DB_PORT,
            dbname=PLATFORM_DB_NAME,
            user=PLATFORM_DB_USER,
            password=PLATFORM_DB_PASSWORD,
        )

    except Exception as exc:

        fail(
            f"Unable to connect to Platform DB: {exc}"
        )


# =========================================================
# FIND TENANT
# =========================================================

def find_tenant(
    conn,
    tenant_code,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT
                id,
                tenant_code,
                tenant_name,
                tenant_type,
                status,
                database_name
            FROM tenants
            WHERE tenant_code = %s
            """,
            (tenant_code,),
        )

        return cur.fetchone()


# =========================================================
# CHECK DOMAIN
# =========================================================

def domain_exists(
    conn,
    domain,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT
                id,
                tenant_id,
                domain,
                is_primary,
                status
            FROM tenant_domains
            WHERE domain = %s
            """,
            (domain,),
        )

        return cur.fetchone()


# =========================================================
# CHECK DATABASE CONFIG
# =========================================================

def database_config_exists(
    conn,
    tenant_id,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT
                id,
                tenant_id,
                database_name,
                host,
                port,
                username,
                secret_reference,
                status
            FROM tenant_database_config
            WHERE tenant_id = %s
            """,
            (tenant_id,),
        )

        return cur.fetchone()


# =========================================================
# CREATE TENANT
# =========================================================

def create_tenant(
    conn,
    tenant_code,
    tenant_name,
    tenant_type,
    database_name,
):

    tenant_id = str(uuid.uuid4())

    with conn.cursor() as cur:

        cur.execute(
            """
            INSERT INTO tenants
            (
                id,
                tenant_code,
                tenant_name,
                tenant_type,
                status,
                database_name
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                'PROVISIONING',
                %s
            )
            RETURNING id
            """,
            (
                tenant_id,
                tenant_code,
                tenant_name,
                tenant_type,
                database_name,
            ),
        )

        tenant_id = cur.fetchone()[0]

    conn.commit()

    return tenant_id


# =========================================================
# UPDATE EXISTING TENANT TO PROVISIONING
# =========================================================

def set_provisioning(
    conn,
    tenant_id,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            UPDATE tenants
            SET
                status = 'PROVISIONING',
                updated_at = NOW()
            WHERE id = %s
            """,
            (tenant_id,),
        )

    conn.commit()


# =========================================================
# CREATE PROVISIONING HISTORY
# =========================================================

def create_history(
    conn,
    tenant_id,
    database_name,
    operation,
):

    history_id = str(uuid.uuid4())

    with conn.cursor() as cur:

        cur.execute(
            """
            INSERT INTO tenant_provisioning_history
            (
                id,
                tenant_id,
                database_name,
                operation,
                status,
                started_at
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                'STARTED',
                NOW()
            )
            RETURNING id
            """,
            (
                history_id,
                tenant_id,
                database_name,
                operation,
            ),
        )

    conn.commit()

    return history_id


# =========================================================
# HISTORY SUCCESS
# =========================================================

def mark_history_success(
    conn,
    history_id,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            UPDATE tenant_provisioning_history
            SET
                status = 'SUCCESS',
                completed_at = NOW(),
                error_message = NULL
            WHERE id = %s
            """,
            (history_id,),
        )

    conn.commit()


# =========================================================
# HISTORY FAILED
# =========================================================

def mark_history_failed(
    conn,
    history_id,
    error_message,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            UPDATE tenant_provisioning_history
            SET
                status = 'FAILED',
                completed_at = NOW(),
                error_message = %s
            WHERE id = %s
            """,
            (
                str(error_message)[:5000],
                history_id,
            ),
        )

    conn.commit()


# =========================================================
# CREATE DOMAIN
# =========================================================

def create_domain(
    conn,
    tenant_id,
    domain,
):

    existing = domain_exists(
        conn,
        domain,
    )

    if existing:

        existing_tenant_id = str(
            existing[1]
        )

        if existing_tenant_id != str(
            tenant_id
        ):
            raise RuntimeError(
                f"Domain already belongs to "
                f"another tenant: {domain}"
            )

        print(
            f"Domain already exists: {domain}"
        )

        return

    with conn.cursor() as cur:

        cur.execute(
            """
            INSERT INTO tenant_domains
            (
                id,
                tenant_id,
                domain,
                is_primary,
                status
            )
            VALUES
            (
                %s,
                %s,
                %s,
                TRUE,
                'ACTIVE'
            )
            """,
            (
                str(uuid.uuid4()),
                tenant_id,
                domain,
            ),
        )

    conn.commit()

    print(
        f"Domain created: {domain}"
    )


# =========================================================
# CREATE DATABASE CONFIG
# =========================================================

def create_database_config(
    conn,
    tenant_id,
    database_name,
):

    existing = database_config_exists(
        conn,
        tenant_id,
    )

    if existing:

        print(
            "Tenant database config already exists."
        )

        return

    with conn.cursor() as cur:

        cur.execute(
            """
            INSERT INTO tenant_database_config
            (
                id,
                tenant_id,
                database_name,
                host,
                port,
                username,
                secret_reference,
                status
            )
            VALUES
            (
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                %s,
                'ACTIVE'
            )
            """,
            (
                str(uuid.uuid4()),
                tenant_id,
                database_name,
                TENANT_DB_HOST,
                int(TENANT_DB_PORT),
                TENANT_DB_USER,
                "ENV:TENANT_DB_PASSWORD",
            ),
        )

    conn.commit()

    print(
        "Tenant database config created."
    )


# =========================================================
# RUN TENANT MIGRATIONS
# =========================================================

def run_tenant_migrations(
    database_name,
):

    migration_script = (
        BASE_DIR
        / "scripts"
        / "migrate_tenant.py"
    )

    if not migration_script.exists():

        raise RuntimeError(
            f"Migration script not found: "
            f"{migration_script}"
        )

    print()
    print("----------------------------------------")
    print("Running tenant database migrations")
    print("----------------------------------------")
    print()

    result = subprocess.run(
        [
            sys.executable,
            str(migration_script),
            database_name,
        ],
        cwd=str(BASE_DIR),
    )

    if result.returncode != 0:

        raise RuntimeError(
            "Tenant database migration failed."
        )

    print(
        "Tenant migrations completed successfully."
    )


# =========================================================
# ACTIVATE TENANT
# =========================================================

def activate_tenant(
    conn,
    tenant_id,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            UPDATE tenants
            SET
                status = 'ACTIVE',
                updated_at = NOW()
            WHERE id = %s
            """,
            (tenant_id,),
        )

    conn.commit()


# =========================================================
# SUSPEND TENANT
# =========================================================

def suspend_tenant(
    conn,
    tenant_id,
):

    with conn.cursor() as cur:

        cur.execute(
            """
            UPDATE tenants
            SET
                status = 'SUSPENDED',
                updated_at = NOW()
            WHERE id = %s
            """,
            (tenant_id,),
        )

    conn.commit()


# =========================================================
# MAIN
# =========================================================

def provision_tenant(
    tenant_code,
    tenant_name,
    tenant_type,
    domain,
):

    database_name = (
        f"psych_{tenant_code.lower()}"
    )

    platform_conn = None
    tenant_id = None
    history_id = None

    try:

        print()
        print("========================================")
        print("       TENANT PROVISIONING")
        print("========================================")
        print()

        print(f"Tenant Code : {tenant_code}")
        print(f"Tenant Name : {tenant_name}")
        print(f"Tenant Type : {tenant_type}")
        print(f"Domain      : {domain}")
        print(f"Database    : {database_name}")
        print()

        # -------------------------------------
        # Platform DB
        # -------------------------------------

        print(
            "Connecting to Platform DB..."
        )

        platform_conn = (
            get_platform_connection()
        )

        print(
            "Platform DB connection successful."
        )

        # -------------------------------------
        # Find existing tenant
        # -------------------------------------

        tenant = find_tenant(
            platform_conn,
            tenant_code,
        )

        if tenant:

            tenant_id = tenant[0]
            existing_name = tenant[2]
            existing_type = tenant[3]
            existing_status = tenant[4]
            existing_database = tenant[5]

            print()
            print(
                "Existing tenant found:"
            )
            print(
                f"  ID       : {tenant_id}"
            )
            print(
                f"  Name     : {existing_name}"
            )
            print(
                f"  Type     : {existing_type}"
            )
            print(
                f"  Status   : {existing_status}"
            )
            print(
                f"  Database : {existing_database}"
            )

            # ---------------------------------
            # ACTIVE = don't recreate
            # ---------------------------------

            if existing_status == "ACTIVE":

                fail(
                    f"Tenant {tenant_code} "
                    "already exists and is ACTIVE."
                )

            # ---------------------------------
            # Validate DB name
            # ---------------------------------

            if existing_database != database_name:

                fail(
                    "Existing tenant database name "
                    "does not match expected database name.\n"
                    f"Existing : {existing_database}\n"
                    f"Expected : {database_name}"
                )

            # ---------------------------------
            # Resume
            # ---------------------------------

            print()
            print(
                "Existing non-active tenant found."
            )
            print(
                "Resuming provisioning..."
            )

            set_provisioning(
                platform_conn,
                tenant_id,
            )

        else:

            # ---------------------------------
            # New tenant
            # ---------------------------------

            # Domain must not belong to another
            # tenant.

            existing_domain = domain_exists(
                platform_conn,
                domain,
            )

            if existing_domain:

                fail(
                    f"Domain already exists: "
                    f"{domain}"
                )

            print(
                "No existing tenant found."
            )

            print(
                "Creating new tenant..."
            )

            tenant_id = create_tenant(
                platform_conn,
                tenant_code,
                tenant_name,
                tenant_type,
                database_name,
            )

            print(
                f"Tenant created: {tenant_id}"
            )

        # -------------------------------------
        # Provisioning history
        # -------------------------------------

        history_id = create_history(
            platform_conn,
            tenant_id,
            database_name,
            "CREATE_TENANT",
        )

        print(
            "Provisioning history created."
        )

        # -------------------------------------
        # Database + migrations
        # -------------------------------------

        run_tenant_migrations(
            database_name
        )

        # -------------------------------------
        # Domain
        # -------------------------------------

        print(
            "Checking/creating tenant domain..."
        )

        create_domain(
            platform_conn,
            tenant_id,
            domain,
        )

        # -------------------------------------
        # Database config
        # -------------------------------------

        print(
            "Checking/creating database config..."
        )

        create_database_config(
            platform_conn,
            tenant_id,
            database_name,
        )

        # -------------------------------------
        # Activate
        # -------------------------------------

        print(
            "Activating tenant..."
        )

        activate_tenant(
            platform_conn,
            tenant_id,
        )

        # -------------------------------------
        # Success
        # -------------------------------------

        mark_history_success(
            platform_conn,
            history_id,
        )

        print()
        print("========================================")
        print("    TENANT PROVISIONING SUCCESS")
        print("========================================")
        print()

        print(
            f"Tenant ID : {tenant_id}"
        )
        print(
            f"Code      : {tenant_code}"
        )
        print(
            f"Database  : {database_name}"
        )
        print(
            f"Domain    : {domain}"
        )
        print(
            "Status    : ACTIVE"
        )

        print()

    except Exception as exc:

        print()
        print("========================================")
        print("    TENANT PROVISIONING FAILED")
        print("========================================")
        print()

        print(str(exc))

        print()

        if platform_conn:

            try:

                if history_id:

                    mark_history_failed(
                        platform_conn,
                        history_id,
                        exc,
                    )

                if tenant_id:

                    suspend_tenant(
                        platform_conn,
                        tenant_id,
                    )

            except Exception as cleanup_error:

                print(
                    "WARNING: Could not update "
                    "failure status: "
                    f"{cleanup_error}"
                )

        sys.exit(1)

    finally:

        if platform_conn:

            platform_conn.close()


# =========================================================
# CLI
# =========================================================

def main():

    parser = argparse.ArgumentParser(
        description=(
            "Create or resume tenant provisioning."
        )
    )

    parser.add_argument(
        "--code",
        required=True,
        help="Tenant code, e.g. TEST01",
    )

    parser.add_argument(
        "--name",
        required=True,
        help="Tenant name",
    )

    parser.add_argument(
        "--type",
        required=True,
        choices=[
            "HOSPITAL_ORGANIZATION",
            "INDIVIDUAL_DOCTOR",
        ],
        help="Tenant type",
    )

    parser.add_argument(
        "--domain",
        required=True,
        help="Primary tenant domain",
    )

    args = parser.parse_args()

    validate_config()

    tenant_code = args.code.upper()
    domain = args.domain.lower()

    validate_tenant_code(
        tenant_code
    )

    validate_domain(
        domain
    )

    provision_tenant(
        tenant_code=tenant_code,
        tenant_name=args.name,
        tenant_type=args.type,
        domain=domain,
    )


if __name__ == "__main__":
    main()