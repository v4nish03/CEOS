# Vistas móviles por rol

Este documento sirve como guía rápida para modificar las vistas móviles sin romper la separación de responsabilidades por rol. La fuente técnica de permisos es `Movil/lib/core/permissions/role_permissions.dart`; si cambia el alcance de un rol, primero actualiza ese archivo y después ajusta las vistas correspondientes.

## Vistas comunes para todos los roles

| Flujo / vista | Archivo | Uso |
| --- | --- | --- |
| Bootstrap de autenticación | `Movil/lib/features/auth/presentation/screens/auth_bootstrap_screen.dart` | Valida el estado inicial de sesión antes de mostrar login o app principal. |
| Login | `Movil/lib/features/auth/presentation/screens/login_screen.dart` | Pantalla de ingreso para todos los usuarios. |
| Contenedor principal | `Movil/lib/features/home/presentation/screens/main_wrapper.dart` | Define las pestañas visibles por rol con base en permisos. |
| Dashboard dispatcher | `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart` | Decide qué dashboard mostrar según el rol autenticado. |
| Más / perfil / sesión | `Movil/lib/features/home/presentation/screens/more_screen.dart` | Muestra perfil, sesión y herramientas disponibles según permisos. |

## SUPERADMIN

| Sección | Archivo de vista | Archivos de widgets relacionados | Notas de alcance |
| --- | --- | --- | --- |
| Inicio | `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart` | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Usa `AdminDashboard` con permisos completos. |
| Usuarios | `Movil/lib/features/users/presentation/screens/users_screen.dart` | `Movil/lib/features/users/presentation/widgets/user_card.dart`, `Movil/lib/features/users/presentation/widgets/user_form_modal.dart` | Puede ver y gestionar usuarios, incluyendo roles elevados. |
| Inventario | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | `Movil/lib/features/inventory/presentation/widgets/material_card.dart`, `Movil/lib/features/inventory/presentation/widgets/material_form_modal.dart`, `Movil/lib/features/inventory/presentation/widgets/movement_form_modal.dart` | Puede ver, crear, editar y registrar movimientos de inventario. |
| Solicitudes | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Puede revisar solicitudes. |
| Reportes | `Movil/lib/features/reports/presentation/screens/reports_screen.dart` | `Movil/lib/features/reports/presentation/providers/reports_provider.dart` | Puede consultar reportes. |
| Gastos | `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart` | `Movil/lib/features/gastos/presentation/providers/gastos_provider.dart` | Puede ver y crear gastos. Se abre desde la vista `Más`. |

## ADMIN

| Sección | Archivo de vista | Archivos de widgets relacionados | Notas de alcance |
| --- | --- | --- | --- |
| Inicio | `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart` | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Usa `AdminDashboard`, pero las acciones deben mantenerse en modo supervisión cuando aplique. |
| Usuarios | `Movil/lib/features/users/presentation/screens/users_screen.dart` | `Movil/lib/features/users/presentation/widgets/user_card.dart`, `Movil/lib/features/users/presentation/widgets/user_form_modal.dart` | Puede gestionar usuarios, pero no debería crear `SUPERADMIN`. |
| Inventario | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Solo consulta/supervisión. No debe crear materiales, editar ni registrar entradas/salidas. |
| Solicitudes | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Puede revisar solicitudes. |
| Reportes | `Movil/lib/features/reports/presentation/screens/reports_screen.dart` | `Movil/lib/features/reports/presentation/providers/reports_provider.dart` | Puede consultar reportes. |
| Gastos | `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart` | `Movil/lib/features/gastos/presentation/providers/gastos_provider.dart` | Solo consulta/supervisión. No debe crear gastos. |

## INVENTARIO

| Sección | Archivo de vista | Archivos de widgets relacionados | Notas de alcance |
| --- | --- | --- | --- |
| Inicio | `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart` | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Usa `InventoryDashboard`. |
| Inventario | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | `Movil/lib/features/inventory/presentation/widgets/material_card.dart`, `Movil/lib/features/inventory/presentation/widgets/material_form_modal.dart`, `Movil/lib/features/inventory/presentation/widgets/movement_form_modal.dart` | Puede ver, crear, editar y registrar movimientos de inventario. |
| Movimientos | `Movil/lib/features/inventory/presentation/screens/movements_screen.dart` | `Movil/lib/features/inventory/presentation/providers/inventory_provider.dart` | Consulta historial operativo de inventario. |
| Solicitudes | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Puede revisar solicitudes. |
| Reportes | `Movil/lib/features/reports/presentation/screens/reports_screen.dart` | `Movil/lib/features/reports/presentation/providers/reports_provider.dart` | Puede consultar reportes asociados a inventario. |
| Gastos | `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart` | `Movil/lib/features/gastos/presentation/providers/gastos_provider.dart` | Puede ver y crear gastos operativos. Se abre desde la vista `Más`. |

## DOCTOR

| Sección | Archivo de vista | Archivos de widgets relacionados | Notas de alcance |
| --- | --- | --- | --- |
| Inicio | `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart` | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Usa `DoctorDashboard`. |
| Materiales | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Solo consulta de disponibilidad. No debe modificar inventario. |
| Solicitudes | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | `Movil/lib/features/request/presentation/widgets/request_card.dart`, `Movil/lib/features/request/presentation/widgets/request_form_modal.dart` | Puede crear solicitudes; no debe aprobar/rechazar solicitudes. |
| Más | `Movil/lib/features/home/presentation/screens/more_screen.dart` | N/A | Perfil, configuración básica y cierre de sesión. |

## Reglas para modificar vistas móviles

1. No dupliques pantallas completas por rol si solo cambia la visibilidad de botones o acciones; usa permisos y componentes compartidos.
2. Si una pantalla cambia mucho en estructura o contenido por rol, separa el dashboard o sección específica, pero mantén widgets comunes reutilizables.
3. El rol `ADMIN` puede supervisar inventario y gastos, pero no debe modificar stock ni crear gastos.
4. El rol `INVENTARIO` concentra las acciones operativas de inventario: altas, ediciones, entradas, salidas y movimientos.
5. El rol `DOCTOR` debe mantenerse enfocado en consultar materiales y crear solicitudes.
6. Cuando agregues una vista nueva, actualiza este documento y `Movil/lib/core/permissions/role_permissions.dart` en el mismo cambio.
