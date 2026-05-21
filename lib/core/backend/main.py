from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from model import gemini, chercher_local, DICO_FR_EW, CATEGORIES
import os
# Sankofa — L’assistant qui relie le passé et l’avenir
# Origine : Le mot vient de la langue akan (Ghana/Côte d’Ivoire). Il est représenté par un oiseau mythique qui se retourne pour prendre un œuf dans son dos.
# Signification : « Retourner à ses sources pour mieux avancer » ou « Il n’est pas tabou de revenir sur ce que l’on a oublié. »

app = FastAPI(title="SANKOFA  API", version="1.0")

# Historique de conversation (pour l'instant, un historique global ; à améliorer avec des sessions)
conversation_history = []

class Message(BaseModel):
    text: str

@app.post("/chat")
async def chat(message: Message):
    user_input = message.text.strip()
    if not user_input:
        raise HTTPException(status_code=400, detail="Message vide")

    # Recherche locale pour un mot seul
    if len(user_input.split()) == 1:
        local = chercher_local(user_input)
        if local:
            conversation_history.append(("user", user_input))
            conversation_history.append(("model", local))
            return {"response": local}

    # Appel à Gemini
    conversation_history.append(("user", user_input))
    if len(conversation_history) > 18:
        conversation_history[:] = conversation_history[-18:]

    rep = gemini(conversation_history)
    conversation_history.append(("model", rep))
    return {"response": rep}

@app.get("/categories")
async def get_categories():
    return {"categories": list(CATEGORIES.keys())}