# Orden recomendado para cambiar apariencia de vistas móviles

Este archivo indica el orden práctico para rediseñar las vistas móviles por rol. La idea es avanzar por bloques visuales sin romper permisos ni navegación.

## Orden general recomendado

1. **Base compartida de navegación y sesión**
2. **SUPERADMIN**
3. **ADMIN**
4. **DOCTOR**
5. **INVENTARIO**
6. **Componentes compartidos finales**

> Recomendación: aunque empieces visualmente por `SUPERADMIN`, primero revisa los archivos base porque todos los roles pasan por ellos.

## 0. Base compartida antes de tocar roles

Estos archivos afectan a todos los roles y conviene dejarlos estables antes de personalizar pantallas específicas.

| Orden | Archivo | Qué modificar visualmente | Por qué va primero |
| --- | --- | --- | --- |
| 0.1 | `Movil/lib/features/home/presentation/screens/main_wrapper.dart` | Navegación inferior, estructura general, orden de tabs, espaciados globales. | Es el contenedor común que muestra las vistas por rol. |
| 0.2 | `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart` | AppBar del panel, contenedor del dashboard, presentación del nombre/rol. | Es el dispatcher visual de dashboards por rol. |
| 0.3 | `Movil/lib/features/home/presentation/screens/more_screen.dart` | Perfil, menú de herramientas, cierre de sesión, cards de resumen. | La vista `Más` aparece en todos o casi todos los roles. |
| 0.4 | `Movil/lib/core/permissions/role_permissions.dart` | No es visual; solo confirmar permisos antes de esconder/mostrar acciones. | Evita diseñar botones que el rol no debe usar. |

## 1. SUPERADMIN

Empieza por `SUPERADMIN` si quieres construir la versión más completa primero. Este rol consume casi todas las vistas, así que sirve como referencia visual general.

| Orden | Archivo | Qué cambiar |
| --- | --- | --- |
| 1.1 | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Rediseñar `AdminDashboard`, cards KPI, accesos rápidos, alertas y listas resumen. |
| 1.2 | `Movil/lib/features/users/presentation/screens/users_screen.dart` | Rediseñar layout de gestión de usuarios, estados vacíos, refresh y FAB. |
| 1.3 | `Movil/lib/features/users/presentation/widgets/user_card.dart` | Rediseñar card de usuario, badges de rol y jerarquía visual. |
| 1.4 | `Movil/lib/features/users/presentation/widgets/user_form_modal.dart` | Rediseñar modal de creación/edición de usuarios. |
| 1.5 | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | Rediseñar listado, buscador, filtros, header de estadísticas y estado vacío. |
| 1.6 | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Rediseñar card de material, indicador de stock y acciones. |
| 1.7 | `Movil/lib/features/inventory/presentation/widgets/material_form_modal.dart` | Rediseñar modal de material. |
| 1.8 | `Movil/lib/features/inventory/presentation/widgets/movement_form_modal.dart` | Rediseñar modal de entradas/salidas. |
| 1.9 | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | Rediseñar pantalla de revisión de solicitudes. |
| 1.10 | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Rediseñar card de solicitud y acciones de revisión. |
| 1.11 | `Movil/lib/features/reports/presentation/screens/reports_screen.dart` | Rediseñar reportes, tabs, tablas/listas y estados de carga. |
| 1.12 | `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart` | Rediseñar resumen de gastos, historial, botón de creación y estados vacíos. |

## 2. ADMIN

Después de `SUPERADMIN`, ajusta `ADMIN` porque comparte mucho dashboard y muchas vistas, pero con modo supervisión en inventario y gastos.

| Orden | Archivo | Qué cambiar |
| --- | --- | --- |
| 2.1 | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Ajustar la variante visual de `AdminDashboard` para modo administrador/supervisión. |
| 2.2 | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | Mejorar banner de supervisión y confirmar que no aparezcan acciones de edición. |
| 2.3 | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Verificar apariencia en modo solo lectura, sin botones de movimiento. |
| 2.4 | `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart` | Mejorar banner de solo lectura y ocultar visualmente creación de gastos. |
| 2.5 | `Movil/lib/features/users/presentation/screens/users_screen.dart` | Ajustar experiencia de administración de usuarios para rol `ADMIN`. |
| 2.6 | `Movil/lib/features/users/presentation/widgets/user_form_modal.dart` | Confirmar que el modal no ofrezca creación de `SUPERADMIN` para `ADMIN`. |
| 2.7 | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | Afinar vista de revisión de solicitudes para supervisión. |
| 2.8 | `Movil/lib/features/reports/presentation/screens/reports_screen.dart` | Ajustar reportes para lectura ejecutiva/supervisión. |

## 3. DOCTOR

Luego trabaja `DOCTOR`, porque su flujo es más pequeño y distinto: consultar materiales y crear solicitudes.

| Orden | Archivo | Qué cambiar |
| --- | --- | --- |
| 3.1 | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Rediseñar `DoctorDashboard`, cards de disponibilidad y accesos a solicitudes/materiales. |
| 3.2 | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | Ajustar título `Materiales`, buscador, filtros y lectura de disponibilidad. |
| 3.3 | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Crear apariencia de material consultable sin acciones de inventario. |
| 3.4 | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | Rediseñar `Mis Solicitudes`, estado vacío y FAB de nueva solicitud. |
| 3.5 | `Movil/lib/features/request/presentation/widgets/request_form_modal.dart` | Rediseñar modal de creación de solicitud. |
| 3.6 | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Ajustar card para que el doctor vea estado, material, cantidad y fecha claramente. |
| 3.7 | `Movil/lib/features/home/presentation/screens/more_screen.dart` | Simplificar la vista `Más` para perfil, configuración y cierre de sesión. |

## 4. INVENTARIO

Deja `INVENTARIO` al final si primero quieres consolidar las vistas administrativas y médicas. Este rol necesita cuidar mucho la usabilidad operativa.

| Orden | Archivo | Qué cambiar |
| --- | --- | --- |
| 4.1 | `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart` | Rediseñar `InventoryDashboard`, alertas, KPIs y accesos rápidos operativos. |
| 4.2 | `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart` | Optimizar para operación diaria: filtros, búsqueda, alta y edición de materiales. |
| 4.3 | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Mejorar botones de entrada/salida y legibilidad de stock bajo. |
| 4.4 | `Movil/lib/features/inventory/presentation/widgets/material_form_modal.dart` | Rediseñar captura de material para uso rápido en móvil. |
| 4.5 | `Movil/lib/features/inventory/presentation/widgets/movement_form_modal.dart` | Rediseñar registro de entradas/salidas con validación visual clara. |
| 4.6 | `Movil/lib/features/inventory/presentation/screens/movements_screen.dart` | Rediseñar historial de movimientos. |
| 4.7 | `Movil/lib/features/request/presentation/screens/requests_screen.dart` | Ajustar revisión de solicitudes para flujo operativo. |
| 4.8 | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Optimizar botones de aprobar/rechazar y datos críticos. |
| 4.9 | `Movil/lib/features/reports/presentation/screens/reports_screen.dart` | Ajustar reportes para inventario operativo. |
| 4.10 | `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart` | Rediseñar captura y revisión de gastos operativos. |

## 5. Componentes compartidos finales

Al terminar los roles, revisa estos componentes para unificar estilo y evitar inconsistencias.

| Orden | Archivo | Qué revisar |
| --- | --- | --- |
| 5.1 | `Movil/lib/features/dashboard/presentation/widgets/role_menu.dart` | Si todavía se usa, alinear estilo de chips/acciones con el nuevo diseño. |
| 5.2 | `Movil/lib/features/inventory/presentation/widgets/material_card.dart` | Confirmar que funciona bien en modo editable y solo lectura. |
| 5.3 | `Movil/lib/features/request/presentation/widgets/request_card.dart` | Confirmar que se adapta a doctor, admin e inventario. |
| 5.4 | `Movil/lib/features/users/presentation/widgets/user_card.dart` | Confirmar consistencia de roles, colores y jerarquía. |
| 5.5 | `Movil/lib/features/home/presentation/screens/more_screen.dart` | Revisar que no queden opciones visuales fuera de permisos. |

## Resumen rápido del orden por archivo principal

1. `Movil/lib/features/home/presentation/screens/main_wrapper.dart`
2. `Movil/lib/features/auth/presentation/widgets/dashboard_view.dart`
3. `Movil/lib/features/home/presentation/screens/more_screen.dart`
4. `Movil/lib/features/dashboard/presentation/widgets/dashboard_widgets.dart`
5. `Movil/lib/features/users/presentation/screens/users_screen.dart`
6. `Movil/lib/features/users/presentation/widgets/user_card.dart`
7. `Movil/lib/features/users/presentation/widgets/user_form_modal.dart`
8. `Movil/lib/features/inventory/presentation/screens/inventory_screen.dart`
9. `Movil/lib/features/inventory/presentation/widgets/material_card.dart`
10. `Movil/lib/features/inventory/presentation/widgets/material_form_modal.dart`
11. `Movil/lib/features/inventory/presentation/widgets/movement_form_modal.dart`
12. `Movil/lib/features/request/presentation/screens/requests_screen.dart`
13. `Movil/lib/features/request/presentation/widgets/request_card.dart`
14. `Movil/lib/features/request/presentation/widgets/request_form_modal.dart`
15. `Movil/lib/features/reports/presentation/screens/reports_screen.dart`
16. `Movil/lib/features/gastos/presentation/screens/gastos_screen.dart`
17. `Movil/lib/features/inventory/presentation/screens/movements_screen.dart`
18. `Movil/lib/features/dashboard/presentation/widgets/role_menu.dart`

## Regla de trabajo recomendada

Para cada archivo que modifiques visualmente:

1. Revisa si lo consume más de un rol en `Docs/VistasMovilesPorRol.md`.
2. Cambia primero el layout sin tocar permisos.
3. Verifica estados: loading, error, vacío, solo lectura y editable.
4. Si aparece o desaparece una acción por rol, actualiza `Movil/lib/core/permissions/role_permissions.dart` solo si realmente cambia el permiso.
5. Actualiza este archivo cuando agregues, elimines o muevas una vista.
