 # Mapeo de Modelos, Entidades y Vistas Compartidas (CEOS Móvil)

Este documento detalla la correspondencia entre los modelos de datos (Entidades) de la aplicación y las pantallas (Vistas) que los consumen, identificando los componentes que son compartidos entre múltiples roles.

---

## 1. Mapeo de Entidades a Vistas

### 📦 MaterialEntity
Representa un insumo o recurso médico en el inventario.
*   **Definición:** `lib/features/inventory/domain/entities/material_entity.dart`
*   **Vistas asociadas:**
    *   [inventory_screen.dart](file:///home/v4/Ceos/Movil/lib/features/inventory/inventory_screen.dart) — Listado del catálogo completo y edición de materiales.
    *   [material_form_modal.dart](file:///home/v4/Ceos/Movil/lib/features/inventory/presentation/widgets/material_form_modal.dart) — Formulario de alta y modificación.
    *   [request_form_modal.dart](file:///home/v4/Ceos/Movil/lib/features/request/presentation/widgets/request_form_modal.dart) — Menú desplegable para que el Doctor elija qué material y cuántas unidades pedir.
    *   [movements_screen.dart](file:///home/v4/Ceos/Movil/lib/features/inventory/presentation/screens/movements_screen.dart) — Selector flotante para registrar entradas y salidas de stock.
*   **¿Es Compartido?** **SÍ (Altamente compartido).** 
    *   El `DOCTOR` lo consume en modo lectura en el catálogo de materiales y para rellenar solicitudes.
    *   `INVENTARIO` y `SUPERADMIN` tienen derechos de escritura para modificar las propiedades del modelo (nombre, stock, alerta de vencimiento).
    *   `ADMIN` lo lee para labores de supervisión e inspección de stock crítico.

### 📝 RequestEntity / RequestModel
Representa una solicitud de material médico generada por un profesional de la salud.
*   **Definición:** `lib/features/request/domain/entities/request_entity.dart`
*   **Vistas asociadas:**
    *   [requests_screen.dart](file:///home/v4/Ceos/Movil/lib/features/request/presentation/screens/requests_screen.dart) — Vista maestra de solicitudes.
    *   [request_card.dart](file:///home/v4/Ceos/Movil/lib/features/request/presentation/widgets/request_card.dart) — Tarjeta de visualización y botones de cambio de estado (Aprobar/Rechazar).
    *   [request_form_modal.dart](file:///home/v4/Ceos/Movil/lib/features/request/presentation/widgets/request_form_modal.dart) — Creación de nuevas solicitudes.
    *   [dashboard_widgets.dart](file:///home/v4/Ceos/Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart) — Muestra un histórico simplificado en `DoctorDashboard`, y un banner de avisos urgentes en `InventoryDashboard`.
*   **¿Es Compartido?** **SÍ.**
    *   El `DOCTOR` crea solicitudes y monitorea su historial personal.
    *   `SUPERADMIN`, `ADMIN` e `INVENTARIO` visualizan todas las solicitudes del hospital y ejecutan el cambio de estado (aprobada/rechazada) sobre el modelo.

### 💳 GastoModel
Representa un registro de compra o egreso financiero del hospital.
*   **Definición:** `lib/features/gastos/data/models/gasto_model.dart`
*   **Vistas asociadas:**
    *   [gastos_screen.dart](file:///home/v4/Ceos/Movil/lib/features/gastos/presentation/screens/gastos_screen.dart) — Vista general de egresos con el presupuesto histórico consumido y el formulario de inserción.
    *   [more_screen.dart](file:///home/v4/Ceos/Movil/lib/features/home/presentation/screens/more_screen.dart) — Widget resumen de presupuesto total gastado.
*   **¿Es Compartido?** **SÍ (Parcialmente).**
    *   `SUPERADMIN` e `INVENTARIO` consumen el modelo para registrar gastos nuevos y ver el histórico.
    *   `ADMIN` tiene acceso exclusivamente para lectura (supervisar el presupuesto ejecutado).
    *   `DOCTOR` no tiene acceso a esta entidad ni a sus vistas.

### 👥 UserEntity / UserSummaryEntity
Representa las credenciales de sesión activa del usuario y las cuentas de personal del hospital.
*   **Definición:** `lib/features/auth/domain/entities/user_entity.dart` y `lib/features/users/domain/entities/user_summary_entity.dart`
*   **Vistas asociadas:**
    *   [users_screen.dart](file:///home/v4/Ceos/Movil/lib/features/users/presentation/screens/users_screen.dart) — Gestión y listado del personal de salud.
    *   [user_form_modal.dart](file:///home/v4/Ceos/Movil/lib/features/users/presentation/widgets/user_form_modal.dart) — Registro y edición de roles/datos de usuarios.
    *   [more_screen.dart](file:///home/v4/Ceos/Movil/lib/features/home/presentation/screens/more_screen.dart) — Perfil de usuario y nombre en cabecera.
*   **¿Es Compartido?** **SÍ.**
    *   `UserEntity` es la base de `authProvider` (compartido de manera transversal y global por todas las pantallas para verificar permisos y personalizar saludos).
    *   `UserSummaryEntity` es gestionado y visualizado de forma exclusiva por `SUPERADMIN` y `ADMIN` (los doctores e inventarios no pueden ver ni listar personal).

---

## 2. Vistas Altamente Compartidas y Variaciones por Rol

Para evitar la duplicación de código, CEOS utiliza las mismas clases de Flutter para varios roles, alterando los componentes visuales mediante lógica condicional:

| Vista / Pantalla Compartida | Roles que la Comparten | Variación Visual / Funcional de la Pantalla |
| :--- | :--- | :--- |
| **`InventoryScreen`** | SUPERADMIN, ADMIN, INVENTARIO, DOCTOR | *   `SUPERADMIN / INVENTARIO`: Acceso total (creación, edición y borrado).<br>*   `ADMIN`: Modo supervisión (banner azul informativo, sin botones de acción).<br>*   `DOCTOR`: Vista de solo lectura adaptada a catálogo clínico. |
| **`RequestsScreen`** | SUPERADMIN, ADMIN, INVENTARIO, DOCTOR | *   `DOCTOR`: Ve únicamente sus solicitudes y el botón para crear nuevas.<br>*   `SUPERADMIN / ADMIN / INVENTARIO`: Ven todas las solicitudes y los botones de aprobación/rechazo. |
| **`GastosScreen`** | SUPERADMIN, ADMIN, INVENTARIO | *   `SUPERADMIN / INVENTARIO`: Acceso total (crea gastos mediante FAB).<br>*   `ADMIN`: Lectura del presupuesto (sin FAB, con banner descriptivo). |
| **`MoreScreen`** | Todos los roles | *   `SUPERADMIN / ADMIN`: Muestra la opción de "Generar respaldo", botón "Gastos" y resumen del presupuesto.<br>*   `INVENTARIO`: Muestra botón "Gastos" y resumen del presupuesto. Oculta "Generar respaldo".<br>*   `DOCTOR`: Oculta gastos, presupuesto y respaldos. |
