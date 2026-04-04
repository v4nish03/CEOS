from datetime import date, timedelta

from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.enums import TipoMovimientoEnum
from app.models.material import Material
from app.models.movimiento import MovimientoInventario


class InventarioService:
    @staticmethod
    def registrar_movimiento(
        db: Session,
        material_id: int,
        tipo: TipoMovimientoEnum,
        cantidad: int,
        usuario_id: int,
    ) -> MovimientoInventario:
        material = db.get(Material, material_id)
        if not material:
            raise ValueError("Material no encontrado")

        # Operación crítica con transacción para garantizar consistencia del stock.
        with db.begin_nested():
            if tipo == TipoMovimientoEnum.ENTRADA:
                material.stock_actual += cantidad
            elif tipo == TipoMovimientoEnum.SALIDA:
                if material.stock_actual < cantidad:
                    raise ValueError("Stock insuficiente para realizar la salida")
                material.stock_actual -= cantidad
            else:  # ajuste
                new_stock = material.stock_actual + cantidad
                if new_stock < 0:
                    raise ValueError("El ajuste produce stock negativo")
                material.stock_actual = new_stock

            movimiento = MovimientoInventario(
                material_id=material_id,
                tipo=tipo,
                cantidad=cantidad,
                usuario_id=usuario_id,
            )
            db.add(movimiento)

        db.commit()
        db.refresh(movimiento)
        return movimiento

    @staticmethod
    def listar_movimientos(db: Session) -> list[MovimientoInventario]:
        return db.query(MovimientoInventario).order_by(MovimientoInventario.fecha.desc()).all()

    @staticmethod
    def obtener_alertas(db: Session) -> list[dict]:
        settings = get_settings()
        hoy = date.today()
        fecha_umbral = hoy + timedelta(days=settings.expiration_alert_days)

        alertas: list[dict] = []
        materiales = db.query(Material).all()

        for material in materiales:
            if material.stock_actual <= material.stock_minimo:
                alertas.append(
                    {
                        "tipo": "stock_bajo",
                        "material_id": material.id,
                        "material_nombre": material.nombre,
                        "detalle": f"Stock actual ({material.stock_actual}) <= stock mínimo ({material.stock_minimo})",
                    }
                )

            fecha_alerta = material.fecha_alerta_vencimiento or material.fecha_vencimiento
            if fecha_alerta and fecha_alerta <= fecha_umbral:
                alertas.append(
                    {
                        "tipo": "por_vencer",
                        "material_id": material.id,
                        "material_nombre": material.nombre,
                        "detalle": f"El material alerta vencimiento para {fecha_alerta.isoformat()}",
                    }
                )

        return alertas
