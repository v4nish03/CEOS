from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.security import create_access_token, get_password_hash, verify_password
from app.models.enums import RoleEnum
from app.models.usuario import Usuario
from app.schemas.usuario import UsuarioCreateByAdmin


class AuthService:
    @staticmethod
    def ensure_superadmin(db: Session) -> None:
        settings = get_settings()
        existing = db.query(Usuario).filter(Usuario.email == settings.bootstrap_superadmin_email).first()
        if existing:
            return

        user = Usuario(
            nombre=settings.bootstrap_superadmin_name,
            email=settings.bootstrap_superadmin_email,
            hashed_password=get_password_hash(settings.bootstrap_superadmin_password),
            rol=RoleEnum.SUPERADMIN,
        )
        db.add(user)
        db.commit()

    @staticmethod
    def create_user_by_admin(db: Session, payload: UsuarioCreateByAdmin, actor: Usuario) -> Usuario:
        if actor.rol not in {RoleEnum.SUPERADMIN, RoleEnum.ADMIN}:
            raise ValueError("No autorizado para crear usuarios")
        if actor.rol == RoleEnum.ADMIN and payload.rol == RoleEnum.SUPERADMIN:
            raise ValueError("ADMIN no puede crear SUPERADMIN")

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
    def login(db: Session, email: str, password: str) -> tuple[str, Usuario]:
        user = db.query(Usuario).filter(Usuario.email == email).first()
        if not user or not verify_password(password, user.hashed_password):
            raise ValueError("Credenciales inválidas")
        token = create_access_token(subject=user.id, extra_claims={"role": user.rol.value, "name": user.nombre})
        return token, user
