from datetime import datetime, timezone
from pathlib import Path
import shutil

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
    if "sqlite:///" not in db_url:
        return {"detail": "Backup automático implementado solo para SQLite en este entorno."}

    db_file = Path(db_url.replace("sqlite:///", ""))
    backups_dir = db_file.parent / "backups"
    backups_dir.mkdir(parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    target = backups_dir / f"ceos_backup_{stamp}.db"
    shutil.copy2(db_file, target)
    return {"backup_file": str(target)}
