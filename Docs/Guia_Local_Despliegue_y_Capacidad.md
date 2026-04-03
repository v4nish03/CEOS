# CEOS · Guía local, despliegue gratuito y simulación de capacidad

> Fecha de elaboración: **2026-04-03**.


## 0) Limpieza de datos y carga sintética

- Se removió `Backend/test.db` del repositorio para evitar dejar datos persistidos versionados.
- Para poblar datos de prueba de forma controlada, usa:

```bash
cd Backend
python scripts/bulk_seed_estimate.py --materials 2000 --users 120 --movements 300000 --solicitudes 80000 --reset
```

El script imprime:
- cantidad de filas insertadas
- tamaño antes/después de la base
- delta de espacio
- densidad aproximada por cada 1,000 filas

## 1) Cómo ejecutar el backend en local (FastAPI)

### Requisitos
- Python 3.11+
- `pip`
- (Opcional) PostgreSQL local si no quieres SQLite

### Pasos
```bash
cd Backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Verificación
- API: `http://127.0.0.1:8000`
- Swagger: `http://127.0.0.1:8000/docs`

### Variables clave en `.env`
- `DATABASE_URL`
- `SECRET_KEY`
- `BOOTSTRAP_SUPERADMIN_EMAIL`
- `BOOTSTRAP_SUPERADMIN_PASSWORD`
- `BOOTSTRAP_SUPERADMIN_NAME`

> Importante: en este sistema **no existe registro público**. Solo hay login; los usuarios se crean desde endpoints internos por `ADMIN/SUPERADMIN`.

---

## 2) Cómo ejecutar la app móvil en local (Flutter)

## 2.1 En laptop (modo escritorio)

### Requisitos
- Flutter SDK 3.x
- Chrome o soporte desktop habilitado

### Pasos
```bash
cd Movil
flutter pub get
flutter run -d chrome
```

> También puedes usar Windows/Mac/Linux desktop si lo tienes habilitado:
```bash
flutter config --enable-windows-desktop
flutter run -d windows
```

## 2.2 En dispositivo Android físico

### Requisitos
- Activar **Opciones de desarrollador** y **Depuración USB**
- Instalar Android SDK + adb

### Pasos
```bash
adb devices
cd Movil
flutter pub get
flutter run -d <device_id>
```

## 2.3 Conexión móvil ↔ backend local

En `Movil/lib/core/constants/app_constants.dart`:
- Emulador Android: `http://10.0.2.2:8000/api/v1`
- Dispositivo físico: usar la IP LAN de tu laptop, por ejemplo:
  - `http://192.168.1.100:8000/api/v1`

Si usas dispositivo físico:
1. Asegura que celular y laptop estén en la misma red WiFi.
2. Permite el puerto 8000 en firewall.
3. Levanta backend con host de red:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

---

## 3) Simulación de carga de datos (resultado práctico)

Se ejecutó una simulación local en SQLite para estimar ocupación de almacenamiento.

### Dataset simulado
- Materiales: **2,000**
- Usuarios: **120**
- Movimientos inventario: **300,000**
- Solicitudes: **80,000**
- Total filas aproximadas: **382,120**

### Resultado de tamaño
- Archivo SQLite generado: **17.31 MB**

### Densidad estimada (aprox)
- **46.39 KB por cada 1,000 filas**
- Proyección lineal: **~45.3 MB por 1,000,000 de filas**

> Nota: en PostgreSQL real el tamaño puede variar por índices, TOAST, vacuum, WAL, retención y patrones de actualización.

---

## 4) ¿Dónde desplegar gratis backend + base de datos?

## Opción A (recomendada para iniciar): **Render + Neon**

- Backend FastAPI en Render (web service)
- PostgreSQL en Neon (free)

### Pros
- Flujo muy simple para FastAPI.
- PostgreSQL serverless en Neon con autoscaling.
- Separa compute API y compute DB.

### Contras
- Render free tiene limitaciones y posibles reinicios.
- Neon free tiene límite de almacenamiento y compute mensual.

---

## Opción B: **Railway (trial / bajo costo)**

### Pros
- Despliegue muy rápido desde GitHub.
- DX excelente para pruebas y demos.

### Contras
- El plan “free” suele operar como trial + créditos y luego costo mensual bajo.

---

## Opción C: **Supabase (DB) + Render (API)**

### Pros
- Supabase muy sólido para Postgres administrado.
- Buen panel y monitoreo básico.

### Contras
- Free plan con límites de tamaño de BD; para crecimiento real, migras a plan pago.

---

## 5) Comparativa rápida de servicios (free/trial)

> Valores sujetos a cambios por proveedor. Verifica siempre en sus páginas oficiales.

| Servicio | Tipo | Free/Trial reportado | Útil para CEOS | Riesgo principal |
|---|---|---|---|---|
| Render | Hosting backend | Instancias free con limitaciones, reinicios y sin garantías para prod | API demo y staging | cold starts/restarts |
| Neon | PostgreSQL | Free con ~0.5 GB por proyecto y cuota de compute mensual | DB de pruebas, MVP | límite de storage/compute |
| Supabase | PostgreSQL + extras | Free limitado por tamaño de DB | DB + panel en MVP | límite de tamaño en free |
| Railway | Hosting full-stack | Trial con créditos + costo mensual bajo luego | Demo temporal rápida | deja de ser “gratis” estable |
| Fly.io | Hosting | sin free tier general (según docs de costos) | producción low-cost | no es opción gratis pura |

---

## 6) Estimación de “cuánto dura” gratis según carga

Usando la simulación anterior: **1M filas ≈ 45.3 MB** (aprox lineal).

### Si tu free DB fuera de 0.5 GB (~512 MB)
- Capacidad teórica: `512 / 45.3 ≈ 11.3 millones de filas` (sin contar crecimiento extra de índices/WAL/retención)

### Escenarios prácticos
- Conservador (con sobrecosto por índices y operación): **5–8 millones de filas**
- Optimista (datos compactos y poco churn): **9–11 millones de filas**

### Horizonte temporal estimado
Depende de movimientos/día:
- 1,000 movimientos/día → ~365,000/año
- 5,000 movimientos/día → ~1.8M/año
- 10,000 movimientos/día → ~3.65M/año

Con free DB pequeña, un sistema activo puede requerir upgrade entre **6 y 24 meses** según uso y retención histórica.

---

## 7) Recomendación de despliegue para CEOS

1. **Fase inicial (0-3 meses):** Render + Neon (free)
2. **Fase MVP estable (3-12 meses):** mantener API en Render y mover DB a plan pago mínimo (Neon/Supabase)
3. **Fase productiva:** API con plan pago + DB con backups, métricas y alertas (SLA)

---

## 8) Checklist rápido de producción mínima

- [ ] Forzar `SECRET_KEY` robusta
- [ ] HTTPS obligatorio
- [ ] CORS restringido por dominios
- [ ] Backups automáticos (DB)
- [ ] Monitoreo de errores (Sentry)
- [ ] Retención/archivado de movimientos antiguos
- [ ] Rotación de credenciales y política de contraseñas

---

## 9) Fuentes oficiales recomendadas

- Render free instances: https://render.com/docs/free
- Railway pricing: https://railway.com/pricing
- Neon pricing: https://neon.com/pricing
- Supabase uso de tamaño/disco: https://supabase.com/docs/guides/platform/manage-your-usage/disk-size
- Supabase billing: https://supabase.com/docs/guides/platform/billing-on-supabase
- Fly.io cost management: https://fly.io/docs/about/cost-management/
