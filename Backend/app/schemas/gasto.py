from datetime import datetime

from pydantic import BaseModel, Field


class GastoCreate(BaseModel):
    concepto: str = Field(min_length=2, max_length=180)
    monto: float = Field(gt=0)
    descripcion: str | None = Field(default=None, max_length=255)


class GastoOut(BaseModel):
    id: int
    concepto: str
    monto: float
    descripcion: str | None
    fecha: datetime
    registrado_por_id: int

    model_config = {"from_attributes": True}
