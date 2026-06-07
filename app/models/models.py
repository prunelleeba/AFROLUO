"""
╔══════════════════════════════════════════════════════════════╗
║         app/models/ — Modèles SQLAlchemy                     ║
║   Traduction fidèle de la base Afroduo.sql existante         ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Chaque classe Python = une table PostgreSQL.
  SQLAlchemy traduit les objets Python ↔ lignes SQL.

  Ta base existante contient :
    - utilisateurs     → class Utilisateur
    - langues          → class Langue
    - themes           → class Theme
    - themes_traductions → class ThemeTraduction
    - types_contenu    → class TypeContenu
    - contenus         → class Contenu
    - contenus_traductions → class ContenuTraduction
    - contenus_variantes   → class ContenuVariante
    - progression      → class Progression
    - sessions_apprentissage → class SessionApprentissage
"""

from sqlalchemy import (
    Column, Integer, BigInteger, Text, Boolean, Date, Float,
    ForeignKey, DateTime, func, String, UniqueConstraint
)
from sqlalchemy.orm import relationship
from app.db.database import Base


# ══════════════════════════════════════════════════════════════
#  LANGUES — Les langues disponibles dans l'application
#  Exemples : ewondo, douala, bassa, français, anglais
# ══════════════════════════════════════════════════════════════
class Langue(Base):
    __tablename__ = "langues"

    id = Column(Integer, primary_key=True, autoincrement=True)
    code = Column(Text, nullable=False, unique=True)   # "ewondo", "douala", "fr"
    nom  = Column(Text, nullable=False)                # "Ewondo", "Douala", "Français"
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Relations
    utilisateurs = relationship("Utilisateur", back_populates="langue_preferee")
    contenus = relationship("Contenu", back_populates="langue_source")


# ══════════════════════════════════════════════════════════════
#  UTILISATEURS — Les comptes utilisateurs
# ══════════════════════════════════════════════════════════════
class Utilisateur(Base):
    __tablename__ = "utilisateurs"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nom        = Column(Text, nullable=False)
    email      = Column(Text, unique=True, index=True)  # Indexé pour recherche rapide
    langue_id  = Column(Integer, ForeignKey("langues.id"), nullable=False)
    password   = Column(Text)                 # Stocké hashé (bcrypt)
    avatar_url = Column(Text)                 # URL de l'image de profil
    is_admin   = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Relations (SQLAlchemy charge automatiquement les objets liés)
    langue_preferee = relationship("Langue", back_populates="utilisateurs")
    progressions = relationship("Progression", back_populates="utilisateur", cascade="all, delete-orphan")
    sessions = relationship("SessionApprentissage", back_populates="utilisateur", cascade="all, delete-orphan")


# ══════════════════════════════════════════════════════════════
#  TYPES DE CONTENU — vocabulaire, phrase, dialogue, quiz...
# ══════════════════════════════════════════════════════════════
class TypeContenu(Base):
    __tablename__ = "types_contenu"

    id      = Column(Integer, primary_key=True, autoincrement=True)
    code    = Column(Text, nullable=False, unique=True)  # "vocabulaire", "phrase", "quiz"
    libelle = Column(Text, nullable=False)               # "Vocabulaire", "Phrase", "Quiz"
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    contenus = relationship("Contenu", back_populates="type_contenu")


# ══════════════════════════════════════════════════════════════
#  THÈMES — catégories de leçons : Famille, Animaux, Couleurs...
# ══════════════════════════════════════════════════════════════
class Theme(Base):
    __tablename__ = "themes"

    id    = Column(Integer, primary_key=True, autoincrement=True)
    code  = Column(Text, nullable=False, unique=True)  # "famille", "animaux"
    ordre = Column(Integer, nullable=False)            # Ordre d'affichage dans l'app
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    traductions = relationship("ThemeTraduction", back_populates="theme", cascade="all, delete-orphan")
    contenus = relationship("Contenu", back_populates="theme")


class ThemeTraduction(Base):
    """Traductions des noms de thèmes dans différentes langues."""
    __tablename__ = "themes_traductions"

    theme_id   = Column(Integer, ForeignKey("themes.id", ondelete="CASCADE"), primary_key=True)
    langue_id  = Column(Integer, ForeignKey("langues.id"), primary_key=True)
    traduction = Column(Text, nullable=False)  # "Famille" (fr), "Family" (en)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    theme  = relationship("Theme", back_populates="traductions")
    langue = relationship("Langue")


# ══════════════════════════════════════════════════════════════
#  CONTENUS — le cœur : mots, phrases, expressions à apprendre
#  Exemple : {"ewondo": "ngɔn", "fr": "mois", "en": "month"}
# ══════════════════════════════════════════════════════════════
class Contenu(Base):
    __tablename__ = "contenus"

    id                = Column(Integer, primary_key=True, autoincrement=True)
    langue_source_id  = Column(Integer, ForeignKey("langues.id"), nullable=False)
    type_contenu_id   = Column(Integer, ForeignKey("types_contenu.id"), nullable=False)
    theme_id          = Column(Integer, ForeignKey("themes.id"))
    texte_source      = Column(Text, nullable=False)   # Le mot en langue africaine : "ngɔn"
    prononciation     = Column(Text)                   # Guide de prononciation : "ngon"
    niveau            = Column(Integer, default=1)     # 1=débutant, 2=intermédiaire, 3=avancé
    audio_fichier     = Column(Text)                   # Chemin du fichier MP3 : "ewondo/ngon.mp3"
    actif             = Column(Boolean, default=True)  # False = masqué dans l'app
    ordre             = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Relations
    langue_source = relationship("Langue", back_populates="contenus")
    type_contenu  = relationship("TypeContenu", back_populates="contenus")
    theme         = relationship("Theme", back_populates="contenus")
    traductions   = relationship("ContenuTraduction", back_populates="contenu", cascade="all, delete-orphan")
    variantes     = relationship("ContenuVariante", back_populates="contenu", cascade="all, delete-orphan")
    progressions  = relationship("Progression", back_populates="contenu", cascade="all, delete-orphan")


class ContenuTraduction(Base):
    """Traduction d'un contenu dans une autre langue."""
    __tablename__ = "contenus_traductions"

    contenu_id = Column(Integer, ForeignKey("contenus.id", ondelete="CASCADE"), primary_key=True)
    langue_id  = Column(Integer, ForeignKey("langues.id"), primary_key=True)
    traduction = Column(Text, nullable=False)  # "month" (en), "mois" (fr)
    exemple    = Column(Text)                  # "This month = Ngɔn oné"
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    contenu = relationship("Contenu", back_populates="traductions")
    langue  = relationship("Langue")


class ContenuVariante(Base):
    """Variantes dialectales d'un mot selon la région."""
    __tablename__ = "contenus_variantes"

    id         = Column(BigInteger, primary_key=True, autoincrement=True)
    contenu_id = Column(Integer, ForeignKey("contenus.id", ondelete="CASCADE"), nullable=False)
    langue_id  = Column(Integer, ForeignKey("langues.id"), nullable=False)
    variante   = Column(Text, nullable=False)  # Forme alternative du mot
    note       = Column(Text)                  # Explication de la variante
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    contenu = relationship("Contenu", back_populates="variantes")
    langue  = relationship("Langue")


# ══════════════════════════════════════════════════════════════
#  PROGRESSION — suivi d'apprentissage par utilisateur
#  Implémente l'algorithme SM-2 (répétition espacée, comme Anki)
# ══════════════════════════════════════════════════════════════
class Progression(Base):
    __tablename__ = "progression"

    utilisateur_id      = Column(Integer, ForeignKey("utilisateurs.id", ondelete="CASCADE"), primary_key=True)
    contenu_id          = Column(Integer, ForeignKey("contenus.id", ondelete="CASCADE"), primary_key=True)
    nb_bonnes_reponses  = Column(Integer, default=0)     # Combien de fois bien répondu
    nb_mauvaises_reponses = Column(Integer, default=0)  # Combien de fois mal répondu
    derniere_vue        = Column(Date)                   # Date de la dernière révision
    prochaine_revision  = Column(Date)                   # Date de la prochaine révision
    intervalle_jours    = Column(Integer, default=1)     # Intervalle avant prochaine révision
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    utilisateur = relationship("Utilisateur", back_populates="progressions")
    contenu     = relationship("Contenu", back_populates="progressions")


# ══════════════════════════════════════════════════════════════
#  SESSIONS D'APPRENTISSAGE — chaque séance de l'app
# ══════════════════════════════════════════════════════════════
class SessionApprentissage(Base):
    __tablename__ = "sessions_apprentissage"

    id             = Column(BigInteger, primary_key=True, autoincrement=True)
    utilisateur_id = Column(Integer, ForeignKey("utilisateurs.id", ondelete="CASCADE"), nullable=False)
    langue_id      = Column(Integer, ForeignKey("langues.id"))
    theme_id       = Column(Integer, ForeignKey("themes.id"))
    nb_total       = Column(Integer, default=0)    # Total de questions dans la session
    nb_correct     = Column(Integer, default=0)    # Bonnes réponses
    duree_secondes = Column(Integer)               # Durée de la session
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    utilisateur = relationship("Utilisateur", back_populates="sessions")
    langue      = relationship("Langue")
    theme       = relationship("Theme")
