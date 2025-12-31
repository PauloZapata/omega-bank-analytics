/* VISTA ANALÍTICA (LAYER DE CONSUMO)
   Objetivo: Unificar la tabla de hechos (Gold) con las dimensiones (Raw) para el Dashboard.
*/

CREATE OR REPLACE VIEW omega_bank_analytics.v_analytics_transacciones_full AS
SELECT 
    f.transaction_id,
    f.account_id,
    f.monto,
    f.fecha_hora,
    f.tipo_movimiento,
    f.saldo_proyectado,
    f.dias_desde_ultima_tx,
    f.year,
    f.month,
    
    -- Datos del Cliente (Dimensión)
    c.nombre AS cliente_nombre,
    c.apellido AS cliente_apellido,
    c.profesion AS cliente_profesion,
    
    -- Datos de Cuenta (Dimensión)
    cu.tipo_cuenta,
    cu.moneda,
    
    -- Datos de Sucursal (Dimensión Geográfica)
    s.nombre_sucursal,
    s.ciudad AS sucursal_ciudad,
    s.branch_id,
    
    -- Datos de Comercio (Dimensión Categoría)
    m.merchant_name,
    m.categoria AS categoria_comercio,
    m.merchant_id

FROM omega_bank_analytics.gold_transacciones_partitioned f
LEFT JOIN omega_bank_analytics.raw_cuentas cu ON f.account_id = cu.account_id
LEFT JOIN omega_bank_analytics.raw_clientes c ON cu.client_id = c.client_id
LEFT JOIN omega_bank_analytics.raw_sucursales s ON cu.sucursal_asociada_id = s.branch_id
LEFT JOIN omega_bank_analytics.raw_comercios m ON f.merchant_id = m.merchant_id;