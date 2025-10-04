#!/bin/bash
# Script para crear datos de ejemplo

set -e

echo "Creating sample data..."

# Crear datos de ejemplo en la base de datos development
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "development" <<-EOSQL
    -- Crear tabla de usuarios
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Crear tabla de productos
    CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        stock INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Crear tabla de órdenes
    CREATE TABLE IF NOT EXISTS orders (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        total DECIMAL(10,2) NOT NULL,
        status VARCHAR(20) DEFAULT 'pending',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    -- Insertar datos de ejemplo
    INSERT INTO users (username, email, first_name, last_name) VALUES
        ('admin', 'admin@example.com', 'Admin', 'User'),
        ('john_doe', 'john@example.com', 'John', 'Doe'),
        ('jane_smith', 'jane@example.com', 'Jane', 'Smith');

    INSERT INTO products (name, description, price, stock) VALUES
        ('Laptop', 'High-performance laptop', 999.99, 10),
        ('Mouse', 'Wireless mouse', 29.99, 50),
        ('Keyboard', 'Mechanical keyboard', 79.99, 25);

    INSERT INTO orders (user_id, total, status) VALUES
        (1, 1029.98, 'completed'),
        (2, 109.98, 'pending'),
        (3, 79.99, 'shipped');

    -- Crear índices
    CREATE INDEX idx_users_email ON users(email);
    CREATE INDEX idx_products_name ON products(name);
    CREATE INDEX idx_orders_user_id ON orders(user_id);
    CREATE INDEX idx_orders_status ON orders(status);

    -- Crear función para actualizar updated_at
    CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS \$\$
    BEGIN
        NEW.updated_at = CURRENT_TIMESTAMP;
        RETURN NEW;
    END;
    \$\$ language 'plpgsql';

    -- Crear triggers para updated_at
    CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
    CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    
    CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

EOSQL

echo "Sample data created successfully!"
