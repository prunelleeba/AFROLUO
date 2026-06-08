"""
╔══════════════════════════════════════════════════════════════╗
║           AfroLuo Backend — Point d'entrée principal         ║
║   Ce fichier démarre le serveur FastAPI                      ║
╚══════════════════════════════════════════════════════════════╝

RÔLE DE CE FICHIER :
  C'est la « porte d'entrée » de toute l'application.
  Quand tu tapes `uvicorn main:app`, Python cherche
  l'objet `app` dans ce fichier.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import logging

from app.core.config import settings
from app.db.database import engine, Base
from app.api.routes import auth, users, languages, lessons, quiz, progress, audio, password_reset, google_auth


# ─────────────────────────────────────────────
# LOGGING — pour voir ce qui se passe dans le terminal
# ─────────────────────────────────────────────
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# ─────────────────────────────────────────────
# LIFESPAN — code qui tourne au démarrage / à l'arrêt
# ─────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    """Exécuté au démarrage du serveur."""
    logger.info("🚀 AfroLuo Backend démarré !")
    logger.info(f"📖 Documentation : http://localhost:8000/docs")
    # Crée les tables si elles n'existent pas encore
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    logger.info("👋 AfroLuo Backend arrêté.")


# ─────────────────────────────────────────────
# CRÉATION DE L'APPLICATION FASTAPI
# ─────────────────────────────────────────────
app = FastAPI(
    title="AfroLuo API",
    description="""
    ## 🌍 Backend pour l'apprentissage des langues africaines

    AfroLuo permet d'apprendre l'**ewondo**, le **douala**, le **bassa** et
    d'autres langues camerounaises via une application mobile Flutter.

    ### Fonctionnalités :
    - 🔐 Authentification JWT (register / login)
    - 📚 Leçons par thème et par langue
    - 🧠 Quiz interactifs
    - 📈 Suivi de progression (algorithme de répétition espacée)
    - 🔊 Gestion des fichiers audio de prononciation
    """,
    version="1.0.0",
    docs_url="/docs",        # Swagger UI → http://localhost:8000/docs
    redoc_url="/redoc",      # ReDoc UI  → http://localhost:8000/redoc
    lifespan=lifespan,
)

# ─────────────────────────────────────────────
# CORS — permet à Flutter de parler à cette API
# Sans ça, Flutter serait bloqué par le navigateur !
# ─────────────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,  # En prod : ton domaine exact
    allow_credentials=True,
    allow_methods=["*"],   # GET, POST, PUT, DELETE, etc.
    allow_headers=["*"],   # Authorization, Content-Type, etc.
)

# ─────────────────────────────────────────────
# FICHIERS STATIQUES — pour servir les MP3 / images
# URL d'accès : http://localhost:8000/uploads/audio/fichier.mp3
# ─────────────────────────────────────────────
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# ─────────────────────────────────────────────
# ROUTES — enregistrement de tous les endpoints
# Chaque "router" est un groupe d'endpoints liés
# ─────────────────────────────────────────────
app.include_router(auth.router,      prefix="/api/v1", tags=["🔐 Auth"])
app.include_router(users.router,     prefix="/api/v1", tags=["👤 Users"])
app.include_router(languages.router, prefix="/api/v1", tags=["🌍 Languages"])
app.include_router(lessons.router,   prefix="/api/v1", tags=["📚 Lessons"])
app.include_router(quiz.router,      prefix="/api/v1", tags=["🧠 Quiz"])
app.include_router(progress.router,  prefix="/api/v1", tags=["📈 Progress"])
app.include_router(audio.router,     prefix="/api/v1", tags=["🔊 Audio"])
app.include_router(password_reset.router, tags=["🔑 Password Reset"])
app.include_router(google_auth.router)


# ─────────────────────────────────────────────
# ROUTE DE SANTÉ — pour vérifier que l'API est vivante
# ─────────────────────────────────────────────
@app.get("/", tags=["🏥 Health"])
async def root():
    """Vérification que le serveur tourne."""
    return {
        "status": "ok",
        "message": "AfroLuo API is running 🌍",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health", tags=["🏥 Health"])
async def health_check():
    """Endpoint de santé pour Docker / monitoring."""
    return {"status": "healthy"}
