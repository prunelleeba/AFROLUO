import requests
 
API_KEY = "AIzaSyBaQDtM-Q-v_JUyUDumUm_t0xb3TZ0qn3k"
 
# Liste tous les modèles disponibles avec cette clé
url = f"https://generativelanguage.googleapis.com/v1beta/models?key={API_KEY}"
r = requests.get(url, timeout=15)
print("Status:", r.status_code)
if r.status_code == 200:
    models = r.json().get("models", [])
    print("\nModèles disponibles :")
    for m in models:
        name = m.get("name","")
        if "gemini" in name.lower():
            print(f"  • {name}")
else:
    print(r.text[:500])
 