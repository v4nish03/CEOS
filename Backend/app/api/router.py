from fastapi import APIRouter

from app.api.endpoints import auth, backups, gastos, inventario, materiales, reportes, solicitudes, usuarios

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(usuarios.router)
api_router.include_router(materiales.router)
api_router.include_router(materiales.legacy_router)
api_router.include_router(inventario.router)
api_router.include_router(inventario.legacy_router)
api_router.include_router(solicitudes.router)
api_router.include_router(reportes.router)
api_router.include_router(reportes.legacy_router)

api_router.include_router(gastos.router)
api_router.include_router(backups.router)
