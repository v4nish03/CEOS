# Estructura de trabajo móvil (reinicio)

Este documento define **cómo trabajar la app móvil desde cero** manteniendo la estructura actual de carpetas.

## 1) Regla general por feature

Cada módulo vive dentro de `lib/features/<feature>/` y se divide así:

- `presentation/`: UI (pantallas, widgets, providers de estado de pantalla).
- `domain/`: reglas de negocio puras (entidades, contratos/repositorios, casos de uso).
- `data/`: implementación técnica (modelos, datasource HTTP/local, repositorios concretos).

Flujo recomendado:

1. Definir entidades y contratos en `domain/`.
2. Definir caso de uso en `domain/usecases/`.
3. Implementar repositorio y datasource en `data/`.
4. Conectar en `presentation/providers/`.
5. Construir pantalla y widgets en `presentation/screens|widgets/`.

## 2) Qué entra en cada carpeta raíz de `lib/`

### `lib/core/`
Código transversal, reutilizable por todo el proyecto:

- `constants/`: constantes globales (URLs, claves, timeouts).
- `network/`: cliente Dio, interceptores, manejo base de errores.
- `router/`: rutas globales de la app.
- `storage/`: secure storage/shared preferences.
- `theme/`: tema, tipografías, colores.
- `widgets/`: widgets genéricos no atados a una feature.

### `lib/features/`
Módulos funcionales de negocio (`auth`, `dashboard`, `inventory`, etc.).

## 3) Criterios para mantener orden

- No poner lógica de negocio dentro de widgets.
- `presentation/` no debe hablar directo con `dio`; usa casos de uso o repositorios del dominio.
- Modelos `data/models/` convierten JSON ↔ entidades de `domain/entities/`.
- Cada feature debe poder entenderse sin leer otras features (bajo acoplamiento).
- Si algo se reutiliza en 2+ features, moverlo a `core/`.

## 4) Convención mínima recomendada

- `*_screen.dart`: pantallas principales.
- `*_provider.dart`: estado Riverpod para la pantalla.
- `*_entity.dart`: entidad de dominio.
- `*_repository.dart`: contrato de dominio.
- `*_repository_impl.dart`: implementación concreta en data.
- `*_remote_datasource.dart`: llamadas API.
- `*_usecase.dart`: caso de uso único y testeable.

## 5) Plan sugerido para reactivar vistas

1. Empezar por `auth` (login + sesión).
2. Activar `dashboard` con datos mínimos.
3. Activar `inventory` (listar + movimientos).
4. Activar `users` y `reports` al final.

Mientras tanto, los archivos de pantallas actuales están como placeholders para mantener compilación y estructura.
