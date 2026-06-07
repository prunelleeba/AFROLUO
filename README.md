# 🌍 AfroLuo — Backend FastAPI

> Backend professionnel pour l'apprentissage des langues africaines (ewondo, douala, bassa…)

---

## 🏗️ Architecture générale

```
Flutter App (Mobile)
       │
       │  HTTP/HTTPS (JSON)
       ▼
┌─────────────────────────────────────────┐
│         FastAPI (Python)                 │
│  ┌──────────┐  ┌─────────┐  ┌────────┐ │
│  │   Auth   │  │ Lessons │  │  Quiz  │ │
│  │  /login  │  │/lessons │  │ /quiz  │ │
│  └──────────┘  └─────────┘  └────────┘ │
│         │                              │
│    SQLAlchemy (ORM)                    │
└─────────────────────────────────────────┘
       │
       │  SQL (asyncpg)
       ▼
┌─────────────────────────────────────────┐
│         PostgreSQL 16                    │
│  utilisateurs │ contenus │ progression  │
│  langues      │ themes   │ sessions     │
└─────────────────────────────────────────┘
```

---

## 📁 Structure des fichiers

```
afroluo-backend/
│
├── main.py                    ← Point d'entrée : démarre FastAPI
├── requirements.txt           ← Toutes les dépendances Python
├── .env.example               ← Template des variables d'environnement
├── Dockerfile                 ← Recette pour créer l'image Docker
├── docker-compose.yml         ← Lance PostgreSQL + FastAPI ensemble
├── alembic.ini                ← Configuration des migrations BDD
│
├── app/
│   ├── core/
│   │   ├── config.py          ← Lit le fichier .env (paramètres)
│   │   └── security.py        ← JWT, hachage mots de passe
│   │
│   ├── db/
│   │   └── database.py        ← Connexion PostgreSQL (SQLAlchemy)
│   │
│   ├── models/
│   │   └── models.py          ← Tables PostgreSQL en Python
│   │
│   ├── schemas/
│   │   └── schemas.py         ← Validation JSON (Pydantic)
│   │
│   └── api/routes/
│       ├── auth.py            ← POST /register, POST /login
│       ├── users.py           ← GET/PUT /profile
│       ├── languages.py       ← GET /languages
│       ├── lessons.py         ← GET /lessons, GET /lessons/themes
│       ├── quiz.py            ← POST /quiz/generate, POST /quiz/submit
│       ├── progress.py        ← GET /progress, GET /progress/stats
│       └── audio.py           ← POST /audio/upload/{id}
│
├── scripts/
│   └── init_db.sql            ← Données initiales (langues, thèmes…)
│
└── uploads/
    ├── audio/                 ← Fichiers MP3/OGG de prononciation
    └── avatars/               ← Photos de profil utilisateurs
```

---

## 🚀 Lancement étape par étape

### Prérequis
- Python 3.11+
- Docker Desktop installé
- Git

---

### Option A : Avec Docker Compose (recommandé)

```bash
# 1. Cloner le projet
git clone <ton-repo> afroluo-backend
cd afroluo-backend

# 2. Copier et configurer les variables d'environnement
cp .env.example .env
# Édite .env et change SECRET_KEY par une vraie clé secrète !

# 3. Lancer tout (PostgreSQL + FastAPI)
docker compose up -d

# 4. Vérifier que tout tourne
docker compose ps
docker compose logs -f api

# 5. Ouvrir la documentation Swagger
# → http://localhost:8000/docs
```

**C'est tout !** Docker s'occupe de tout installer automatiquement.

---

### Option B : En local (développement)

```bash
# 1. Créer un environnement virtuel Python
python -m venv venv
source venv/bin/activate    # Linux/Mac
# OU : venv\Scripts\activate  # Windows

# 2. Installer les dépendances
pip install -r requirements.txt

# 3. Créer le fichier .env
cp .env.example .env
# Modifie DATABASE_URL pour pointer vers ton PostgreSQL local

# 4. Créer la base de données PostgreSQL
createdb afroluo_db
psql afroluo_db < scripts/init_db.sql

# 5. Lancer le serveur en mode développement
uvicorn main:app --reload --port 8000
# --reload = redémarre automatiquement si tu modifies le code

# 6. Ouvrir Swagger
# → http://localhost:8000/docs
```

---

## 🧪 Tester l'API avec Swagger

1. Ouvre **http://localhost:8000/docs**
2. Tu vois tous les endpoints organisés par groupe
3. Pour tester un endpoint protégé :
   - Clique d'abord sur **POST /api/v1/register** → crée un compte
   - Copie le `access_token` de la réponse
   - Clique sur le bouton **Authorize 🔒** en haut à droite
   - Colle ton token : `Bearer ton_token_ici`
   - Maintenant tous les endpoints protégés fonctionnent !

---

## 🔌 Connexion Flutter → Backend

Dans Flutter, l'URL de base est :
- **Émulateur Android** : `http://10.0.2.2:8000/api/v1`
- **Simulateur iOS / Web** : `http://localhost:8000/api/v1`
- **Production** : `https://api.afroluo.com/api/v1`

Voir le fichier `flutter_integration_example.py` pour le code Dart complet.

---

## 🗄️ Base de données existante

Le fichier `Afroduo.sql` contient la structure originale.
Les tables créées automatiquement par SQLAlchemy correspondent exactement :

| Table PostgreSQL         | Modèle Python          | Description                    |
|--------------------------|------------------------|--------------------------------|
| `langues`                | `Langue`               | Ewondo, Douala, Français…      |
| `utilisateurs`           | `Utilisateur`          | Comptes utilisateurs           |
| `types_contenu`          | `TypeContenu`          | Vocabulaire, Phrase, Quiz…     |
| `themes`                 | `Theme`                | Famille, Animaux, Couleurs…    |
| `themes_traductions`     | `ThemeTraduction`      | Noms des thèmes traduits       |
| `contenus`               | `Contenu`              | Mots et phrases à apprendre   |
| `contenus_traductions`   | `ContenuTraduction`    | Traductions des mots           |
| `contenus_variantes`     | `ContenuVariante`      | Variantes dialectales          |
| `progression`            | `Progression`          | Suivi par utilisateur (SM-2)  |
| `sessions_apprentissage` | `SessionApprentissage` | Sessions de quiz               |

---

## 📡 Endpoints disponibles

| Méthode | URL                          | Auth | Description                    |
|---------|------------------------------|------|-------------------------------|
| POST    | /api/v1/register             | ❌   | Créer un compte               |
| POST    | /api/v1/login                | ❌   | Se connecter                  |
| GET     | /api/v1/languages            | ❌   | Liste des langues             |
| GET     | /api/v1/profile              | ✅   | Mon profil                    |
| PUT     | /api/v1/profile              | ✅   | Modifier mon profil           |
| GET     | /api/v1/lessons/themes       | ❌   | Liste des thèmes              |
| GET     | /api/v1/lessons              | ✅   | Liste des leçons (paginée)   |
| GET     | /api/v1/lessons/{id}         | ✅   | Détail d'une leçon           |
| POST    | /api/v1/quiz/generate        | ✅   | Générer un quiz               |
| POST    | /api/v1/quiz/submit          | ✅   | Soumettre les réponses        |
| GET     | /api/v1/quiz/history         | ✅   | Historique des quiz           |
| GET     | /api/v1/progress             | ✅   | Ma progression                |
| GET     | /api/v1/progress/stats       | ✅   | Mes statistiques              |
| GET     | /api/v1/progress/review      | ✅   | Mots à réviser aujourd'hui   |
| POST    | /api/v1/audio/upload/{id}    | 👑   | Upload audio (admin)          |

✅ = Token JWT requis | 👑 = Admin requis | ❌ = Public

---

## 🔐 Sécurité

1. **Mots de passe** : jamais stockés en clair, toujours hashés avec bcrypt
2. **JWT** : token signé avec une clé secrète, expiration configurable
3. **CORS** : configure `ALLOWED_ORIGINS` pour restreindre les origines en prod
4. **Variables d'environnement** : les secrets sont dans `.env` (jamais sur GitHub)

---

## 🏆 Points forts pour la compétition

- ✅ Architecture RESTful professionnelle
- ✅ Base de données fidèle aux données réelles (scraper ewondo)
- ✅ Algorithme de répétition espacée (SM-2) pour la mémorisation
- ✅ API documentée automatiquement (Swagger UI)
- ✅ Tests d'intégration inclus
- ✅ Déploiement Docker en une commande
- ✅ Code commenté et pédagogique
- ✅ Gestion des erreurs robuste
- ✅ Support audio pour la prononciation
