"""
╔══════════════════════════════════════════════════════════════╗
║         app/core/config.py — Configuration centrale          ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Lit toutes les variables d'environnement du fichier .env
  et les rend disponibles partout dans l'application.

  Pydantic Settings valide automatiquement les types :
  si DATABASE_URL est absent → erreur claire au démarrage.
"""

from pydantic_settings import BaseSettings
from typing import List
import json


class Settings(BaseSettings):
    """
    Toutes les configurations de l'application.
    Pydantic lit automatiquement le fichier .env.
    """

    # ── Application ────────────────────────────────────────
    APP_NAME: str = "AfroLuo"
    APP_ENV: str = "development"
    DEBUG: bool = True

    # ── Base de données ────────────────────────────────────
    DATABASE_URL: str

    # ── JWT ────────────────────────────────────────────────
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 jours

    # ── CORS ───────────────────────────────────────────────
    ALLOWED_ORIGINS: List[str] = ["*"]

    # ── Upload fichiers ────────────────────────────────────
    UPLOAD_DIR: str = "uploads"
    MAX_AUDIO_SIZE_MB: int = 10

    # ── Pagination ─────────────────────────────────────────
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100

    # ── Email / Gmail SMTP ────────────────────────────────────
    MAIL_SERVER: str = "smtp.gmail.com"
    MAIL_PORT: int = 587
    MAIL_USERNAME: str = ""
    MAIL_PASSWORD: str = ""
    MAIL_FROM: str = ""
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""
    GOOGLE_REDIRECT_URI: str = "http://localhost:8000/api/v1/auth/google/callback"
    class Config:
        env_file = ".env"          # Fichier à lire
        env_file_encoding = "utf-8"
        case_sensitive = True


# Instance unique partagée dans tout le projet
# Usage : from app.core.config import settings
settings = Settings()
