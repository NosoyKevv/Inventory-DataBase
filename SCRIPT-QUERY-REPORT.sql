-- Parámetros: reemplaza estos con los valores reales
-- por ejemplo: '2025-07-01' y '2025-07-31'
WITH params AS (
    SELECT
        DATE '2025-07-01' AS start_date,
        DATE '2025-07-31' AS end_date
),

-- Movimientos de entrada y salida por producto y bodega
     movements_summary AS (
         SELECT
             inv.product_id,
             inv.warehouse_id,
             SUM(CASE WHEN hm.type_movement_id = 2 THEN hm.amount ELSE 0 END) AS total_entradas,
             SUM(CASE WHEN hm.type_movement_id = 3 THEN hm.amount ELSE 0 END) AS total_salidas
         FROM history_movements hm
                  INNER JOIN inventory inv ON inv.inventory_id = hm.inventory_id
                  CROSS JOIN params p
         WHERE hm.movement_date BETWEEN p.start_date AND p.end_date
         GROUP BY inv.product_id, inv.warehouse_id
     )

-- Resultado final del reporte
SELECT
    w.warehouse_name AS bodega,
    p.product_name AS producto,
    i.inventory_stock AS stock_actual,
    COALESCE(m.total_entradas, 0) AS total_entradas_periodo,
    COALESCE(m.total_salidas, 0) AS total_salidas_periodo
FROM inventory i
         INNER JOIN products p ON p.product_id = i.product_id
         INNER JOIN warehouses w ON w.warehouse_id = i.warehouse_id
         LEFT JOIN movements_summary m
                   ON m.product_id = i.product_id AND m.warehouse_id = i.warehouse_id
ORDER BY w.warehouse_name, p.product_name;
