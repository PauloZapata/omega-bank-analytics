/* CREACIÓN DE LA BASE DE DATOS Y TABLAS RAW (BRONZE LAYER)
   Objetivo: Conectar archivos CSV en S3 con Athena sin transformaciones.
*/

CREATE DATABASE IF NOT EXISTS omega_bank_analytics;

-- 1. Tabla Clientes
CREATE EXTERNAL TABLE IF NOT EXISTS omega_bank_analytics.raw_clientes (
  client_id string,
  nombre string,
  apellido string,
  email string,
  fecha_registro string,
  telefono string,
  profesion string,
  genero string,
  fecha_nacimiento string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://omega-bank-analytics-paulo-26dic/raw-data/clientes/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 2. Tabla Cuentas
CREATE EXTERNAL TABLE IF NOT EXISTS omega_bank_analytics.raw_cuentas (
  account_id string,
  client_id string,
  tipo_cuenta string,
  moneda string,
  fecha_apertura string,
  sucursal_asociada_id string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://omega-bank-analytics-paulo-26dic/raw-data/cuentas/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 3. Tabla Transacciones (Histórico Voluminoso)
CREATE EXTERNAL TABLE IF NOT EXISTS omega_bank_analytics.raw_transacciones (
  transaction_id string,
  account_id string,
  merchant_id string,
  monto string,
  fecha_hora string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://omega-bank-analytics-paulo-26dic/raw-data/transacciones/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 4. Tabla Sucursales
CREATE EXTERNAL TABLE IF NOT EXISTS omega_bank_analytics.raw_sucursales (
  branch_id string,
  nombre_sucursal string,
  ciudad string,
  direccion string,
  telefono string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://omega-bank-analytics-paulo-26dic/raw-data/sucursales/'
TBLPROPERTIES ('skip.header.line.count'='1');

-- 5. Tabla Comercios
CREATE EXTERNAL TABLE IF NOT EXISTS omega_bank_analytics.raw_comercios (
  merchant_id string,
  merchant_name string,
  categoria string,
  pais string
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '\"',
  'escapeChar' = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://omega-bank-analytics-paulo-26dic/raw-data/comercios/'
TBLPROPERTIES ('skip.header.line.count'='1');