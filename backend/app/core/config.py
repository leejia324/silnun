from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    database_url: str = "sqlite:///./silnun.db"
    firebase_credentials_path: str = "./firebase-service-account.json"


settings = Settings()
