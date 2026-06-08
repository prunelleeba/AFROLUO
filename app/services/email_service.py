"""
╔══════════════════════════════════════════════════════════════╗
║      app/services/email_service.py — Service Email          ║
║   Envoie les codes OTP par email via Gmail SMTP              ║
╚══════════════════════════════════════════════════════════════╝

RÔLE :
  Ce fichier contient toute la logique pour envoyer des emails.
  Il utilise la bibliothèque "aiosmtplib" pour envoyer des
  emails de façon asynchrone (sans bloquer le serveur).

  Comment ça marche :
  1. Le backend génère un OTP : "482916"
  2. Ce service crée un beau email HTML avec le code
  3. Il se connecte à Gmail (SMTP) avec tes identifiants
  4. Il envoie l'email à l'utilisateur
  5. L'utilisateur reçoit l'email avec le code
"""

import aiosmtplib  # Pour envoyer des emails de façon asynchrone
from email.mime.multipart import MIMEMultipart  # Pour créer des emails avec plusieurs parties
from email.mime.text import MIMEText  # Pour la partie texte de l'email
from app.core.config import settings  # Pour lire les variables du fichier .env
import logging  # Pour écrire des logs (messages de debug)

# Crée un logger pour ce fichier
# Les logs apparaîtront dans le terminal quand tu lances le serveur
logger = logging.getLogger(__name__)


async def envoyer_otp_par_email(email_destinataire: str, code_otp: str, nom_utilisateur: str) -> bool:
    """
    Envoie un email avec le code OTP à l'utilisateur.

    Paramètres :
    - email_destinataire : l'email de l'utilisateur (ex: "marie@gmail.com")
    - code_otp           : le code à 6 chiffres (ex: "482916")
    - nom_utilisateur    : le prénom pour personnaliser l'email (ex: "Marie")

    Retourne :
    - True  si l'email a été envoyé avec succès
    - False si une erreur s'est produite
    """

    # ── Étape 1 : Créer l'email ───────────────────────────────
    message = MIMEMultipart("alternative")
    # "alternative" = l'email aura une version texte ET une version HTML
    # Si le client email ne supporte pas HTML → version texte

    message["Subject"] = "🔐 AfroLuo — Votre code de réinitialisation"
    message["From"] = settings.MAIL_FROM
    # settings.MAIL_FROM vient de ton fichier .env
    message["To"] = email_destinataire

    # ── Étape 2 : Créer le contenu texte (version simple) ─────
    texte_simple = f"""
Bonjour {nom_utilisateur},

Vous avez demandé à réinitialiser votre mot de passe AfroLuo.

Votre code de vérification est : {code_otp}

Ce code est valable pendant 5 minutes.
Si vous n'avez pas fait cette demande, ignorez cet email.

L'équipe AfroLuo
    """

    # ── Étape 3 : Créer le contenu HTML (version jolie) ───────
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body {{ font-family: Arial, sans-serif; background: #f5f5f5; margin: 0; padding: 20px; }}
            .container {{ max-width: 500px; margin: auto; background: white; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1); }}
            .header {{ background: linear-gradient(135deg, #FF6B35, #F7C948); padding: 30px; text-align: center; }}
            .header h1 {{ color: white; margin: 0; font-size: 28px; }}
            .header p {{ color: rgba(255,255,255,0.9); margin: 5px 0 0; }}
            .body {{ padding: 35px 30px; }}
            .greeting {{ font-size: 18px; color: #333; margin-bottom: 15px; }}
            .message {{ color: #666; line-height: 1.6; margin-bottom: 25px; }}
            .otp-box {{ background: #FFF8E7; border: 2px dashed #F7C948; border-radius: 12px; padding: 25px; text-align: center; margin: 25px 0; }}
            .otp-label {{ font-size: 13px; color: #999; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 10px; }}
            .otp-code {{ font-size: 42px; font-weight: bold; color: #FF6B35; letter-spacing: 10px; }}
            .expiry {{ font-size: 13px; color: #e74c3c; margin-top: 10px; }}
            .warning {{ background: #fff3cd; border-left: 4px solid #ffc107; padding: 12px 15px; border-radius: 4px; font-size: 13px; color: #856404; margin-top: 20px; }}
            .footer {{ background: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #999; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1>🌍 AfroLuo</h1>
                <p>Apprentissage des langues africaines</p>
            </div>
            <div class="body">
                <p class="greeting">Bonjour <strong>{nom_utilisateur}</strong> 👋</p>
                <p class="message">
                    Vous avez demandé à réinitialiser votre mot de passe.
                    Utilisez le code ci-dessous pour continuer :
                </p>
                <div class="otp-box">
                    <div class="otp-label">Votre code de vérification</div>
                    <div class="otp-code">{code_otp}</div>
                    <div class="expiry">⏱ Valable pendant <strong>5 minutes</strong></div>
                </div>
                <div class="warning">
                    ⚠️ Si vous n'avez pas fait cette demande, ignorez cet email.
                    Votre mot de passe ne sera pas modifié.
                </div>
            </div>
            <div class="footer">
                © 2026 AfroLuo — Préservons les langues africaines 🌍
            </div>
        </div>
    </body>
    </html>
    """

    # ── Étape 4 : Assembler les deux versions ─────────────────
    partie_texte = MIMEText(texte_simple, "plain", "utf-8")
    partie_html  = MIMEText(html, "html", "utf-8")

    message.attach(partie_texte)  # Version texte d'abord
    message.attach(partie_html)   # Version HTML en dernier (priorité)
    # Le client email choisit automatiquement la meilleure version

    # ── Étape 5 : Envoyer via Gmail SMTP ─────────────────────
    try:
        await aiosmtplib.send(
            message,
            hostname=settings.MAIL_SERVER,    # "smtp.gmail.com"
            port=settings.MAIL_PORT,          # 587
            username=settings.MAIL_USERNAME,  # ton.email@gmail.com
            password=settings.MAIL_PASSWORD,  # mot de passe d'application Gmail
            start_tls=True,                   # Connexion sécurisée obligatoire
        )

        # Log de succès (visible dans le terminal)
        logger.info(f"✅ Email OTP envoyé à {email_destinataire}")
        return True  # Succès

    except Exception as e:
        # Log d'erreur (visible dans le terminal)
        logger.error(f"❌ Erreur envoi email à {email_destinataire}: {str(e)}")
        return False  # Échec
