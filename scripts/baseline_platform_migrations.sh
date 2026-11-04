#!/bin/bash

set -e

echo "========================================"
echo " Baseline Platform DB Migrations"
echo "========================================"

DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="psychometric_platform"
DB_USER="psych_platform_app"
DB_PASSWORD="Welcome@1234#Abc"

export PGPASSWORD="$DB_PASSWORD"

echo ""
echo "Database: $DB_NAME"
echo "User:     $DB_USER"
echo ""

echo "Creating migration history table..."

psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -c "
        CREATE TABLE IF NOT EXISTS schema_migrations (
            version VARCHAR(20) PRIMARY KEY,
            filename VARCHAR(255) NOT NULL UNIQUE,
            checksum VARCHAR(64) NOT NULL,
            applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
        );
    "

echo ""
echo "Checking migration files..."

for file in platform/V*.sql
do

    filename=$(basename "$file")

    if [[ "$filename" == "V000__migration_history.sql" ]]; then
        continue
    fi

    version=$(echo "$filename" | cut -d'_' -f1)

    checksum=$(sha256sum "$file" | awk '{print $1}')

    echo "Baselining: $filename"

    psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -v ON_ERROR_STOP=1 \
        -c "
            INSERT INTO schema_migrations (
                version,
                filename,
                checksum
            )
            VALUES (
                '$version',
                '$filename',
                '$checksum'
            )
            ON CONFLICT (version) DO NOTHING;
        "

done

unset PGPASSWORD

echo ""
echo "========================================"
echo " Baseline completed."
echo "========================================"