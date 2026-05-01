#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8000/api/v1}"

# Credenciales opcionales por rol
SUPERADMIN_EMAIL="${SUPERADMIN_EMAIL:-}"
SUPERADMIN_PASSWORD="${SUPERADMIN_PASSWORD:-}"
ADMIN_EMAIL="${ADMIN_EMAIL:-}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-}"
INVENTARIO_EMAIL="${INVENTARIO_EMAIL:-}"
INVENTARIO_PASSWORD="${INVENTARIO_PASSWORD:-}"
DOCTOR_EMAIL="${DOCTOR_EMAIL:-}"
DOCTOR_PASSWORD="${DOCTOR_PASSWORD:-}"

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

extract_token() {
  python -c 'import json,sys; print(json.load(sys.stdin)["access_token"])'
}

extract_role() {
  python -c 'import json,sys; print(json.load(sys.stdin)["rol"])'
}

call_get() {
  local token="$1"
  local path="$2"
  curl "${CURL_OPTS[@]}" -X GET "${BASE_URL}${path}" -H "Authorization: Bearer ${token}" >/dev/null
}

expect_ok() {
  local token="$1"
  local path="$2"
  say "200 esperado: GET ${path}"
  call_get "$token" "$path"
}

expect_forbidden() {
  local token="$1"
  local path="$2"
  say "403 esperado: GET ${path}"
  local code
  code=$(curl --silent -o /tmp/resp.$$ -w "%{http_code}" -X GET "${BASE_URL}${path}" -H "Authorization: Bearer ${token}")
  if [[ "$code" != "403" ]]; then
    echo "Esperaba 403 en ${path}, recibí ${code}" >&2
    cat /tmp/resp.$$ >&2 || true
    rm -f /tmp/resp.$$
    exit 1
  fi
  rm -f /tmp/resp.$$
}

run_for_role() {
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
  expect_ok "$token" "/usuarios/me"
  expect_ok "$token" "/materiales"

  case "$role" in
    SUPERADMIN|ADMIN)
      expect_ok "$token" "/usuarios"
      expect_ok "$token" "/reportes/resumen-inventario"
      expect_ok "$token" "/inventario/alertas"
      ;;
    INVENTARIO)
      expect_forbidden "$token" "/usuarios"
      expect_ok "$token" "/reportes/resumen-inventario"
      expect_ok "$token" "/inventario/alertas"
      ;;
    DOCTOR)
      expect_forbidden "$token" "/usuarios"
      expect_forbidden "$token" "/reportes/resumen-inventario"
      expect_forbidden "$token" "/inventario/alertas"
      ;;
    *)
      warn "Rol no contemplado: ${role}"
      ;;
  esac

  say "OK ${role_name}"
}

say "Validando backend para app móvil en ${BASE_URL}"

run_for_role "SUPERADMIN" "$SUPERADMIN_EMAIL" "$SUPERADMIN_PASSWORD"
run_for_role "ADMIN" "$ADMIN_EMAIL" "$ADMIN_PASSWORD"
run_for_role "INVENTARIO" "$INVENTARIO_EMAIL" "$INVENTARIO_PASSWORD"
run_for_role "DOCTOR" "$DOCTOR_EMAIL" "$DOCTOR_PASSWORD"

say "Validación completada ✅"
