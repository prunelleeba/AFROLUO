"""
╔══════════════════════════════════════════════════════════════╗
║         app/models/otp_model.py — Modèle OTP                ║
║   Table PostgreSQL pour stocker les codes OTP temporaires    ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Ce fichier crée une nouvelle table "otp_codes" dans PostgreSQL.
  Chaque ligne = un code OTP envoyé à un utilisateur.

  Fonctionnement :
  1. L'utilisateur demande un mot de passe oublié
  2. On génère un code OTP à 6 chiffres (ex: 482916)
  3. On sauvegarde ce code ici avec une date d'expiration (5 min)
  4. On envoie le code par email
  5. L'utilisateur saisit le code
  6. On vérifie ici si le code est bon et pas expiré
  7. On supprime le code après utilisation
"""

from sqlalchemy import Column, Integer, Text, DateTime, Boolean, ForeignKey, func
from sqlalchemy.orm import relationship
from app.db.database import Base  # Base partagée avec tous les autres modèles


class OTPCode(Base):
    """
    Table 'otp_codes' — Stocke les codes OTP temporaires.

    Exemple d'une ligne dans cette table :
    | id | utilisateur_id | code   | expire_at           | utilise |
    |----|----------------|--------|---------------------|---------|
    | 1  | 42             | 482916 | 2026-06-05 10:35:00 | False   |
    """

    __tablename__ = "otp_codes"

    # ── Clé primaire ──────────────────────────────────────────
    id = Column(Integer, primary_key=True, autoincrement=True)
    # Numéro unique pour chaque OTP (1, 2, 3...)

    # ── Lien vers l'utilisateur ───────────────────────────────
    utilisateur_id = Column(
        Integer,
        ForeignKey("utilisateurs.id", ondelete="CASCADE"),
        # ondelete CASCADE = si l'utilisateur est supprimé,
        # tous ses OTP sont aussi supprimés automatiquement
        nullable=False,
        index=True  # Index pour recherche rapide par utilisateur
    )

    # ── Le code OTP ───────────────────────────────────────────
    code = Column(Text, nullable=False)
    # Le code à 6 chiffres : "482916"
    # On stocke en Text (pas Integer) pour garder les zéros du début
    # Ex: "082916" resterait "082916" et pas 82916

    # ── Date d'expiration ─────────────────────────────────────
    expire_at = Column(DateTime(timezone=True), nullable=False)
    # Le code expire après 5 minutes
    # Ex: créé à 10:30 → expire à 10:35
    # Après cette heure, le code est refusé

    # ── Le code a-t-il déjà été utilisé ? ────────────────────
    utilise = Column(Boolean, default=False, nullable=False)
    # False = pas encore utilisé (valide)
    # True  = déjà utilisé (invalide, ne peut pas resservir)

    # ── Dates de création ─────────────────────────────────────
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False
    )
    # Enregistre quand l'OTP a été créé

    # ── Relation avec la table utilisateurs ───────────────────
    utilisateur = relationship("Utilisateur")
    # Permet d'accéder à l'utilisateur via otp.utilisateur
    # Ex: otp.utilisateur.email → "marie@gmail.com"
