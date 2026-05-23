#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python -m compileall app
python -m pytest -q

echo "✅ Backend static compile + tests OK"
