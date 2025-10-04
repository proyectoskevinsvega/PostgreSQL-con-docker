#!/bin/bash
# Script de inicialización para crear bases de datos

set -e

echo "Creating initial databases..."

# Crear base de datos de desarrollo
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE development;
    CREATE DATABASE testing;
    CREATE DATABASE staging;
    GRANT ALL PRIVILEGES ON DATABASE development TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE testing TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE staging TO $POSTGRES_USER;
EOSQL

echo "Databases created successfully!"
