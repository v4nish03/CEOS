#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python -m compileall app

if python -c "import pytest" >/dev/null 2>&1; then
  python -m pytest -q
else
  echo "⚠️ pytest no está instalado en este entorno."
  echo "Instálalo con: pip install pytest"
  echo "O instala dependencias completas: pip install -r requirements.txt"
fi

echo "✅ Backend static compile + tests script finalizado"
