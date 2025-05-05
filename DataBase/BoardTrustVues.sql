USE BoardTrust;
CREATE OR REPLACE VIEW vue_jeux_disponibles AS
SELECT 
    i.id_exemplaire,
    j.nom AS nom_jeu,
    j.description,
    i.statut
FROM Inventaire i
JOIN Jeu j ON i.id_jeu = j.id_jeu
WHERE i.statut = 'disponible';

CREATE OR REPLACE VIEW vue_historique_locations AS
SELECT 
    loc.id_location,
    loc.date_debut,
    loc.date_fin,
    loc.duree_location,
    u.pseudo AS loueur,
    j.nom AS nom_jeu
FROM Location loc
JOIN Utilisateur u ON loc.id_utilisateur = u.id_utilisateur
JOIN Inventaire i ON loc.id_exemplaire = i.id_exemplaire
JOIN Jeu j ON i.id_jeu = j.id_jeu;

CREATE OR REPLACE VIEW vue_top_utilisateurs AS
SELECT
    u.id_utilisateur,
    u.pseudo
    -- Supprimer nombre_emprunts si vous ne l'avez pas
FROM Utilisateur u
ORDER BY u.id_utilisateur DESC;  -- Ou un autre critère

-- Afficher la liste de toutes les vues (et tables)
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- Afficher le contenu de chaque vue
SELECT * FROM vue_jeux_disponibles;
SELECT * FROM vue_historique_locations;
SELECT * FROM vue_top_utilisateurs;

SELECT * FROM Location;