from fastapi import FastAPI

from app.api.router import api_router
from app.core.config import get_settings
from app.database.base import Base
from app.database.session import engine
from app.models import material, movimiento, solicitud, usuario  # noqa: F401

settings = get_settings()

app = FastAPI(title=settings.project_name)
app.include_router(api_router, prefix=settings.api_v1_prefix)


@app.get("/")
def root():
    return {"message": "CEOS Inventory API running"}


# Para simplificar el arranque en entorno local sin migraciones.
Base.metadata.create_all(bind=engine)
