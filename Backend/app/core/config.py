from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    project_name: str = "CEOS Inventory API"
    api_v1_prefix: str = "/api/v1"

    secret_key: str = "change-me-in-production"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    database_url: str = "sqlite:///./ceos.db"
    expiration_alert_days: int = 30

    # Seeder inicial (solo backend)
    bootstrap_superadmin_email: str = "superadmin@ceos.local"
    bootstrap_superadmin_password: str = "ChangeMe123!"
    bootstrap_superadmin_name: str = "Super Admin"

    # Días previos al vencimiento para alertar
    expiration_alert_days: int = 30

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", case_sensitive=False)


@lru_cache
def get_settings() -> Settings:
    return Settings()
