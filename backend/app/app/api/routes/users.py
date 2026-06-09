"""
╔══════════════════════════════════════════════════════════════╗
║       app/api/routes/users.py — Profil utilisateur           ║
╚══════════════════════════════════════════════════════════════╝

ROUTES :
  GET    /api/v1/profile        → Mon profil
  PUT    /api/v1/profile        → Modifier mon profil
  POST   /api/v1/profile/avatar → Changer ma photo
  POST   /api/v1/change-password → Changer mon mot de passe
"""

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import aiofiles
import os
import uuid
from pathlib import Path

from app.db.database import get_db
from app.models.models import Utilisateur
from app.schemas.schemas import UserResponse, UserUpdateRequest, ChangePasswordRequest
from app.core.security import get_current_user, hash_password, verify_password
from app.core.config import settings

router = APIRouter()


@router.get(
    "/profile",
    response_model=UserResponse,
    summary="Obtenir mon profil"
)
async def get_profile(
    current_user: Utilisateur = Depends(get_current_user)
):
    """
    ## Mon profil

    Retourne les informations de l'utilisateur connecté.

    **Requiert :** Token JWT dans le header Authorization.
    """
    return UserResponse.model_validate(current_user)


@router.put(
    "/profile",
    response_model=UserResponse,
    summary="Modifier mon profil"
)
async def update_profile(
    request: UserUpdateRequest,
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    ## Modifier mon profil

    Met à jour les champs envoyés (les champs absents ne sont pas modifiés).
    """
    # Vérifier si le nouvel email est déjà pris
    if request.email and request.email != current_user.email:
        existing = await db.execute(
            select(Utilisateur).where(Utilisateur.email == request.email)
        )
        if existing.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Cet email est déjà utilisé"
            )

    # Mise à jour des champs fournis seulement
    update_data = request.model_dump(exclude_none=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)

    db.add(current_user)
    await db.flush()

    return UserResponse.model_validate(current_user)


@router.post(
    "/change-password",
    status_code=status.HTTP_200_OK,
    summary="Changer mon mot de passe"
)
async def change_password(
    request: ChangePasswordRequest,
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Vérifie l'ancien mot de passe et définit le nouveau."""
    if not verify_password(request.old_password, current_user.password or ""):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ancien mot de passe incorrect"
        )

    current_user.password = hash_password(request.new_password)
    db.add(current_user)
    await db.flush()

    return {"message": "Mot de passe mis à jour avec succès"}


@router.post(
    "/profile/avatar",
    response_model=UserResponse,
    summary="Changer ma photo de profil"
)
async def upload_avatar(
    file: UploadFile = File(..., description="Image JPG ou PNG, max 2 Mo"),
    current_user: Utilisateur = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Upload une image comme photo de profil."""
    # Vérifications de sécurité
    allowed_types = {"image/jpeg", "image/png", "image/webp"}
    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Format non supporté. Utilisez JPG, PNG ou WebP."
        )

    # Créer le dossier avatars si nécessaire
    avatar_dir = Path(settings.UPLOAD_DIR) / "avatars"
    avatar_dir.mkdir(parents=True, exist_ok=True)

    # Nom de fichier unique pour éviter les collisions
    ext = file.filename.rsplit(".", 1)[-1]
    filename = f"{uuid.uuid4()}.{ext}"
    filepath = avatar_dir / filename

    # Écriture async du fichier
    content = await file.read()
    if len(content) > 2 * 1024 * 1024:  # 2 Mo max
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail="Image trop grande (max 2 Mo)"
        )

    async with aiofiles.open(filepath, "wb") as f:
        await f.write(content)

    # Mettre à jour l'URL en base
    current_user.avatar_url = f"/uploads/avatars/{filename}"
    db.add(current_user)
    await db.flush()

    return UserResponse.model_validate(current_user)
