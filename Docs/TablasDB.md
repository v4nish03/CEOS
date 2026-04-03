# 🗂️ MÓDULO: INVENTARIO
*** 📦 Tabla: Material ***
id
nombre
categoria
stock_actual
stock_minimo
fecha_vencimiento
fecha_alerta_vencimiento
precio_unitario
activo (bool)**

*** Tabla: MovimientoInventario ***
id
material_id
tipo (entrada / salida / ajuste)
cantidad
fecha
usuario_id
motivo (compra, uso, vencido, etc.)

💡 Esto te da:
✔ historial completo
✔ reportes
✔ control real

# MÓDULO: USUARIOS
*** Tabla: Usuario ***
id
nombre
email
contraseña
rol
🎭 Roles:
Administrador: ve todo, NO modifica inventario
Operador: registra entradas y salidas
Solicitante: pide material, no modifica stock directamente

# 📥 MÓDULO: SOLICITUDES

*** Tabla: SolicitudMaterial ***

id
material_id
cantidad
usuario_id
estado (pendiente, aprobado, rechazado)
fecha

# 🚨 MÓDULO: ALERTAS

Se generan automáticamente:

stock bajo
producto por vencer

💡 Esto NO es tabla necesariamente
puede ser lógica + logs

# 📊 MÓDULO: REPORTES
PDF diario
Material más usado
Gastos
Movimientos

👉 Librerías:

Python → reportlab o weasyprint