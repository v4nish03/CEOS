from datetime import date

from sqlalchemy import Date, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base


class Material(Base):
    __tablename__ = "materiales"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    nombre: Mapped[str] = mapped_column(String(120), unique=True, index=True, nullable=False)
    categoria: Mapped[str] = mapped_column(String(120), nullable=False)
    stock_actual: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    stock_minimo: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    fecha_vencimiento: Mapped[date | None] = mapped_column(Date, nullable=True)
    fecha_alerta_vencimiento: Mapped[date | None] = mapped_column(Date, nullable=True)

    movimientos = relationship("MovimientoInventario", back_populates="material")
    solicitudes = relationship("SolicitudMaterial", back_populates="material")
