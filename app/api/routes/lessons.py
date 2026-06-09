"""
╔══════════════════════════════════════════════════════════════╗
║       app/api/routes/lessons.py — Leçons                     ║
╚══════════════════════════════════════════════════════════════╝

ROUTES :
  GET /api/v1/lessons                → Liste paginée des contenus
  GET /api/v1/lessons/themes         → Tous les thèmes
  GET /api/v1/lessons/themes/{id}    → Contenus d'un thème
  GET /api/v1/lessons/{id}           → Détail d'un contenu
  POST /api/v1/lessons               → Créer un contenu (admin)
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from typing import Optional

from app.db.database import get_db
from app.models.models import Contenu, Theme, ThemeTraduction, ContenuTraduction, Langue
from app.schemas.schemas import (
    ContenuResponse, ContenuCreate, ThemeResponse,
    TraductionResponse, PaginatedResponse
)
from app.core.security import get_current_user, get_current_admin
from app.core.config import settings

router = APIRouter()


def build_audio_url(audio_fichier: Optional[str], base_url: str = "http://localhost:8000") -> Optional[str]:
    """Construit l'URL complète d'un fichier audio."""
    if not audio_fichier:
        return None
    return f"{base_url}/uploads/audio/{audio_fichier}"


def contenu_to_response(contenu: Contenu) -> ContenuResponse:
    """Convertit un objet Contenu SQLAlchemy en schéma de réponse."""
    traductions = []
    for t in (contenu.traductions or []):
        if t.langue:
            traductions.append(TraductionResponse(
                langue_code=t.langue.code,
                langue_nom=t.langue.nom,
                traduction=t.traduction,
                exemple=t.exemple
            ))

    return ContenuResponse(
        id=contenu.id,
        texte_source=contenu.texte_source,
        prononciation=contenu.prononciation,
        niveau=contenu.niveau,
        audio_url=build_audio_url(contenu.audio_fichier),
        theme_code=contenu.theme.code if contenu.theme else None,
        type_code=contenu.type_contenu.code if contenu.type_contenu else "inconnu",
        traductions=traductions
    )


@router.get(
    "/lessons/themes",
    response_model=list[ThemeResponse],
    summary="Liste des thèmes de leçons"
)
async def get_themes(
    langue_id: Optional[int] = Query(None, description="ID de langue pour les noms traduits"),
    db: AsyncSession = Depends(get_db)
):
    """
    Retourne tous les thèmes disponibles.

    Si `langue_id` est fourni, les noms des thèmes sont retournés
    dans cette langue (sinon le code brut est retourné).
    """
    result = await db.execute(
        select(Theme)
        .options(selectinload(Theme.traductions).selectinload(ThemeTraduction.langue))
        .order_by(Theme.ordre)
    )
    themes = result.scalars().all()

    response = []
    for theme in themes:
        nom_traduit = theme.code  # Valeur par défaut
        if langue_id:
            for trad in theme.traductions:
                if trad.langue_id == langue_id:
                    nom_traduit = trad.traduction
                    break
        response.append(ThemeResponse(
            id=theme.id,
            code=theme.code,
            ordre=theme.ordre,
            nom_traduit=nom_traduit
        ))

    return response


@router.get(
    "/lessons",
    response_model=PaginatedResponse,
    summary="Liste des leçons (mots/phrases)"
)
async def get_lessons(
    langue_id: int = Query(..., description="ID de la langue source (ex: 1 pour ewondo)"),
    theme_id: Optional[int] = Query(None, description="Filtrer par thème"),
    niveau: Optional[int] = Query(None, ge=1, le=3, description="Filtrer par niveau"),
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    db: AsyncSession = Depends(get_db),
    _user=Depends(get_current_user)
):
    """
    ## Liste des leçons

    Retourne les mots et phrases à apprendre avec leurs traductions.

    **Exemple Flutter :**
    ```
    GET /api/v1/lessons?langue_id=1&theme_id=3&page=1
    Authorization: Bearer <token>
    ```
    """
    # Construction de la requête de base
    query = (
        select(Contenu)
        .options(
            selectinload(Contenu.traductions).selectinload(ContenuTraduction.langue),
            selectinload(Contenu.theme),
            selectinload(Contenu.type_contenu)
        )
        .where(Contenu.langue_source_id == langue_id)
        .where(Contenu.actif == True)
    )

    if theme_id:
        query = query.where(Contenu.theme_id == theme_id)
    if niveau:
        query = query.where(Contenu.niveau == niveau)

    # Compter le total
    count_query = select(func.count()).select_from(
        query.subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Paginer
    offset = (page - 1) * page_size
    query = query.order_by(Contenu.ordre, Contenu.id).offset(offset).limit(page_size)

    result = await db.execute(query)
    contenus = result.scalars().all()

    return PaginatedResponse(
        total=total,
        page=page,
        page_size=page_size,
        total_pages=(total + page_size - 1) // page_size,
        items=[contenu_to_response(c) for c in contenus]
    )


@router.get(
    "/lessons/{lesson_id}",
    response_model=ContenuResponse,
    summary="Détail d'une leçon"
)
async def get_lesson(
    lesson_id: int,
    db: AsyncSession = Depends(get_db),
    _user=Depends(get_current_user)
):
    """Retourne les détails complets d'un contenu, avec toutes ses traductions."""
    result = await db.execute(
        select(Contenu)
        .options(
            selectinload(Contenu.traductions).selectinload(ContenuTraduction.langue),
            selectinload(Contenu.theme),
            selectinload(Contenu.type_contenu)
        )
        .where(Contenu.id == lesson_id)
    )
    contenu = result.scalar_one_or_none()

    if not contenu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Leçon {lesson_id} introuvable"
        )

    return contenu_to_response(contenu)


@router.post(
    "/lessons",
    response_model=ContenuResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Créer une leçon (admin)"
)
async def create_lesson(
    request: ContenuCreate,
    _admin=Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Crée un nouveau contenu. Réservé aux administrateurs."""
    contenu = Contenu(**request.model_dump())
    db.add(contenu)
    await db.flush()

    # Recharger avec les relations
    result = await db.execute(
        select(Contenu)
        .options(
            selectinload(Contenu.traductions).selectinload(ContenuTraduction.langue),
            selectinload(Contenu.theme),
            selectinload(Contenu.type_contenu)
        )
        .where(Contenu.id == contenu.id)
    )
    return contenu_to_response(result.scalar_one())
