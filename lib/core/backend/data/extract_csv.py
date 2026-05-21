import csv
import json
import os

dico_fr_ew = {}
dico_ew_fr = {}

for fichier in os.listdir('.'):
    if not fichier.endswith('.csv'):
        continue
    with open(fichier, encoding='utf-8') as f:
        reader = csv.reader(f)
        entetes = next(reader)  # Ewondo, English, français
        for ligne in reader:
            if len(ligne) < 3:
                continue
            ew = ligne[0].strip().lower()
            fr = ligne[2].strip().lower()
            # Ignorer les entrées vides ou "nan"
            if ew and fr and ew != 'nan' and fr != 'nan':
                dico_fr_ew[fr] = ew
                dico_ew_fr[ew] = fr

resultat = {
    "fr_ew": dico_fr_ew,
    "ew_fr": dico_ew_fr
}

with open('dictionary.json', 'w', encoding='utf-8') as js:
    json.dump(resultat, js, ensure_ascii=False, indent=2)

print(f"Dictionnaire généré : {len(dico_fr_ew)} entrées français‑ewondo, {len(dico_ew_fr)} entrées ewondo‑français.")