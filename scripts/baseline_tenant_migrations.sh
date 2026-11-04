#!/bin/bash

set -e

echo "Baselining Tenant DB migrations..."

DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="psych_mvw"
DB_USER="psych_tenant_app"
DB_PASSWORD="Welcome@1234#Abc"

export PGPASSWORD="$DB_PASSWORD"

psql \
  -h "$DB_HOST" \
  -p "$DB_PORT" \
  -U "$DB_USER" \
  -d "$DB_NAME" \
  -v ON_ERROR_STOP=1 \
  -f tenant/V000__migration_history.sql

for file in tenant/V*.sql
do
    filename=$(basename "$file")

    if [[ "$filename" == "V000__migration_history.sql" ]]; then
        continue
    fi

    version=$(echo "$filename" | cut -d'_' -f1)
    checksum=$(sha256sum "$file" | awk '{print $1}')

    echo "Baselining $filename..."

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

echo "Tenant DB baseline completed."