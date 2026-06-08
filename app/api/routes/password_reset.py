"""
╔══════════════════════════════════════════════════════════════╗
║   app/api/routes/password_reset.py — Routes Mot de Passe    ║
║   3 endpoints : forgot-password, verify-otp, reset-password  ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Ce fichier contient les 3 endpoints du système OTP :

  1. POST /api/v1/forgot-password
     → L'utilisateur envoie son email
     → Le backend génère un OTP et l'envoie par email

  2. POST /api/v1/verify-otp
     → L'utilisateur envoie son email + le code OTP reçu
     → Le backend vérifie si le code est correct et pas expiré

  3. POST /api/v1/reset-password
     → L'utilisateur envoie email + code OTP + nouveau mot de passe
     → Le backend change le mot de passe et supprime l'OTP

FLUX COMPLET :
  App mobile → forgot-password → email avec OTP
  App mobile → verify-otp → confirmation code valide
  App mobile → reset-password → mot de passe changé ✅
"""

import random          # Pour générer le code OTP aléatoire
import string          # Pour les caractères du code
from datetime import datetime, timedelta, timezone  # Pour la date d'expiration

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession  # Session base de données asynchrone
from sqlalchemy import select, delete            # Requêtes SQL
from passlib.context import CryptContext         # Pour hasher le mot de passe

from app.db.database import get_db               # Connexion à PostgreSQL
from app.models.models import Utilisateur        # Modèle utilisateur existant
from app.models.otp_model import OTPCode         # Notre nouveau modèle OTP
from app.schemas.otp_schemas import (            # Nos schémas de validation
    ForgotPasswordRequest,
    VerifyOTPRequest,
    ResetPasswordRequest,
    MessageResponse,
    OTPVerifyResponse
)
from app.services.email_service import envoyer_otp_par_email  # Service email

# ── Configuration ─────────────────────────────────────────────
router = APIRouter(
    prefix="/api/v1",   # Tous les endpoints commencent par /api/v1
    tags=["🔑 Password Reset"]  # Groupe dans la documentation /docs
)

# Contexte pour hasher les mots de passe avec bcrypt
# bcrypt est l'algorithme le plus sécurisé pour les mots de passe
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ══════════════════════════════════════════════════════════════
#  FONCTION UTILITAIRE — Générer un OTP
# ══════════════════════════════════════════════════════════════

def generer_otp() -> str:
    """
    Génère un code OTP aléatoire à 6 chiffres.

    Exemples de codes générés :
    - "482916"
    - "073541"
    - "999012"

    Retourne toujours une chaîne de 6 caractères numériques.
    """
    # random.choices choisit 6 chiffres au hasard dans "0123456789"
    # "".join() les assemble en une seule chaîne
    return "".join(random.choices(string.digits, k=6))


# ══════════════════════════════════════════════════════════════
#  ENDPOINT 1 — POST /api/v1/forgot-password
# ══════════════════════════════════════════════════════════════

@router.post(
    "/forgot-password",
    response_model=MessageResponse,
    summary="Demander un code OTP pour réinitialiser le mot de passe",
    status_code=status.HTTP_200_OK
)
async def forgot_password(
    donnees: ForgotPasswordRequest,   # JSON envoyé par l'app mobile
    db: AsyncSession = Depends(get_db)  # Connexion automatique à PostgreSQL
):
    """
    Étape 1 du système Forgot Password.

    L'app mobile envoie :
    POST /api/v1/forgot-password
    {
        "email": "marie@gmail.com"
    }

    Le backend :
    1. Vérifie si l'email existe dans la base
    2. Supprime les anciens OTP de cet utilisateur
    3. Génère un nouveau code OTP à 6 chiffres
    4. Sauvegarde l'OTP avec expiration dans 5 minutes
    5. Envoie l'OTP par email
    6. Retourne un message de succès

    SÉCURITÉ : Même si l'email n'existe pas, on retourne le même
    message pour ne pas révéler quels emails sont enregistrés.
    """

    # ── Étape 1 : Chercher l'utilisateur par email ────────────
    resultat = await db.execute(
        select(Utilisateur).where(Utilisateur.email == donnees.email)
    )
    utilisateur = resultat.scalar_one_or_none()
    # scalar_one_or_none() retourne l'utilisateur ou None si pas trouvé

    # ── Sécurité : Ne pas révéler si l'email existe ───────────
    # On retourne TOUJOURS le même message succès
    # Ainsi un attaquant ne peut pas savoir quels emails sont enregistrés
    if not utilisateur:
        # Email non trouvé → on fait semblant que c'est OK
        return MessageResponse(
            message="Si cet email existe, vous recevrez un code OTP dans quelques instants."
        )

    # ── Étape 2 : Supprimer les anciens OTP ───────────────────
    # Un utilisateur ne peut avoir qu'un seul OTP valide à la fois
    await db.execute(
        delete(OTPCode).where(OTPCode.utilisateur_id == utilisateur.id)
    )
    # Supprime tous les anciens OTP de cet utilisateur
    # Cela évite d'avoir plusieurs OTP valides en même temps

    # ── Étape 3 : Générer le nouveau code OTP ─────────────────
    code = generer_otp()
    # Ex: code = "482916"

    # ── Étape 4 : Calculer l'expiration (maintenant + 5 min) ──
    maintenant = datetime.now(timezone.utc)
    # datetime.now(timezone.utc) = heure actuelle en UTC
    # UTC = standard international, évite les problèmes de fuseaux horaires

    expiration = maintenant + timedelta(minutes=5)
    # timedelta(minutes=5) = ajoute 5 minutes
    # Si maintenant = 10:30:00 → expiration = 10:35:00

    # ── Étape 5 : Sauvegarder l'OTP dans PostgreSQL ───────────
    nouvel_otp = OTPCode(
        utilisateur_id=utilisateur.id,  # L'ID de l'utilisateur
        code=code,                       # Le code "482916"
        expire_at=expiration,            # Expire à 10:35:00
        utilise=False                    # Pas encore utilisé
    )
    db.add(nouvel_otp)    # Ajoute à la session
    await db.commit()     # Sauvegarde dans PostgreSQL

    # ── Étape 6 : Envoyer l'email ─────────────────────────────
    email_envoye = await envoyer_otp_par_email(
        email_destinataire=utilisateur.email,
        code_otp=code,
        nom_utilisateur=utilisateur.nom
    )

    if not email_envoye:
        # L'email n'a pas pu être envoyé (ex: problème Gmail)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Erreur lors de l'envoi de l'email. Réessayez plus tard."
        )

    # ── Succès ────────────────────────────────────────────────
    return MessageResponse(
        message="Si cet email existe, vous recevrez un code OTP dans quelques instants."
    )


# ══════════════════════════════════════════════════════════════
#  ENDPOINT 2 — POST /api/v1/verify-otp
# ══════════════════════════════════════════════════════════════

@router.post(
    "/verify-otp",
    response_model=OTPVerifyResponse,
    summary="Vérifier le code OTP reçu par email",
    status_code=status.HTTP_200_OK
)
async def verify_otp(
    donnees: VerifyOTPRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Étape 2 du système Forgot Password.

    L'app mobile envoie :
    POST /api/v1/verify-otp
    {
        "email": "marie@gmail.com",
        "code": "482916"
    }

    Le backend vérifie :
    1. L'email existe-t-il ? (utilisateur trouvé)
    2. Un OTP existe-t-il pour cet utilisateur ?
    3. Le code correspond-il ? (ex: "482916" == "482916")
    4. L'OTP n'a-t-il pas expiré ? (moins de 5 minutes)
    5. L'OTP n'a-t-il pas déjà été utilisé ?

    Si tout est OK → retourne reset_autorise = True
    """

    # ── Étape 1 : Trouver l'utilisateur ───────────────────────
    resultat = await db.execute(
        select(Utilisateur).where(Utilisateur.email == donnees.email)
    )
    utilisateur = resultat.scalar_one_or_none()

    if not utilisateur:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Email introuvable."
        )

    # ── Étape 2 : Trouver l'OTP de cet utilisateur ────────────
    resultat_otp = await db.execute(
        select(OTPCode).where(
            OTPCode.utilisateur_id == utilisateur.id,
            OTPCode.utilise == False  # Seulement les OTP pas encore utilisés
        )
    )
    otp = resultat_otp.scalar_one_or_none()

    if not otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Aucun code OTP trouvé. Veuillez redemander un code."
        )

    # ── Étape 3 : Vérifier si l'OTP est expiré ────────────────
    maintenant = datetime.now(timezone.utc)

    if maintenant > otp.expire_at:
        # L'OTP a expiré → le supprimer et retourner une erreur
        await db.execute(
            delete(OTPCode).where(OTPCode.id == otp.id)
        )
        await db.commit()

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le code OTP a expiré. Veuillez redemander un nouveau code."
        )

    # ── Étape 4 : Vérifier si le code est correct ─────────────
    if otp.code != donnees.code:
        # Mauvais code
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code OTP incorrect."
        )

    # ── Tout est OK : L'OTP est valide ────────────────────────
    return OTPVerifyResponse(
        message="Code OTP valide. Vous pouvez maintenant changer votre mot de passe.",
        reset_autorise=True
    )


# ══════════════════════════════════════════════════════════════
#  ENDPOINT 3 — POST /api/v1/reset-password
# ══════════════════════════════════════════════════════════════

@router.post(
    "/reset-password",
    response_model=MessageResponse,
    summary="Changer le mot de passe avec le code OTP",
    status_code=status.HTTP_200_OK
)
async def reset_password(
    donnees: ResetPasswordRequest,
    db: AsyncSession = Depends(get_db)
):
    """
    Étape 3 du système Forgot Password.

    L'app mobile envoie :
    POST /api/v1/reset-password
    {
        "email": "marie@gmail.com",
        "code": "482916",
        "nouveau_mot_de_passe": "NouveauMotDePasse123"
    }

    Le backend :
    1. Vérifie l'email et l'OTP (comme verify-otp)
    2. Hashe le nouveau mot de passe avec bcrypt
    3. Met à jour le mot de passe dans PostgreSQL
    4. Supprime l'OTP utilisé (ne peut plus resservir)
    5. Retourne un message de succès
    """

    # ── Étape 1 : Trouver l'utilisateur ───────────────────────
    resultat = await db.execute(
        select(Utilisateur).where(Utilisateur.email == donnees.email)
    )
    utilisateur = resultat.scalar_one_or_none()

    if not utilisateur:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Email introuvable."
        )

    # ── Étape 2 : Trouver et vérifier l'OTP ───────────────────
    resultat_otp = await db.execute(
        select(OTPCode).where(
            OTPCode.utilisateur_id == utilisateur.id,
            OTPCode.utilise == False
        )
    )
    otp = resultat_otp.scalar_one_or_none()

    if not otp:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Aucun code OTP trouvé. Veuillez redemander un code."
        )

    # ── Étape 3 : Vérifier expiration ─────────────────────────
    maintenant = datetime.now(timezone.utc)

    if maintenant > otp.expire_at:
        await db.execute(delete(OTPCode).where(OTPCode.id == otp.id))
        await db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le code OTP a expiré. Veuillez redemander un nouveau code."
        )

    # ── Étape 4 : Vérifier le code ────────────────────────────
    if otp.code != donnees.code:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Code OTP incorrect."
        )

    # ── Étape 5 : Hasher le nouveau mot de passe ──────────────
    mot_de_passe_hashe = pwd_context.hash(donnees.nouveau_mot_de_passe)
    # AVANT le hash : "NouveauMotDePasse123"
    # APRÈS le hash : "$2b$12$abc123xyz..." (illisible, sécurisé)
    # bcrypt est irréversible : impossible de retrouver le mot de passe original
    # même si quelqu'un vole la base de données

    # ── Étape 6 : Mettre à jour le mot de passe ───────────────
    utilisateur.password = mot_de_passe_hashe
    # Met à jour l'objet en mémoire

    # ── Étape 7 : Marquer l'OTP comme utilisé et supprimer ────
    await db.execute(
        delete(OTPCode).where(OTPCode.utilisateur_id == utilisateur.id)
    )
    # Supprime tous les OTP de cet utilisateur
    # L'OTP ne peut plus être réutilisé

    await db.commit()
    # Sauvegarde tout dans PostgreSQL en une seule transaction

    # ── Succès ────────────────────────────────────────────────
    return MessageResponse(
        message="Mot de passe réinitialisé avec succès. Vous pouvez maintenant vous connecter."
    )
