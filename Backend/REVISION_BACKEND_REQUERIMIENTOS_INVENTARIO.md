# Revisión funcional del backend vs requerimientos de Inventario

Fecha de revisión: 2026-05-22

## Resumen ejecutivo
- **Cumplido**: Alta/listado/actualización de materiales, movimientos entrada/salida, alertas de stock y vencimiento, solicitudes de material, dashboard de materiales más salidos, roles base y resumen global de inventario.
- **Parcial**: Segmentación de permisos por rol no coincide al 100% con tu matriz objetivo.
- **No implementado en backend actual**: reportes diarios en PDF programados por hora, registro de dinero gastado, módulo de respaldo automático de BD.

## Matriz de cumplimiento

### 1) Control de inventario y vencimientos
**Requerimiento**: Control de material con faltantes y por vencer.

**Estado**: ✅ Cumplido.

**Evidencia técnica**:
- Material maneja `stock_actual`, `stock_minimo`, `fecha_vencimiento`, `fecha_alerta_vencimiento`.
- Endpoint de alertas `/inventario/alertas` genera alertas por stock bajo y por vencer.

### 2) Ingreso manual con datos del material
**Requerimiento**: ingreso manual de fecha ingreso, nombre, caducidad, salida, quién saca, categorías.

**Estado**: 🟡 Parcial.

**Evidencia técnica**:
- Se captura nombre/categoría/stock/caducidad/fecha alerta en `Material`.
- Se captura salida/entrada, cantidad, fecha (automática) y usuario que realizó movimiento en `MovimientoInventario`.

**Brecha**:
- No existe campo explícito `fecha_ingreso` por lote/material.
- La fecha de salida se registra por movimiento (correcto para trazabilidad), pero no existe una “fecha de salida” fija en material (lo cual suele ser correcto por diseño).

### 3) Control por usuario y control general acumulado
**Requerimiento**: material por usuario y general acumulado.

**Estado**: ✅ Cumplido.

**Evidencia técnica**:
- Cada movimiento guarda `usuario_id` (trazabilidad por usuario).
- Existe resumen global con total de materiales/stock total/stock bajo.

### 4) Reportes diarios y envío PDF programado
**Requerimiento**: generar reportes diarios, PDF y envío a hora específica.

**Estado**: ❌ No implementado.

**Brecha**:
- No hay servicio de generación PDF.
- No hay scheduler (cron/celery/APScheduler) para disparo horario.
- No hay integración de envío (email/whatsapp/etc.).

### 5) Stock mínimo configurable y alerta de vencimiento
**Requerimiento**: definir stock mínimo (default 5) y fecha de alerta de vencimiento.

**Estado**: 🟡 Parcial.

**Evidencia técnica**:
- `stock_minimo` y `fecha_alerta_vencimiento` sí existen.

**Brecha**:
- El default actual de `stock_minimo` es `0`, no `5`.

### 6) Dashboard de materiales más salidos
**Requerimiento**: ranking materiales más salidos.

**Estado**: ✅ Cumplido.

**Evidencia técnica**:
- Endpoint `/reportes/materiales-mas-usados` agrupa salidas y ordena por mayor uso.

### 7) Solicitud de stock poco frecuente
**Requerimiento**: usuarios solicitan stock que no se usa frecuentemente / no disponible.

**Estado**: ✅ Cumplido (base).

**Evidencia técnica**:
- Existe módulo de solicitudes (`/solicitudes`) con creación y flujo pendiente/aprobada/rechazada.

**Observación**:
- Falta validación específica de “solo cuando no hay stock” si ese es un requisito estricto (hoy permite solicitar cualquier material).

### 8) Ingreso de dinero gastado
**Requerimiento**: registrar gasto/dinero.

**Estado**: ❌ No implementado.

**Brecha**:
- No hay entidad/campos/endpoints de costos, compras o egresos.

### 9) Roles de usuario con permisos específicos
**Requerimiento**:
1. Administrador no modifica inventario, solo alertas.
2. Rol que registra entrada/salida (modifica) y recibe alertas.
3. Rol salida de material y solicitudes cuando no hay stock.

**Estado**: 🟡 Parcial.

**Evidencia técnica**:
- Existen roles `SUPERADMIN`, `ADMIN`, `INVENTARIO`, `DOCTOR`.
- Permisos por endpoint usando `require_roles`.

**Brecha contra tu matriz**:
- `ADMIN` sí puede modificar inventario/materiales hoy (contradice “no modifica inventario”).
- `DOCTOR` solo puede solicitar y consultar materiales; no puede registrar salida directa.

### 10) Respaldo de base de datos
**Requerimiento**: backup de BD.

**Estado**: ❌ No implementado a nivel backend app.

**Observación**:
- Hay recomendaciones en README para respaldo operativo, pero no módulo automático/versionado dentro del backend.

---

## Recomendación de prioridad (MVP)
1. Ajustar matriz de permisos por rol exactamente a tu operación.
2. Cambiar default `stock_minimo` a 5.
3. Agregar módulo de gastos/compras.
4. Implementar reportes PDF diarios con scheduler y envío.
5. Implementar estrategia de backups automatizados (diario + retención).

## Conclusión
El backend **sí cubre la base operativa de inventario** (materiales, movimientos, alertas, solicitudes y reportes de uso), pero para cumplir al 100% tu lista faltan piezas clave de **automatización de reportes, costos, backups y ajuste fino de roles**.
