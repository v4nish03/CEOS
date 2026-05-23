# Cómo probar el MVP backend

## 1) Levantar backend
```bash
cd Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 2) Ejecutar tests automáticos
```bash
cd Backend
bash scripts/run_backend_tests.sh
```

## 3) Ejecutar prueba end-to-end (smoke API)
Con el backend corriendo:
```bash
cd Backend
bash scripts/mvp_api_smoke.sh
```

Variables opcionales:
```bash
BASE_URL="http://127.0.0.1:8000/api/v1" SA_EMAIL="superadmin@ceos.com" SA_PASSWORD="ChangeMe123!" bash scripts/mvp_api_smoke.sh
```

## Qué valida el smoke
- Login
- Crear material
- Registrar movimiento de salida
- Crear gasto y consultar total
- Descargar PDF diario
- Ejecutar backup
- Consultar resumen de inventario
