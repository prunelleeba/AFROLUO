import random
import string
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from passlib.context import CryptContext

from app.db.database import get_db
from app.models.models import Utilisateur
from app.models.otp_model import OTPCode

router = APIRouter(tags=["Password Reset"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def generate_otp(length=6):
    return "".join(random.choices(string.digits, k=length))


@router.post("/forgot-password", summary="Demander reinitialisation mot de passe")
async def forgot_password(email: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Utilisateur).where(Utilisateur.email == email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Email introuvable")

    await db.execute(delete(OTPCode).where(OTPCode.utilisateur_id == user.id))

    otp_code = generate_otp()
    expire_at = datetime.now(timezone.utc) + timedelta(minutes=5)

    otp = OTPCode(
        utilisateur_id=user.id,
        code=otp_code,
        expire_at=expire_at,
        utilise=False
    )
    db.add(otp)
    await db.flush()

    return {
        "message": "Code OTP genere. En production, il sera envoye par email.",
        "otp_code": otp_code,
        "expire_dans": "5 minutes"
    }


@router.post("/verify-otp", summary="Verifier le code OTP")
async def verify_otp(email: str, code: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Utilisateur).where(Utilisateur.email == email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Email introuvable")

    otp_result = await db.execute(
        select(OTPCode).where(
            OTPCode.utilisateur_id == user.id,
            OTPCode.code == code,
            OTPCode.utilise == False
        )
    )
    otp = otp_result.scalar_one_or_none()

    if not otp:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code OTP invalide")

    if datetime.now(timezone.utc) > otp.expire_at:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code OTP expire")

    return {"message": "Code OTP valide", "email": email}


@router.post("/reset-password", summary="Reinitialiser le mot de passe")
async def reset_password(email: str, code: str, new_password: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Utilisateur).where(Utilisateur.email == email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Email introuvable")

    otp_result = await db.execute(
        select(OTPCode).where(
            OTPCode.utilisateur_id == user.id,
            OTPCode.code == code,
            OTPCode.utilise == False
        )
    )
    otp = otp_result.scalar_one_or_none()

    if not otp:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code OTP invalide")

    if datetime.now(timezone.utc) > otp.expire_at:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Code OTP expire")

    user.password = pwd_context.hash(new_password)
    otp.utilise = True
    db.add(user)
    db.add(otp)
    await db.flush()

    return {"message": "Mot de passe reinitialise avec succes"}
