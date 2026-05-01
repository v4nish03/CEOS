# Especificación de vistas móvil por rol (CEOS)

## Objetivo
Definir cómo debe funcionar la app móvil por rol para que la experiencia de usuario y los permisos estén alineados con el backend.

---

## 1) Flujo base obligatorio (todos los roles)

1. **Splash/Bootstrap de sesión**
   - Leer token local.
   - Si existe token, validar sesión (`/usuarios/me`).
   - Si falla (401), limpiar sesión y enviar a login.

2. **Login**
   - Formulario con email y password.
   - `POST /login`.
   - Guardar `access_token`, `rol`, `nombre`.

3. **Navegación por rol**
   - Después de login, redirigir al dashboard correspondiente al rol.
   - El menú debe mostrar solo opciones permitidas para ese rol.

4. **Manejo global de errores**
   - 401: cerrar sesión y volver a login.
   - 403: mostrar “No tienes permisos para esta acción”.
   - 400/422: mostrar mensaje de validación del backend.

---

## 2) Mapa de roles y capacidades

### SUPERADMIN
- Acceso total.
- Puede administrar usuarios, materiales, movimientos, solicitudes, reportes y dashboard completo.

### ADMIN
- Acceso casi total.
- Igual que SUPERADMIN en operación diaria.
- Restricción recomendada: no crear usuarios SUPERADMIN desde UI (si backend también lo restringe, mejor).

### INVENTARIO
- Acceso operativo de inventario.
- Puede gestionar materiales, movimientos, solicitudes y ver reportes.
- No accede a administración de usuarios.

### DOCTOR
- Acceso de consumo/solicitud.
- Puede ver materiales y crear solicitudes.
- No accede a usuarios, reportes, alertas ni movimientos administrativos.

---

## 3) Vistas por rol (qué debe ver cada uno)

## 3.1 Vistas comunes

### LoginScreen
- Inputs: email, password.
- Botón iniciar sesión.
- Estado loading/error.

### Perfil/Configuración básica
- Mostrar nombre y rol actual.
- Botón cerrar sesión.

---

## 3.2 SUPERADMIN

### Dashboard Admin
- KPIs globales:
  - total materiales
  - stock bajo
  - movimientos recientes
  - solicitudes pendientes
- Accesos rápidos:
  - Usuarios
  - Inventario
  - Solicitudes
  - Reportes

### Usuarios
- Lista de usuarios.
- Crear usuario.
- (Opcional MVP+) editar estado/rol.

### Inventario
- Lista de materiales.
- Crear/editar material.
- Registrar movimientos (entrada/salida/ajuste).
- Ver alertas de stock bajo/por vencer.

### Solicitudes
- Lista completa de solicitudes.
- Cambiar estado: pendiente/aprobada/rechazada según reglas del backend.

### Reportes
- Resumen de inventario.
- Materiales más usados.
- Movimientos por rango (si endpoint existe en backend).

---

## 3.3 ADMIN

> Mismas pantallas que SUPERADMIN para MVP, con estas reglas visuales:

- En creación de usuario, ocultar opción SUPERADMIN (recomendado).
- Mostrar mensaje de alcance de permisos si intenta acción no permitida.

---

## 3.4 INVENTARIO

### Dashboard Inventario
- KPIs de operación:
  - stock bajo
  - próximos a vencer
  - solicitudes pendientes
- Accesos rápidos:
  - Materiales
  - Movimientos
  - Solicitudes
  - Reportes

### Materiales
- Listar materiales.
- Crear/editar material.

### Movimientos
- Crear entrada/salida.
- Historial de movimientos.

### Solicitudes
- Ver solicitudes.
- Aprobar/rechazar según reglas.

### Reportes
- Resumen inventario.
- Materiales más usados.

### Restricción
- No mostrar pantalla de usuarios en menú.

---

## 3.5 DOCTOR

### Dashboard Doctor
- Vista simplificada:
  - materiales disponibles
  - solicitudes recientes del doctor (si aplica)
- Mensaje informativo de permisos.

### Materiales
- Solo lectura de catálogo de materiales.

### Solicitudes
- Crear solicitud:
  - seleccionar material
  - cantidad
  - motivo
- Ver estado de solicitudes propias (si backend lo soporta o filtro en cliente).

### Restricciones
- No mostrar en menú:
  - Usuarios
  - Reportes
  - Alertas
  - Movimientos admin

---

## 4) Menú/navegación recomendada por rol

### SUPERADMIN / ADMIN
- Dashboard
- Usuarios
- Inventario
- Solicitudes
- Reportes
- Perfil/Salir

### INVENTARIO
- Dashboard
- Inventario
- Movimientos
- Solicitudes
- Reportes
- Perfil/Salir

### DOCTOR
- Dashboard
- Materiales
- Solicitudes
- Perfil/Salir

---

## 5) Reglas de UX y seguridad para todas las vistas

1. **Doble protección**
   - Ocultar UI no permitida.
   - Proteger rutas con guard por rol.

2. **Feedback claro**
   - Loading en cada request.
   - Empty state cuando no hay datos.
   - Error state con botón reintentar.

3. **Consistencia de sesión**
   - Inyectar token en todas las requests autenticadas.
   - Refresh/validación de sesión al abrir app.

4. **Estados de negocio**
   - En solicitudes, mostrar chips por estado: pendiente/aprobada/rechazada.
   - En inventario, destacar stock bajo con color/alerta.

---

## 6) Checklist funcional mínimo para validar por rol

## SUPERADMIN
- Login OK.
- Ve menú completo.
- Crea usuario.
- Crea material y movimiento.
- Ve reportes.

## ADMIN
- Login OK.
- Ve menú admin operativo.
- No puede realizar acciones reservadas a SUPERADMIN (si aplica).

## INVENTARIO
- Login OK.
- No ve usuarios.
- Sí puede materiales/movimientos/solicitudes/reportes.

## DOCTOR
- Login OK.
- Solo ve materiales + solicitudes.
- No ve reportes/usuarios/movimientos.

---

## 7) Roadmap de implementación sugerido (prioridad MVP)

1. Auth + guards por rol.
2. Menú dinámico por rol.
3. Dashboard por rol (3 variantes: admin, inventario, doctor).
4. Inventario (listado + movimientos).
5. Solicitudes (doctor crea, inventario/admin gestionan).
6. Reportes (inventario/admin/superadmin).
7. Usuarios (admin/superadmin).

---

## 8) Criterio de aceptación del MVP móvil

Se considera listo para demo cuando:
- Cada rol entra y ve solo sus vistas permitidas.
- Las acciones bloqueadas muestran mensaje claro.
- Los endpoints críticos responden correctamente desde app.
- Se puede demostrar flujo completo:
  - DOCTOR crea solicitud
  - INVENTARIO/ADMIN la procesa
  - impacto visible en inventario/reportes

