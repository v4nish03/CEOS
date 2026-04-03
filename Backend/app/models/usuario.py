from sqlalchemy import Enum, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import RoleEnum


class Usuario(Base):
    __tablename__ = "usuarios"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    nombre: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    rol: Mapped[RoleEnum] = mapped_column(Enum(RoleEnum), nullable=False)

    movimientos = relationship("MovimientoInventario", back_populates="usuario")
    solicitudes = relationship("SolicitudMaterial", back_populates="solicitante")
