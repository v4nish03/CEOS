from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from datetime import datetime
from database.base import Base

class MovimientoInventario(Base):
    __tablename__ = "movimientos"

    id = Column(Integer, primary_key=True, index=True)
    material_id = Column(Integer, ForeignKey("materiales.id"))
    tipo = Column(String)  # entrada | salida
    cantidad = Column(Integer)
    fecha = Column(DateTime, default=datetime.utcnow)