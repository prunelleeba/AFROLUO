"""
╔══════════════════════════════════════════════════════════════╗
║       app/core/security.py — Sécurité & JWT                  ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Tout ce qui concerne la sécurité :
  1. Hachage des mots de passe (bcrypt)
  2. Création des tokens JWT
  3. Vérification des tokens JWT

  Un token JWT ressemble à : xxxxx.yyyyy.zzzzz
  Il contient des infos (user_id, expiration) signées par notre SECRET_KEY.
  Si quelqu'un modifie le token → la vérification échoue → accès refusé.
"""

from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.db.database import get_db

# ─────────────────────────────────────────────
# HACHAGE DES MOTS DE PASSE
# bcrypt transforme "monmotdepasse" en "$2b$12$xxx..."
# On ne stocke JAMAIS le mot de passe en clair !
# ─────────────────────────────────────────────
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# ─────────────────────────────────────────────
# SCHÉMA BEARER TOKEN
# Lit le header : Authorization: Bearer <token>
# ─────────────────────────────────────────────
security = HTTPBearer()


def hash_password(password: str) -> str:
    """
    Transforme un mot de passe en texte → hash sécurisé.
    Exemple : "abc123" → "$2b$12$N9qo8uLOickgx2ZMRZoMye..."
    """
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Vérifie qu'un mot de passe correspond à son hash.
    Retourne True si correct, False sinon.
    """
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """
    Crée un token JWT contenant les données passées.

    Exemple d'utilisation :
        token = create_access_token({"sub": str(user.id)})

    Le token contient :
        - sub : l'identifiant de l'utilisateur
        - exp : la date d'expiration
    """
    to_encode = data.copy()

    # Calcul de la date d'expiration
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )

    to_encode.update({"exp": expire})

    # Signature du token avec notre SECRET_KEY
    encoded_jwt = jwt.encode(
        to_encode,
        settings.SECRET_KEY,
        algorithm=settings.ALGORITHM
    )
    return encoded_jwt


def decode_token(token: str) -> dict:
    """
    Décode et vérifie un token JWT.
    Lève une exception si le token est invalide ou expiré.
    """
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide ou expiré",
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
):
    """
    Dépendance FastAPI : extrait l'utilisateur depuis le token JWT.

    Usage dans un endpoint :
        @router.get("/protected")
        async def protected(user = Depends(get_current_user)):
            return {"hello": user.nom}

    FastAPI appelle automatiquement cette fonction avant l'endpoint.
    """
    from app.models.models import Utilisateur
    from sqlalchemy import select

    # 1. Décoder le token
    payload = decode_token(credentials.credentials)
    user_id: str = payload.get("sub")

    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invalide : user_id manquant"
        )

    # 2. Chercher l'utilisateur en base
    result = await db.execute(
        select(Utilisateur).where(Utilisateur.id == int(user_id))
    )
    user = result.scalar_one_or_none()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Utilisateur introuvable"
        )

    return user


async def get_current_admin(current_user=Depends(get_current_user)):
    """
    Dépendance : vérifie que l'utilisateur est admin.
    Usage : @router.delete("/admin-only", dependencies=[Depends(get_current_admin)])
    """
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Accès réservé aux administrateurs"
        )
    return current_user
