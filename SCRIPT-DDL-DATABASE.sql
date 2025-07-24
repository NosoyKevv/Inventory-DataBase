-- Tabla: type_product
CREATE TABLE type_product (
                              type_id SERIAL PRIMARY KEY,
                              type_name VARCHAR(50) NOT NULL
);

-- Tabla: products
CREATE TABLE products (
                          product_id SERIAL PRIMARY KEY,
                          product_name VARCHAR(50) NOT NULL UNIQUE,
                          product_description VARCHAR(120),
                          product_price DOUBLE PRECISION NOT NULL,
                          type_id INTEGER NOT NULL REFERENCES type_product(type_id)
);

-- Tabla: capacity
CREATE TABLE capacity (
                          capacity_id SERIAL PRIMARY KEY,
                          capacity_name VARCHAR(50) NOT NULL,
                          capacity INTEGER NOT NULL CHECK (capacity >= 0)
);

-- Tabla: warehouses
CREATE TABLE warehouses (
                            warehouse_id SERIAL PRIMARY KEY,
                            warehouse_name VARCHAR(50) NOT NULL,
                            warehouse_address VARCHAR(50) NOT NULL,
                            capacity_id INTEGER NOT NULL REFERENCES capacity(capacity_id)
);

-- Tabla: inventory
CREATE TABLE inventory (
                           inventory_id SERIAL PRIMARY KEY,
                           product_id INTEGER NOT NULL REFERENCES products(product_id),
                           warehouse_id INTEGER NOT NULL REFERENCES warehouses(warehouse_id),
                           inventory_stock INTEGER NOT NULL CHECK (inventory_stock >= 0),
                           UNIQUE (product_id, warehouse_id)
);

-- Tabla: type_movement
CREATE TABLE type_movement (
                               type_movement_id SERIAL PRIMARY KEY,
                               type_movement_name VARCHAR(50) NOT NULL
);

-- Tabla: history_movements
CREATE TABLE history_movements (
                                   history_id SERIAL PRIMARY KEY,
                                   inventory_id INTEGER NOT NULL REFERENCES inventory(inventory_id),
                                   warehouse_output_id INTEGER REFERENCES warehouses(warehouse_id),
                                   warehouse_input_id INTEGER REFERENCES warehouses(warehouse_id),
                                   type_movement_id INTEGER NOT NULL REFERENCES type_movement(type_movement_id),
                                   amount DOUBLE PRECISION NOT NULL CHECK (amount >= 0),
                                   movement_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);