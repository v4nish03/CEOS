from datetime import datetime

from pydantic import BaseModel, Field

from app.models.enums import TipoMovimientoEnum


class MovimientoCreate(BaseModel):
    material_id: int
    tipo: TipoMovimientoEnum
    cantidad: int = Field(gt=0)


class MovimientoOut(BaseModel):
    id: int
    material_id: int
    tipo: TipoMovimientoEnum
    cantidad: int
    fecha: datetime
    usuario_id: int

    model_config = {"from_attributes": True}


class AlertaOut(BaseModel):
    tipo: str
    material_id: int
    material_nombre: str
    detalle: str
