from pydantic import BaseModel


class MaterialMasUsadoOut(BaseModel):
    material_id: int
    material_nombre: str
    total_salida: int


class ResumenInventarioOut(BaseModel):
    total_materiales: int
    stock_total_unidades: int
    materiales_stock_bajo: int
