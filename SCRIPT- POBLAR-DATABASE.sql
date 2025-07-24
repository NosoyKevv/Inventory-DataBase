-- Poblar type_product
INSERT INTO type_product (type_name) VALUES
                                         ('ELECTRONICO'),
                                         ('ALIMENTOS'),
                                         ('ROPA');

-- Poblar products
INSERT INTO products (product_name, product_description, product_price, type_id) VALUES
                                                                                     ('CELULAR', 'Teléfono inteligente gama media', 1200.50, 1),
                                                                                     ('LECHE', 'Leche entera 1L', 3.75, 2),
                                                                                     ('CAMISETA', 'Camiseta de algodón', 20.00, 3);

-- Poblar capacity
INSERT INTO capacity (capacity_name, capacity) VALUES
                                                   ('PEQUENO', 100),
                                                   ('MEDIANO', 500),
                                                   ('GRANDE', 1000);

-- Poblar warehouses
INSERT INTO warehouses (warehouse_name, warehouse_address, capacity_id) VALUES
                                                                            ('BODEGA NORTE', 'Calle 10 #20-30', 3),
                                                                            ('BODEGA SUR', 'Av. Central #15-25', 2);

-- Poblar inventory
INSERT INTO inventory (product_id, warehouse_id, inventory_stock) VALUES
                                                                      (1, 1, 50),  -- Celular en Bodega Norte
                                                                      (2, 1, 150), -- Leche en Bodega Norte
                                                                      (3, 2, 200); -- Camiseta en Bodega Sur

-- Poblar type_movement
INSERT INTO type_movement (type_movement_name) VALUES
                                                   ('ENTRADA'),
                                                   ('SALIDA'),
                                                   ('TRASLADO');

-- Poblar history_movements
-- Ejemplo de una salida de celulares desde Bodega Norte
INSERT INTO history_movements (inventory_id, warehouse_output_id, warehouse_input_id, type_movement_id, amount) VALUES
    (1, 1, NULL, 2, 10.0);

-- Ejemplo de entrada de camisetas en Bodega Sur
INSERT INTO history_movements (inventory_id, warehouse_output_id, warehouse_input_id, type_movement_id, amount) VALUES
    (3, NULL, 2, 1, 25.0);

-- Ejemplo de traslado de leche de Bodega Norte a Bodega Sur
INSERT INTO history_movements (inventory_id, warehouse_output_id, warehouse_input_id, type_movement_id, amount) VALUES
    (3, 1, 2, 3, 200)
