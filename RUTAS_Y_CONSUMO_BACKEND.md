# Guía de Rutas Móviles y Consumo del Backend (CEOS)

Este documento detalla la estructura de navegación de la aplicación móvil de CEOS, las vistas asignadas a cada rol de usuario y los puntos específicos del código donde se consumen los endpoints del backend.

---

## 1. Sistema de Enrutamiento y Navegación

El enrutamiento principal de la aplicación se gestiona en:
*   **Enrutador Global:** [app_router.dart](file:///home/v4/Ceos/Movil/lib/core/router/app_router.dart) (usa `go_router` para definir las pantallas generales como login, wrapper de inicio y vistas secundarias).
*   **Gestor de Pestañas Dinámicas:** [main_wrapper.dart](file:///home/v4/Ceos/Movil/lib/features/home/presentation/screens/main_wrapper.dart) (maneja la navegación inferior dinámica de acuerdo al rol del usuario en la sesión activa).

---

## 2. Rutas y Vistas Móviles por Rol

A continuación, se detalla qué pantallas están disponibles para cada rol y en qué archivos están definidas:

### 👤 SUPERADMIN
El rol de desarrollador/superadministrador tiene acceso absoluto a todas las secciones.
*   **`/` (Inicio):** [dashboard_view.dart](file:///home/v4/Ceos/Movil/lib/features/auth/presentation/widgets/dashboard_view.dart) -> Carga `AdminDashboard` en [dashboard_widgets.dart](file:///home/v4/Ceos/Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart).
*   **`/usuarios` (Gestión de Usuarios):** [users_screen.dart](file:///home/v4/Ceos/Movil/lib/features/users/presentation/screens/users_screen.dart) -> Listado y creación de cuentas.
*   **`/inventario` (Inventario - R/W):** [inventory_screen.dart](file:///home/v4/Ceos/Movil/lib/features/inventory/presentation/screens/inventory_screen.dart) -> Edición, eliminación e inserción de nuevos insumos.
*   **`/solicitudes` (Procesamiento):** [requests_screen.dart](file:///home/v4/Ceos/Movil/lib/features/request/presentation/screens/requests_screen.dart) -> Aprobación o rechazo de solicitudes de doctores.
*   **`/reportes` (Analíticas y Descarga):** [reports_screen.dart](file:///home/v4/Ceos/Movil/lib/features/reports/presentation/screens/reports_screen.dart) -> Visualización de KPIs y exportación a PDF.
*   **`/gastos` (Presupuesto - R/W):** [gastos_screen.dart](file:///home/v4/Ceos/Movil/lib/features/gastos/presentation/screens/gastos_screen.dart) -> Registro de compras hospitalarias y totalizador.
*   **`/más` (Herramientas):** [more_screen.dart](file:///home/v4/Ceos/Movil/lib/features/home/presentation/screens/more_screen.dart) -> Generación de respaldos de base de datos.

### 👤 ADMIN
Rol directivo con acceso de supervisión y gestión de personal.
*   **`/` (Inicio):** Carga `AdminDashboard` con banner de rol.
*   **`/usuarios` (Gestión de Usuarios):** Acceso total para crear nuevos usuarios de rango menor.
*   **`/inventario` (Supervisión - Lectura):** Carga [inventory_screen.dart](file:///home/v4/Ceos/Movil/lib/features/inventory/presentation/screens/inventory_screen.dart) en modo **Solo Lectura** (formularios bloqueados, sin botones de acción).
*   **`/solicitudes` (Procesamiento):** Acceso total para evaluar y resolver solicitudes pendientes.
*   **`/reportes` (Analíticas y Descarga):** Consulta de métricas y descarga de reportes diarios en PDF.
*   **`/gastos` (Oversight - Lectura):** Visualiza el historial de gastos y presupuesto consumido, pero tiene deshabilitada la creación de nuevos gastos.
*   **`/más` (Herramientas):** Generación de respaldos de base de datos.

### 📦 INVENTARIO
Rol operativo enfocado en el stock y flujo de materiales.
*   **`/` (Inicio):** Carga `InventoryDashboard` (KPIs de stock y alertas críticas).
*   **`/inventario` (Gestión - R/W):** Edición, alertas y stock en tiempo real.
*   **`/movimientos` (Historial y Registro - R/W):** [movements_screen.dart](file:///home/v4/Ceos/Movil/lib/features/inventory/presentation/screens/movements_screen.dart) -> Registro de entradas, salidas y ajustes manuales.
*   **`/solicitudes` (Procesamiento):** Aprobación y despacho de materiales pedidos por los doctores.
*   **`/reportes` (Monitoreo):** Consulta de estadísticas de consumo y alertas.
*   **`/gastos` (Registro - R/W):** Registro de gastos de compra de insumos.
*   **`/más` (Herramientas):** Cerrar sesión e información general.

### 🩺 DOCTOR
Rol consumidor enfocado en requerimientos médicos.
*   **`/` (Inicio):** Carga `DoctorDashboard` (KPIs de disponibilidad de materiales y listado de solicitudes recientes).
*   **`/materiales` (Consulta - Lectura):** Visualización del catálogo de insumos médicos sin capacidades de edición o borrado.
*   **`/solicitudes` (Mis Solicitudes - R/W):** Creación de solicitudes de materiales (validado que no exceda el stock disponible) y listado de solicitudes propias.
*   **`/más` (Ajustes):** Cierre de sesión y estado de conexión.

---

## 3. Consumo de Backend y Servicios API

La comunicación HTTP se centraliza usando `Dio` configurado en [dio_client.dart](file:///home/v4/Ceos/Movil/lib/core/network/dio_client.dart). A continuación se asocian las pantallas con sus respectivos consumos:

| Módulo / Pantalla | Archivo de Lógica / Provider | Endpoint Backend | Método HTTP | Razón / Acción |
| :--- | :--- | :--- | :---: | :--- |
| **Autenticación** | `auth_repository_impl.dart` | `/api/v1/login` | `POST` | Iniciar sesión y obtener token JWT. |
| **Validar Sesión** | `auth_repository_impl.dart` | `/api/v1/usuarios/me` | `GET` | Recuperar datos de usuario al abrir la app. |
| **Gestión Usuarios** | `users_provider.dart` | `/api/v1/usuarios` | `GET` / `POST` | Listar y registrar nuevos usuarios. |
| **Inventario Físico** | `inventory_provider.dart` | `/api/v1/inventario` | `GET` / `POST` | Listar materiales, crear y actualizar alertas. |
| **Alertas Stock** | `inventory_provider.dart` | `/api/v1/inventario/alertas` | `GET` | Mostrar alertas de stock bajo y caducidad. |
| **Movimientos** | `movements_screen.dart` | `/api/v1/inventario/movimientos` | `GET` / `POST` | Listar y crear entradas, salidas o ajustes de stock. |
| **Solicitudes** | `request_provider.dart` | `/api/v1/solicitudes` | `GET` / `POST` | Listar solicitudes, y enviar nuevos requerimientos médicos. |
| **Procesar Solicitud** | `request_provider.dart` | `/api/v1/solicitudes/{id}/estado` | `PUT` | Aprobar o rechazar solicitudes (Admin/Inventario). |
| **Gastos Hospital** | `gastos_provider.dart` | `/api/v1/gastos` | `GET` / `POST` | Listar transacciones y registrar compras de insumos. |
| **Total Gastado** | `gastos_provider.dart` | `/api/v1/gastos/total` | `GET` | Obtener la sumatoria total del presupuesto devengado. |
| **Respaldos DB** | `more_screen.dart` | `/api/v1/respaldo/generar` | `POST` | Generar un backup de base de datos (Admin/Superadmin). |
| **Exportar PDF** | `reports_screen.dart` | `/api/v1/reportes/diario.pdf` | `GET` | Obtener stream binario del reporte diario e iniciar descarga. |
