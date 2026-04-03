from fastapi import APIRouter, Depends, HTTPException, status
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.usuario import UsuarioCreateByAdmin, UsuarioOut
from app.services.auth_service import AuthService
from app.schemas.usuario import UsuarioOut

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@router.get("/me", response_model=UsuarioOut)
def get_me(current_user: Usuario = Depends(require_roles(*list(RoleEnum)))):
    return current_user


@router.post("", response_model=UsuarioOut, status_code=status.HTTP_201_CREATED)
def create_user(
    payload: UsuarioCreateByAdmin,
    db: Session = Depends(get_db),
    actor: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN)),
):
    """Creación de usuarios SOLO por SUPERADMIN/ADMIN desde sistema interno."""
    try:
        return AuthService.create_user_by_admin(db, payload, actor)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("", response_model=list[UsuarioOut])
def list_users(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN)),
):
def get_me(current_user: Usuario = Depends(require_roles(RoleEnum.ADMIN, RoleEnum.OPERADOR, RoleEnum.SOLICITANTE))):
    """Ejemplo: devuelve datos del usuario autenticado."""
    return current_user


@router.get("", response_model=list[UsuarioOut])
def list_users(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.ADMIN)),
):
    """Ejemplo: listado de usuarios (solo ADMIN, visualización)."""
    return db.query(Usuario).order_by(Usuario.id.asc()).all()
