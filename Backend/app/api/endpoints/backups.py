from datetime import datetime, timezone
from pathlib import Path
import os
import shutil
import subprocess
from urllib.parse import urlparse, unquote

from fastapi import APIRouter, Depends

from app.api.deps import require_roles
from app.core.config import get_settings
from app.models.enums import RoleEnum
from app.models.usuario import Usuario

router = APIRouter(prefix="/backups", tags=["Backups"])


@router.post("/database")
def backup_database(_: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN))):
    settings = get_settings()
    db_url = settings.database_url
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")

    if "sqlite:///" in db_url:
        db_file = Path(db_url.replace("sqlite:///", ""))
        backups_dir = db_file.parent / "backups"
        backups_dir.mkdir(parents=True, exist_ok=True)
        target = backups_dir / f"ceos_backup_{stamp}.db"
        shutil.copy2(db_file, target)
        return {"backup_file": str(target), "engine": "sqlite"}

    if db_url.startswith("postgresql"):
        backups_dir = Path("./backups")
        backups_dir.mkdir(parents=True, exist_ok=True)
        target = backups_dir / f"ceos_backup_{stamp}.sql"

        parsed = urlparse(db_url)
        db_name = parsed.path.lstrip("/")
        if not db_name:
            return {"detail": "DATABASE_URL inválida: falta nombre de base de datos."}

        cmd = [
            "pg_dump",
            "-h", parsed.hostname or "127.0.0.1",
            "-p", str(parsed.port or 5432),
            "-U", unquote(parsed.username or ""),
            "-d", db_name,
            "-f", str(target),
        ]

        env = os.environ.copy()
        if parsed.password:
            env["PGPASSWORD"] = unquote(parsed.password)

        try:
            subprocess.run(cmd, check=True, capture_output=True, text=True, env=env)
            return {"backup_file": str(target), "engine": "postgresql"}
        except FileNotFoundError:
            return {"detail": "pg_dump no disponible en entorno. Instalar cliente PostgreSQL."}
        except subprocess.CalledProcessError as exc:
            return {"detail": f"Error ejecutando pg_dump: {exc.stderr.strip()}"}

    return {"detail": "Motor de base de datos no soportado para backup automático."}
