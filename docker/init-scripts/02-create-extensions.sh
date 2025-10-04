#!/bin/bash
# Script para crear extensiones de PostgreSQL

set -e

echo "Creating PostgreSQL extensions..."

# Instalar extensiones en todas las bases de datos
for db in postgres development testing staging; do
    echo "Installing extensions in database: $db"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$db" <<-EOSQL
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";
        CREATE EXTENSION IF NOT EXISTS "pg_trgm";
        CREATE EXTENSION IF NOT EXISTS "btree_gin";
        CREATE EXTENSION IF NOT EXISTS "btree_gist";
        CREATE EXTENSION IF NOT EXISTS "hstore";
        CREATE EXTENSION IF NOT EXISTS "ltree";
        CREATE EXTENSION IF NOT EXISTS "unaccent";
EOSQL
done

echo "Extensions created successfully!"
