"""
╔══════════════════════════════════════════════════════════════╗
║       app/api/routes/progress.py — Progression               ║
╚══════════════════════════════════════════════════════════════╝

ROUTES :
  GET  /api/v1/progress         → Ma progression complète
  GET  /api/v1/progress/stats   → Mes statistiques
  GET  /api/v1/progress/review  → Mots à réviser aujourd'hui
  POST /api/v1/progress/update  → Mettre à jour après une réponse
"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from typing import Optional
from datetime import date

from app.db.database import get_db
from app.models.models import Progression, Contenu, SessionApprentissage, Utilisateur
from app.schemas.schemas import (
    ProgressionResponse, ProgressionUpdateRequest, StatsUtilisateur
)
from app.core.security import get_current_user

router = APIRouter()


@router.get(
    "/progress",
    response_model=list[ProgressionResponse],
    summary="Ma progression complète"
)
async def get_my_progress(
    langue_id: Optional[int] = Query(None),
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retourne la progression de l'utilisateur pour chaque mot appris.

    Inclut le taux de maîtrise calculé :
    `maitrise = bonnes / (bonnes + mauvaises) * 100`
    """
    query = (
        select(Progression)
        .options(selectinload(Progression.contenu))
        .where(Progression.utilisateur_id == current_user.id)
        .order_by(Progression.updated_at.desc())
    )

    if langue_id:
        query = query.join(Contenu).where(Contenu.langue_source_id == langue_id)

    result = await db.execute(query)
    progressions = result.scalars().all()

    return [
        ProgressionResponse(
            contenu_id=p.contenu_id,
            texte_source=p.contenu.texte_source if p.contenu else "",
            nb_bonnes_reponses=p.nb_bonnes_reponses,
            nb_mauvaises_reponses=p.nb_mauvaises_reponses,
            derniere_vue=p.derniere_vue,
            prochaine_revision=p.prochaine_revision,
            intervalle_jours=p.intervalle_jours,
            maitrise_pourcent=round(
                p.nb_bonnes_reponses / max(p.nb_bonnes_reponses + p.nb_mauvaises_reponses, 1) * 100,
                1
            )
        )
        for p in progressions
    ]


@router.get(
    "/progress/stats",
    response_model=StatsUtilisateur,
    summary="Mes statistiques globales"
)
async def get_my_stats(
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retourne les statistiques globales de l'utilisateur :
    - Total mots appris
    - Score global
    - Mots à réviser aujourd'hui
    """
    today = date.today()

    # Total des progressions
    prog_result = await db.execute(
        select(
            func.count(Progression.contenu_id).label("total"),
            func.sum(Progression.nb_bonnes_reponses).label("bonnes"),
            func.sum(Progression.nb_mauvaises_reponses).label("mauvaises"),
            func.count(
                Progression.contenu_id.label("a_revoir")
            ).filter(Progression.prochaine_revision <= today)
        )
        .where(Progression.utilisateur_id == current_user.id)
    )
    stats = prog_result.one()

    # Nombre de sessions
    session_count = await db.execute(
        select(func.count(SessionApprentissage.id))
        .where(SessionApprentissage.utilisateur_id == current_user.id)
    )

    # Mots à revoir aujourd'hui
    review_count = await db.execute(
        select(func.count(Progression.contenu_id))
        .where(
            Progression.utilisateur_id == current_user.id,
            Progression.prochaine_revision <= today
        )
    )

    total_reponses = (stats.bonnes or 0) + (stats.mauvaises or 0)
    score = round((stats.bonnes or 0) / max(total_reponses, 1) * 100, 1)

    return StatsUtilisateur(
        total_mots_appris=stats.total or 0,
        total_bonnes_reponses=stats.bonnes or 0,
        total_mauvaises_reponses=stats.mauvaises or 0,
        score_global_pourcent=score,
        nb_sessions=session_count.scalar() or 0,
        mots_a_revoir_aujourd_hui=review_count.scalar() or 0
    )


@router.get(
    "/progress/review",
    summary="Mots à réviser aujourd'hui"
)
async def get_words_to_review(
    langue_id: Optional[int] = Query(None),
    limit: int = Query(default=20, ge=1, le=50),
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Retourne les mots dont la date de prochaine révision est dépassée.
    Basé sur l'algorithme de répétition espacée (SM-2).
    """
    today = date.today()
    query = (
        select(Progression)
        .options(
            selectinload(Progression.contenu)
            .selectinload(Contenu.traductions)
        )
        .where(
            Progression.utilisateur_id == current_user.id,
            Progression.prochaine_revision <= today
        )
        .order_by(Progression.prochaine_revision)
        .limit(limit)
    )

    if langue_id:
        query = query.join(Contenu).where(Contenu.langue_source_id == langue_id)

    result = await db.execute(query)
    progressions = result.scalars().all()

    return {
        "total_a_revoir": len(progressions),
        "mots": [
            {
                "contenu_id": p.contenu_id,
                "texte_source": p.contenu.texte_source if p.contenu else "",
                "en_retard_depuis": str(today - p.prochaine_revision) if p.prochaine_revision else "nouveau",
                "nb_revisions": p.nb_bonnes_reponses + p.nb_mauvaises_reponses
            }
            for p in progressions
        ]
    }


@router.post(
    "/progress/update",
    status_code=200,
    summary="Enregistrer une réponse"
)
async def update_progress(
    request: ProgressionUpdateRequest,
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    Met à jour la progression après qu'un utilisateur a répondu à une question.
    Appelé automatiquement par /quiz/submit mais peut aussi être utilisé
    depuis les écrans de leçons simples.
    """
    from datetime import timedelta

    result = await db.execute(
        select(Progression).where(
            Progression.utilisateur_id == current_user.id,
            Progression.contenu_id == request.contenu_id
        )
    )
    progression = result.scalar_one_or_none()

    if not progression:
        progression = Progression(
            utilisateur_id=current_user.id,
            contenu_id=request.contenu_id,
        )
        db.add(progression)

    today = date.today()
    if request.correct:
        progression.nb_bonnes_reponses += 1
        progression.intervalle_jours = min(progression.intervalle_jours * 2, 30)
    else:
        progression.nb_mauvaises_reponses += 1
        progression.intervalle_jours = 1

    progression.derniere_vue = today
    progression.prochaine_revision = today + timedelta(days=progression.intervalle_jours)

    await db.flush()
    return {"message": "Progression mise à jour", "prochain_rappel_dans": f"{progression.intervalle_jours} jours"}
