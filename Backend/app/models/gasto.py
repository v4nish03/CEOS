from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Numeric, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base


class Gasto(Base):
    __tablename__ = "gastos"

    id: Mapped[int] = mapped_column(primary_key=True, index=True)
    concepto: Mapped[str] = mapped_column(String(180), nullable=False)
    monto: Mapped[float] = mapped_column(Numeric(12, 2), nullable=False)
    descripcion: Mapped[str | None] = mapped_column(String(255), nullable=True)
    fecha: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    registrado_por_id: Mapped[int] = mapped_column(ForeignKey("usuarios.id"), nullable=False)

    registrado_por = relationship("Usuario")
