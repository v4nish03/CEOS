#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/api/v1}"
SA_EMAIL="${SA_EMAIL:-superadmin@ceos.com}"
SA_PASSWORD="${SA_PASSWORD:-ChangeMe123!}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

json() { python - <<'PY' "$1"; import json,sys; print(json.loads(sys.argv[1])); PY; }

echo "[1/8] Login superadmin"
TOKEN=$(curl -sf -X POST "$BASE_URL/login" -H 'Content-Type: application/json' \
  -d "{\"email\":\"$SA_EMAIL\",\"password\":\"$SA_PASSWORD\"}" | python -c 'import sys,json; print(json.load(sys.stdin)["access_token"])')
AUTH=(-H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json')

echo "[2/8] Crear material"
MAT_ID=$(curl -sf -X POST "$BASE_URL/materiales" "${AUTH[@]}" \
  -d '{"nombre":"Guantes Nitrilo MVP","categoria":"Insumos","stock_minimo":5,"stock_actual":25}' | python -c 'import sys,json; print(json.load(sys.stdin)["id"])')

echo "[3/8] Registrar salida"
curl -sf -X POST "$BASE_URL/inventario/movimientos" "${AUTH[@]}" \
  -d "{\"material_id\":$MAT_ID,\"tipo\":\"salida\",\"cantidad\":2}" >/dev/null

echo "[4/8] Crear gasto"
curl -sf -X POST "$BASE_URL/gastos" "${AUTH[@]}" \
  -d '{"concepto":"Compra insumos MVP","monto":150.50,"descripcion":"Prueba smoke"}' >/dev/null

echo "[5/8] Consultar total gastos"
curl -sf "$BASE_URL/gastos/total" "${AUTH[@]}" > "$WORKDIR/gastos_total.json"
python - "$WORKDIR/gastos_total.json" <<'PY'
python - <<'PY' "$WORKDIR/gastos_total.json"
import json,sys
v=json.load(open(sys.argv[1]))
assert "total_gastado" in v
print("total_gastado=",v["total_gastado"])
PY

echo "[6/8] Descargar reporte diario PDF"
curl -sf "$BASE_URL/reportes/diario.pdf" "${AUTH[@]}" -o "$WORKDIR/reporte.pdf"
python - "$WORKDIR/reporte.pdf" <<'PY'
python - <<'PY' "$WORKDIR/reporte.pdf"
import sys
b=open(sys.argv[1],'rb').read(8)
assert b.startswith(b'%PDF-1.'), b
print('PDF OK')
PY

echo "[7/8] Ejecutar backup"
curl -sf -X POST "$BASE_URL/backups/database" "${AUTH[@]}" > "$WORKDIR/backup.json"
cat "$WORKDIR/backup.json"

echo "[8/8] Consultar resumen inventario"
curl -sf "$BASE_URL/reportes/resumen-inventario" "${AUTH[@]}" > "$WORKDIR/resumen.json"
cat "$WORKDIR/resumen.json"

echo "✅ Smoke MVP API finalizado OK"
