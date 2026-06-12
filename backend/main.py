from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import logging

from app.core.config import settings
from app.db.database import engine, Base
from app.api.routes import auth, users, languages, lessons, quiz, progress, audio
from app.api.routes import google_auth, password_reset

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("AfroLuo Backend started!")
    logger.info("Documentation: http://localhost:8000/docs")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield
    logger.info("AfroLuo Backend stopped.")


app = FastAPI(
    title="AfroLuo API",
    description="Backend pour l'apprentissage des langues africaines",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(auth.router,           prefix="/api/v1", tags=["Auth"])
app.include_router(users.router,          prefix="/api/v1", tags=["Users"])
app.include_router(languages.router,      prefix="/api/v1", tags=["Languages"])
app.include_router(lessons.router,        prefix="/api/v1", tags=["Lessons"])
app.include_router(quiz.router,           prefix="/api/v1", tags=["Quiz"])
app.include_router(progress.router,       prefix="/api/v1", tags=["Progress"])
app.include_router(audio.router,          prefix="/api/v1", tags=["Audio"])
app.include_router(google_auth.router,    tags=["Google Auth"])
app.include_router(password_reset.router, prefix="/api/v1", tags=["Password Reset"])


@app.get("/", tags=["Health"])
async def root():
    return {
        "status": "ok",
        "message": "AfroLuo API is running",
        "version": "1.0.0",
        "docs": "/docs"
    }


@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy"}
