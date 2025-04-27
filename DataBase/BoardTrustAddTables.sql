USE BoardTrust;

-- Table Inventaire
CREATE TABLE IF NOT EXISTS Inventaire (
    id_exemplaire INT AUTO_INCREMENT PRIMARY KEY,
    id_jeu INT NOT NULL,
    statut ENUM('disponible','loué','réservé') DEFAULT 'disponible',
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Location (
    id_location INT AUTO_INCREMENT PRIMARY KEY,
    id_exemplaire INT NOT NULL,
    id_utilisateur INT NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE NULL,
    duree_location INT DEFAULT 0,
    FOREIGN KEY (id_exemplaire) REFERENCES Inventaire(id_exemplaire) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE
) ENGINE=InnoDB;

USE BoardTrust;

-- ----------------------------------------------------------------
-- 1. Insérer dans la table Inventaire
--    (Chaque ligne représente un exemplaire spécifique d’un jeu)
-- ----------------------------------------------------------------
INSERT INTO Inventaire (id_jeu, statut)
VALUES
    -- Deux exemplaires de Catan (id_jeu = 1)
    (1, 'disponible'),
    (1, 'disponible'),

    -- Deux exemplaires de Ticket to Ride (id_jeu = 2)
    (2, 'disponible'),
    (2, 'loué'),

    -- Un exemplaire de 7 Wonders (id_jeu = 3)
    (3, 'disponible'),

    -- Un exemplaire de Carcassonne (id_jeu = 4)
    (4, 'disponible');

-- ----------------------------------------------------------------
-- 2. Insérer dans la table Location
--    (Chaque ligne représente une location d’un exemplaire)
-- ----------------------------------------------------------------

/*
  Note: 
   - 'date_fin' = NULL indique que le jeu n’est pas encore retourné.
   - 'duree_location' peut être mise à 0 ou calculée via un trigger.
   - Les 'id_exemplaire' ci-dessous doivent correspondre aux valeurs AUTO_INCREMENT
     réellement générées dans Inventaire.
*/

-- Exemple 1: Un exemplaire déjà retourné (id_exemplaire=4)
--            loué par l'utilisateur #2 (Bob) du 2023-01-10 au 2023-01-15.
INSERT INTO Location (id_exemplaire, id_utilisateur, date_debut, date_fin, duree_location)
VALUES
    (4, 2, '2023-01-10', '2023-01-15', 5);

-- Exemple 2: Un exemplaire en cours de location (id_exemplaire=2)
--            loué par l'utilisateur #3 (Charlie) depuis le 2023-03-01, pas encore rendu.
INSERT INTO Location (id_exemplaire, id_utilisateur, date_debut, date_fin, duree_location)
VALUES
    (2, 3, '2023-03-01', NULL, 0);

