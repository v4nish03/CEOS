Resumen directo
Para el MVP móvil de CEOS, yo diseñaría la app con 8 pantallas principales y varios modales/formularios. La estructura debe ser por rol, porque el backend ya trabaja con roles (SUPERADMIN, ADMIN, INVENTARIO, DOCTOR) y la app móvil actual ya cambia el menú inferior según el rol autenticado. 

Mi recomendación UX/UI: no hacer una app con demasiadas pantallas sueltas, sino una app tipo clínica/inventario con:

Login limpio.

Dashboard inicial.

Barra inferior por rol.

Cards grandes y claras.

Acciones rápidas con botones visibles.

Formularios en bottom sheets.

Estados visuales fuertes: stock bajo, pendiente, aprobado, rechazado.

Confirmaciones antes de acciones críticas.

1. Mapa general de pantallas móviles
Cantidad recomendada
Para el MVP yo usaría:

Pantallas obligatorias
Splash / Verificación de sesión

Login

Inicio / Dashboard

Inventario / Materiales

Detalle de material

Solicitudes

Reportes

Perfil / Cuenta

Pantallas administrativas opcionales para MVP completo
Usuarios

Gastos

Backups / Respaldo

Configuración

Mi recomendación práctica: para comenzar el front móvil, hacer primero las 8 obligatorias y después añadir Usuarios, Gastos y Backups para ADMIN/SUPERADMIN.

2. Navegación recomendada por rol
El backend ya expone login, usuarios, materiales, movimientos, reportes, gastos y backups desde routers principales. 

La app móvil actual ya tiene un MainWrapper que construye pantallas e ítems de navegación según el rol. Para DOCTOR, muestra Inicio, Materiales y Solicitudes; para INVENTARIO, muestra Inicio, Inventario, Movimientos, Solicitudes y Reportes; para ADMIN/SUPERADMIN, muestra Inicio, Usuarios, Inventario, Solicitudes y Reportes. 

Rol DOCTOR
Menú inferior recomendado
Inicio

Materiales

Solicitudes

Perfil

Qué debe poder hacer
Ver disponibilidad de materiales.

Buscar material.

Crear solicitud de material.

Ver estado de sus solicitudes.

No modificar stock directamente.

El backend permite que DOCTOR consulte materiales y cree solicitudes. 

Rol INVENTARIO
Menú inferior recomendado
Inicio

Inventario

Movimientos

Solicitudes

Reportes

Qué debe poder hacer
Crear materiales.

Editar materiales.

Registrar entradas.

Registrar salidas.

Ver alertas.

Procesar solicitudes.

Ver reportes.

El backend permite a INVENTARIO crear/editar materiales, registrar movimientos, ver alertas, procesar solicitudes y consultar reportes. 

Rol ADMIN
Menú inferior recomendado
Inicio

Usuarios

Reportes

Solicitudes

Perfil

Qué debe poder hacer
Crear usuarios.

Ver inventario.

Ver reportes.

Ver gastos.

Ejecutar backup.

Revisar solicitudes si así lo decides funcionalmente.

El backend permite que ADMIN cree usuarios, liste solicitudes, vea reportes, consulte gastos y ejecute backup. 

Ojo UX/funcional: si el requerimiento final dice que admin no modifica inventario, entonces en la app no deberías ponerle botones de “Entrada”, “Salida” o “Aprobar salida” sin confirmarlo.

Rol SUPERADMIN
Menú inferior recomendado
Inicio

Usuarios

Inventario

Reportes

Más

En Más pondría:

Gastos.

Backups.

Configuración.

Cerrar sesión.

SUPERADMIN tiene acceso amplio en el backend: usuarios, materiales, movimientos, solicitudes, reportes, gastos y backups. 

3. Pantalla 1: Splash / Verificación de sesión
Objetivo UX
Que la app revise si hay sesión guardada y mande al usuario automáticamente a Login o Inicio.

La app actual ya tiene router con lógica de redirección: si no está autenticado manda a /login, y si ya está autenticado manda a /main. 

Interfaz
Elementos visuales
Logo CEOS o ícono clínico.

Texto: “CEOS Inventario Clínico”

Loading pequeño.

Fondo claro, limpio, profesional.

Estados
Cargando sesión: spinner.

Sesión válida: navegar a Inicio.

Sesión inválida: navegar a Login.

Botones
No necesita botones.

4. Pantalla 2: Login
La app actual ya tiene una pantalla de login con email, contraseña, botón de visibilidad y botón “INGRESAR”. 

Objetivo UX
Ingresar rápido, sin registro público, porque el sistema no debe permitir registro libre. El README confirma que no hay registro público y que usuarios se crean desde endpoint interno por SUPERADMIN o ADMIN. 

Campos
Correo electrónico

Icono: email.

Teclado tipo email.

Placeholder: usuario@ceos.com.

Contraseña

Icono: candado.

Botón de mostrar/ocultar.

Botones
Principal
Ingresar

Color principal CEOS.

Ocupa ancho completo.

Muestra loading al enviar.

Secundario
¿Olvidaste tu contraseña?

Para MVP puede estar deshabilitado o mostrar mensaje: “Contacta al administrador”.

Validaciones UX
Si email vacío: “Ingresa tu correo”.

Si contraseña vacía: “Ingresa tu contraseña”.

Si credenciales incorrectas: snackbar rojo.

Si no hay conexión: “No se pudo conectar con el servidor”.

Recomendación visual
No usar demasiados colores.

Fondo blanco o azul muy claro.

Botón principal grande.

Logo arriba.

Card central si se usa tablet/web.

5. Pantalla 3: Inicio / Dashboard
Objetivo UX
Que el usuario entienda qué está pasando hoy en 5 segundos.

El backend tiene resumen global de inventario, materiales más usados, alertas y reportes. 

La app móvil actual ya usa un Dashboard como primera pantalla dentro del MainWrapper. 

Diseño recomendado
Header
Saludo:

“Hola, Dr. Nombre”

“Rol: Inventario”

Fecha actual.

Botón pequeño de actualizar.

Cards KPI
Para ADMIN, SUPERADMIN, INVENTARIO:

Total materiales

Stock total

Stock bajo

Solicitudes pendientes

Gasto total del mes si se implementa pantalla de gastos

El backend ya devuelve resumen con total_materiales, stock_total_unidades y materiales_stock_bajo. 

Para DOCTOR:

Materiales disponibles

Mis solicitudes pendientes

Mis solicitudes aprobadas

Materiales con bajo stock si se quiere mostrar solo como aviso

Secciones
1. Alertas críticas
Cards rojas/naranjas:

“3 materiales con stock bajo”

“2 materiales por vencer”

El backend genera alertas por stock bajo y vencimiento. 

2. Acciones rápidas
Botones grandes:

Registrar entrada

Registrar salida

Nueva solicitud

Nuevo material

Ver reportes

Mostrar solo las acciones permitidas por rol.

3. Top materiales usados
Lista corta de 5 materiales más usados.

El backend tiene endpoint de ranking de materiales más usados. 

Botones en Inicio
Para DOCTOR
Solicitar material

Ver mis solicitudes

Buscar material

Para INVENTARIO
Nuevo material

Registrar entrada

Registrar salida

Ver alertas

Revisar solicitudes

Para ADMIN/SUPERADMIN
Crear usuario

Ver reportes

Backup

Ver gastos

Revisar solicitudes

6. Pantalla 4: Inventario / Materiales
La app actual ya tiene una pantalla InventoryScreen con AppBar, botón refresh, FAB “Nuevo Material”, lista con cards, estados loading/error/vacío y bottom sheet para formularios. 

Objetivo UX
Permitir encontrar materiales rápido, ver stock y ejecutar acciones sin entrar a demasiadas pantallas.

Estructura visual
AppBar
Título:

Para inventario/admin: Inventario

Para doctor: Materiales disponibles

Acciones:

Refresh.

Filtro.

Buscar.

La pantalla actual ya tiene botón refresh en el AppBar. 

Barra de búsqueda
Arriba de la lista:

Placeholder: “Buscar material…”

Filtro por categoría.

Filtro por estado:

Todos.

Stock bajo.

Por vencer.

Sin stock.

Vencidos.

Cards de material
La app actual ya usa MaterialCard, con icono, nombre, categoría, stock y borde rojo si hay bajo stock. 

Cada card debería mostrar:

Nombre.

Categoría.

Stock actual.

Stock mínimo.

Fecha de vencimiento.

Badge:

Verde: OK.

Amarillo: Por vencer.

Rojo: Stock bajo.

Gris: Sin stock.

Botones por card
Para DOCTOR
Solicitar

Ver detalle

No debería tener botón de editar ni entrada/salida.

Para INVENTARIO
Entrada

Salida

Editar

Detalle

La card actual ya tiene iconos para entrada y salida cuando canEdit es true. 

Para ADMIN
Depende de tu regla:

Si admin solo observa:

Ver detalle

Ver historial

Si admin puede operar:

Entrada

Salida

Editar

Mi recomendación: admin no debería modificar stock si quieres respetar el requerimiento original. 

Para SUPERADMIN
Entrada

Salida

Editar

Detalle

Eliminar solo si después se agrega endpoint de borrado.

7. Modal: Nuevo / Editar material
Cuándo aparece
Botón FAB Nuevo Material.

Tap en card o botón Editar.

La pantalla actual abre MaterialFormModal usando bottom sheet. 

Campos
Nombre del material

Ejemplo: “Guantes Nitrilo M”

Categoría

Dropdown recomendado:

Insumos

Instrumental

Medicamentos

Desechables

Limpieza

Otros

Stock actual

Stock mínimo

Fecha de vencimiento

Fecha de alerta de vencimiento

El backend permite nombre, categoría, stock mínimo, fecha de vencimiento, fecha de alerta y stock actual al crear material. 

Botones
Guardar material

Cancelar

UX recomendada
Bottom sheet alto con scroll.

Validación campo por campo.

Botón guardar deshabilitado si falta algo obligatorio.

Confirmación verde al guardar.

Si se edita, título: “Editar material”.

8. Modal: Registrar movimiento
La app actual ya tiene MovementFormModal para entrada/salida, con cantidad, motivo opcional y botón “Confirmar Operación”. 

Objetivo UX
Registrar entrada/salida sin fricción, pero evitando errores de stock.

Campos
Material seleccionado.

Tipo:

Entrada.

Salida.

Ajuste, si decides exponerlo.

Cantidad.

Motivo / nota.

Confirmación del stock resultante:

“Stock actual: 25”

“Después de salida: 20”

El backend soporta entrada, salida y ajuste. 

Botones
Confirmar entrada

Confirmar salida

Cancelar

UX crítica
Para salida:

Si cantidad supera stock, bloquear antes de enviar.

Mostrar alerta: “No hay suficiente stock”.

La app actual ya valida cantidad inválida y stock insuficiente localmente. 

Antes de confirmar:

Dialog:

“¿Confirmar salida de 5 unidades de Guantes Nitrilo?”

Botones: Cancelar / Confirmar salida

9. Pantalla 5: Detalle de material
Esta pantalla no es estrictamente obligatoria en el backend actual porque puedes operar desde cards, pero en UX móvil es muy conveniente.

Objetivo UX
Ver toda la información de un material y sus acciones relacionadas.

Contenido
Header
Nombre del material.

Categoría.

Badge de estado:

OK.

Stock bajo.

Por vencer.

Sin stock.

KPIs
Stock actual.

Stock mínimo.

Días para vencimiento.

Última salida, si luego se agrega endpoint.

Información
Fecha de vencimiento.

Fecha de alerta.

Historial reciente.

Solicitudes relacionadas, si se agrega.

Botones
Para DOCTOR
Solicitar material

Volver

Para INVENTARIO/SUPERADMIN
Registrar entrada

Registrar salida

Editar material

Ver historial

Para ADMIN
Ver historial

Ver reporte

UX recomendada
Usar tabs:

Resumen

Movimientos

Solicitudes

10. Pantalla 6: Solicitudes
La app actual ya tiene RequestsScreen, con título dinámico según rol, refresh, FAB para doctor y cards con aprobar/rechazar para roles revisores. 

Objetivo UX
Que el doctor pida material fácil y que inventario procese rápido.

Para DOCTOR
Título:

Mis solicitudes

Botones:

FAB: Nueva solicitud

Filtros:

Todas.

Pendientes.

Aprobadas.

Rechazadas.

Card:

Material.

Cantidad.

Motivo.

Estado.

Fecha.

Color por estado.

El backend hace que DOCTOR solo vea sus propias solicitudes. 

Para INVENTARIO / ADMIN / SUPERADMIN
Título:

Revisión de solicitudes

Filtros:

Pendientes.

Aprobadas.

Rechazadas.

Por material.

Por fecha.

Card:

Material solicitado.

Cantidad.

Solicitante.

Motivo.

Estado.

Botones si está pendiente:

Aprobar

Rechazar

La card actual ya muestra estado con color e icono, cantidad, motivo, solicitante y botones aprobar/rechazar. 

UX importante
Al aprobar:

Mostrar confirmación:

“Aprobar esta solicitud descontará stock del inventario.”

Botones:

Cancelar

Aprobar y descontar

Esto es importante porque el backend descuenta stock cuando una solicitud se aprueba. 

11. Modal: Nueva solicitud
La app actual abre RequestFormModal desde el FAB de doctor. 

Campos
Material

Buscador/dropdown.

Cantidad

Motivo

Opcional, pero recomendado.

Prioridad

No existe en backend todavía; se puede omitir.

Resumen

“Solicitarás 3 unidades de X.”

El backend espera material_id, cantidad y motivo. 

Botones
Enviar solicitud

Cancelar

UX recomendada
Si stock es bajo o cero, mostrar:

“Este material tiene stock limitado.”

Después de enviar:

Snackbar verde: “Solicitud enviada.”

Navegar o actualizar lista de solicitudes.

12. Pantalla 7: Reportes
La app actual ya tiene pantalla de reportes con tabs: Resumen, Top Materiales y Movimientos. 

Objetivo UX
Dar visión ejecutiva sin abrumar.

Tabs recomendados
Tab 1: Resumen
La app actual ya muestra resumen global, KPIs y alertas activas. 

Contenido:

Total materiales.

Stock total.

Materiales bajo stock.

Alertas activas.

Botones:

Actualizar

Descargar PDF

Compartir PDF, si se implementa en móvil.

El backend tiene endpoint de PDF diario. 

Tab 2: Top materiales
Contenido:

Ranking de materiales más usados.

Barras horizontales.

Cantidad de salidas.

El backend tiene endpoint /reportes/materiales-mas-usados. 

Botones:

Filtrar por periodo, si luego se agrega backend.

Actualizar

Tab 3: Movimientos
Contenido:

Lista de movimientos.

Tipo: entrada/salida/ajuste.

Material.

Cantidad.

Fecha.

Usuario.

El backend tiene endpoint de reporte de movimientos. 

Botones:

Filtrar

Exportar, si se agrega.

13. Pantalla 8: Usuarios
La app actual ya tiene UsersScreen, protegida visualmente para ADMIN y SUPERADMIN, con botón refresh, FAB “Nuevo Usuario” y lista de usuarios. 

Objetivo UX
Que admin/superadmin puedan crear usuarios internos sin registro público.

Lista de usuarios
Card:

Nombre.

Email.

Rol.

Estado, si luego se agrega activo/inactivo.

Botones
Nuevo usuario

Actualizar

Editar usuario, si luego existe endpoint.

Desactivar, si luego existe endpoint.

Modal Nuevo usuario
Campos:

Nombre.

Email.

Contraseña temporal.

Rol.

El backend permite crear usuario con nombre, email, password y rol. 

Botones:

Crear usuario

Cancelar

UX recomendada
Mostrar aviso:

“El usuario deberá cambiar su contraseña al primer ingreso”, si luego se implementa.

Rol como chips:

Admin

Inventario

Doctor

14. Pantalla 9: Gastos
Esta pantalla no aparece como navegación principal en el MainWrapper actual, pero el backend ya tiene endpoints de gastos. 

Objetivo UX
Registrar compras/egresos de insumos.

Acceso recomendado
SUPERADMIN

ADMIN para ver.

INVENTARIO para registrar si compra insumos.

El backend permite crear gasto a SUPERADMIN e INVENTARIO, y listar/consultar total a SUPERADMIN, ADMIN e INVENTARIO. 

Pantalla
Header
Total gastado.

Mes actual.

Botón añadir gasto.

Lista
Card de gasto:

Concepto.

Monto.

Fecha.

Registrado por.

Descripción.

Botones
Nuevo gasto

Actualizar

Filtrar por fecha

Ver total

Modal Nuevo gasto
Campos:

Concepto.

Monto.

Descripción.

Fecha, si luego se permite seleccionar.

El backend espera concepto, monto y descripcion. 

Botones:

Guardar gasto

Cancelar

15. Pantalla 10: Backups / Respaldo
El backend ya tiene endpoint POST /backups/database para SUPERADMIN y ADMIN. 

Objetivo UX
Permitir respaldo manual antes de una demo, cierre del día o actualización.

Acceso recomendado
Solo SUPERADMIN.

Opcionalmente ADMIN.

Interfaz
Card principal:

Título: Respaldo de base de datos

Texto: “Genera una copia de seguridad del sistema.”

Último respaldo, si luego se guarda historial.

Botones
Generar respaldo

Ver carpeta de respaldos, si aplica.

Descargar último respaldo, si luego se implementa.

Ayuda

Confirmación
Antes de ejecutar:

“¿Deseas generar un respaldo ahora? Esto puede tardar unos segundos.”

Botones:

Cancelar

Generar respaldo

Estados
Loading: “Generando respaldo…”

Éxito: “Respaldo creado correctamente.”

Error: mostrar detalle.

16. Pantalla 11: Perfil / Cuenta
Objetivo UX
Dar control básico de sesión.

Contenido
Nombre.

Email.

Rol.

Estado de conexión.

Versión de la app.

Servidor actual.

El login del backend devuelve token, rol y nombre, útil para poblar esta vista. 

Botones
Cerrar sesión

Cambiar servidor, solo en modo desarrollo/demo.

Ayuda

Acerca de CEOS

UX recomendada
El botón Cerrar sesión debe pedir confirmación:

“¿Quieres cerrar sesión?”

Cancelar

Cerrar sesión

17. Pantalla 12: Configuración
No la pondría en el menú principal del MVP, sino dentro de “Más”.

Opciones
URL del backend, solo si haces modo técnico/demo.

Tema claro/oscuro.

Notificaciones.

Hora de reporte, si luego se permite configurar.

Preferencias de alertas.

El backend ya tiene configuración de hora/minuto para reporte diario vía settings. 

18. Botones principales por pantalla
Login
Ingresar

Mostrar/Ocultar contraseña

¿Olvidaste tu contraseña?

La pantalla actual ya tiene estos elementos. 

Inicio
Actualizar

Nuevo material

Registrar entrada

Registrar salida

Nueva solicitud

Ver reportes

Crear usuario

Backup

Mostrar según rol.

Inventario
Buscar

Filtrar

Actualizar

Nuevo material

Entrada

Salida

Editar

Solicitar

Ver detalle

La pantalla actual ya tiene refresh, FAB “Nuevo Material” y cards con entrada/salida para roles editables. 

Solicitudes
Nueva solicitud

Aprobar

Rechazar

Filtrar

Actualizar

Ver detalle

La pantalla actual ya tiene FAB “Nueva Solicitud”, refresh y botones Aprobar/Rechazar en las cards. 

Reportes
Actualizar

Descargar PDF

Compartir PDF

Filtrar periodo

Ver movimientos

La pantalla actual ya tiene botón actualizar y tabs de resumen/top/movimientos. 

Usuarios
Nuevo usuario

Actualizar

Editar

Desactivar

La pantalla actual ya tiene refresh y FAB “Nuevo Usuario”. 

Gastos
Nuevo gasto

Actualizar

Filtrar

Ver total

El backend ya soporta crear, listar y consultar total de gastos. 

Backups
Generar respaldo

Descargar respaldo

Copiar ruta

Ayuda

El backend ya genera backup manual desde /backups/database. 

19. Componentes UI recomendados
Cards
Usar cards para:

Materiales.

Solicitudes.

Usuarios.

Gastos.

Alertas.

KPIs.

La app actual ya usa cards con sombras, bordes redondeados y colores de estado para materiales y solicitudes. 

Colores
Recomendación:

Uso	Color
Principal CEOS	Azul clínico
Éxito / disponible	Verde
Advertencia / pendiente	Naranja
Error / stock bajo	Rojo
Neutro	Gris
Fondo	Blanco o gris muy claro
La app actual ya usa rojo para bajo stock, verde para aprobado y naranja para pendiente/salida. 

Estados vacíos
Cada pantalla debe tener estado vacío con:

Icono.

Texto claro.

Acción sugerida.

Ejemplos:

Inventario vacío:

“No hay materiales registrados.”

Botón: Nuevo material

La app actual ya maneja estado vacío en inventario, solicitudes y usuarios. 

Estados de error
Cada pantalla debe tener:

Icono de error.

Mensaje entendible.

Botón Reintentar.

La app actual ya maneja error + botón Reintentar en inventario, solicitudes y usuarios. 

Loading
Usar:

Skeletons para listas si se quiere más profesional.

CircularProgressIndicator para MVP.

La app actual usa CircularProgressIndicator en varias pantallas. 

20. Flujo UX ideal por rol
Flujo DOCTOR
Abre app.

Login.

Inicio muestra:

Materiales disponibles.

Mis solicitudes pendientes.

Va a Materiales.

Busca material.

Toca Solicitar.

Ingresa cantidad y motivo.

Envía solicitud.

Ve estado en Mis solicitudes.

Flujo INVENTARIO
Login.

Inicio muestra alertas críticas.

Ve Inventario.

Si llegó material, toca Entrada.

Si sale material, toca Salida.

Si stock bajo, ve alerta.

En Solicitudes, aprueba/rechaza.

En Reportes, revisa movimientos y top materiales.

Flujo ADMIN
Login.

Inicio muestra resumen general.

Ve reportes.

Crea usuarios si hace falta.

Revisa gastos.

Genera backup antes de demo/cierre.

Flujo SUPERADMIN
Login.

Control total.

Usuarios.

Inventario.

Reportes.

Gastos.

Backup.

Configuración.

21. Qué ya existe en la app móvil y qué falta
Ya existe o está encaminado
Router con bootstrap, login y main. 

Menú inferior por rol. 

Login visual con email/password. 

Inventario con lista, refresh, FAB y modales. 

Cards de materiales con stock bajo y acciones de entrada/salida. 

Solicitudes con listado, FAB doctor y aprobar/rechazar. 

Reportes con tabs. 

Usuarios con lista y crear usuario. 

Falta o mejoraría
UX/UI
Pantalla de detalle de material.

Buscador y filtros en inventario.

Filtros en solicitudes.

Pantalla de gastos.

Pantalla de backup.

Perfil/cuenta.

Confirmaciones antes de aprobar solicitud o registrar salida.

Mejor feedback visual cuando no hay conexión.

Mejor experiencia de “sin permisos”.

Botón de descarga/compartir PDF.

Funcionalidad móvil
Guardar token seguro.

Manejo global de expiración de sesión.

Interceptor para errores 401/403.

Pull to refresh en todas las listas.

Estados offline básicos.

22. Mi propuesta final de estructura MVP
Bottom navigation por rol
DOCTOR
Inicio

Materiales

Solicitudes

Perfil

INVENTARIO
Inicio

Inventario

Solicitudes

Reportes

Perfil

No pondría “Movimientos” como tab independiente todavía; pondría movimientos dentro de Inventario/Reportes. La app actual tiene “Movimientos (Próximamente)” para inventario, pero para UX móvil eso puede sentirse incompleto. 

ADMIN
Inicio

Usuarios

Reportes

Más

Dentro de Más:

Gastos.

Backup.

Perfil.

SUPERADMIN
Inicio

Usuarios

Inventario

Reportes

Más

Dentro de Más:

Gastos.

Backup.

Configuración.

Perfil.

23. Orden recomendado de desarrollo del front
Sprint 1: Base y navegación
Splash.

Login.

MainWrapper por rol.

Perfil/cerrar sesión.

Sprint 2: Inventario
Lista de materiales.

Buscador.

Filtros.

Nuevo/editar material.

Entrada/salida.

Sprint 3: Solicitudes
Mis solicitudes para doctor.

Nueva solicitud.

Revisión de solicitudes para inventario.

Confirmación aprobar/rechazar.

Sprint 4: Reportes
Dashboard resumen.

Top materiales.

Movimientos.

Descargar/compartir PDF.

Sprint 5: Admin
Usuarios.

Gastos.

Backup.

Configuración.

24. Checklist UX antes de decir “listo para demo”
Cada pantalla tiene loading.

Cada pantalla tiene error con botón Reintentar.

Cada pantalla tiene estado vacío.

Cada acción crítica tiene confirmación.

Cada acción exitosa tiene snackbar.

Los botones peligrosos son rojos o naranjas.

Los botones principales son claros y grandes.

El usuario nunca ve botones que su rol no puede usar.

El stock bajo se ve sin tener que leer demasiado.

Las solicitudes pendientes resaltan.

La app funciona con una sola mano.

Los formularios no tapan campos cuando aparece el teclado.

El menú inferior no tiene más de 5 ítems.

La pantalla inicial resume lo importante.

