from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.gasto import GastoCreate, GastoOut
from app.services.gasto_service import GastoService

router = APIRouter(prefix="/gastos", tags=["Gastos"])


@router.post("", response_model=GastoOut, status_code=status.HTTP_201_CREATED)
def crear_gasto(
    payload: GastoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.INVENTARIO)),
):
    return GastoService.crear(db, payload, user_id=current_user.id)


@router.get("", response_model=list[GastoOut])
def listar_gastos(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    return GastoService.listar(db)


@router.get("/total")
def total_gastos(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    return {"total_gastado": GastoService.total(db)}
