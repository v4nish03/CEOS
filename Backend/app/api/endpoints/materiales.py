from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import require_roles
from app.database.session import get_db
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.material import MaterialCreate, MaterialOut, MaterialUpdate
from app.services.material_service import MaterialService

router = APIRouter(prefix="/materiales", tags=["Materiales"])
legacy_router = APIRouter(tags=["Materials (legacy)"])


@router.post("", response_model=MaterialOut, status_code=status.HTTP_201_CREATED)
@legacy_router.post("/materials", response_model=MaterialOut, status_code=status.HTTP_201_CREATED)
def create_material(
    payload: MaterialCreate,
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.INVENTARIO)),
):
    try:
        return MaterialService.create(db, payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.get("", response_model=list[MaterialOut])
@legacy_router.get("/materials", response_model=list[MaterialOut])
def list_materiales(
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.SUPERADMIN, RoleEnum.ADMIN, RoleEnum.INVENTARIO, RoleEnum.DOCTOR)),
):
    return MaterialService.list_all(db)


@router.put("/{material_id}", response_model=MaterialOut)
def update_material(
    material_id: int,
    payload: MaterialUpdate,
    db: Session = Depends(get_db),
    _: Usuario = Depends(require_roles(RoleEnum.INVENTARIO)),
):
    try:
        return MaterialService.update(db, material_id, payload)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
