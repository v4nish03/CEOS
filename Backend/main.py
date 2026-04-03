from fastapi import FastAPI
from database.base import Base
from database.session import engine
from routers import material
from routers import movimiento





app = FastAPI()
app.include_router(material.router)
app.include_router(movimiento.router)
Base.metadata.create_all(bind=engine)