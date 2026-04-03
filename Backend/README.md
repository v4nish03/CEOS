# CEOS - Backend de Inventario para Clínica Dental

Backend completo con **FastAPI + SQLAlchemy + JWT**, organizado por capas para escalar y mantener.

## Arquitectura

```text
Backend/
├── app/
│   ├── main.py
│   ├── core/            # Configuración y seguridad
│   ├── database/        # Engine, sesiones y base declarativa
│   ├── models/          # Entidades SQLAlchemy
│   ├── schemas/         # DTOs Pydantic
│   ├── services/        # Lógica de negocio
│   ├── api/
│   │   ├── deps.py      # Inyección de dependencias + control de roles
│   │   ├── router.py
│   │   └── endpoints/   # Routers por dominio
│   ├── utils/
│   └── integrations/
├── requirements.txt
└── .env
```

## Funcionalidades implementadas

- Usuarios y roles (ADMIN, OPERADOR, SOLICITANTE)
- Registro/Login con JWT
- Inventario:
  - creación/edición de materiales
  - movimientos (entrada/salida/ajuste)
  - validación de stock y bloqueo de stock negativo
- Alertas:
  - stock bajo
  - productos por vencer
- Solicitudes de material:
  - creación por SOLICITANTE
  - aprobación/rechazo por OPERADOR
- Reportes:
  - movimientos
  - materiales más usados
  - resumen de inventario

## Requisitos

- Python 3.11+
- PostgreSQL (opcional para producción)
- SQLite (incluido para desarrollo)

## Instalación y ejecución

1. Entrar a carpeta backend:

```bash
cd Backend
```

2. Crear y activar entorno virtual:

```bash
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# .venv\Scripts\activate  # Windows
```

3. Instalar dependencias:

```bash
pip install -r requirements.txt
```

4. Configurar variables de entorno en `.env` (ya viene ejemplo).

5. Levantar servidor:

```bash
uvicorn app.main:app --reload
```

6. Documentación interactiva:
- Swagger UI: `http://127.0.0.1:8000/docs`
- ReDoc: `http://127.0.0.1:8000/redoc`

## Endpoints principales (ejemplos)

### Auth
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`

### Usuarios
- `GET /api/v1/usuarios/me`
- `GET /api/v1/usuarios` (solo ADMIN)

### Materiales
- `POST /api/v1/materiales` (OPERADOR)
- `GET /api/v1/materiales` (todos autenticados)
- `PUT /api/v1/materiales/{material_id}` (OPERADOR)

### Inventario
- `POST /api/v1/inventario/movimientos` (OPERADOR)
- `GET /api/v1/inventario/movimientos` (ADMIN/OPERADOR)
- `GET /api/v1/inventario/alertas` (ADMIN/OPERADOR)

### Solicitudes
- `POST /api/v1/solicitudes` (SOLICITANTE)
- `GET /api/v1/solicitudes` (ADMIN/OPERADOR)
- `PATCH /api/v1/solicitudes/{id}/estado` (OPERADOR)

### Reportes
- `GET /api/v1/reportes/movimientos`
- `GET /api/v1/reportes/materiales-mas-usados?limit=10`
- `GET /api/v1/reportes/resumen-inventario`

## Notas de seguridad

- Contraseñas hasheadas con bcrypt (`passlib`)
- JWT Bearer para autenticación
- Protección por roles con dependencias (`Depends`)

## Próximos pasos recomendados

- Añadir migraciones con Alembic
- Añadir tests (pytest)
- Agregar logging estructurado y observabilidad
- Separar configuración por entornos (dev/staging/prod)
