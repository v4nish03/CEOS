from sqlalchemy.orm import Session

from app.models.material import Material
from app.schemas.material import MaterialCreate, MaterialUpdate


class MaterialService:
    @staticmethod
    def create(db: Session, payload: MaterialCreate) -> Material:
        existing = db.query(Material).filter(Material.nombre == payload.nombre).first()
        if existing:
            raise ValueError("Ya existe un material con ese nombre")

        material = Material(**payload.model_dump())
        db.add(material)
        db.commit()
        db.refresh(material)
        return material

    @staticmethod
    def list_all(db: Session) -> list[Material]:
        return db.query(Material).order_by(Material.nombre.asc()).all()

    @staticmethod
    def get_by_id(db: Session, material_id: int) -> Material:
        material = db.get(Material, material_id)
        if not material:
            raise ValueError("Material no encontrado")
        return material

    @staticmethod
    def update(db: Session, material_id: int, payload: MaterialUpdate) -> Material:
        material = MaterialService.get_by_id(db, material_id)
        updates = payload.model_dump(exclude_unset=True)
        for key, value in updates.items():
            setattr(material, key, value)
        db.commit()
        db.refresh(material)
        return material
