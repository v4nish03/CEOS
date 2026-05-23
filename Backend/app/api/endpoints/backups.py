from datetime import datetime, timezone
from pathlib import Path
import shutil
import subprocess

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
        cmd = ["pg_dump", db_url, "-f", str(target)]
        try:
            subprocess.run(cmd, check=True, capture_output=True, text=True)
            return {"backup_file": str(target), "engine": "postgresql"}
        except FileNotFoundError:
            return {"detail": "pg_dump no disponible en entorno. Instalar cliente PostgreSQL."}
        except subprocess.CalledProcessError as exc:
            return {"detail": f"Error ejecutando pg_dump: {exc.stderr.strip()}"}

    return {"detail": "Motor de base de datos no soportado para backup automático."}
    if "sqlite:///" not in db_url:
        return {"detail": "Backup automático implementado solo para SQLite en este entorno."}

    db_file = Path(db_url.replace("sqlite:///", ""))
    backups_dir = db_file.parent / "backups"
    backups_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    target = backups_dir / f"ceos_backup_{stamp}.db"
    shutil.copy2(db_file, target)
    return {"backup_file": str(target)}
