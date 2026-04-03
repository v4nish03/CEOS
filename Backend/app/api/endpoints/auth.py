from fastapi import APIRouter, Depends, HTTPException
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.auth import Token
from app.schemas.usuario import UsuarioLogin
from app.services.auth_service import AuthService

router = APIRouter(tags=["Auth"])


@router.post("/auth/login", response_model=Token)
@router.post("/login", response_model=Token)
def login(payload: UsuarioLogin, db: Session = Depends(get_db)):
    """Login público. No existe registro público en el sistema."""
    try:
        token, user = AuthService.login(db, payload.email, payload.password)
        return Token(access_token=token, rol=user.rol, nombre=user.nombre)
from app.schemas.usuario import UsuarioCreate, UsuarioLogin, UsuarioOut
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=UsuarioOut, status_code=status.HTTP_201_CREATED)
def register_user(payload: UsuarioCreate, db: Session = Depends(get_db)):
    """Ejemplo: registra un usuario con rol ADMIN/OPERADOR/SOLICITANTE."""
    try:
        return AuthService.register_user(db, payload)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc


@router.post("/login", response_model=Token)
def login(payload: UsuarioLogin, db: Session = Depends(get_db)):
    """Ejemplo: obtiene JWT enviando email y password."""
    try:
        token = AuthService.login(db, payload.email, payload.password)
        return Token(access_token=token)
    except ValueError as exc:
        raise HTTPException(status_code=401, detail=str(exc)) from exc
