from sqlalchemy import Column, Integer, Text, DateTime, Boolean, ForeignKey, func
from sqlalchemy.orm import relationship
from app.db.database import Base


class OTPCode(Base):
    __tablename__ = "otp_codes"

    id = Column(Integer, primary_key=True, autoincrement=True)
    utilisateur_id = Column(Integer, ForeignKey("utilisateurs.id", ondelete="CASCADE"), nullable=False, index=True)
    code = Column(Text, nullable=False)
    expire_at = Column(DateTime(timezone=True), nullable=False)
    utilise = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    utilisateur = relationship("Utilisateur")
