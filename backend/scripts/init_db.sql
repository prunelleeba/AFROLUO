-- ══════════════════════════════════════════════════════════════
--  scripts/init_db.sql — Données initiales (seed data)
--  Exécuté automatiquement par Docker au premier démarrage
-- ══════════════════════════════════════════════════════════════
--  Ce script insère les données de base nécessaires au
--  fonctionnement de l'application :
--  - Les langues (ewondo, douala, bassa, français, anglais)
--  - Les types de contenu (vocabulaire, phrase, expression...)
--  - Les thèmes (famille, animaux, couleurs...)
-- ══════════════════════════════════════════════════════════════

-- Trigger pour updated_at automatique
CREATE OR REPLACE FUNCTION maj_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ── LANGUES ────────────────────────────────────────────────────
INSERT INTO langues (code, nom) VALUES
  ('ewondo',  'Ewondo'),
  ('douala',  'Douala'),
  ('bassa',   'Bassa'),
  ('beti',    'Beti'),
  ('fulfulde','Fulfulde'),
  ('fr',      'Français'),
  ('en',      'English')
ON CONFLICT (code) DO NOTHING;

-- ── TYPES DE CONTENU ───────────────────────────────────────────
INSERT INTO types_contenu (code, libelle) VALUES
  ('vocabulaire',  'Vocabulaire'),
  ('phrase',       'Phrase'),
  ('expression',   'Expression courante'),
  ('dialogue',     'Dialogue'),
  ('proverbe',     'Proverbe')
ON CONFLICT (code) DO NOTHING;

-- ── THÈMES ─────────────────────────────────────────────────────
-- Les thèmes correspondent aux catégories du scraper ewondo
INSERT INTO themes (code, ordre) VALUES
  ('salutations',  1),
  ('famille',      2),
  ('nombres',      3),
  ('couleurs',     4),
  ('animaux',      5),
  ('nourriture',   6),
  ('corps_humain', 7),
  ('maison',       8),
  ('vetements',    9),
  ('mois_saisons', 10),
  ('jours',        11),
  ('verbes',       12),
  ('adjectifs',    13),
  ('pronoms',      14),
  ('questions',    15),
  ('expressions',  16),
  ('sante',        17),
  ('transports',   18),
  ('nature',       19),
  ('musique',      20)
ON CONFLICT (code) DO NOTHING;

-- ── TRADUCTIONS DES THÈMES ─────────────────────────────────────
-- En français
INSERT INTO themes_traductions (theme_id, langue_id, traduction)
SELECT t.id, l.id, trad.nom_fr
FROM themes t
JOIN langues l ON l.code = 'fr'
JOIN (VALUES
  ('salutations',  'Salutations'),
  ('famille',      'Famille'),
  ('nombres',      'Nombres'),
  ('couleurs',     'Couleurs'),
  ('animaux',      'Animaux'),
  ('nourriture',   'Nourriture'),
  ('corps_humain', 'Corps humain'),
  ('maison',       'Maison'),
  ('vetements',    'Vêtements'),
  ('mois_saisons', 'Mois et saisons'),
  ('jours',        'Jours de la semaine'),
  ('verbes',       'Verbes'),
  ('adjectifs',    'Adjectifs'),
  ('pronoms',      'Pronoms'),
  ('questions',    'Questions'),
  ('expressions',  'Expressions courantes'),
  ('sante',        'Santé'),
  ('transports',   'Transports'),
  ('nature',       'Nature'),
  ('musique',      'Musique')
) AS trad(code, nom_fr) ON t.code = trad.code
ON CONFLICT DO NOTHING;

-- En anglais
INSERT INTO themes_traductions (theme_id, langue_id, traduction)
SELECT t.id, l.id, trad.nom_en
FROM themes t
JOIN langues l ON l.code = 'en'
JOIN (VALUES
  ('salutations',  'Greetings'),
  ('famille',      'Family'),
  ('nombres',      'Numbers'),
  ('couleurs',     'Colors'),
  ('animaux',      'Animals'),
  ('nourriture',   'Food'),
  ('corps_humain', 'Human Body'),
  ('maison',       'House'),
  ('vetements',    'Clothing'),
  ('mois_saisons', 'Months & Seasons'),
  ('jours',        'Days of the Week'),
  ('verbes',       'Verbs'),
  ('adjectifs',    'Adjectives'),
  ('pronoms',      'Pronouns'),
  ('questions',    'Questions'),
  ('expressions',  'Common Expressions'),
  ('sante',        'Health'),
  ('transports',   'Transport'),
  ('nature',       'Nature'),
  ('musique',      'Music')
) AS trad(code, nom_en) ON t.code = trad.code
ON CONFLICT DO NOTHING;

-- ── CONTENUS EXEMPLE — Mois de l'année en Ewondo ──────────────
-- Données issues du fichier ewondo_example.json
INSERT INTO contenus (langue_source_id, type_contenu_id, theme_id, texte_source, prononciation, niveau, ordre)
SELECT
  (SELECT id FROM langues WHERE code = 'ewondo'),
  (SELECT id FROM types_contenu WHERE code = 'vocabulaire'),
  (SELECT id FROM themes WHERE code = 'mois_saisons'),
  c.texte, c.prono, 1, c.ord
FROM (VALUES
  ('ngɔn osu',      'ngon osu',      1),
  ('ngɔn bèè',      'ngon bee',      2),
  ('ngɔn lala',     'ngon lala',     3),
  ('ngɔn nyina',    'ngon nyina',    4),
  ('ngɔn tana',     'ngon tana',     5),
  ('ngɔn samena',   'ngon samena',   6),
  ('ngɔn zamgbala', 'ngon zamgbala', 7),
  ('ngɔn mòòmo',    'ngon moomo',    8),
  ('ngɔn ebulu',    'ngon ebulu',    9),
  ('ngɔn awòmo',    'ngon awomo',    10),
  ('eseb',          'eseb',          11)
) AS c(texte, prono, ord)
ON CONFLICT DO NOTHING;

-- Traductions françaises des mois ewondo
INSERT INTO contenus_traductions (contenu_id, langue_id, traduction)
SELECT c.id, (SELECT id FROM langues WHERE code = 'fr'), trad.fr
FROM contenus c
JOIN (VALUES
  ('ngɔn osu',      'janvier'),
  ('ngɔn bèè',      'février'),
  ('ngɔn lala',     'mars'),
  ('ngɔn nyina',    'avril'),
  ('ngɔn tana',     'mai'),
  ('ngɔn samena',   'juin'),
  ('ngɔn zamgbala', 'juillet'),
  ('ngɔn mòòmo',    'août'),
  ('ngɔn ebulu',    'septembre'),
  ('ngɔn awòmo',    'octobre'),
  ('eseb',          'l''été')
) AS trad(ewondo, fr) ON c.texte_source = trad.ewondo
WHERE c.langue_source_id = (SELECT id FROM langues WHERE code = 'ewondo')
ON CONFLICT DO NOTHING;

-- ── UTILISATEUR ADMIN PAR DÉFAUT ───────────────────────────────
-- Mot de passe : admin123 (hashé avec bcrypt)
-- ⚠️ CHANGE CE MOT DE PASSE EN PRODUCTION !
INSERT INTO utilisateurs (nom, email, password, langue_id, is_admin)
VALUES (
  'Admin AfroLuo',
  'admin@afroluo.com',
  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQyCgvbNbkZCCQl/Dl3RJxnHa',
  (SELECT id FROM langues WHERE code = 'fr'),
  true
)
ON CONFLICT (email) DO NOTHING;

-- Message de confirmation
DO $$ BEGIN
  RAISE NOTICE '✅ AfroLuo — Base de données initialisée avec succès !';
  RAISE NOTICE '📊 Langues : %, Thèmes : %, Contenus : %',
    (SELECT COUNT(*) FROM langues),
    (SELECT COUNT(*) FROM themes),
    (SELECT COUNT(*) FROM contenus);
END $$;
