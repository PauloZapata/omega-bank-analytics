/* TRANSFORMACIÓN A CAPA GOLD
   Objetivo: Optimizar rendimiento convirtiendo a Parquet y particionando por Año/Mes.
   Técnica: CTAS (Create Table As Select) con funciones de ventana.
*/

CREATE TABLE omega_bank_analytics.gold_transacciones_partitioned
WITH (
  format = 'PARQUET',
  external_location = 's3://omega-bank-analytics-paulo-26dic/gold-data/fact_transacciones_optimized/',
  partitioned_by = ARRAY['year', 'month']
) AS
SELECT 
    t.transaction_id,
    t.account_id,
    t.merchant_id,
    
    -- Conversión de tipos de datos (Casting)
    CAST(t.monto AS DOUBLE) AS monto,
    CAST(from_iso8601_timestamp(t.fecha_hora) AS TIMESTAMP) AS fecha_hora,
    
    -- Lógica de Negocio: Clasificación de Movimiento
    CASE 
        WHEN CAST(t.monto AS DOUBLE) > 0 THEN 'INGRESO'
        ELSE 'EGRESO'
    END AS tipo_movimiento,
    
    -- Window Functions: Análisis de comportamiento histórico
    SUM(CAST(t.monto AS DOUBLE)) OVER (
        PARTITION BY t.account_id 
        ORDER BY from_iso8601_timestamp(t.fecha_hora)
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS saldo_proyectado,
    
    date_diff('day', 
        LAG(CAST(from_iso8601_timestamp(t.fecha_hora) AS TIMESTAMP)) OVER (
            PARTITION BY t.account_id 
            ORDER BY from_iso8601_timestamp(t.fecha_hora)
        ),
        CAST(from_iso8601_timestamp(t.fecha_hora) AS TIMESTAMP)
    ) AS dias_desde_ultima_tx,
    
    -- Columnas para particionamiento físico
    CAST(YEAR(from_iso8601_timestamp(t.fecha_hora)) AS INTEGER) AS year,
    CAST(MONTH(from_iso8601_timestamp(t.fecha_hora)) AS INTEGER) AS month

FROM omega_bank_analytics.raw_transacciones t;