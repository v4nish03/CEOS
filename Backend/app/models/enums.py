from enum import Enum


class RoleEnum(str, Enum):
    SUPERADMIN = "SUPERADMIN"
    ADMIN = "ADMIN"
    INVENTARIO = "INVENTARIO"
    DOCTOR = "DOCTOR"


class TipoMovimientoEnum(str, Enum):
    ENTRADA = "entrada"
    SALIDA = "salida"
    AJUSTE = "ajuste"


class EstadoSolicitudEnum(str, Enum):
    PENDIENTE = "pendiente"
    APROBADA = "aprobada"
    RECHAZADA = "rechazada"
