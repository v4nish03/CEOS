from datetime import datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base
from app.models.enums import EstadoSolicitudEnum


class SolicitudMaterial(Base):
    __tablename__ = "solicitudes_material"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    material_id: Mapped[int] = mapped_column(ForeignKey("materiales.id"), nullable=False)
    cantidad: Mapped[int] = mapped_column(Integer, nullable=False)
    motivo: Mapped[str | None] = mapped_column(String(255), nullable=True)
    estado: Mapped[EstadoSolicitudEnum] = mapped_column(
        Enum(EstadoSolicitudEnum), nullable=False, default=EstadoSolicitudEnum.PENDIENTE
    )
    solicitante_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id"), nullable=False)
    fecha_creacion: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    material = relationship("Material", back_populates="solicitudes")
    solicitante = relationship("Usuario", back_populates="solicitudes")
