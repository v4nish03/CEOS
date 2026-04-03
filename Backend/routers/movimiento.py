from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database.session import SessionLocal
from models.material import Material
from models.movimiento import MovimientoInventario

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/entrada")
def registrar_entrada(material_id: int, cantidad: int, db: Session = Depends(get_db)):
    material = db.query(Material).filter(Material.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Material no encontrado")

    material.stock += cantidad

    movimiento = MovimientoInventario(
        material_id=material_id,
        tipo="entrada",
        cantidad=cantidad
    )

    db.add(movimiento)
    db.commit()

    return {"msg": "Entrada registrada"}


@router.post("/salida")
def registrar_salida(material_id: int, cantidad: int, db: Session = Depends(get_db)):
    material = db.query(Material).filter(Material.id == material_id).first()

    if not material:
        raise HTTPException(status_code=404, detail="Material no encontrado")

    if material.stock < cantidad:
        raise HTTPException(status_code=400, detail="Stock insuficiente")

    material.stock -= cantidad

    movimiento = MovimientoInventario(
        material_id=material_id,
        tipo="salida",
        cantidad=cantidad
    )

    db.add(movimiento)
    db.commit()

    return {"msg": "Salida registrada"}