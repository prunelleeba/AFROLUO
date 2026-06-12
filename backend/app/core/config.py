from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    APP_NAME: str = "AfroLuo"
    APP_ENV: str = "development"
    DEBUG: bool = True
    DATABASE_URL: str
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080
    ALLOWED_ORIGINS: List[str] = ["*"]
    UPLOAD_DIR: str = "uploads"
    MAX_AUDIO_SIZE_MB: int = 10
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100
    MAIL_SERVER: str = "smtp.gmail.com"
    MAIL_PORT: int = 587
    MAIL_USERNAME: str = ""
    MAIL_PASSWORD: str = ""
    MAIL_FROM: str = ""
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""
    GOOGLE_REDIRECT_URI: str = "http://localhost:8000/api/v1/auth/google/callback"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


settings = Settings()
