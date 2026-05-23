from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.inventario import AlertaOut, MovimientoCreate, MovimientoOut
from app.services.inventario_service import InventarioService

router = APIRouter(prefix="/inventario", tags=["Inventario"])
legacy_router = APIRouter(tags=["Movements (legacy)"])


@router.post("/movimientos", response_model=MovimientoOut, status_code=status.HTTP_201_CREATED)
@legacy_router.post("/movements", response_model=MovimientoOut, status_code=status.HTTP_201_CREATED)
def registrar_movimiento(
    payload: MovimientoCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.INVENTARIO)),
):
    """Registra entrada/salida/ajuste y actualiza stock automáticamente."""
    try:
        return InventarioService.registrar_movimiento(
            db=db,
            material_id=payload.material_id,
            tipo=payload.tipo,
            cantidad=payload.cantidad,
            usuario_id=current_user.id,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("/movimientos", response_model=list[MovimientoOut])
def listar_movimientos(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.INVENTARIO)),
):
    """Consulta histórica de movimientos."""
    return InventarioService.listar_movimientos(db)


@router.get("/alertas", response_model=list[AlertaOut])
def listar_alertas(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.INVENTARIO)),
):
    """Alertas por stock bajo y materiales por vencer."""
    return InventarioService.obtener_alertas(db)
