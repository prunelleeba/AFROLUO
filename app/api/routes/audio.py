"""
╔══════════════════════════════════════════════════════════════╗
║       app/api/routes/audio.py — Gestion des fichiers audio   ║
╚══════════════════════════════════════════════════════════════╝

ROUTES :
  POST /api/v1/audio/upload/{contenu_id}  → Upload un fichier MP3
  GET  /api/v1/audio/{contenu_id}         → Infos audio d'un contenu
  DELETE /api/v1/audio/{contenu_id}       → Supprimer un audio (admin)

LOGIQUE :
  Les fichiers audio MP3/OGG sont stockés dans uploads/audio/
  Ils sont servis comme fichiers statiques via :
  http://localhost:8000/uploads/audio/ewondo_ngon_osu.mp3
"""

from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
import aiofiles
import os
import uuid
from pathlib import Path

from app.db.database import get_db
from app.models.models import Contenu
from app.schemas.schemas import AudioUploadResponse
from app.core.security import get_current_user, get_current_admin
from app.core.config import settings

router = APIRouter()

ALLOWED_AUDIO_TYPES = {
    "audio/mpeg",       # MP3
    "audio/mp3",
    "audio/ogg",        # OGG
    "audio/wav",        # WAV
    "audio/x-wav",
}


@router.post(
    "/audio/upload/{contenu_id}",
    response_model=AudioUploadResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Uploader un fichier audio pour un mot"
)
async def upload_audio(
    contenu_id: int,
    file: UploadFile = File(..., description="Fichier MP3 ou OGG, max 10 Mo"),
    _admin=Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """
    ## Upload audio

    Associe un fichier audio MP3/OGG à un contenu (mot/phrase).

    **Flux :**
    1. Vérifie que le contenu existe
    2. Vérifie le format du fichier
    3. Sauvegarde le fichier dans uploads/audio/
    4. Met à jour le champ `audio_fichier` du contenu

    **Réservé aux administrateurs.**
    """
    # ── 1. Vérifier que le contenu existe ──────────────────────
    contenu = await db.get(Contenu, contenu_id)
    if not contenu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Contenu {contenu_id} introuvable"
        )

    # ── 2. Vérifier le type de fichier ─────────────────────────
    if file.content_type not in ALLOWED_AUDIO_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Format non supporté : {file.content_type}. Utilisez MP3, OGG ou WAV."
        )

    # ── 3. Lire et vérifier la taille ──────────────────────────
    content = await file.read()
    max_size = settings.MAX_AUDIO_SIZE_MB * 1024 * 1024

    if len(content) > max_size:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Fichier trop grand (max {settings.MAX_AUDIO_SIZE_MB} Mo)"
        )

    # ── 4. Générer un nom de fichier sécurisé ──────────────────
    # Format : {langue}_{texte_source_nettoyé}_{uuid_court}.mp3
    # Exemple : ewondo_ngon_osu_a1b2.mp3
    ext = file.filename.rsplit(".", 1)[-1].lower() if "." in file.filename else "mp3"
    safe_text = "".join(c if c.isalnum() else "_" for c in contenu.texte_source[:20])
    short_uuid = str(uuid.uuid4())[:8]
    filename = f"{safe_text}_{short_uuid}.{ext}"

    # ── 5. Créer le dossier et sauvegarder ──────────────────────
    audio_dir = Path(settings.UPLOAD_DIR) / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)
    filepath = audio_dir / filename

    async with aiofiles.open(filepath, "wb") as f:
        await f.write(content)

    # ── 6. Supprimer l'ancien fichier si existant ───────────────
    if contenu.audio_fichier:
        old_path = audio_dir / contenu.audio_fichier
        if old_path.exists():
            old_path.unlink()

    # ── 7. Mettre à jour la base de données ─────────────────────
    contenu.audio_fichier = filename
    db.add(contenu)
    await db.flush()

    return AudioUploadResponse(
        contenu_id=contenu_id,
        audio_url=f"/uploads/audio/{filename}",
        fichier_nom=filename,
        taille_ko=round(len(content) / 1024, 2)
    )


@router.get(
    "/audio/{contenu_id}",
    summary="Informations audio d'un contenu"
)
async def get_audio_info(
    contenu_id: int,
    db: AsyncSession = Depends(get_db),
    _user=Depends(get_current_user)
):
    """Retourne l'URL du fichier audio associé à un contenu."""
    contenu = await db.get(Contenu, contenu_id)
    if not contenu:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Contenu {contenu_id} introuvable"
        )

    if not contenu.audio_fichier:
        return {"contenu_id": contenu_id, "audio_url": None, "message": "Aucun audio disponible"}

    return {
        "contenu_id": contenu_id,
        "texte_source": contenu.texte_source,
        "audio_url": f"/uploads/audio/{contenu.audio_fichier}",
        "fichier_nom": contenu.audio_fichier
    }


@router.delete(
    "/audio/{contenu_id}",
    status_code=status.HTTP_200_OK,
    summary="Supprimer le fichier audio (admin)"
)
async def delete_audio(
    contenu_id: int,
    _admin=Depends(get_current_admin),
    db: AsyncSession = Depends(get_db)
):
    """Supprime le fichier audio d'un contenu. Réservé aux admins."""
    contenu = await db.get(Contenu, contenu_id)
    if not contenu or not contenu.audio_fichier:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Contenu ou audio introuvable"
        )

    # Supprimer le fichier physique
    audio_path = Path(settings.UPLOAD_DIR) / "audio" / contenu.audio_fichier
    if audio_path.exists():
        audio_path.unlink()

    # Nettoyer en base
    contenu.audio_fichier = None
    db.add(contenu)
    await db.flush()

    return {"message": "Audio supprimé avec succès"}
