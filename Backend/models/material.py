from sqlalchemy import Column, Integer, String
from database.base import Base

class Material(Base):
    __tablename__ = "materiales"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True)
    stock = Column(Integer, default=0)
    stock_minimo = Column(Integer, default=5)