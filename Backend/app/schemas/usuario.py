from pydantic import BaseModel, EmailStr, Field

from app.models.enums import RoleEnum


class UsuarioCreate(BaseModel):
    nombre: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(min_length=6, max_length=128)
    rol: RoleEnum


class UsuarioOut(BaseModel):
    id: int
    nombre: str
    email: EmailStr
    rol: RoleEnum

    model_config = {"from_attributes": True}


class UsuarioLogin(BaseModel):
    email: EmailStr
    password: str
