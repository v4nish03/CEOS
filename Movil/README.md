# CEOS Móvil (Flutter)

Aplicación móvil en **Flutter** para consumir el backend FastAPI de CEOS.

## Ejecutar

```bash
cd Movil
flutter pub get
flutter run
```

## Configuración backend
Edita `lib/core/constants/app_constants.dart` y cambia `baseUrl` a la URL de tu API.

## Arquitectura
- Clean Architecture: `presentation`, `domain`, `data`.
- Modular por features: `auth`, `dashboard`, `inventory`, `users`, `reports`.
- State management: Riverpod.
- Navegación: GoRouter.
- Cliente HTTP: Dio.
- JWT en almacenamiento seguro: flutter_secure_storage.


## Script de validación rápida (backend + roles)
Ejecuta este script para validar que el backend responde correctamente a la app móvil por rol:

```bash
cd Movil
BASE_URL="http://<TU_IP>:8000/api/v1" SUPERADMIN_EMAIL="superadmin@ceos.local" SUPERADMIN_PASSWORD="..." ADMIN_EMAIL="admin@ceos.local" ADMIN_PASSWORD="..." INVENTARIO_EMAIL="inventario@ceos.local" INVENTARIO_PASSWORD="..." DOCTOR_EMAIL="doctor@ceos.local" DOCTOR_PASSWORD="..." RUN_WRITE_TESTS="0" ./scripts/validate_mobile_backend.sh
```

Si no tienes todas las credenciales, el script omite automáticamente el rol faltante.


Para pruebas de escritura (movimientos y solicitudes), activa:

```bash
RUN_WRITE_TESTS="1" TEST_MATERIAL_ID="1" TEST_SOLICITUD_MATERIAL_ID="1" ./scripts/validate_mobile_backend.sh
```
