from datetime import date

from pydantic import BaseModel, Field


class MaterialBase(BaseModel):
    nombre: str = Field(min_length=2, max_length=120)
    categoria: str = Field(min_length=2, max_length=120)
    stock_minimo: int = Field(ge=0)
    fecha_vencimiento: date | None = None
    fecha_alerta_vencimiento: date | None = None


class MaterialCreate(MaterialBase):
    stock_actual: int = Field(ge=0, default=0)


class MaterialUpdate(BaseModel):
    nombre: str | None = Field(default=None, min_length=2, max_length=120)
    categoria: str | None = Field(default=None, min_length=2, max_length=120)
    stock_minimo: int | None = Field(default=None, ge=0)
    fecha_vencimiento: date | None = None
    fecha_alerta_vencimiento: date | None = None


class MaterialOut(MaterialBase):
    id: int
    stock_actual: int

    model_config = {"from_attributes": True}
