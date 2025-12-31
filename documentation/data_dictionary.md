🔑 Identificadores y Llaves (Relaciones)
•	transaction_id: El ADN de cada operación. Único por fila. Se usa para contar el Volumen de Transacciones.
•	account_id: La cuenta bancaria. Un cliente puede tener varias. Conecta con el saldo.
•	client_id: El DNI digital del cliente. Conecta con sus datos personales.
•	branch_id / merchant_id: Dónde ocurrió la operación (Sucursal o Comercio).
💰 Métricas Financieras (Hechos)
•	monto: La variable más importante.
o	Positivo: Dinero que entra al banco (Depósitos).
o	Negativo: Dinero que sale (Pagos, Retiros).
•	tipo_movimiento: Clasificación binaria creada en SQL (INGRESO vs EGRESO). Vital para filtros rápidos y colores condicionales.
•	saldo_proyectado (Window Function): Es el "saldo corriente" histórico. Muestra cuánto dinero tenía el cliente en la cuenta justo después de esa transacción. Sirve para ver la salud financiera del cliente en el tiempo.
🌍 Dimensiones de Contexto (Quién, Dónde, Qué)
•	fecha_hora: Cuándo ocurrió. Permite análisis de tendencias (horas pico, estacionalidad anual).
•	cliente_nombre / cliente_apellido: Para identificar a la persona en tablas de detalle.
•	cliente_profesion: Permite segmentar por perfil de riesgo (ej: "¿Gastan más los Arquitectos que los Estudiantes?").
•	tipo_cuenta: Corriente vs. Ahorros. Define el producto bancario.
•	moneda: USD, EUR, PEN. Importante si tuvieras que hacer conversiones (asumimos consolidado).
•	nombre_sucursal / sucursal_ciudad: Geografía. Permite mapas y análisis regional.
•	categoria_comercio: En qué gasta el dinero el cliente (Salud, Tecnología, Retail). Fundamental para el gráfico de Pareto.
🧠 Métricas de Inteligencia (Analytical SQL)
•	dias_desde_ultima_tx: Mide la Recurrencia.
o	Valor bajo (0-2): Cliente muy activo.
o	Valor alto (30+): Cliente en riesgo de abandono (Churn).
o	Uso: Detectar patrones de comportamiento o posibles fraudes (frecuencia inhumana).
•	year / month: Columnas derivadas para optimizar el filtrado temporal en el dashboard sin procesar fechas complejas.

