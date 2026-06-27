from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import get_settings
from app.database.base import Base
from app.database.session import SessionLocal, engine
from app.models import gasto, material, movimiento, solicitud, usuario  # noqa: F401
from app.services.auth_service import AuthService
from app.services.scheduler_service import SchedulerService

settings = get_settings()

app = FastAPI(title=settings.project_name)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=settings.cors_allow_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.api_v1_prefix)


@app.on_event("startup")
def startup_event() -> None:
    # Crea tablas y garantiza que exista el SUPERADMIN inicial.
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        AuthService.ensure_superadmin(db)
    finally:
        db.close()

    SchedulerService.start(
        hour=settings.daily_report_hour_utc,
        minute=settings.daily_report_minute_utc,
        output_dir=settings.reports_output_dir,
    )


@app.get("/")
def root():
    return {"message": "CEOS Inventory API running"}


@app.on_event("shutdown")
def shutdown_event() -> None:
    SchedulerService.shutdown()
