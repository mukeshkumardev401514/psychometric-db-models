#!/bin/bash

set -e

echo "========================================"
echo " Running Platform DB Migrations"
echo "========================================"

DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="psychometric_platform"
DB_USER="psych_platform_app"

# Temporary password for local development
DB_PASSWORD="Welcome@1234#Abc"

export PGPASSWORD="$DB_PASSWORD"

echo ""
echo "Database: $DB_NAME"
echo "User:     $DB_USER"
echo ""

# ========================================
# 1. Create migration history table
# ========================================

echo "Checking migration history table..."

psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -v ON_ERROR_STOP=1 \
    -f platform/V000__migration_history.sql


# ========================================
# 2. Process migrations
# ========================================

for file in platform/V*.sql
do

    filename=$(basename "$file")

    # Skip migration history file
    if [[ "$filename" == "V000__migration_history.sql" ]]; then
        continue
    fi

    version=$(echo "$filename" | cut -d'_' -f1)

    checksum=$(sha256sum "$file" | awk '{print $1}')

    echo ""
    echo "----------------------------------------"
    echo "Migration : $filename"
    echo "Version   : $version"
    echo "----------------------------------------"


    # ========================================
    # 3. Check if already executed
    # ========================================

    existing_checksum=$(
        psql \
            -h "$DB_HOST" \
            -p "$DB_PORT" \
            -U "$DB_USER" \
            -d "$DB_NAME" \
            -tAc "
                SELECT checksum
                FROM schema_migrations
                WHERE version = '$version';
            "
    )

    existing_checksum=$(echo "$existing_checksum" | xargs)


    # ========================================
    # 4. Already executed
    # ========================================

    if [[ -n "$existing_checksum" ]]; then

        if [[ "$existing_checksum" != "$checksum" ]]; then

            echo ""
            echo "ERROR: Migration checksum mismatch!"
            echo ""
            echo "Migration: $filename"
            echo ""
            echo "Expected:"
            echo "$existing_checksum"
            echo ""
            echo "Current:"
            echo "$checksum"
            echo ""

            unset PGPASSWORD
            exit 1
        fi

        echo "Already executed. Skipping..."

        continue
    fi


    # ========================================
    # 5. Execute new migration
    # ========================================

    echo "Executing migration..."

    psql \
        -h "$DB_HOST" \
        -p "$DB_PORT" \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -v ON_ERROR_STOP=1 \
        -f "$file"


    # ========================================
    # 6. Save migration history
    # ========================================

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
            );
        "

    echo "Migration completed: $filename"

done


unset PGPASSWORD

echo ""
echo "========================================"
echo " Platform DB migrations completed."
echo "========================================"