from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.solicitud import SolicitudCreate, SolicitudEstadoUpdate, SolicitudOut
from app.services.solicitud_service import SolicitudService

router = APIRouter(prefix="/solicitudes", tags=["Solicitudes"])


@router.post("", response_model=SolicitudOut)
def crear_solicitud(
    payload: SolicitudCreate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(require_roles(RoleEnum.DOCTOR)),
):
    """Un DOCTOR crea una solicitud de material."""
    try:
        return SolicitudService.crear(db, payload, solicitante_id=current_user.id)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.get("", response_model=list[SolicitudOut])
def listar_solicitudes(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    """Listado de solicitudes para revisión (INVENTARIO/ADMIN)."""
    return SolicitudService.listar(db)


@router.patch("/{solicitud_id}/estado", response_model=SolicitudOut)
def cambiar_estado_solicitud(
    solicitud_id: int,
    payload: SolicitudEstadoUpdate,
    db: Session = Depends(get_db),
    current_user: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO)),
):
    """INVENTARIO/ADMIN aprueba o rechaza una solicitud."""
    try:
        return SolicitudService.cambiar_estado(
            db,
            solicitud_id=solicitud_id,
            estado=payload.estado,
            aprobador_id=current_user.id,
        )
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
