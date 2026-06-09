from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import timedelta, date

from app.db.database import get_db
from app.models.models import Utilisateur, Langue, Progression, SessionApprentissage
from app.schemas.schemas import RegisterRequest, LoginRequest, TokenResponse, UserFullResponse, LangueResponse, ProgressionResume
from app.core.security import hash_password, verify_password, create_access_token
from app.core.config import settings

router = APIRouter()


async def get_user_progression(user_id: int, db: AsyncSession) -> ProgressionResume:
    today = date.today()
    prog_result = await db.execute(
        select(
            func.count(Progression.contenu_id).label('total'),
            func.sum(Progression.nb_bonnes_reponses).label('bonnes'),
            func.sum(Progression.nb_mauvaises_reponses).label('mauvaises'),
        ).where(Progression.utilisateur_id == user_id)
    )
    stats = prog_result.one()
    review_count = await db.execute(
        select(func.count(Progression.contenu_id)).where(
            Progression.utilisateur_id == user_id,
            Progression.prochaine_revision <= today
        )
    )
    session_count = await db.execute(
        select(func.count(SessionApprentissage.id)).where(
            SessionApprentissage.utilisateur_id == user_id
        )
    )
    total_reponses = (stats.bonnes or 0) + (stats.mauvaises or 0)
    score = round((stats.bonnes or 0) / max(total_reponses, 1) * 100, 1)
    total_mots = stats.total or 0
    if total_mots < 30:
        niveau = 'debutant'
    elif total_mots < 100:
        niveau = 'intermediaire'
    else:
        niveau = 'avance'
    return ProgressionResume(
        total_mots_vus=total_mots,
        total_bonnes_reponses=stats.bonnes or 0,
        total_mauvaises_reponses=stats.mauvaises or 0,
        score_global_pourcent=score,
        mots_a_revoir_aujourd_hui=review_count.scalar() or 0,
        nb_sessions_total=session_count.scalar() or 0,
        niveau=niveau,
    )


async def build_token_response(user: Utilisateur, db: AsyncSession) -> TokenResponse:
    token = create_access_token(
        data={'sub': str(user.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    langue_data = None
    if user.langue_id:
        langue = await db.get(Langue, user.langue_id)
        if langue:
            langue_data = LangueResponse(id=langue.id, code=langue.code, nom=langue.nom)
    progression = await get_user_progression(user.id, db)
    user_full = UserFullResponse(
        id=user.id,
        nom=user.nom,
        email=user.email,
        avatar_url=user.avatar_url,
        is_admin=user.is_admin,
        langue_id=user.langue_id,
        langue=langue_data,
        created_at=user.created_at,
        progression=progression,
    )
    return TokenResponse(
        access_token=token,
        token_type='bearer',
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        user=user_full,
    )


@router.post('/register', response_model=TokenResponse, status_code=status.HTTP_201_CREATED, summary='Creer un compte')
async def register(request: RegisterRequest, db: AsyncSession = Depends(get_db)):
    existing = await db.execute(select(Utilisateur).where(Utilisateur.email == request.email))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=f'Email {request.email} deja utilise')
    langue = await db.get(Langue, request.langue_id)
    if not langue:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Langue {request.langue_id} introuvable')
    new_user = Utilisateur(
        nom=request.nom,
        email=request.email,
        password=hash_password(request.password),
        langue_id=request.langue_id,
    )
    db.add(new_user)
    await db.flush()
    return await build_token_response(new_user, db)


@router.post('/login', response_model=TokenResponse, summary='Se connecter')
async def login(request: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Utilisateur).where(Utilisateur.email == request.email))
    user = result.scalar_one_or_none()
    if not user or not verify_password(request.password, user.password or ''):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail='Email ou mot de passe incorrect',
            headers={'WWW-Authenticate': 'Bearer'},
        )
    return await build_token_response(user, db)
