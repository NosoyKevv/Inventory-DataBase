CREATE OR REPLACE FUNCTION create_or_update_product(
    in_product_name VARCHAR,
    in_product_description VARCHAR,
    in_type_product_name VARCHAR,
    in_product_price DOUBLE PRECISION
) RETURNS TEXT AS
$$

DECLARE
    -- Variables Locales
    local_type_id           INTEGER;
    local_product_id        INTEGER;
    local_return_product_id INTEGER;
BEGIN
    -- SE ELIMINAN ESPACIOS AL INICIO Y AL FINAL, Y SE CONVIERTE A MAYÚSCULAS
    in_product_name := UPPER(TRIM(in_product_name));
    in_type_product_name := UPPER(TRIM(in_type_product_name));

    -- VALIDAR VACÍO O NULL
    IF in_product_name IS NULL OR in_product_name = '' THEN
        RAISE EXCEPTION 'EL NOMBRE DEL PRODUCTO NO PUEDE VENIR VACÍO.'
            USING ERRCODE = '22004';
    END IF;

    -- VALIDAR LONGITUD MÁXIMA
    IF CHARACTER_LENGTH(in_product_name) > 40 THEN
        RAISE EXCEPTION 'EL NOMBRE DEL PRODUCTO NO PUEDE SUPERAR LOS 40 CARACTERES: "%".', in_product_name
            USING ERRCODE = '22004';
    END IF;

    -- VALIDAR VACÍO O NULL
    IF in_product_description IS NULL OR in_product_description = '' THEN
        RAISE EXCEPTION 'LA DESCRIPCION DEL PRODUCTO NO PUEDE VENIR VACÍO.'
            USING ERRCODE = '22004';
    END IF;

    -- VALIDAR LONGITUD MÁXIMA
    IF CHARACTER_LENGTH(in_product_description) > 100 THEN
        RAISE EXCEPTION 'LA DESCRIPCION DEL PRODUCTO NO PUEDE SUPERAR LOS 100 CARACTERES: "%".', in_product_description
            USING ERRCODE = '22004';
    END IF;

    -- VALIDAR QUE EL PRECIO DEL PRODUCTO NO SEA NULO NI NEGATIVO
    IF in_product_price IS NULL OR in_product_price < 0 THEN
        RAISE EXCEPTION 'EL PRECIO DEL PRODUCTO NO PUEDE VENIR VACIO NI SER MENOR QUE CERO'
            USING ERRCODE = '22004';
    END IF;

    SELECT type_id
    INTO local_type_id
    FROM type_product
    WHERE type_name = in_type_product_name;

    IF (local_type_id IS NULL) THEN
        RAISE EXCEPTION 'NO SE ENCONTRO EL TIPO DE PRODUCTO CON EL NOMBRE "%"',in_type_product_name;
    END IF;

    SELECT product_id
    INTO local_product_id
    FROM products
    WHERE product_name = in_product_name
      AND type_id = local_type_id;

    IF (local_product_id IS NULL) THEN

        INSERT INTO products (product_name, product_description, product_price, type_id)
        VALUES (in_product_name, in_product_description, in_product_price, local_type_id)
        RETURNING product_id INTO local_return_product_id;

        IF local_return_product_id IS NULL THEN
            RAISE EXCEPTION 'ERROR AL REGISTRAR EL PRODUCTO "%".', in_product_name;
        END IF;
        RETURN FORMAT('PRODUCTO %s REGISTRADO CORRECTAMENTE con ID %s.', in_product_name, local_return_product_id);


    ELSE
        UPDATE products
        SET product_name        = in_product_name,
            product_description = in_product_description,
            product_price       = in_product_price
        WHERE product_id = local_product_id
          AND type_id = local_type_id
        RETURNING product_id INTO local_return_product_id;
        IF local_return_product_id IS NULL THEN
            RAISE EXCEPTION 'ERROR AL ACTUALIZAR EL PRODUCTO "%".', in_product_name;
        END IF;
        RETURN FORMAT('PRODUCTO %s ACTUALIZADO CORRECTAMENTE.', in_product_name);

    END IF;

END;
$$ LANGUAGE plpgsql;
------------------------------------
CREATE OR REPLACE FUNCTION create_or_update_type_product(
    in_type_product_name VARCHAR,
    in_type_product_id INTEGER DEFAULT NULL
) RETURNS TEXT AS
$$

DECLARE
    local_return_type_product_id INTEGER;
BEGIN

    in_type_product_name := UPPER(TRIM(in_type_product_name));

    IF in_type_product_name IS NULL OR in_type_product_name = '' THEN
        RAISE EXCEPTION 'EL NOMBRE DEL TIPO DE PRODUCTO NO PUEDE VENIR VACÍO.'
            USING ERRCODE = '22004';
    ELSIF LENGTH(in_type_product_name) > 40 THEN
        RAISE EXCEPTION 'EL NOMBRE DEL TIPO DE PRODUCTO NO PUEDE SUPERAR LOS 40 CARACTERES: "%".', in_type_product_name
            USING ERRCODE = '22004';
    END IF;

    IF in_type_product_id IS NULL THEN
        PERFORM 1 FROM type_product WHERE type_name = in_type_product_name;
        IF NOT FOUND THEN
            INSERT INTO type_product (type_name)
            VALUES (in_type_product_name)
            RETURNING type_id INTO local_return_type_product_id;

            RETURN FORMAT('TIPO DE PRODUCTO "%s" REGISTRADO CORRECTAMENTE CON ID %s.',
                          in_type_product_name, local_return_type_product_id);
        END IF;

    ELSIF EXISTS (SELECT 1 FROM type_product WHERE type_id = in_type_product_id) THEN
        UPDATE type_product
        SET type_name = in_type_product_name
        WHERE type_id = in_type_product_id
        RETURNING type_id INTO local_return_type_product_id;

        RETURN FORMAT('TIPO DE PRODUCTO "%s" ACTUALIZADO CORRECTAMENTE.', in_type_product_name);
    END IF;

    RETURN FORMAT('NO SE REALIZÓ NINGUNA MODIFICACIÓN. EL TIPO DE PRODUCTO "%s" YA EXISTE.', in_type_product_name);
END;
$$ LANGUAGE plpgsql;
------------------------------------------
CREATE OR REPLACE FUNCTION create_or_update_warehouses(
    in_warehouse_name VARCHAR,
    in_warehouses_address VARCHAR,
    in_warehouses_capacity VARCHAR,
    in_warehouses_id INTEGER DEFAULT NULL
) RETURNS TEXT AS
$$

DECLARE
    local_return_warehouse_id INTEGER;
    local_capacity_id         INTEGER;
BEGIN

    in_warehouse_name := UPPER(TRIM(in_warehouse_name));
    in_warehouses_address := UPPER(TRIM(in_warehouses_address));
    in_warehouses_capacity := UPPER(TRIM(in_warehouses_capacity));


    IF in_warehouse_name IS NULL OR in_warehouse_name = '' THEN
        RAISE EXCEPTION 'EL NOMBRE DE LA BODEGA NO PUEDE VENIR VACÍO.'
            USING ERRCODE = '22004';
    ELSIF LENGTH(in_warehouse_name) > 40 THEN
        RAISE EXCEPTION 'EL NOMBRE DE LA BODEGA  NO PUEDE SUPERAR LOS 40 CARACTERES: "%".', in_warehouse_name
            USING ERRCODE = '22004';
    END IF;

    IF in_warehouses_address IS NULL OR in_warehouses_address = '' THEN
        RAISE EXCEPTION 'LA DIRECCION DE LA BODEGA NO PUEDE VENIR VACÍO.'
            USING ERRCODE = '22004';
    ELSIF LENGTH(in_warehouses_address) > 40 THEN
        RAISE EXCEPTION 'LA DIRECCION DE LA BODEGA  NO PUEDE SUPERAR LOS 40 CARACTERES: "%".', in_warehouses_address
            USING ERRCODE = '22004';
    END IF;

    SELECT capacity_id
    INTO local_capacity_id
    FROM capacity
    WHERE capacity_name = in_warehouses_capacity;

    IF (local_capacity_id IS NULL) THEN
        RAISE EXCEPTION 'LA CAPACIDAD NO ES VALIDA %',in_warehouses_capacity
            USING ERRCODE = '22004';
    END IF;

    IF in_warehouses_id IS NULL THEN
        PERFORM 1 FROM warehouses WHERE warehouse_name = in_warehouse_name;
        IF NOT FOUND THEN
            INSERT INTO warehouses (warehouse_name, warehouse_address, capacity_id)
            VALUES (in_warehouse_name, in_warehouses_address, local_capacity_id)
            RETURNING warehouse_id INTO local_return_warehouse_id;

            RETURN FORMAT('EL ALMACEN "%s" REGISTRADO CORRECTAMENTE CON ID %s.',
                          in_warehouse_name, local_return_warehouse_id);
        END IF;

    ELSIF EXISTS (SELECT 1 FROM warehouses WHERE warehouse_id = in_warehouses_id) THEN
        UPDATE warehouses
        SET warehouse_name    = in_warehouse_name,
            warehouse_address = in_warehouses_address,
            capacity_id       = local_capacity_id
        WHERE warehouse_id = in_warehouses_id
        RETURNING warehouse_id INTO local_return_warehouse_id;

        RETURN FORMAT('EL ALMACEN "%s" SE ACTUALIZADO CORRECTAMENTE.', in_warehouse_name);
    END IF;

    RETURN FORMAT('NO SE REALIZÓ NINGUNA MODIFICACIÓN. DEL ALMACEN "%s" YA EXISTE.', in_warehouse_name);
END;
$$ LANGUAGE plpgsql;
--------------------------------
CREATE OR REPLACE FUNCTION register_product_in_inventory(
    in_product_name VARCHAR,
    in_warehouse_name VARCHAR,
    in_stock INTEGER
)
    RETURNS TABLE
            (
                message           TEXT,
                return_inventory_id INTEGER
            )
AS
$$
DECLARE
    local_product_id   INTEGER;
    local_warehouse_id INTEGER;
    local_inventory_id INTEGER;
BEGIN
    in_product_name := UPPER(TRIM(in_product_name));
    in_warehouse_name := UPPER(TRIM(in_warehouse_name));

    IF in_product_name IS NULL OR in_product_name = '' THEN
        RAISE EXCEPTION 'EL NOMBRE DEL PRODUCTO NO PUEDE VENIR VACÍO.' USING ERRCODE = '22004';
    END IF;

    IF in_warehouse_name IS NULL OR in_warehouse_name = '' THEN
        RAISE EXCEPTION 'EL NOMBRE DE LA BODEGA NO PUEDE VENIR VACÍO.' USING ERRCODE = '22004';
    END IF;

    IF in_stock IS NULL OR in_stock < 0 THEN
        RAISE EXCEPTION 'EL STOCK DEBE SER UN NÚMERO NO NEGATIVO.' USING ERRCODE = '22004';
    END IF;

    SELECT product_id
    INTO local_product_id
    FROM products
    WHERE product_name = in_product_name;

    IF local_product_id IS NULL THEN
        RAISE EXCEPTION 'NO EXISTE UN PRODUCTO CON EL NOMBRE "%".', in_product_name;
    END IF;

    SELECT warehouse_id
    INTO local_warehouse_id
    FROM warehouses
    WHERE warehouse_name = in_warehouse_name;

    IF local_warehouse_id IS NULL THEN
        RAISE EXCEPTION 'NO EXISTE UNA BODEGA CON EL NOMBRE "%".', in_warehouse_name;
    END IF;

    SELECT inventory_id
    INTO local_inventory_id
    FROM inventory
    WHERE product_id = local_product_id
      AND warehouse_id = local_warehouse_id;

    IF local_inventory_id IS NOT NULL THEN

        UPDATE inventory
        SET inventory_stock = in_stock
        WHERE inventory_id = local_inventory_id;

        message := FORMAT('INVENTARIO ACTUALIZADO: PRODUCTO "%s" EN BODEGA "%s" CON STOCK %s.',
                          in_product_name, in_warehouse_name, in_stock);
    ELSE

        INSERT INTO inventory (product_id, warehouse_id, inventory_stock)
        VALUES (local_product_id, local_warehouse_id, in_stock)
        RETURNING inventory_id INTO local_inventory_id;

        message := FORMAT(
                'INVENTARIO REGISTRADO: PRODUCTO "%s" EN BODEGA "%s" CON STOCK %s, CON ID "%s"',
                in_product_name,
                in_warehouse_name,
                in_stock,
                local_inventory_id
                   );
    END IF;

    RETURN QUERY SELECT message, local_inventory_id;

END;
$$ LANGUAGE plpgsql;
----------------------------------------
CREATE OR REPLACE FUNCTION move_product_between_warehouses(
    in_origin_warehouse_name VARCHAR,
    in_target_warehouse_name VARCHAR,
    in_product_name VARCHAR,
    in_quantity INTEGER
) RETURNS TEXT AS
$$
DECLARE
    local_origin_warehouse_id INTEGER;
    local_target_warehouse_id INTEGER;
    local_product_id          INTEGER;
    local_origin_inventory_id INTEGER;
    local_target_inventory_id INTEGER;
    local_origin_stock        INTEGER;
    local_max_capacity        INTEGER;
    local_current_stock       INTEGER;
BEGIN
    in_origin_warehouse_name := UPPER(TRIM(in_origin_warehouse_name));
    in_target_warehouse_name := UPPER(TRIM(in_target_warehouse_name));
    in_product_name := UPPER(TRIM(in_product_name));

    IF in_origin_warehouse_name IS NULL OR in_origin_warehouse_name = '' THEN
        RAISE EXCEPTION 'NOMBRE DE BODEGA ORIGEN NO VÁLIDO.';
    END IF;

    IF in_target_warehouse_name IS NULL OR in_target_warehouse_name = '' THEN
        RAISE EXCEPTION 'NOMBRE DE BODEGA DESTINO NO VÁLIDO.';
    END IF;

    IF in_product_name IS NULL OR in_product_name = '' THEN
        RAISE EXCEPTION 'NOMBRE DEL PRODUCTO NO VÁLIDO.';
    END IF;

    IF in_quantity IS NULL OR in_quantity <= 0 THEN
        RAISE EXCEPTION 'LA CANTIDAD A MOVER DEBE SER MAYOR A CERO.';
    END IF;

    SELECT warehouse_id INTO local_origin_warehouse_id FROM warehouses WHERE warehouse_name = in_origin_warehouse_name;
    IF local_origin_warehouse_id IS NULL THEN
        RAISE EXCEPTION 'NO EXISTE LA BODEGA ORIGEN "%".', in_origin_warehouse_name;
    END IF;

    SELECT warehouse_id INTO local_target_warehouse_id FROM warehouses WHERE warehouse_name = in_target_warehouse_name;
    IF local_target_warehouse_id IS NULL THEN
        RAISE EXCEPTION 'NO EXISTE LA BODEGA DESTINO "%".', in_target_warehouse_name;
    END IF;

    SELECT product_id INTO local_product_id FROM products WHERE product_name = in_product_name;
    IF local_product_id IS NULL THEN
        RAISE EXCEPTION 'NO EXISTE EL PRODUCTO "%".', in_product_name;
    END IF;

    -- Stock origen
    SELECT inventory_id, inventory_stock
    INTO local_origin_inventory_id, local_origin_stock
    FROM inventory
    WHERE warehouse_id = local_origin_warehouse_id
      AND product_id = local_product_id;

    IF local_origin_inventory_id IS NULL THEN
        RAISE EXCEPTION 'EL PRODUCTO NO EXISTE EN LA BODEGA ORIGEN.';
    END IF;

    IF local_origin_stock < in_quantity THEN
        RAISE EXCEPTION 'STOCK INSUFICIENTE EN LA BODEGA ORIGEN. DISPONIBLE: %, REQUERIDO: %', local_origin_stock, in_quantity;
    END IF;

    -- Inventario destino
    SELECT inventory_id
    INTO local_target_inventory_id
    FROM inventory
    WHERE warehouse_id = local_target_warehouse_id
      AND product_id = local_product_id;

    SELECT c.capacity,
           COALESCE(SUM(i.inventory_stock), 0) AS current_stock
    INTO
        local_max_capacity,
        local_current_stock
    FROM warehouses AS w
             INNER JOIN capacity AS c ON w.capacity_id = c.capacity_id
             LEFT JOIN inventory i ON i.warehouse_id = w.warehouse_id
    WHERE w.warehouse_id = local_target_warehouse_id
    GROUP BY c.capacity;

    IF local_current_stock + in_quantity > local_max_capacity THEN
        RAISE EXCEPTION 'LA BODEGA DESTINO NO TIENE CAPACIDAD SUFICIENTE. ACTUAL: %, A MOVER: %, MÁXIMA: %',
            local_current_stock, in_quantity, local_max_capacity;
    END IF;


    IF local_target_inventory_id IS NULL THEN
        INSERT INTO inventory (product_id, warehouse_id, inventory_stock)
        VALUES (local_product_id, local_target_warehouse_id, 0)
        RETURNING inventory_id INTO local_target_inventory_id;
    END IF;

    -- Actualizar stock
    UPDATE inventory
    SET inventory_stock = inventory_stock - in_quantity
    WHERE inventory_id = local_origin_inventory_id;

    UPDATE inventory
    SET inventory_stock = inventory_stock + in_quantity
    WHERE inventory_id = local_target_inventory_id;

    -- Registrar movimiento
    IF local_origin_stock = in_quantity THEN
        -- TRASLADO
        INSERT INTO history_movements (inventory_id,
                                       warehouse_output_id,
                                       warehouse_input_id,
                                       type_movement_id,
                                       amount)
        VALUES (local_origin_inventory_id,
                local_origin_warehouse_id,
                local_target_warehouse_id,
                3, -- TRASLADO
                in_quantity);
    ELSE
        -- SALIDA
        INSERT INTO history_movements (inventory_id,
                                       warehouse_output_id,
                                       warehouse_input_id,
                                       type_movement_id,
                                       amount)
        VALUES (local_origin_inventory_id,
                local_origin_warehouse_id,
                NULL,
                2, -- SALIDA
                in_quantity);

        -- ENTRADA
        INSERT INTO history_movements (inventory_id,
                                       warehouse_output_id,
                                       warehouse_input_id,
                                       type_movement_id,
                                       amount)
        VALUES (local_target_inventory_id,
                NULL,
                local_target_warehouse_id,
                1, -- ENTRADA
                in_quantity);
    END IF;

    RETURN FORMAT('SE MOVIERON %s UNIDADES DEL PRODUCTO "%s" DE "%s" A "%s".',
                  in_quantity, in_product_name, in_origin_warehouse_name, in_target_warehouse_name);
END;
$$ LANGUAGE plpgsql;
