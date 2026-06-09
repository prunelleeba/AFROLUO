"""
╔══════════════════════════════════════════════════════════════╗
║       app/api/routes/languages.py — Langues disponibles      ║
╚══════════════════════════════════════════════════════════════╝

ROUTES :
  GET  /api/v1/languages      → Liste toutes les langues
  GET  /api/v1/languages/{id} → Détails d'une langue
  POST /api/v1/languages      → Ajouter une langue (admin)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.db.database import get_db
from app.models.models import Langue
from app.schemas.schemas import LangueResponse, LangueCreate
from app.core.security import get_current_user, get_current_admin

router = APIRouter()


@router.get(
    "/languages",
    response_model=list[LangueResponse],
    summary="Liste des langues disponibles"
)
async def get_languages(db: AsyncSession = Depends(get_db)):
    """
    Retourne toutes les langues disponibles.

    **Public** — pas besoin d'être connecté.
    Utilisé par Flutter pour remplir le sélecteur de langue à l'inscription.
    """
    result = await db.execute(select(Langue).order_by(Langue.nom))
    return result.scalars().all()


@router.get(
    "/languages/{language_id}",
    response_model=LangueResponse,
    summary="Détails d'une langue"
)
async def get_language(
    language_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Retourne les détails d'une langue par son ID."""
    langue = await db.get(Langue, language_id)
    if not langue:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Langue {language_id} introuvable"
        )
    return langue


@router.post(
    "/languages",
    response_model=LangueResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Ajouter une nouvelle langue (admin)"
)
async def create_language(
    request: LangueCreate,
    _admin=Depends(get_current_admin),   # Seuls les admins peuvent ajouter
    db: AsyncSession = Depends(get_db)
):
    """Crée une nouvelle langue. Réservé aux administrateurs."""
    # Vérifier l'unicité du code
    existing = await db.execute(
        select(Langue).where(Langue.code == request.code)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Une langue avec le code '{request.code}' existe déjà"
        )

    langue = Langue(code=request.code, nom=request.nom)
    db.add(langue)
    await db.flush()
    return langue
