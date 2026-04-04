from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.enums import TipoMovimientoEnum
from app.models.material import Material
from app.models.movimiento import MovimientoInventario


class ReporteService:
    @staticmethod
    def materiales_mas_usados(db: Session, limit: int = 10) -> list[dict]:
        rows = (
            db.query(
                MovimientoInventario.material_id,
                Material.nombre,
                func.sum(MovimientoInventario.cantidad).label("total_salida"),
            )
            .join(Material, Material.id == MovimientoInventario.material_id)
            .filter(MovimientoInventario.tipo == TipoMovimientoEnum.SALIDA)
            .group_by(MovimientoInventario.material_id, Material.nombre)
            .order_by(func.sum(MovimientoInventario.cantidad).desc())
            .limit(limit)
            .all()
        )

        return [
            {
                "material_id": row.material_id,
                "material_nombre": row.nombre,
                "total_salida": int(row.total_salida or 0),
            }
            for row in rows
        ]

    @staticmethod
    def resumen_inventario(db: Session) -> dict:
        total_materiales = db.query(func.count(Material.id)).scalar() or 0
        stock_total = db.query(func.coalesce(func.sum(Material.stock_actual), 0)).scalar() or 0
        stock_bajo = db.query(func.count(Material.id)).filter(Material.stock_actual <= Material.stock_minimo).scalar() or 0

        return {
            "total_materiales": int(total_materiales),
            "stock_total_unidades": int(stock_total),
            "materiales_stock_bajo": int(stock_bajo),
        }
