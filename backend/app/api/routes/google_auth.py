import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import timedelta

from app.db.database import get_db
from app.models.models import Utilisateur, Langue
from app.core.config import settings
from app.core.security import create_access_token

router = APIRouter(prefix="/api/v1/auth", tags=["Google Auth"])

GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo"


@router.get("/google", summary="Se connecter avec Google")
async def login_google():
    params = {
        "client_id": settings.GOOGLE_CLIENT_ID,
        "redirect_uri": settings.GOOGLE_REDIRECT_URI,
        "response_type": "code",
        "scope": "openid email profile",
        "access_type": "offline",
    }
    query_string = "&".join([f"{k}={v}" for k, v in params.items()])
    google_url = f"{GOOGLE_AUTH_URL}?{query_string}"
    return RedirectResponse(url=google_url)


@router.get("/google/callback", summary="Callback Google OAuth")
async def google_callback(code: str, db: AsyncSession = Depends(get_db)):
    async with httpx.AsyncClient() as client:
        token_response = await client.post(
            GOOGLE_TOKEN_URL,
            data={
                "client_id": settings.GOOGLE_CLIENT_ID,
                "client_secret": settings.GOOGLE_CLIENT_SECRET,
                "code": code,
                "redirect_uri": settings.GOOGLE_REDIRECT_URI,
                "grant_type": "authorization_code",
            }
        )

    if token_response.status_code != 200:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Erreur connexion Google")

    token_data = token_response.json()
    access_token = token_data.get("access_token")

    async with httpx.AsyncClient() as client:
        userinfo_response = await client.get(
            GOOGLE_USERINFO_URL,
            headers={"Authorization": f"Bearer {access_token}"}
        )

    if userinfo_response.status_code != 200:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Impossible de recuperer les infos Google")

    userinfo = userinfo_response.json()
    email = userinfo.get("email")
    nom = userinfo.get("name", email)
    avatar_url = userinfo.get("picture")

    result = await db.execute(select(Utilisateur).where(Utilisateur.email == email))
    user = result.scalar_one_or_none()

    if not user:
        langue_result = await db.execute(select(Langue).limit(1))
        langue = langue_result.scalar_one_or_none()
        langue_id = langue.id if langue else 1

        user = Utilisateur(
            nom=nom,
            email=email,
            avatar_url=avatar_url,
            langue_id=langue_id,
            password=None,
        )
        db.add(user)
        await db.flush()

    token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {"id": user.id, "nom": user.nom, "email": user.email}
    }
