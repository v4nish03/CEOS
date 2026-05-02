# CEOS - Backend FastAPI

API para gestión de inventario de clínica dental.

## Cambios clave de seguridad
- **No hay registro público**.
- Los usuarios se crean únicamente desde `POST /api/v1/usuarios` por `SUPERADMIN` o `ADMIN`.
- El `SUPERADMIN` inicial se crea automáticamente en backend al iniciar (seed con variables `.env`).

## Roles
- `SUPERADMIN`
- `ADMIN`
- `INVENTARIO`
- `DOCTOR`

## Endpoints principales
- `POST /api/v1/login` (alias: `/api/v1/auth/login`)
- `GET /api/v1/usuarios/me`
- `POST /api/v1/usuarios` (solo ADMIN/SUPERADMIN)
- `GET /api/v1/materiales` (alias: `/api/v1/materials`)
- `POST /api/v1/inventario/movimientos` (alias: `/api/v1/movements`)
- `GET /api/v1/reportes/materiales-mas-usados` (alias: `/api/v1/reports`)

## Variables de entorno
Revisa `.env`:
- `DATABASE_URL` (default PostgreSQL local)
- `SECRET_KEY`
- `BOOTSTRAP_SUPERADMIN_EMAIL`
- `BOOTSTRAP_SUPERADMIN_PASSWORD`
- `BOOTSTRAP_SUPERADMIN_NAME`

## PostgreSQL local (recomendado)

### Opción A: Docker Compose
```bash
cd Backend
docker compose -f docker-compose.postgres.yml up -d
```

Cadena de conexión esperada:
`postgresql+psycopg2://ceos:ceos@localhost:5432/ceos`

### Opción B: PostgreSQL instalado localmente
1. Crear base de datos `ceos`.
2. Crear usuario `ceos` con permisos.
3. Ajustar `DATABASE_URL` en `.env`.

## Ejecutar backend
```bash
cd Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## Verificación rápida
- Swagger: `http://127.0.0.1:8000/docs`
- Login: `POST /api/v1/login`
- El superadmin inicial se crea al arrancar (`BOOTSTRAP_SUPERADMIN_*`).

## Integración con app móvil
1. Ajustar `Movil/lib/core/constants/app_constants.dart` con la IP LAN del backend (ej: `http://192.168.0.10:8000/api/v1`).
2. Ejecutar script de validación por rol:
```bash
cd Movil
BASE_URL="http://<IP_PC>:8000/api/v1" RUN_WRITE_TESTS="0" ./scripts/validate_mobile_backend.sh
```
3. Si quieres validar escrituras:
```bash
RUN_WRITE_TESTS="1" TEST_MATERIAL_ID="1" TEST_SOLICITUD_MATERIAL_ID="1" ./scripts/validate_mobile_backend.sh
```

## Qué falta para MVP de presentación
1. **Datos demo consistentes**: usuarios por rol, 20-50 materiales, movimientos y solicitudes de ejemplo.
2. **Checklist de demo**: login por rol + flujo principal por cada rol (doctor solicita, inventario procesa, admin reporta).
3. **Hardening mínimo**:
   - `SECRET_KEY` fuerte y no default.
   - Contraseñas demo seguras.
   - CORS restringido al frontend móvil/web que presentes.
4. **Observabilidad básica**:
   - logging de errores en backend.
   - respaldo DB (dump simple antes de demo).
5. **Plan B offline demo**:
   - export SQL/backup para restaurar rápido.
   - script de seed para rearmar datos en minutos.

## Carga masiva sintética y estimación de espacio
```bash
cd Backend
python scripts/bulk_seed_estimate.py --materials 500 --users 40 --movements 50000 --solicitudes 10000 --reset
```

El script sirve para poblar datos de prueba según cantidad y reporta espacio usado en la base.
