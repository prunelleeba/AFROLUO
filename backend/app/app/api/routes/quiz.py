"""
╔══════════════════════════════════════════════════════════════╗
║       app/api/routes/quiz.py — Quiz interactifs              ║
╚══════════════════════════════════════════════════════════════╝

ROUTES :
  POST /api/v1/quiz/generate  → Génère un quiz
  POST /api/v1/quiz/submit    → Soumet les réponses et calcule le score
  GET  /api/v1/quiz/history   → Historique des sessions de quiz
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from sqlalchemy.orm import selectinload
from typing import List
import random
from datetime import datetime, timezone

from app.db.database import get_db
from app.models.models import (
    Contenu, ContenuTraduction, Progression,
    SessionApprentissage, Utilisateur
)
from app.schemas.schemas import (
    QuizRequest, QuizQuestion, QuizAnswerRequest, QuizResultResponse
)
from app.core.security import get_current_user

router = APIRouter()


@router.post(
    "/quiz/generate",
    response_model=List[QuizQuestion],
    summary="Générer un quiz"
)
async def generate_quiz(
    request: QuizRequest,
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    ## Génération d'un quiz

    Génère des questions de type QCM (4 choix).

    **Stratégie :**
    - Sélectionne des mots de la langue demandée
    - Pour chaque mot : 1 bonne réponse + 3 distracteurs aléatoires
    - La question demande la traduction française du mot africain

    **Exemple de question générée :**
    ```json
    {
      "texte_source": "ngɔn osu",
      "question": "Comment traduit-on 'ngɔn osu' ?",
      "choix": ["janvier", "février", "mars", "l'été"],
      "bonne_reponse_index": 0
    }
    ```
    """
    # ── 1. Charger les contenus disponibles ──────────────────────
    query = (
        select(Contenu)
        .options(
            selectinload(Contenu.traductions).selectinload(ContenuTraduction.langue),
            selectinload(Contenu.theme),
            selectinload(Contenu.type_contenu)
        )
        .where(Contenu.langue_source_id == request.langue_id)
        .where(Contenu.actif == True)
    )

    if request.theme_id:
        query = query.where(Contenu.theme_id == request.theme_id)
    if request.niveau:
        query = query.where(Contenu.niveau == request.niveau)

    result = await db.execute(query)
    all_contenus = result.scalars().all()

    if len(all_contenus) < 4:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Pas assez de contenus pour générer un quiz (minimum 4, trouvé {len(all_contenus)})"
        )

    # ── 2. Sélectionner les questions ────────────────────────────
    nb_questions = min(request.nb_questions, len(all_contenus))
    selected = random.sample(all_contenus, nb_questions)

    # ── 3. Construire les questions ──────────────────────────────
    questions = []
    for contenu in selected:
        # Trouver la traduction française
        trad_fr = next(
            (t.traduction for t in contenu.traductions if t.langue and t.langue.code == "fr"),
            None
        )
        if not trad_fr:
            # Prendre la première traduction disponible si pas de français
            trad_fr = contenu.traductions[0].traduction if contenu.traductions else "???"

        # Générer 3 distracteurs (mauvaises réponses)
        autres = [c for c in all_contenus if c.id != contenu.id]
        distracteurs_contenus = random.sample(autres, min(3, len(autres)))
        distracteurs = []
        for d in distracteurs_contenus:
            trad = next(
                (t.traduction for t in d.traductions if t.langue and t.langue.code == "fr"),
                d.texte_source
            )
            distracteurs.append(trad)

        # Mélanger bonne réponse et distracteurs
        choix = [trad_fr] + distracteurs
        random.shuffle(choix)
        bonne_reponse_index = choix.index(trad_fr)

        questions.append(QuizQuestion(
            contenu_id=contenu.id,
            texte_source=contenu.texte_source,
            prononciation=contenu.prononciation,
            audio_url=f"/uploads/audio/{contenu.audio_fichier}" if contenu.audio_fichier else None,
            question=f"Comment traduit-on « {contenu.texte_source} » ?",
            choix=choix,
            bonne_reponse_index=bonne_reponse_index
        ))

    return questions


@router.post(
    "/quiz/submit",
    response_model=QuizResultResponse,
    summary="Soumettre les réponses d'un quiz"
)
async def submit_quiz(
    langue_id: int,
    answers: List[QuizAnswerRequest],
    questions: List[QuizQuestion],
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    ## Soumission d'un quiz

    Reçoit les réponses, calcule le score et met à jour la progression.

    **Important :** Flutter doit renvoyer les questions originales
    (pour connaître la bonne réponse) + les réponses de l'utilisateur.
    """
    if len(answers) != len(questions):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le nombre de réponses ne correspond pas au nombre de questions"
        )

    nb_correct = 0
    total_temps = 0

    for answer, question in zip(answers, questions):
        est_correct = answer.reponse_index == question.bonne_reponse_index
        if est_correct:
            nb_correct += 1
        if answer.temps_secondes:
            total_temps += answer.temps_secondes

        # ── Mettre à jour la progression (algorithme SM-2 simplifié) ──
        result = await db.execute(
            select(Progression).where(
                Progression.utilisateur_id == current_user.id,
                Progression.contenu_id == answer.contenu_id
            )
        )
        progression = result.scalar_one_or_none()

        from datetime import date, timedelta

        if not progression:
            progression = Progression(
                utilisateur_id=current_user.id,
                contenu_id=answer.contenu_id
            )
            db.add(progression)

        if est_correct:
            progression.nb_bonnes_reponses += 1
            # Augmenter l'intervalle de révision
            progression.intervalle_jours = min(
                progression.intervalle_jours * 2, 30
            )
        else:
            progression.nb_mauvaises_reponses += 1
            # Réinitialiser l'intervalle
            progression.intervalle_jours = 1

        today = date.today()
        progression.derniere_vue = today
        progression.prochaine_revision = today + timedelta(days=progression.intervalle_jours)

    # ── Créer la session d'apprentissage ──────────────────────
    session = SessionApprentissage(
        utilisateur_id=current_user.id,
        langue_id=langue_id,
        nb_total=len(answers),
        nb_correct=nb_correct,
        duree_secondes=total_temps if total_temps > 0 else None
    )
    db.add(session)
    await db.flush()

    score = (nb_correct / len(answers)) * 100 if answers else 0

    # Message de motivation
    if score >= 90:
        message = "🏆 Excellent ! Tu maîtrises très bien cette leçon !"
    elif score >= 70:
        message = "👏 Bien joué ! Continue comme ça !"
    elif score >= 50:
        message = "💪 Pas mal ! Encore un peu de pratique !"
    else:
        message = "📚 Continue à pratiquer, tu vas y arriver !"

    return QuizResultResponse(
        session_id=session.id,
        nb_total=len(answers),
        nb_correct=nb_correct,
        score_pourcent=round(score, 1),
        duree_secondes=total_temps if total_temps > 0 else None,
        message=message
    )


@router.get(
    "/quiz/history",
    summary="Historique des sessions de quiz"
)
async def get_quiz_history(
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Retourne les dernières sessions d'apprentissage de l'utilisateur."""
    result = await db.execute(
        select(SessionApprentissage)
        .where(SessionApprentissage.utilisateur_id == current_user.id)
        .order_by(SessionApprentissage.created_at.desc())
        .limit(20)
    )
    sessions = result.scalars().all()

    return [
        {
            "id": s.id,
            "nb_total": s.nb_total,
            "nb_correct": s.nb_correct,
            "score_pourcent": round((s.nb_correct / s.nb_total * 100) if s.nb_total > 0 else 0, 1),
            "duree_secondes": s.duree_secondes,
            "date": s.created_at.isoformat()
        }
        for s in sessions
    ]
