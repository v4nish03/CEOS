from pathlib import Path

from fastapi.responses import StreamingResponse
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.inventario import MovimientoOut
from app.schemas.reporte import MaterialMasUsadoOut, ResumenInventarioOut
from app.services.inventario_service import InventarioService
from app.services.report_export_service import ReportExportService
from app.services.reporte_service import ReporteService

router = APIRouter(prefix="/reportes", tags=["Reportes"])
legacy_router = APIRouter(tags=["Reports (legacy)"])


@router.get("/movimientos", response_model=list[MovimientoOut])
def reporte_movimientos(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    """Reporte detallado de movimientos de inventario."""
    return InventarioService.listar_movimientos(db)


@router.get("/materiales-mas-usados", response_model=list[MaterialMasUsadoOut])
@legacy_router.get("/reports", response_model=list[MaterialMasUsadoOut])
def reporte_materiales_mas_usados(
    limit: int = 10,
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    """Ranking de materiales con mayor salida."""
    return ReporteService.materiales_mas_usados(db, limit=limit)


@router.get("/resumen-inventario", response_model=ResumenInventarioOut)
def resumen_inventario(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    """Resumen global de inventario."""
    return ReporteService.resumen_inventario(db)


@router.get("/diario.pdf")
def reporte_diario_pdf(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    pdf_data = ReportExportService.generar_reporte_diario_pdf(db)
    output = Path("./reports")
    output.mkdir(parents=True, exist_ok=True)
    (output / "reporte_diario_latest.pdf").write_bytes(pdf_data)
    return StreamingResponse(iter([pdf_data]), media_type="application/pdf", headers={"Content-Disposition": "attachment; filename=reporte_diario.pdf"})
