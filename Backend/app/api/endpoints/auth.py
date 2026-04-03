from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.schemas.auth import Token
from app.schemas.usuario import UsuarioLogin
from app.services.auth_service import AuthService

router = APIRouter(tags=["Auth"])


@router.post("/login", response_model=Token)
@router.post("/auth/login", response_model=Token)
def login(payload: UsuarioLogin, db: Session = Depends(get_db)):
    """Login público. No existe registro público en el sistema."""
    try:
        token, user = AuthService.login(db, payload.email, payload.password)
        return Token(access_token=token, rol=user.rol, nombre=user.nombre)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)) from exc
