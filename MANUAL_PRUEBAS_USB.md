# Manual de pruebas por USB (MVP CEOS)

## 1) Levantar PostgreSQL en Docker
```bash
cd Backend
docker compose -f docker-compose.postgres.yml up -d
docker compose -f docker-compose.postgres.yml ps
```

## 2) Levantar backend
```bash
cd Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 3) Crear usuarios de prueba
```bash
curl -X POST http://127.0.0.1:8000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@ceos.com","password":"password"}'
# copiar access_token
TOKEN="<ACCESS_TOKEN>"

curl -X POST http://127.0.0.1:8000/api/v1/usuarios \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nombre":"Admin Demo","email":"admin@ceos.com","password":"Admin12345","rol":"ADMIN"}'

curl -X POST http://127.0.0.1:8000/api/v1/usuarios \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nombre":"Inventario Demo","email":"inventario@ceos.com","password":"Inventario123","rol":"INVENTARIO"}'

curl -X POST http://127.0.0.1:8000/api/v1/usuarios \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nombre":"Doctor Demo","email":"doctor@ceos.com","password":"Doctor12345","rol":"DOCTOR"}'
```

## 4) Crear material base (obligatorio para pruebas de escritura)
```bash
curl -X POST http://127.0.0.1:8000/api/v1/materiales \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"nombre":"Guantes Nitrilo","categoria":"Insumos","stock_minimo":5,"stock_actual":20,"fecha_vencimiento":null,"fecha_alerta_vencimiento":null}'

curl -s -X GET http://127.0.0.1:8000/api/v1/materiales \
  -H "Authorization: Bearer $TOKEN"
```

## 5) Probar script por roles
### 5.1 Solo lectura
```bash
cd Movil
BASE_URL="http://127.0.0.1:8000/api/v1" \
SUPERADMIN_EMAIL="superadmin@ceos.com" SUPERADMIN_PASSWORD="password" \
ADMIN_EMAIL="admin@ceos.com" ADMIN_PASSWORD="Admin12345" \
INVENTARIO_EMAIL="inventario@ceos.com" INVENTARIO_PASSWORD="Inventario123" \
DOCTOR_EMAIL="doctor@ceos.com" DOCTOR_PASSWORD="Doctor12345" \
RUN_WRITE_TESTS="0" \
./scripts/validate_mobile_backend.sh
```

### 5.2 Lectura + escritura
```bash
cd Movil
BASE_URL="http://127.0.0.1:8000/api/v1" \
SUPERADMIN_EMAIL="superadmin@ceos.com" SUPERADMIN_PASSWORD="password" \
ADMIN_EMAIL="admin@ceos.com" ADMIN_PASSWORD="Admin12345" \
INVENTARIO_EMAIL="inventario@ceos.com" INVENTARIO_PASSWORD="Inventario123" \
DOCTOR_EMAIL="doctor@ceos.com" DOCTOR_PASSWORD="Doctor12345" \
RUN_WRITE_TESTS="1" \
TEST_MATERIAL_ID="1" \
TEST_SOLICITUD_MATERIAL_ID="1" \
TEST_MOVIMIENTO_CANTIDAD="1" \
TEST_SOLICITUD_CANTIDAD="1" \
./scripts/validate_mobile_backend.sh
```

## 6) Ejecutar app Android por USB
1. Verificar dispositivo:
```bash
adb devices
flutter devices
```
2. En `Movil/lib/core/constants/app_constants.dart` usar IP de tu PC, no `127.0.0.1` para celular real.
3. Ejecutar:
```bash
cd Movil
flutter clean
flutter pub get
flutter run -d 76818f5a
```


### Opción recomendada para USB (sin depender de WiFi): adb reverse

Antes de correr Flutter, enlaza el puerto del teléfono al puerto local de tu PC:

```bash
adb reverse tcp:8000 tcp:8000
```

Luego ejecuta la app usando localhost en el teléfono mediante `--dart-define`:

```bash
cd Movil
flutter run -d 76818f5a --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1
```

Con esto, el móvil conectado por USB consume tu backend local aunque no uses IP LAN.

## 7) Errores comunes
- `Material no encontrado`: usa un `TEST_MATERIAL_ID` que exista.
- `401`: credenciales/token incorrectos.
- `403`: permiso del rol (esperado en varios casos).
- `flutter run` con errores de archivos faltantes (`session_storage.dart`, `dashboard_view.dart`, `UserEntity.token`, `migratory`): tu copia local está desfasada.

### Limpieza de rama/caché cuando el build está roto
```bash
cd ~/Ceos
git checkout main
git pull origin main

cd Movil
flutter clean
rm -rf .dart_tool build pubspec.lock
flutter pub get
flutter run -d 76818f5a
```
