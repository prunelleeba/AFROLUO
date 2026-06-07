"""
╔══════════════════════════════════════════════════════════════╗
║       app/db/database.py — Connexion PostgreSQL              ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Crée le « pont » entre Python et PostgreSQL.
  
  Vocabulaire à comprendre :
  - Engine     : la connexion physique à PostgreSQL
  - Session    : une conversation temporaire avec la BDD
                 (comme ouvrir/fermer un onglet dans pgAdmin)
  - Base       : la classe parente de tous nos modèles SQLAlchemy
  - get_db()   : une "dépendance" FastAPI → ouvre une session par requête
"""

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import DeclarativeBase
from app.core.config import settings


# ─────────────────────────────────────────────
# MOTEUR ASYNCHONE
# Utilise asyncpg (driver PostgreSQL rapide et async)
# pool_size : nb de connexions maintenues ouvertes en permanence
# max_overflow : connexions supplémentaires si la pool est pleine
# ─────────────────────────────────────────────
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=settings.DEBUG,    # Si True : affiche les requêtes SQL dans le terminal
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,     # Vérifie que la connexion est vivante avant usage
)

# ─────────────────────────────────────────────
# SESSION FACTORY
# Crée des sessions à la demande
# ─────────────────────────────────────────────
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,  # Les objets restent utilisables après commit
    autocommit=False,
    autoflush=False,
)


# ─────────────────────────────────────────────
# BASE DES MODÈLES
# Tous nos modèles (Utilisateur, Contenu, etc.)
# héritent de cette classe
# ─────────────────────────────────────────────
class Base(DeclarativeBase):
    pass


# ─────────────────────────────────────────────
# DÉPENDANCE FastAPI : get_db()
# Utilisée dans chaque route qui a besoin de la BDD
#
# Exemple d'utilisation dans une route :
#   async def ma_route(db: AsyncSession = Depends(get_db)):
#       result = await db.execute(select(Utilisateur))
#
# FastAPI ouvre une session → exécute la route → ferme la session
# Le "finally" garantit que la session est TOUJOURS fermée
# ─────────────────────────────────────────────
async def get_db():
    """Générateur de session de base de données."""
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()   # Valide les changements si tout s'est bien passé
        except Exception:
            await session.rollback() # Annule tout si une erreur survient
            raise
        finally:
            await session.close()    # Ferme la session dans tous les cas
