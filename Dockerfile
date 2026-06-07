# ══════════════════════════════════════════════════════════════
#  Dockerfile — Image Docker pour AfroLuo Backend
# ══════════════════════════════════════════════════════════════
#
#  RÔLE DE DOCKER :
#  Docker crée une "boîte" (container) isolée qui contient
#  tout ce qu'il faut pour faire tourner l'application :
#  Python, les bibliothèques, le code.
#  Avantage : "ça marche chez moi" → "ça marche partout"
#
#  CONSTRUCTION :
#    docker build -t afroluo-backend .
#
#  EXÉCUTION :
#    docker run -p 8000:8000 afroluo-backend
# ══════════════════════════════════════════════════════════════

# ── Étape 1 : Image de base ────────────────────────────────────
# python:3.11-slim = Python 3.11 minimal (pas d'extras inutiles)
# Cela réduit la taille de l'image : ~180MB au lieu de ~900MB
FROM python:3.11-slim

# ── Étape 2 : Variables d'environnement Python ─────────────────
ENV PYTHONDONTWRITEBYTECODE=1  # Ne pas créer de fichiers .pyc
ENV PYTHONUNBUFFERED=1         # Afficher les logs en temps réel

# ── Étape 3 : Dossier de travail dans le container ─────────────
WORKDIR /app

# ── Étape 4 : Dépendances système ──────────────────────────────
# Nécessaires pour compiler certaines bibliothèques Python
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# ── Étape 5 : Copier et installer les dépendances Python ───────
# IMPORTANT : on copie d'abord requirements.txt SEUL.
# Pourquoi ? Docker met en cache cette couche.
# Si on change seulement le code Python (pas les deps),
# Docker réutilise le cache → build plus rapide !
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Étape 6 : Copier le code source ────────────────────────────
COPY . .

# ── Étape 7 : Créer les dossiers nécessaires ──────────────────
RUN mkdir -p uploads/audio uploads/avatars

# ── Étape 8 : Port exposé ──────────────────────────────────────
# Informe Docker que le container écoute sur le port 8000
EXPOSE 8000

# ── Étape 9 : Commande de démarrage ────────────────────────────
# uvicorn main:app = lance le serveur FastAPI
# --host 0.0.0.0  = accepte les connexions de l'extérieur du container
# --port 8000     = port d'écoute
# --workers 2     = 2 processus parallèles (pour la prod)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "2"]
