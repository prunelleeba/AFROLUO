"""
╔══════════════════════════════════════════════════════════════╗
║       tests/test_auth.py — Tests d'authentification          ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Ces tests vérifient que les endpoints d'authentification
  fonctionnent correctement.

  Exécution : pytest tests/ -v
"""

import pytest
from httpx import AsyncClient, ASGITransport
from main import app


@pytest.mark.asyncio
async def test_register_success():
    """Un utilisateur peut s'inscrire avec des données valides."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.post("/api/v1/register", json={
            "nom": "Test User",
            "email": "test@example.com",
            "password": "password123",
            "langue_id": 1
        })

    # 201 Created
    assert response.status_code == 201
    data = response.json()

    # Le token JWT est retourné
    assert "access_token" in data
    assert data["token_type"] == "bearer"
    assert "user" in data
    assert data["user"]["email"] == "test@example.com"


@pytest.mark.asyncio
async def test_register_duplicate_email():
    """L'inscription échoue si l'email est déjà utilisé."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Premier enregistrement
        await client.post("/api/v1/register", json={
            "nom": "User 1",
            "email": "duplicate@example.com",
            "password": "pass123",
            "langue_id": 1
        })

        # Deuxième avec le même email → erreur 409
        response = await client.post("/api/v1/register", json={
            "nom": "User 2",
            "email": "duplicate@example.com",
            "password": "pass456",
            "langue_id": 1
        })

    assert response.status_code == 409
    assert "déjà utilisé" in response.json()["detail"]


@pytest.mark.asyncio
async def test_login_success():
    """Un utilisateur peut se connecter avec les bons identifiants."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # D'abord créer le compte
        await client.post("/api/v1/register", json={
            "nom": "Login Test",
            "email": "login@example.com",
            "password": "mypassword",
            "langue_id": 1
        })

        # Puis se connecter
        response = await client.post("/api/v1/login", json={
            "email": "login@example.com",
            "password": "mypassword"
        })

    assert response.status_code == 200
    assert "access_token" in response.json()


@pytest.mark.asyncio
async def test_login_wrong_password():
    """La connexion échoue avec un mauvais mot de passe."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        response = await client.post("/api/v1/login", json={
            "email": "nobody@example.com",
            "password": "wrongpassword"
        })

    assert response.status_code == 401


@pytest.mark.asyncio
async def test_profile_requires_auth():
    """Le profil nécessite un token JWT valide."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Sans token → 403
        response = await client.get("/api/v1/profile")

    assert response.status_code in [401, 403]


@pytest.mark.asyncio
async def test_profile_with_token():
    """Un utilisateur connecté peut voir son profil."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # S'inscrire et récupérer le token
        register_response = await client.post("/api/v1/register", json={
            "nom": "Profile Test",
            "email": "profile@example.com",
            "password": "pass123",
            "langue_id": 1
        })
        token = register_response.json()["access_token"]

        # Appeler le profil avec le token
        response = await client.get(
            "/api/v1/profile",
            headers={"Authorization": f"Bearer {token}"}
        )

    assert response.status_code == 200
    data = response.json()
    assert data["email"] == "profile@example.com"
    assert "password" not in data  # Le mot de passe ne doit JAMAIS être retourné
