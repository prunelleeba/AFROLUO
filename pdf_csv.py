# extraire_dictionnaire_complet.py
# Version qui préserve TOUS les caractères ewondo

import re
import csv
import os
import PyPDF2

# =============================================================
# DÉFINITION DES CARACTÈRES EWONDO VALIDES
# =============================================================

CARACTERES_EWONDO = {
    # Voyelles de base
    'a', 'e', 'i', 'o', 'u', 'y',
    'A', 'E', 'I', 'O', 'U', 'Y',
    
    # Consonnes spéciales
    'ŋ', 'Ŋ',
    'ń', 'Ń', 'ň', 'Ň', 'ñ', 'Ñ',
    'ḿ', 'Ḿ', 'ǹ', 'Ǹ',
    
    # Autres phonèmes
    'ə', 'ɔ', 'ɛ', 'ʃ', 'ʒ',
    
    # Voyelles avec accents (tons)
    'á', 'à', 'â', 'ä', 'ǎ', 'ā',
    'Á', 'À', 'Â', 'Ä', 'Ǎ', 'Ā',
    'é', 'è', 'ê', 'ë', 'ě', 'ē',
    'É', 'È', 'Ê', 'Ë', 'Ě', 'Ē',
    'í', 'ì', 'î', 'ï', 'ǐ', 'ī',
    'Í', 'Ì', 'Î', 'Ï', 'Ǐ', 'Ī',
    'ó', 'ò', 'ô', 'ö', 'ǒ', 'ō',
    'Ó', 'Ò', 'Ô', 'Ö', 'Ǒ', 'Ō',
    'ú', 'ù', 'û', 'ü', 'ǔ', 'ū',
    'Ú', 'Ù', 'Û', 'Ü', 'Ǔ', 'Ū',
    
    # Ponctuation
    ' ', '.', ',', ';', ':', '!', '?', "'", '"', '-', '—', '–',
    '(', ')', '[', ']', '{', '}', '«', '»', '…', ' ',
}
chemin_pdf=r"C:\Users\Fouodji Prudencia\Desktop\dataset AFROLUO"
def nettoyer_texte(texte: str) -> str:
    """Nettoie le texte en préservant les caractères ewondo"""
    resultat = []
    for c in texte:
        if c in CARACTERES_EWONDO or c.isalpha() or c.isdigit():
            resultat.append(c)
        elif c == '\n':
            resultat.append(' ')
        elif c in 'œæ':
            resultat.append(c)
    # Nettoyer les espaces multiples
    return re.sub(r'\s+', ' ', ''.join(resultat)).strip()

def extraire_dictionnaire_pdf(chemin_pdf: str):
    """Extrait le dictionnaire en préservant les caractères spéciaux"""
    
    print(f"📖 Lecture du PDF : {chemin_pdf}")
    
    # Lire le PDF
    texte_complet = ""
    with open(chemin_pdf, 'rb') as f:
        reader = PyPDF2.PdfReader(f)
        for i, page in enumerate(reader.pages):
            texte = page.extract_text()
            texte_complet += nettoyer_texte(texte) + "\n"
            if (i + 1) % 10 == 0:
                print(f"   Page {i+1}/{len(reader.pages)} traitée...")
    
    print("✅ PDF lu, extraction des mots...")
    
    # Dictionnaires
    ewondo_to_fr = {}
    fr_to_ewondo = {}
    
    # Pattern pour "mot_ewondo (classe), mot_francais"
    # Capture les caractères spéciaux ewondo
    pattern1 = re.compile(
        r'^([a-zàâäáǎāéèêëěēíìîïǐīóòôöǒōúùûüǔūŋńňñḿǹəɔɛʃʒ]+(?:\s+[a-zàâäáǎāéèêëěēíìîïǐīóòôöǒōúùûüǔūŋńňñḿǹəɔɛʃʒ]+)*)\s*\([^)]+\)\s*,\s*([^.,;]+(?:[^.,;]*)?)',
        re.MULTILINE | re.IGNORECASE
    )
    
    # Pattern pour la section française (inverse)
    pattern2 = re.compile(
        r'^([a-zàâäáǎāéèêëěēíìîïǐīóòôöǒōúùûüǔū]+(?:[,\s]+[a-zàâäáǎāéèêëěēíìîïǐīóòôöǒōúùûüǔū]+)*)\s*,\s*([a-zàâäáǎāéèêëěēíìîïǐīóòôöǒōúùûüǔūŋńňñḿǹəɔɛʃʒ]+(?:\s+[a-zàâäáǎāéèêëěēíìîïǐīóòôöǒōúùûüǔūŋńňñḿǹəɔɛʃʒ]+)*)\s*\([^)]+\)',
        re.MULTILINE | re.IGNORECASE
    )
    
    # Extraire
    for match in pattern1.finditer(texte_complet):
        ewondo = match.group(1).strip().lower()
        francais = match.group(2).strip().lower()
        # Nettoyer le français
        if ';' in francais:
            francais = francais.split(';')[0]
        if ',' in francais:
            francais = francais.split(',')[0]
        if len(ewondo) > 1 and len(francais) > 1 and ewondo not in ewondo_to_fr:
            ewondo_to_fr[ewondo] = francais
            if francais not in fr_to_ewondo:
                fr_to_ewondo[francais] = ewondo
    
    for match in pattern2.finditer(texte_complet):
        francais = match.group(1).strip().lower()
        ewondo = match.group(2).strip().lower()
        if len(ewondo) > 1 and len(francais) > 1 and ewondo not in ewondo_to_fr:
            ewondo_to_fr[ewondo] = francais
            if francais not in fr_to_ewondo:
                fr_to_ewondo[francais] = ewondo
    
    # Supprimer les entrées trop courtes ou invalides
    invalides = ['a', 'e', 'i', 'o', 'u', 'y', 'le', 'la', 'les', 'un', 'une', 'et']
    for mot in invalides:
        ewondo_to_fr.pop(mot, None)
        fr_to_ewondo.pop(mot, None)
    
    print(f"\n✅ Extraction terminée !")
    print(f"   - {len(ewondo_to_fr)} mots ewondo → français")
    print(f"   - {len(fr_to_ewondo)} mots français → ewondo")
    
    return ewondo_to_fr, fr_to_ewondo

def sauvegarder_csv(ewondo_to_fr: dict, fr_to_ewondo: dict, dossier: str = "data"):
    """Sauvegarde en CSV sans perte"""
    
    os.makedirs(dossier, exist_ok=True)
    
    # Sauvegarde avec encodage UTF-8 (préserve tous les caractères)
    with open(os.path.join(dossier, 'dictionnaire_ewondo_fr.csv'), 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['ewondo', 'francais'])
        for ew, fr in sorted(ewondo_to_fr.items()):
            writer.writerow([ew, fr])
    
    with open(os.path.join(dossier, 'dictionnaire_fr_ewondo.csv'), 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['francais', 'ewondo'])
        for fr, ew in sorted(fr_to_ewondo.items()):
            writer.writerow([fr, ew])
    
    # Sauvegarde JSON (préserve aussi les caractères)
    import json
    with open(os.path.join(dossier, 'dictionnaire.json'), 'w', encoding='utf-8') as f:
        json.dump({
            'ewondo_to_francais': ewondo_to_fr,
            'francais_to_ewondo': fr_to_ewondo
        }, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Fichiers sauvegardés dans '{dossier}/' avec encodage UTF-8")

def afficher_apercu(ewondo_to_fr: dict, n: int = 20):
    """Affiche un aperçu des caractères spéciaux"""
    
    print("\n" + "=" * 60)
    print("  APERÇU DES CARACTÈRES EWONDO")
    print("=" * 60)
    
    for i, (ew, fr) in enumerate(sorted(ewondo_to_fr.items())[:n]):
        # Afficher les caractères Unicode
        chars = [f"U+{ord(c):04X}" for c in ew if ord(c) > 127]
        if chars:
            print(f"  {ew:20} → {fr:30} ({', '.join(chars[:3])})")
        else:
            print(f"  {ew:20} → {fr}")
    
    if len(ewondo_to_fr) > n:
        print(f"\n  ... et {len(ewondo_to_fr) - n} autres mots")

# =============================================================
# EXÉCUTION
# =============================================================

if __name__ == "__main__":
    PDF_PATH = r"C:\Users\Fouodji Prudencia\Desktop\dataset AFROLUO\Dico_ewondo.pdf"
    
    print("=" * 60)
    print("  📚 EXTRACTION DU DICTIONNAIRE EWONDO")
    print("  Préservation des caractères spéciaux")
    print("=" * 60)
    
    ewondo_to_fr, fr_to_ewondo = extraire_dictionnaire_pdf(PDF_PATH)
    sauvegarder_csv(ewondo_to_fr, fr_to_ewondo)
    afficher_apercu(ewondo_to_fr)
    
    print("\n" + "=" * 60)
    print("  ✅ EXTRACTION TERMINÉE !")
    print("  📁 Fichiers dans le dossier 'data/'")
    print("  🔤 Les caractères spéciaux sont préservés")
    print("=" * 60)