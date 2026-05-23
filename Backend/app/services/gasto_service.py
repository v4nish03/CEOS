from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.gasto import Gasto
from app.schemas.gasto import GastoCreate


class GastoService:
    @staticmethod
    def crear(db: Session, payload: GastoCreate, user_id: int) -> Gasto:
        gasto = Gasto(
            concepto=payload.concepto,
            monto=payload.monto,
            descripcion=payload.descripcion,
            registrado_por_id=user_id,
        )
        db.add(gasto)
        db.commit()
        db.refresh(gasto)
        return gasto

    @staticmethod
    def listar(db: Session) -> list[Gasto]:
        return db.query(Gasto).order_by(Gasto.fecha.desc()).all()

    @staticmethod
    def total(db: Session) -> float:
        return float(db.query(func.coalesce(func.sum(Gasto.monto), 0)).scalar() or 0)
