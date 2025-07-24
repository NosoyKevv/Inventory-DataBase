-- CREAR PRODUCTO O ACTUALIZAR BASADO EN EL NOMBRE
--      DESCRIPCIÓN:
--     Permite crear o actualizar un producto. Si el producto con el mismo nombre
--     y tipo ya existe, se actualiza. De lo contrario, se crea uno nuevo
SELECT*
FROM create_or_update_product('Camiseta', 'camisa de gala', 'ROPA', 1200);

-- CREAR TIPO DE PRODUCTO O ACTUALIZAR
--      DESCRIPCIÓN:
--     Permite crear o actualizar un tipo de producto.
--     - Si se pasa solo el nombre, se intenta registrar uno nuevo (si no existe).
--     - Si se pasa el nombre y el ID, se actualiza el registro con dicho ID.
SELECT*
FROM create_or_update_type_product('FRUTAS');-- CREAR TIPO DE PRODUCTO
SELECT*
FROM create_or_update_type_product('VERDURAS', 4);

-- ACTUALIZAR BODEGA
--      DESCRIPCIÓN:
--     Permite crear o actualizar una bodega.
--     - Si se pasa solo el nombre, se intenta registrar uno nuevo (si no existe).
--     - Si se pasa el nombre y el ID, se actualiza el registro con dicho ID.
SELECT*
FROM create_or_update_warehouses('BODEGA OCAÑERITA', 'Barrio Juan 23', 'GRANDE'); -- CREAR BODEGA
SELECT*
FROM create_or_update_warehouses('Bodega PLAZARELA', 'PLAZARELA', 'PEQUEÑO', 4);

--  REGISTRAR O ACTUALIZAR PRODUCTO DE UN INVENTARIO
--      DESCRIPCIÓN:
--     Permite crear o actualizar una producto de una bodega en especifico.
--     Se debe pasar el nombre del producto previamente registrado y el nombre de la bodega donde va estar ubicado ese producto junto al stock
SELECT register_product_in_inventory('CAMISETA', 'BODEGA PLAZARELA', 25);
--REGISTRAR STOCK DE UN PRODUCTO EN INVENTARIO DE UNA BODEGA


-- MOVER PRODUCTOS DE BODEGA A BODEGA
-- DESCRIPCIÓN:
-- Permite mover productos de una bodega de salida a una bodega de entrada indicando el nombre del producto y el stock a mover
SELECT*
FROM move_product_between_warehouses('Bodega Sur', 'Bodega Norte', 'Camiseta', 100);