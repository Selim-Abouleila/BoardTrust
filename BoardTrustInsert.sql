USE BoardTrust;

-- ----------------------------------------------------------------
-- 1. Insertion dans les tables "parent" (sans clés étrangères)
-- ----------------------------------------------------------------

-- Table Jeu
INSERT INTO Jeu (id_jeu, nom, description, annee_publication, min_joueurs, max_joueurs, temps_jeu, age_min)
VALUES
    (1, 'Catan', 'Un jeu de placement et de commerce sur une île en développement.', 1995, 3, 4, 60, 10),
    (2, 'Ticket to Ride', 'Un jeu de construction de lignes de chemin de fer à travers différents pays.', 2004, 2, 5, 45, 8),
    (3, '7 Wonders', 'Un jeu de draft de cartes pour construire les plus grandes merveilles de l’Antiquité.', 2010, 2, 7, 30, 10),
    (4, 'Carcassonne', 'Un jeu de placement de tuiles pour construire un paysage médiéval.', 2000, 2, 5, 45, 8);

-- Table Utilisateur
INSERT INTO Utilisateur (id_utilisateur, pseudo, email, mot_de_passe, date_inscription)
VALUES
    (1, 'Alice', 'alice@example.com', 'motdepasse1', '2023-01-15'),
    (2, 'Bob', 'bob@example.com', 'motdepasse2', '2023-02-10'),
    (3, 'Charlie', 'charlie@example.com', 'motdepasse3', '2023-03-20'),
    (4, 'Diana', 'diana@example.com', 'motdepasse4', '2023-04-01');

-- Table Contributeur
INSERT INTO Contributeur (id_contributeur, nom, role)
VALUES
    (1, 'Klaus Teuber', 'designer'),
    (2, 'Days of Wonder', 'editeur'),
    (3, 'Alan R. Moon', 'designer'),
    (4, 'Antoine Bauza', 'designer'),
    (5, 'Repos Production', 'editeur'),
    (6, 'Asmodee', 'editeur');

-- Table Metadata
-- type_metadata exemples : 'categorie', 'mecanique', 'famille', 'tag', 'theme', etc.
INSERT INTO Metadata (id_metadata, nom, type_metadata)
VALUES
    (1, 'Stratégie', 'categorie'),
    (2, 'Famille', 'categorie'),
    (3, 'Drafting', 'mecanique'),
    (4, 'Placement de tuiles', 'mecanique'),
    (5, 'Négociation', 'mecanique'),
    (6, 'Transport', 'theme');

-- Table Badge
INSERT INTO Badge (id_badge, titre, description)
VALUES
    (1, 'Top Reviewer', 'Attribué aux utilisateurs qui rédigent de nombreux commentaires de qualité.'),
    (2, 'Early Adopter', 'Attribué aux utilisateurs qui rejoignent la plateforme durant sa première année.'),
    (3, 'Veteran Member', 'Attribué aux utilisateurs inscrits depuis plus de deux ans.');

-- ----------------------------------------------------------------
-- 2. Insertion dans les tables "enfant" (avec clés étrangères)
-- ----------------------------------------------------------------

-- Table Commentaire
INSERT INTO Commentaire (id_commentaire, id_jeu, id_utilisateur, contenu, note, date_creation)
VALUES
    (1, 1, 1, 'Excellent jeu pour découvrir le jeu de plateau moderne.', 4.5, '2023-02-01 10:15:00'), -- Catan par Alice
    (2, 1, 2, 'Très sympa mais peut durer un peu trop longtemps.', 4.0, '2023-02-05 14:30:00'),      -- Catan par Bob
    (3, 2, 3, 'Parfait pour jouer en famille, très accessible.', 4.2, '2023-03-05 11:00:00'),       -- Ticket to Ride par Charlie
    (4, 3, 1, 'Le système de draft est très plaisant et rapide.', 4.8, '2023-03-15 09:20:00'),      -- 7 Wonders par Alice
    (5, 4, 4, 'Facile à apprendre, se joue rapidement et plaît à tout le monde.', 4.1, '2023-03-25 16:45:00'); -- Carcassonne par Diana

-- Table JeuContributeur (Association N:N entre Jeu et Contributeur)
-- Quelques exemples de liens
INSERT INTO JeuContributeur (id_jeu, id_contributeur)
VALUES
    -- Catan
    (1, 1), -- Klaus Teuber (designer)
    (1, 6), -- Asmodee (éditeur)
    -- Ticket to Ride
    (2, 3), -- Alan R. Moon (designer)
    (2, 2), -- Days of Wonder (éditeur)
    -- 7 Wonders
    (3, 4), -- Antoine Bauza (designer)
    (3, 5), -- Repos Production (éditeur)
    -- Carcassonne
    (4, 6); -- Asmodee (éditeur), par exemple

-- Table JeuMetadata (Association N:N)
-- Montre comment les jeux sont catégorisés
INSERT INTO JeuMetadata (id_jeu, id_metadata)
VALUES
    -- Catan
    (1, 1),  -- Stratégie
    (1, 5),  -- Négociation (possibilité d'échanger des ressources)
    -- Ticket to Ride
    (2, 2),  -- Famille
    (2, 6),  -- Transport (trains)
    -- 7 Wonders
    (3, 1),  -- Stratégie
    (3, 3),  -- Drafting
    -- Carcassonne
    (4, 2),  -- Famille
    (4, 4);  -- Placement de tuiles

-- Table UtilisateurBadge (Association N:N entre Utilisateur et Badge)
INSERT INTO UtilisateurBadge (id_utilisateur, id_badge, date_attribution)
VALUES
    (1, 1, '2023-03-01'),  -- Alice reçoit le badge "Top Reviewer"
    (2, 2, '2023-02-15'),  -- Bob reçoit le badge "Early Adopter"
    (3, 2, '2023-03-21'),  -- Charlie reçoit aussi le badge "Early Adopter"
    (1, 3, '2025-01-01');  -- Alice reçoit "Veteran Member" (exemple fictif)
