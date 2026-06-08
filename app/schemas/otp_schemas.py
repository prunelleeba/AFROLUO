"""
╔══════════════════════════════════════════════════════════════╗
║       app/schemas/otp_schemas.py — Schémas OTP              ║
║   Validation des données envoyées par l'application mobile   ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Ces classes définissent exactement quel JSON l'app mobile
  doit envoyer pour chaque endpoint, et quel JSON le backend
  va renvoyer en réponse.

  Pydantic vérifie automatiquement :
  - Les champs obligatoires (si email manque → erreur 422)
  - Les types (email doit être un vrai email)
  - Les longueurs (code OTP doit avoir 6 chiffres)
"""

from pydantic import BaseModel, EmailStr, Field


# ══════════════════════════════════════════════════════════════
#  REQUÊTES (ce que l'app mobile ENVOIE au backend)
# ══════════════════════════════════════════════════════════════

class ForgotPasswordRequest(BaseModel):
    """
    POST /api/v1/forgot-password

    L'app mobile envoie :
    {
        "email": "marie@gmail.com"
    }
    """
    email: EmailStr
    # EmailStr = Pydantic vérifie automatiquement que c'est
    # un vrai format email (contient @, un domaine, etc.)
    # Si l'email est invalide → erreur 422 automatique


class VerifyOTPRequest(BaseModel):
    """
    POST /api/v1/verify-otp

    L'app mobile envoie :
    {
        "email": "marie@gmail.com",
        "code": "482916"
    }
    """
    email: EmailStr
    # L'email de l'utilisateur (pour identifier à qui appartient le code)

    code: str = Field(
        min_length=6,
        max_length=6,
        pattern=r'^\d{6}$'
        # pattern = doit être exactement 6 chiffres
        # "482916" ✅  "abc123" ❌  "1234" ❌
    )


class ResetPasswordRequest(BaseModel):
    """
    POST /api/v1/reset-password

    L'app mobile envoie :
    {
        "email": "marie@gmail.com",
        "code": "482916",
        "nouveau_mot_de_passe": "NouveauMotDePasse123"
    }
    """
    email: EmailStr

    code: str = Field(
        min_length=6,
        max_length=6,
        pattern=r'^\d{6}$'
    )

    nouveau_mot_de_passe: str = Field(
        min_length=8,
        # Le mot de passe doit avoir au moins 8 caractères
        # "abc" ❌  "MonMotDePasse123" ✅
    )


# ══════════════════════════════════════════════════════════════
#  RÉPONSES (ce que le backend RENVOIE à l'app mobile)
# ══════════════════════════════════════════════════════════════

class MessageResponse(BaseModel):
    """
    Réponse simple avec un message.

    Le backend renvoie :
    {
        "message": "OTP envoyé avec succès"
    }
    """
    message: str


class OTPVerifyResponse(BaseModel):
    """
    Réponse après vérification réussie de l'OTP.

    Le backend renvoie :
    {
        "message": "OTP valide",
        "reset_autorise": true
    }

    reset_autorise = True signifie que l'utilisateur peut
    maintenant changer son mot de passe.
    """
    message: str
    reset_autorise: bool = True
class DeleteAccountRequest(BaseModel):
    mot_de_passe: str = Field(
        min_length=1,
        description="Mot de passe actuel pour confirmer la suppression"
    )
