"""
╔══════════════════════════════════════════════════════════════╗
║   app/api/routes/google_auth.py — Connexion Google OAuth     ║
╚══════════════════════════════════════════════════════════════╝

COMMENT ÇA MARCHE :
  1. L'app Flutter appelle GET /api/v1/auth/google
  2. Le backend redirige vers Google
  3. L'utilisateur accepte sur Google
  4. Google redirige vers /api/v1/auth/google/callback
  5. Le backend vérifie le token Google
  6. Si l'email existe → connexion directe
  7. Si l'email n'existe pas → création de compte automatique
  8. Le backend retourne un JWT token AfroLuo
"""

import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime, timezone

from app.db.database import get_db
from app.models.models import Utilisateur, Langue
from app.core.config import settings
from app.core.security import create_access_token

router = APIRouter(
    prefix="/api/v1/auth",
    tags=["🔑 Google Auth"]
)

# ── URLs Google OAuth ─────────────────────────────────────────
GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo"


# ══════════════════════════════════════════════════════════════
#  ENDPOINT 1 — GET /api/v1/auth/google
#  Redirige l'utilisateur vers Google pour qu'il se connecte
# ══════════════════════════════════════════════════════════════
@router.get("/google", summary="Se connecter avec Google")
async def login_google():
    """
    Redirige vers la page de connexion Google.

    L'app Flutter ouvre cette URL dans un navigateur.
    Google demande à l'utilisateur d'autoriser AfroLuo.
    """
    # Construire l'URL de connexion Google
    params = {
        "client_id": settings.GOOGLE_CLIENT_ID,
        "redirect_uri": settings.GOOGLE_REDIRECT_URI,
        "response_type": "code",
        "scope": "openid email profile",
        # openid = identifiant unique
        # email = adresse email
        # profile = nom et photo
        "access_type": "offline",
    }

    # Construire l'URL avec les paramètres
    query_string = "&".join([f"{k}={v}" for k, v in params.items()])
    google_url = f"{GOOGLE_AUTH_URL}?{query_string}"

    # Rediriger l'utilisateur vers Google
    return RedirectResponse(url=google_url)


# ══════════════════════════════════════════════════════════════
#  ENDPOINT 2 — GET /api/v1/auth/google/callback
#  Google redirige ici après que l'utilisateur s'est connecté
# ══════════════════════════════════════════════════════════════
@router.get("/google/callback", summary="Callback Google OAuth")
async def google_callback(
    code: str,  # Code temporaire envoyé par Google
    db: AsyncSession = Depends(get_db)
):
    """
    Google redirige ici après connexion.

    Le backend :
    1. Échange le code contre un token Google
    2. Récupère les infos de l'utilisateur (email, nom, photo)
    3. Crée ou connecte l'utilisateur dans AfroLuo
    4. Retourne un JWT token AfroLuo
    """

    # ── Étape 1 : Échanger le code contre un token Google ─────
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
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Erreur lors de la connexion avec Google."
        )

    token_data = token_response.json()
    access_token_google = token_data.get("access_token")

    # ── Étape 2 : Récupérer les infos de l'utilisateur ────────
    async with httpx.AsyncClient() as client:
        userinfo_response = await client.get(
            GOOGLE_USERINFO_URL,
            headers={"Authorization": f"Bearer {access_token_google}"}
        )

    if userinfo_response.status_code != 200:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Impossible de récupérer les informations Google."
        )

    userinfo = userinfo_response.json()
    # userinfo contient : email, name, picture, sub (ID Google)
    email = userinfo.get("email")
    nom   = userinfo.get("name", email)
    photo = userinfo.get("picture")

    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email non disponible depuis Google."
        )

    # ── Étape 3 : Chercher l'utilisateur dans AfroLuo ─────────
    resultat = await db.execute(
        select(Utilisateur).where(Utilisateur.email == email)
    )
    utilisateur = resultat.scalar_one_or_none()

    if not utilisateur:
        # ── L'utilisateur n'existe pas → créer son compte ─────
        # Trouver la langue par défaut (français = id 1)
        langue_result = await db.execute(
            select(Langue).where(Langue.code == "fr")
        )
        langue = langue_result.scalar_one_or_none()
        langue_id = langue.id if langue else 1

        utilisateur = Utilisateur(
            nom=nom,
            email=email,
            langue_id=langue_id,
            password=None,      # Pas de mot de passe pour connexion Google
            avatar_url=photo,   # Photo Google comme avatar
            is_admin=False
        )
        db.add(utilisateur)
        await db.commit()
        await db.refresh(utilisateur)

    # ── Étape 4 : Créer un JWT token AfroLuo ──────────────────
    jwt_token = create_access_token(data={"sub": str(utilisateur.id)})

    # ── Étape 5 : Retourner le token ───────────────────────────
    return {
        "message": "Connexion Google réussie !",
        "access_token": jwt_token,
        "token_type": "bearer",
        "user": {
            "id": utilisateur.id,
            "nom": utilisateur.nom,
            "email": utilisateur.email,
            "avatar_url": utilisateur.avatar_url,
        }
    }
