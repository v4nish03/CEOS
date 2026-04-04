from pydantic import BaseModel

from app.models.enums import RoleEnum


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    rol: RoleEnum
    nombre: str
