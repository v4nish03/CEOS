#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/api/v1}"
RUN_WRITE_TESTS="${RUN_WRITE_TESTS:-0}"

# Credenciales opcionales por rol
SUPERADMIN_EMAIL="${SUPERADMIN_EMAIL:-}"
SUPERADMIN_PASSWORD="${SUPERADMIN_PASSWORD:-}"
ADMIN_EMAIL="${ADMIN_EMAIL:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
INVENTARIO_EMAIL="${INVENTARIO_EMAIL:-}"
INVENTARIO_PASSWORD="${INVENTARIO_PASSWORD:-}"
DOCTOR_EMAIL="${DOCTOR_EMAIL:-}"
DOCTOR_PASSWORD="${DOCTOR_PASSWORD:-}"

# Datos de prueba para endpoints de escritura (solo se usan si RUN_WRITE_TESTS=1)
TEST_MATERIAL_ID="${TEST_MATERIAL_ID:-}"
TEST_SOLICITUD_MATERIAL_ID="${TEST_SOLICITUD_MATERIAL_ID:-}"
TEST_MOVIMIENTO_CANTIDAD="${TEST_MOVIMIENTO_CANTIDAD:-1}"
TEST_SOLICITUD_CANTIDAD="${TEST_SOLICITUD_CANTIDAD:-1}"

CURL_OPTS=(--silent --show-error --fail-with-body)

say() { printf "\n[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }
warn() { printf "\n[WARN] %s\n" "$*"; }

login() {
  local email="$1"
  local pass="$2"
  curl "${CURL_OPTS[@]}" -X POST "${BASE_URL}/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${email}\",\"password\":\"${pass}\"}"
}

extract_token() { python -c 'import json,sys; print(json.load(sys.stdin)["access_token"])'; }
extract_role() { python -c 'import json,sys; print(json.load(sys.stdin)["rol"])'; }
extract_id() { python -c 'import json,sys; print((json.load(sys.stdin).get("id") or ""))'; }

call_get_code() {
  local token="$1"
  local path="$2"
  curl --silent -o /tmp/resp.$$ -w "%{http_code}" -X GET "${BASE_URL}${path}" -H "Authorization: Bearer ${token}"
}

expect_get_code() {
  local token="$1"
  local path="$2"
  local expected="$3"
  say "${expected} esperado: GET ${path}"
  local code
  code=$(call_get_code "$token" "$path")
  if [[ "$code" != "$expected" ]]; then
    echo "Esperaba ${expected} en GET ${path}, recibí ${code}" >&2
    cat /tmp/resp.$$ >&2 || true
    rm -f /tmp/resp.$$
    exit 1
  fi
  rm -f /tmp/resp.$$
}

expect_post_code() {
  local token="$1"
  local path="$2"
  local payload="$3"
  local expected="$4"
  say "${expected} esperado: POST ${path}"
  local code
  code=$(curl --silent -o /tmp/resp.$$ -w "%{http_code}" -X POST "${BASE_URL}${path}" \
    -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -d "$payload")
  if [[ "$code" != "$expected" ]]; then
    echo "Esperaba ${expected} en POST ${path}, recibí ${code}" >&2
    cat /tmp/resp.$$ >&2 || true
    rm -f /tmp/resp.$$
    exit 1
  fi
  rm -f /tmp/resp.$$
}

expect_patch_code() {
  local token="$1"
  local path="$2"
  local payload="$3"
  local expected="$4"
  say "${expected} esperado: PATCH ${path}"
  local code
  code=$(curl --silent -o /tmp/resp.$$ -w "%{http_code}" -X PATCH "${BASE_URL}${path}" \
    -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -d "$payload")
  if [[ "$code" != "$expected" ]]; then
    echo "Esperaba ${expected} en PATCH ${path}, recibí ${code}" >&2
    cat /tmp/resp.$$ >&2 || true
    rm -f /tmp/resp.$$
    exit 1
  fi
  rm -f /tmp/resp.$$
}

create_solicitud_and_get_id() {
  local token="$1"
  local material_id="$2"
  local cantidad="$3"
  local payload="{\"material_id\":${material_id},\"cantidad\":${cantidad},\"motivo\":\"Prueba móvil automatizada\"}"

  local body
  body=$(curl "${CURL_OPTS[@]}" -X POST "${BASE_URL}/solicitudes" \
    -H "Authorization: Bearer ${token}" -H "Content-Type: application/json" -d "$payload")
  printf '%s' "$body" | extract_id
}

run_common_read_tests() {
  local token="$1"
  expect_get_code "$token" "/usuarios/me" "200"
  expect_get_code "$token" "/materiales" "200"
}

run_write_tests_superadmin_admin_inventario() {
  local token="$1"
  local role="$2"

  if [[ -z "$TEST_MATERIAL_ID" ]]; then
    warn "RUN_WRITE_TESTS=1 pero falta TEST_MATERIAL_ID. Se omiten POST /inventario/movimientos para ${role}."
  else
    expect_post_code "$token" "/inventario/movimientos" "{\"material_id\":${TEST_MATERIAL_ID},\"tipo\":\"entrada\",\"cantidad\":${TEST_MOVIMIENTO_CANTIDAD}}" "201"
    expect_post_code "$token" "/inventario/movimientos" "{\"material_id\":${TEST_MATERIAL_ID},\"tipo\":\"salida\",\"cantidad\":${TEST_MOVIMIENTO_CANTIDAD}}" "201"
  fi
}

run_role_tests() {
  local role_name="$1"
  local email="$2"
  local pass="$3"

  if [[ -z "$email" || -z "$pass" ]]; then
    warn "Saltando ${role_name}: faltan credenciales (${role_name}_EMAIL / ${role_name}_PASSWORD)."
    return
  fi

  say "Login ${role_name} (${email})"
  local payload token role
  payload=$(login "$email" "$pass")
  token=$(printf '%s' "$payload" | extract_token)
  role=$(printf '%s' "$payload" | extract_role)

  say "Rol devuelto por backend: ${role}"
  run_common_read_tests "$token"

  case "$role" in
    SUPERADMIN|ADMIN)
      expect_get_code "$token" "/usuarios" "200"
      expect_get_code "$token" "/reportes/resumen-inventario" "200"
      expect_get_code "$token" "/reportes/materiales-mas-usados" "200"
      expect_get_code "$token" "/inventario/alertas" "200"
      expect_get_code "$token" "/inventario/movimientos" "200"
      expect_get_code "$token" "/solicitudes" "200"

      if [[ "$RUN_WRITE_TESTS" == "1" ]]; then
        run_write_tests_superadmin_admin_inventario "$token" "$role"
      fi
      ;;

    INVENTARIO)
      expect_get_code "$token" "/usuarios" "403"
      expect_get_code "$token" "/reportes/resumen-inventario" "200"
      expect_get_code "$token" "/reportes/materiales-mas-usados" "200"
      expect_get_code "$token" "/inventario/alertas" "200"
      expect_get_code "$token" "/inventario/movimientos" "200"
      expect_get_code "$token" "/solicitudes" "200"

      if [[ "$RUN_WRITE_TESTS" == "1" ]]; then
        run_write_tests_superadmin_admin_inventario "$token" "$role"
      fi
      ;;

    DOCTOR)
      expect_get_code "$token" "/usuarios" "403"
      expect_get_code "$token" "/reportes/resumen-inventario" "403"
      expect_get_code "$token" "/reportes/materiales-mas-usados" "403"
      expect_get_code "$token" "/inventario/alertas" "403"
      expect_get_code "$token" "/inventario/movimientos" "403"
      expect_get_code "$token" "/solicitudes" "403"

      if [[ "$RUN_WRITE_TESTS" == "1" ]]; then
        if [[ -z "$TEST_SOLICITUD_MATERIAL_ID" ]]; then
          warn "RUN_WRITE_TESTS=1 pero falta TEST_SOLICITUD_MATERIAL_ID. Se omite POST /solicitudes para DOCTOR."
        else
          local solicitud_id
          solicitud_id=$(create_solicitud_and_get_id "$token" "$TEST_SOLICITUD_MATERIAL_ID" "$TEST_SOLICITUD_CANTIDAD")
          say "Solicitud creada por DOCTOR con ID=${solicitud_id}"
        fi
      fi
      ;;

    *)
      warn "Rol no contemplado: ${role}"
      ;;
  esac

  say "OK ${role_name}"
}

say "Validando backend para app móvil en ${BASE_URL}"
say "RUN_WRITE_TESTS=${RUN_WRITE_TESTS}"

run_role_tests "SUPERADMIN" "$SUPERADMIN_EMAIL" "$SUPERADMIN_PASSWORD"
run_role_tests "ADMIN" "$ADMIN_EMAIL" "$ADMIN_PASSWORD"
run_role_tests "INVENTARIO" "$INVENTARIO_EMAIL" "$INVENTARIO_PASSWORD"
run_role_tests "DOCTOR" "$DOCTOR_EMAIL" "$DOCTOR_PASSWORD"

if [[ "$RUN_WRITE_TESTS" == "1" ]]; then
  warn "Se ejecutaron pruebas de escritura. Revisa datos generados (movimientos/solicitudes)."
fi

say "Validación completada ✅"
