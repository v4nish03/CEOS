from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.inventario import MovimientoOut
from app.schemas.reporte import MaterialMasUsadoOut, ResumenInventarioOut
from app.services.inventario_service import InventarioService
from app.services.reporte_service import ReporteService

router = APIRouter(prefix="/reportes", tags=["Reportes"])
legacy_router = APIRouter(tags=["Reports (legacy)"])


@router.get("/movimientos", response_model=list[MovimientoOut])
def reporte_movimientos(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    _: Usuario = Depends(require_roles(RoleEnum.ADMIN, RoleEnum.OPERADOR)),
):
    """Ejemplo: reporte detallado de movimientos de inventario."""
    return InventarioService.listar_movimientos(db)


@router.get("/materiales-mas-usados", response_model=list[MaterialMasUsadoOut])
@legacy_router.get("/reports", response_model=list[MaterialMasUsadoOut])
def reporte_materiales_mas_usados(
    limit: int = 10,
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
def reporte_materiales_mas_usados(
    limit: int = 10,
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.ADMIN, RoleEnum.OPERADOR)),
):
    """Ejemplo: ranking de materiales con mayor salida."""
    return ReporteService.materiales_mas_usados(db, limit=limit)


@router.get("/resumen-inventario", response_model=ResumenInventarioOut)
def resumen_inventario(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    _: Usuario = Depends(require_roles(RoleEnum.ADMIN, RoleEnum.OPERADOR)),
):
    """Ejemplo: resumen global de inventario."""
    return ReporteService.resumen_inventario(db)
