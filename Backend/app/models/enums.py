from enum import Enum


class RoleEnum(str, Enum):
    ADMIN = "ADMIN"
    OPERADOR = "OPERADOR"
    SOLICITANTE = "SOLICITANTE"


class TipoMovimientoEnum(str, Enum):
    ENTRADA = "entrada"
    SALIDA = "salida"
    AJUSTE = "ajuste"


class EstadoSolicitudEnum(str, Enum):
    PENDIENTE = "pendiente"
    APROBADA = "aprobada"
    RECHAZADA = "rechazada"
