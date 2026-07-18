from sqlalchemy.orm import Session

from app.models.enums import EstadoSolicitudEnum, TipoMovimientoEnum
from app.models.material import Material
from app.models.solicitud import SolicitudMaterial
from app.schemas.solicitud import SolicitudCreate
from app.services.inventario_service import InventarioService


class SolicitudService:
    @staticmethod
    def crear(db: Session, payload: SolicitudCreate, solicitante_id: int) -> SolicitudMaterial:
        material = db.get(Material, payload.material_id)
        if not material:
            raise ValueError("Material no encontrado")

        if payload.cantidad > material.stock_actual:
            raise ValueError("La cantidad solicitada supera el stock disponible")

        solicitud = SolicitudMaterial(
            material_id=payload.material_id,
            cantidad=payload.cantidad,
            motivo=payload.motivo,
            solicitante_id=solicitante_id,
        )
        db.add(solicitud)
        db.commit()
        db.refresh(solicitud)
        return solicitud

    @staticmethod
    def listar(db: Session, current_user=None) -> list[SolicitudMaterial]:
        query = db.query(SolicitudMaterial)
        if current_user and current_user.rol.value == "DOCTOR":
            query = query.filter(SolicitudMaterial.solicitante_id == current_user.id)
        return query.order_by(SolicitudMaterial.fecha_creacion.desc()).all()

    @staticmethod
    def cambiar_estado(
        db: Session,
        solicitud_id: int,
        estado: EstadoSolicitudEnum,
        aprobador_id: int,
    ) -> SolicitudMaterial:
        solicitud = db.get(SolicitudMaterial, solicitud_id)
        if not solicitud:
            raise ValueError("Solicitud no encontrada")

        if solicitud.estado != EstadoSolicitudEnum.PENDIENTE:
            raise ValueError("Solo se pueden procesar solicitudes pendientes")

        solicitud.estado = estado
        db.commit()
        db.refresh(solicitud)

        if estado == EstadoSolicitudEnum.APROBADA:
            InventarioService.registrar_movimiento(
                db=db,
                material_id=solicitud.material_id,
                tipo=TipoMovimientoEnum.SALIDA,
                cantidad=solicitud.cantidad,
                usuario_id=aprobador_id,
            )

        return solicitud
