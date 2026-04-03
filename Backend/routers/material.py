from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database.session import SessionLocal
from models.material import Material

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/material")
def crear_material(nombre: str, stock: int, db: Session = Depends(get_db)):
    material = Material(nombre=nombre, stock=stock)
    db.add(material)
    db.commit()
    db.refresh(material)
    return material

@router.get("/material")
def listar_materiales(db: Session = Depends(get_db)):
    return db.query(Material).all()