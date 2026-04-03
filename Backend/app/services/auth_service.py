from sqlalchemy.orm import Session

from app.core.security import create_access_token, get_password_hash, verify_password
from app.models.usuario import Usuario
from app.schemas.usuario import UsuarioCreate


class AuthService:
    @staticmethod
    def register_user(db: Session, payload: UsuarioCreate) -> Usuario:
        exists = db.query(Usuario).filter(Usuario.email == payload.email).first()
        if exists:
            raise ValueError("Ya existe un usuario con ese email")

        user = Usuario(
            nombre=payload.nombre,
            email=payload.email,
            hashed_password=get_password_hash(payload.password),
            rol=payload.rol,
        )
        db.add(user)
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def login(db: Session, email: str, password: str) -> str:
        user = db.query(Usuario).filter(Usuario.email == email).first()
        if not user or not verify_password(password, user.hashed_password):
            raise ValueError("Credenciales inválidas")
        return create_access_token(subject=user.id)
