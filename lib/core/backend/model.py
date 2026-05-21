"""
AFROLINGUO - Chatbot Ewondo intelligent
Gemini 2.5 Flash Lite + dictionnaire CSV
"""

import os
import sys
import pandas as pd
import requests

# ─── CLÉ API ───────────────────────────────────────────────
API_KEY = "AIzaSyAg5wVtrMAc4Vd_ejq52MVlKKlVtdiPbXA"
GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-2.5-flash-lite:generateContent?key=" + API_KEY
)

DATA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")

# ─── CHARGEMENT DU DICTIONNAIRE ────────────────────────────
def charger_dictionnaire():
    dico_fr_ew = {}
    dico_ew_fr = {}
    categories = {}

    if not os.path.exists(DATA_DIR):
        print(f"ERREUR : dossier data/ introuvable : {DATA_DIR}")
        sys.exit(1)

    for fichier in sorted(os.listdir(DATA_DIR)):
        if not fichier.endswith(".csv"):
            continue
        cat = fichier.replace(".csv", "").replace("_", " ").title()
        chemin = os.path.join(DATA_DIR, fichier)
        try:
            df = pd.read_csv(chemin, encoding="utf-8")
            df.columns = [c.strip().lower() for c in df.columns]
            mots = []
            for _, row in df.iterrows():
                ew = str(row.get("ewondo", "")).strip()
                fr = str(row.get("français", row.get("francais", ""))).strip()
                if ew and fr and ew != "nan" and fr != "nan":
                    fr_nu = fr
                    for art in ("le ", "la ", "les ", "l'"):
                        if fr_nu.lower().startswith(art):
                            fr_nu = fr_nu[len(art):]
                            break
                    dico_fr_ew[fr_nu.lower()] = ew
                    dico_fr_ew[fr.lower()] = ew
                    dico_ew_fr[ew.lower()] = fr_nu
                    mots.append({"fr": fr_nu, "ew": ew})
            if mots:
                categories[cat] = mots
        except Exception as e:
            print(f"Erreur {fichier} : {e}")

    return dico_fr_ew, dico_ew_fr, categories


DICO_FR_EW, DICO_EW_FR, CATEGORIES = charger_dictionnaire()


# ─── PROMPT SYSTÈME ────────────────────────────────────────
def construire_systeme():
    blocs = []
    for cat, mots in CATEGORIES.items():
        lignes = " | ".join([f"{m['fr']}={m['ew']}" for m in mots[:30]])
        blocs.append(f"[{cat}] {lignes}")
    vocab = "\n".join(blocs)

    return f"""Tu es TARA, une assistante pédagogique bilingue français-ewondo de l'application Afrolinguo.
L'ewondo est une langue bantoue du Cameroun.

DICTIONNAIRE COMPLET ({len(DICO_FR_EW)} mots) :
{vocab}

SALUTATIONS :
bonjour matin=mbombо kidí | bonjour journée=mbombo amos | bonsoir=mbombo ngogé
bonne nuit=mbombo alú | au revoir=o kolog mbong | merci=abuí | merci beaucoup=abuí ngaŋ
comment ça va=Ono mvoe ? | ça va bien=Mvoe biŋ | je t'aime=Ma diŋ wa | oui=wé | non=dé

RÈGLES :
1. TRADUCTION fr→ew : cherche dans le dictionnaire et donne le mot exact.
2. TRADUCTION ew→fr : cherche et donne le sens en français.
3. PHRASE : décompose mot par mot, cherche chaque mot, assemble en ewondo.
4. MOT ABSENT : dis-le clairement et propose le plus proche.
5. Réponds toujours en français. Les mots ewondo entre guillemets.
6. Sois courte et pédagogique. Max 5 lignes. Encourage l'utilisateur.

GRAMMAIRE : ordre SUJET+VERBE+COMPLÉMENT. je=mə, tu=o, il/elle=à"""


SYSTEM_PROMPT = construire_systeme()


# ─── APPEL GEMINI ───────────────────────────────────────────
def gemini(historique: list) -> str:
    # Le system prompt est injecté comme premier échange user/model
    contents = []

    # Injection du système comme 1er message si historique vide
    if not historique or historique[0][0] != "user" or "TARA" not in historique[0][1]:
        contents.append({
            "role": "user",
            "parts": [{"text": "Voici tes instructions : " + SYSTEM_PROMPT}]
        })
        contents.append({
            "role": "model",
            "parts": [{"text": "Compris ! Je suis TARA, prête à enseigner l'ewondo."}]
        })

    for role, texte in historique:
        contents.append({"role": role, "parts": [{"text": texte}]})

    payload = {
        "contents": contents,
        "generationConfig": {
            "temperature": 0.4,
            "maxOutputTokens": 600,
        },
    }

    try:
        r = requests.post(GEMINI_URL, json=payload, timeout=30)
        if r.status_code == 200:
            return r.json()["candidates"][0]["content"]["parts"][0]["text"].strip()
        else:
            err = r.json().get("error", {}).get("message", r.text[:200])
            return f"[Erreur API {r.status_code}: {err}]"
    except requests.exceptions.Timeout:
        return "[Délai dépassé — vérifie ta connexion internet]"
    except Exception as e:
        return f"[Erreur : {e}]"


# ─── RECHERCHE LOCALE (1 mot) ───────────────────────────────
def chercher_local(mot: str):
    m = mot.lower().strip()
    if m in DICO_FR_EW:
        return f"'{mot}' se dit '{DICO_FR_EW[m]}' en ewondo."
    if m in DICO_EW_FR:
        return f"'{mot}' signifie '{DICO_EW_FR[m]}' en français."
    return None


# ─── BOUCLE PRINCIPALE ──────────────────────────────────────
def main():
    print("=" * 58)
    print("  AFROLINGUO — Apprends l'Ewondo avec TARA")
    print("=" * 58)
    print(f"  {len(DICO_FR_EW)} mots  |  {len(CATEGORIES)} categories")
    print("  Tape 'quit' pour quitter")
    print("=" * 58)

    historique = []

    # Message d'accueil
    historique.append(("user",
        "Présente-toi en 2 phrases en français et ewondo, "
        "puis propose 3 catégories pour commencer."))
    accueil = gemini(historique)
    historique.append(("model", accueil))
    print(f"\nTara : {accueil}\n" + "-" * 58)

    while True:
        try:
            saisie = input("Vous : ").strip()
        except (KeyboardInterrupt, EOFError):
            print("\nTara : o kolog mbong ! A bientot !\n")
            break

        if not saisie:
            continue
        if saisie.lower() in ("quit", "exit", "q", "au revoir"):
            print("\nTara : o kolog mbong ! Bonne pratique !\n")
            break

        # Mot seul → recherche locale instantanée
        if len(saisie.split()) == 1:
            local = chercher_local(saisie)
            if local:
                print(f"\nTara : {local}\n" + "-" * 58)
                historique.append(("user", saisie))
                historique.append(("model", local))
                continue

        # Phrases → Gemini
        historique.append(("user", saisie))
        if len(historique) > 18:
            historique = historique[-18:]

        rep = gemini(historique)
        historique.append(("model", rep))
        print(f"\nTara : {rep}\n" + "-" * 58)


if __name__ == "__main__":
    main()