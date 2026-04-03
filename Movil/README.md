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
