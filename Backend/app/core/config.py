from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    environment: str = "dev"

    project_name: str = "CEOS Inventory API"
    api_v1_prefix: str = "/api/v1"

    secret_key: str = "change-me-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    database_url: str = "postgresql+psycopg2://ceos:ceos@localhost:5432/ceos"

    # Días previos al vencimiento para emitir alerta
    expiration_alert_days: int = 30

    # Seeder inicial (solo backend)
    bootstrap_superadmin_email: str = "superadmin@ceos.com"
    bootstrap_superadmin_password: str = "ChangeMe123!"
    bootstrap_superadmin_name: str = "Super Admin"

    daily_report_hour_utc: int = 13
    daily_report_minute_utc: int = 0
    reports_output_dir: str = "./reports"

    # CORS para Flutter Web/desarrollo local. En producción, ajusta a dominios reales.
    cors_allow_origin_regex: str = r"https?://(localhost|127\.0\.0\.1|0\.0\.0\.0)(:\d+)?"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", case_sensitive=False)


@lru_cache
def get_settings() -> Settings:
    return Settings()
