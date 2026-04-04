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
- `DATABASE_URL`
- `SECRET_KEY`
- `BOOTSTRAP_SUPERADMIN_EMAIL`
- `BOOTSTRAP_SUPERADMIN_PASSWORD`
- `BOOTSTRAP_SUPERADMIN_NAME`

## Ejecutar
```bash
cd Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```


## Carga masiva sintética y estimación de espacio

```bash
cd Backend
python scripts/bulk_seed_estimate.py --materials 500 --users 40 --movements 50000 --solicitudes 10000 --reset
```

El script sirve para poblar datos de prueba según cantidad y reporta espacio usado en la base.
