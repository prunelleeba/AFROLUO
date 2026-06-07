from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime, date


class RegisterRequest(BaseModel):
    nom: str = Field(..., min_length=2, max_length=100, description="Nom complet de l'utilisateur")
    email: EmailStr = Field(..., description="Adresse email valide et unique")
    password: str = Field(..., min_length=6, description="Mot de passe minimum 6 caracteres")
    langue_id: int = Field(..., description="ID de la langue preferee (1=Francais, 2=Ewondo, etc)")
    model_config = {
        'json_schema_extra': {
            'example': {
                'nom': 'Amina Bello',
                'email': 'amina@gmail.com',
                'password': 'motdepasse123',
                'langue_id': 1
            }
        }
    }


class LoginRequest(BaseModel):
    email: EmailStr = Field(..., description="Adresse email du compte")
    password: str = Field(..., description="Mot de passe du compte")
    model_config = {
        'json_schema_extra': {
            'example': {
                'email': 'amina@gmail.com',
                'password': 'motdepasse123'
            }
        }
    }


class LangueResponse(BaseModel):
    id: int = Field(..., description="Identifiant unique de la langue")
    code: str = Field(..., description="Code court de la langue: fr, ewondo, douala, bassa")
    nom: str = Field(..., description="Nom complet de la langue")
    model_config = {
        'from_attributes': True,
        'json_schema_extra': {
            'example': {
                'id': 1,
                'code': 'ewondo',
                'nom': 'Ewondo'
            }
        }
    }


class LangueCreate(BaseModel):
    code: str = Field(..., min_length=2, max_length=20, description="Code court unique: ewondo, douala, bassa")
    nom: str = Field(..., min_length=2, description="Nom complet de la langue")


class ProgressionResume(BaseModel):
    total_mots_vus: int = Field(..., description="Nombre total de mots que l'utilisateur a deja rencontres")
    total_bonnes_reponses: int = Field(..., description="Nombre total de bonnes reponses dans tous les quiz")
    total_mauvaises_reponses: int = Field(..., description="Nombre total de mauvaises reponses dans tous les quiz")
    score_global_pourcent: float = Field(..., description="Score global en pourcentage de 0 a 100")
    mots_a_revoir_aujourd_hui: int = Field(..., description="Nombre de mots dont la revision est due aujourd'hui (algorithme SM-2)")
    nb_sessions_total: int = Field(..., description="Nombre total de sessions de quiz effectuees")
    niveau: str = Field(..., description="Niveau actuel: debutant (0-29 mots), intermediaire (30-99 mots), avance (100+ mots)")
    model_config = {
        'json_schema_extra': {
            'example': {
                'total_mots_vus': 45,
                'total_bonnes_reponses': 38,
                'total_mauvaises_reponses': 7,
                'score_global_pourcent': 84.4,
                'mots_a_revoir_aujourd_hui': 3,
                'nb_sessions_total': 5,
                'niveau': 'intermediaire'
            }
        }
    }


class UserResponse(BaseModel):
    id: int = Field(..., description="Identifiant unique de l'utilisateur")
    nom: str = Field(..., description="Nom complet de l'utilisateur")
    email: Optional[str] = Field(None, description="Adresse email de l'utilisateur")
    avatar_url: Optional[str] = Field(None, description="URL de la photo de profil, null si pas encore definie")
    is_admin: bool = Field(..., description="True si administrateur, False si utilisateur normal")
    langue_id: int = Field(..., description="ID de la langue preferee de l'utilisateur")
    langue: Optional[LangueResponse] = Field(None, description="Details complets de la langue preferee")
    created_at: datetime = Field(..., description="Date et heure de creation du compte au format ISO 8601")
    model_config = {'from_attributes': True}


class UserFullResponse(BaseModel):
    id: int = Field(..., description="Identifiant unique de l'utilisateur")
    nom: str = Field(..., description="Nom complet de l'utilisateur")
    email: Optional[str] = Field(None, description="Adresse email de l'utilisateur")
    avatar_url: Optional[str] = Field(None, description="URL complete de la photo de profil, null si pas definie")
    is_admin: bool = Field(..., description="True si administrateur, False si utilisateur normal")
    langue_id: int = Field(..., description="ID de la langue preferee")
    langue: Optional[LangueResponse] = Field(None, description="Details complets de la langue preferee")
    created_at: datetime = Field(..., description="Date et heure de creation du compte au format ISO 8601")
    progression: Optional[ProgressionResume] = Field(None, description="Resume complet de la progression et des statistiques")
    model_config = {
        'from_attributes': True,
        'json_schema_extra': {
            'example': {
                'id': 3,
                'nom': 'Amina Bello',
                'email': 'amina@gmail.com',
                'avatar_url': None,
                'is_admin': False,
                'langue_id': 2,
                'langue': {'id': 2, 'code': 'ewondo', 'nom': 'Ewondo'},
                'created_at': '2026-05-30T21:47:33.749970Z',
                'progression': {
                    'total_mots_vus': 45,
                    'total_bonnes_reponses': 38,
                    'total_mauvaises_reponses': 7,
                    'score_global_pourcent': 84.4,
                    'mots_a_revoir_aujourd_hui': 3,
                    'nb_sessions_total': 5,
                    'niveau': 'intermediaire'
                }
            }
        }
    }


class TokenResponse(BaseModel):
    access_token: str = Field(..., description="Token JWT a stocker dans SharedPreferences et envoyer dans chaque requete dans le header Authorization: Bearer <token>")
    token_type: str = Field(default='bearer', description="Type du token, toujours 'bearer'")
    expires_in: int = Field(..., description="Duree de validite du token en secondes (604800 = 7 jours)")
    user: UserFullResponse = Field(..., description="Toutes les informations de l'utilisateur connecte avec sa progression")
    model_config = {
        'json_schema_extra': {
            'example': {
                'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                'token_type': 'bearer',
                'expires_in': 604800,
                'user': {
                    'id': 3,
                    'nom': 'Amina Bello',
                    'email': 'amina@gmail.com',
                    'avatar_url': None,
                    'is_admin': False,
                    'langue_id': 2,
                    'langue': {'id': 2, 'code': 'ewondo', 'nom': 'Ewondo'},
                    'created_at': '2026-05-30T21:47:33.749970Z',
                    'progression': {
                        'total_mots_vus': 45,
                        'total_bonnes_reponses': 38,
                        'total_mauvaises_reponses': 7,
                        'score_global_pourcent': 84.4,
                        'mots_a_revoir_aujourd_hui': 3,
                        'nb_sessions_total': 5,
                        'niveau': 'intermediaire'
                    }
                }
            }
        }
    }


class UserUpdateRequest(BaseModel):
    nom: Optional[str] = Field(None, min_length=2, max_length=100, description="Nouveau nom complet")
    email: Optional[EmailStr] = Field(None, description="Nouvel email unique")
    avatar_url: Optional[str] = Field(None, description="Nouvelle URL de photo de profil")
    langue_id: Optional[int] = Field(None, description="Nouvel ID de langue preferee")
    model_config = {
        'json_schema_extra': {
            'example': {
                'nom': 'Amina Bello Updated',
                'langue_id': 2
            }
        }
    }


class ChangePasswordRequest(BaseModel):
    old_password: str = Field(..., description="Ancien mot de passe pour verification")
    new_password: str = Field(..., min_length=6, description="Nouveau mot de passe minimum 6 caracteres")
    model_config = {
        'json_schema_extra': {
            'example': {
                'old_password': 'ancienmdp123',
                'new_password': 'nouveaumdp456'
            }
        }
    }


class ThemeResponse(BaseModel):
    id: int = Field(..., description="Identifiant unique du theme")
    code: str = Field(..., description="Code du theme: famille, animaux, couleurs, salutations...")
    ordre: int = Field(..., description="Ordre d'affichage dans l'application")
    nom_traduit: Optional[str] = Field(None, description="Nom du theme dans la langue de l'utilisateur")
    model_config = {
        'from_attributes': True,
        'json_schema_extra': {
            'example': {
                'id': 2,
                'code': 'famille',
                'ordre': 2,
                'nom_traduit': 'Famille'
            }
        }
    }


class TraductionResponse(BaseModel):
    langue_code: str = Field(..., description="Code de la langue de traduction: fr, en, douala...")
    langue_nom: str = Field(..., description="Nom complet de la langue de traduction")
    traduction: str = Field(..., description="Traduction du mot dans cette langue")
    exemple: Optional[str] = Field(None, description="Exemple d'utilisation du mot dans une phrase")
    model_config = {
        'from_attributes': True,
        'json_schema_extra': {
            'example': {
                'langue_code': 'fr',
                'langue_nom': 'Francais',
                'traduction': 'janvier',
                'exemple': 'Ngon osu ozo = Nous sommes en janvier'
            }
        }
    }


class ContenuResponse(BaseModel):
    id: int = Field(..., description="Identifiant unique du contenu")
    texte_source: str = Field(..., description="Le mot ou la phrase dans la langue africaine a apprendre")
    prononciation: Optional[str] = Field(None, description="Guide de prononciation phonetique du mot")
    niveau: int = Field(..., description="Niveau de difficulte: 1=debutant, 2=intermediaire, 3=avance")
    audio_url: Optional[str] = Field(None, description="URL complete du fichier audio MP3 pour la prononciation, null si pas encore enregistre")
    theme_code: Optional[str] = Field(None, description="Code du theme auquel appartient ce mot: famille, animaux...")
    type_code: str = Field(..., description="Type de contenu: vocabulaire, phrase, expression, dialogue, proverbe")
    traductions: List[TraductionResponse] = Field(default=[], description="Liste des traductions dans toutes les langues disponibles")
    model_config = {
        'from_attributes': True,
        'json_schema_extra': {
            'example': {
                'id': 1,
                'texte_source': 'ngon osu',
                'prononciation': 'ngon osu',
                'niveau': 1,
                'audio_url': 'http://localhost:8000/uploads/audio/ngon_osu.mp3',
                'theme_code': 'mois_saisons',
                'type_code': 'vocabulaire',
                'traductions': [
                    {'langue_code': 'fr', 'langue_nom': 'Francais', 'traduction': 'janvier', 'exemple': None},
                    {'langue_code': 'en', 'langue_nom': 'English', 'traduction': 'january', 'exemple': None}
                ]
            }
        }
    }


class ContenuCreate(BaseModel):
    langue_source_id: int = Field(..., description="ID de la langue source du contenu (ex: 2 pour ewondo)")
    type_contenu_id: int = Field(..., description="ID du type de contenu (1=vocabulaire, 2=phrase...)")
    theme_id: Optional[int] = Field(None, description="ID du theme (optionnel)")
    texte_source: str = Field(..., min_length=1, description="Le mot ou phrase dans la langue africaine")
    prononciation: Optional[str] = Field(None, description="Guide phonetique de prononciation")
    niveau: int = Field(default=1, ge=1, le=3, description="Niveau: 1=debutant, 2=intermediaire, 3=avance")
    ordre: int = Field(default=0, description="Ordre d'affichage dans la liste")


class QuizQuestion(BaseModel):
    contenu_id: int = Field(..., description="ID du contenu source de la question")
    texte_source: str = Field(..., description="Le mot en langue africaine a traduire")
    prononciation: Optional[str] = Field(None, description="Prononciation phonetique du mot")
    audio_url: Optional[str] = Field(None, description="URL audio du mot pour ecouter la prononciation")
    question: str = Field(..., description="La question posee a l'utilisateur")
    choix: List[str] = Field(..., description="Liste de 4 reponses possibles, une seule est correcte")
    bonne_reponse_index: int = Field(..., description="Index (0 a 3) de la bonne reponse dans la liste choix")
    model_config = {
        'json_schema_extra': {
            'example': {
                'contenu_id': 1,
                'texte_source': 'ngon osu',
                'prononciation': 'ngon osu',
                'audio_url': 'http://localhost:8000/uploads/audio/ngon_osu.mp3',
                'question': "Comment traduit-on 'ngon osu' ?",
                'choix': ['janvier', 'fevrier', 'mars', 'avril'],
                'bonne_reponse_index': 0
            }
        }
    }


class QuizRequest(BaseModel):
    langue_id: int = Field(..., description="ID de la langue a apprendre (ex: 2 pour ewondo)")
    theme_id: Optional[int] = Field(None, description="ID du theme pour filtrer les questions, null pour toutes les categories")
    nb_questions: int = Field(default=10, ge=1, le=50, description="Nombre de questions souhaite, entre 1 et 50")
    niveau: Optional[int] = Field(None, ge=1, le=3, description="Filtrer par niveau: 1=debutant, 2=intermediaire, 3=avance, null pour tous")
    model_config = {
        'json_schema_extra': {
            'example': {
                'langue_id': 2,
                'theme_id': 3,
                'nb_questions': 10,
                'niveau': 1
            }
        }
    }


class QuizAnswerRequest(BaseModel):
    contenu_id: int = Field(..., description="ID du contenu auquel l'utilisateur repond")
    reponse_index: int = Field(..., description="Index de la reponse choisie par l'utilisateur (0 a 3)")
    temps_secondes: Optional[int] = Field(None, description="Temps en secondes que l'utilisateur a pris pour repondre")
    model_config = {
        'json_schema_extra': {
            'example': {
                'contenu_id': 1,
                'reponse_index': 0,
                'temps_secondes': 5
            }
        }
    }


class QuizResultResponse(BaseModel):
    session_id: int = Field(..., description="Identifiant unique de la session de quiz")
    nb_total: int = Field(..., description="Nombre total de questions dans le quiz")
    nb_correct: int = Field(..., description="Nombre de bonnes reponses obtenues")
    score_pourcent: float = Field(..., description="Score en pourcentage de 0 a 100")
    duree_secondes: Optional[int] = Field(None, description="Duree totale du quiz en secondes")
    message: str = Field(..., description="Message de motivation selon le score obtenu")
    model_config = {
        'json_schema_extra': {
            'example': {
                'session_id': 12,
                'nb_total': 10,
                'nb_correct': 8,
                'score_pourcent': 80.0,
                'duree_secondes': 120,
                'message': 'Bien joue ! Continue comme ca !'
            }
        }
    }


class ProgressionResponse(BaseModel):
    contenu_id: int = Field(..., description="ID du contenu suivi")
    texte_source: str = Field(..., description="Le mot en langue africaine")
    nb_bonnes_reponses: int = Field(..., description="Nombre de fois que l'utilisateur a bien repondu a ce mot")
    nb_mauvaises_reponses: int = Field(..., description="Nombre de fois que l'utilisateur a mal repondu a ce mot")
    derniere_vue: Optional[date] = Field(None, description="Date de la derniere revision de ce mot (format YYYY-MM-DD)")
    prochaine_revision: Optional[date] = Field(None, description="Date prevue pour la prochaine revision selon l'algorithme SM-2")
    intervalle_jours: int = Field(..., description="Nombre de jours avant la prochaine revision (augmente si bonnes reponses)")
    maitrise_pourcent: float = Field(..., description="Taux de maitrise de ce mot en pourcentage de 0 a 100")
    model_config = {
        'from_attributes': True,
        'json_schema_extra': {
            'example': {
                'contenu_id': 1,
                'texte_source': 'ngon osu',
                'nb_bonnes_reponses': 5,
                'nb_mauvaises_reponses': 1,
                'derniere_vue': '2026-05-29',
                'prochaine_revision': '2026-06-05',
                'intervalle_jours': 7,
                'maitrise_pourcent': 83.3
            }
        }
    }


class ProgressionUpdateRequest(BaseModel):
    contenu_id: int = Field(..., description="ID du contenu auquel l'utilisateur vient de repondre")
    correct: bool = Field(..., description="True si bonne reponse, False si mauvaise reponse")
    model_config = {
        'json_schema_extra': {
            'example': {
                'contenu_id': 1,
                'correct': True
            }
        }
    }


class StatsUtilisateur(BaseModel):
    total_mots_appris: int = Field(..., description="Nombre total de mots rencontres au moins une fois")
    total_bonnes_reponses: int = Field(..., description="Cumul de toutes les bonnes reponses")
    total_mauvaises_reponses: int = Field(..., description="Cumul de toutes les mauvaises reponses")
    score_global_pourcent: float = Field(..., description="Score global en pourcentage")
    nb_sessions: int = Field(..., description="Nombre total de sessions de quiz effectuees")
    mots_a_revoir_aujourd_hui: int = Field(..., description="Mots dont la date de revision est aujourd'hui ou depassee")


class AudioUploadResponse(BaseModel):
    contenu_id: int = Field(..., description="ID du contenu auquel l'audio a ete associe")
    audio_url: str = Field(..., description="URL complete pour acceder au fichier audio depuis Flutter")
    fichier_nom: str = Field(..., description="Nom du fichier audio sur le serveur")
    taille_ko: float = Field(..., description="Taille du fichier en kilooctets")
    model_config = {
        'json_schema_extra': {
            'example': {
                'contenu_id': 1,
                'audio_url': 'http://localhost:8000/uploads/audio/ngon_osu_a1b2.mp3',
                'fichier_nom': 'ngon_osu_a1b2.mp3',
                'taille_ko': 45.2
            }
        }
    }


class PaginatedResponse(BaseModel):
    total: int = Field(..., description="Nombre total d'elements dans la base de donnees")
    page: int = Field(..., description="Numero de la page actuelle (commence a 1)")
    page_size: int = Field(..., description="Nombre d'elements par page")
    total_pages: int = Field(..., description="Nombre total de pages disponibles")
    items: list = Field(..., description="Liste des elements de la page actuelle")
    model_config = {
        'json_schema_extra': {
            'example': {
                'total': 150,
                'page': 1,
                'page_size': 20,
                'total_pages': 8,
                'items': []
            }
        }
    }


TokenResponse.model_rebuild()
