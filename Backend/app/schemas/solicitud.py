from datetime import datetime

from pydantic import BaseModel, Field

from app.models.enums import EstadoSolicitudEnum


class SolicitudCreate(BaseModel):
    material_id: int
    cantidad: int = Field(gt=0)
    motivo: str | None = Field(default=None, max_length=255)


class SolicitudEstadoUpdate(BaseModel):
    estado: EstadoSolicitudEnum


class SolicitudOut(BaseModel):
    id: int
    material_id: int
    cantidad: int
    motivo: str | None
    estado: EstadoSolicitudEnum
    solicitante_id: int
    fecha_creacion: datetime

    model_config = {"from_attributes": True}
