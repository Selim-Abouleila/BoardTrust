USE Boardtrust;

CREATE TABLE Jeu (
  id_jeu INT PRIMARY KEY AUTO_INCREMENT,
  nom VARCHAR(255) NOT NULL,
  description TEXT,
  annee_publication INT,
  average INT,
  bayes_average INT,
  nb_users INT
);

CREATE TABLE Utilisateur (
  id_utilisateur INT PRIMARY KEY AUTO_INCREMENT,
  pseudo VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  mot_de_passe VARCHAR(255) NOT NULL,
  date_inscription DATE NOT NULL
);
USE Boardtrust;
DROP TABLE Commentaire;
CREATE TABLE Commentaire (
  id_commentaire INT PRIMARY KEY AUTO_INCREMENT,
  id_jeu INT NOT NULL,
  id_utilisateur INT NOT NULL,
  contenu VARCHAR(200),
  note FLOAT,
  date_creation DATETIME NOT NULL,
  FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur)
);

CREATE TABLE Location (
  id_location INT PRIMARY KEY AUTO_INCREMENT,
  id_utilisateur INT NOT NULL,
  id_jeu INT NOT NULL,
  date_location DATE NOT NULL,
  date_retour_prevue DATE NOT NULL,
  date_retour_effective DATE,
  FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
  FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu)
);

DROP TABLE HistoriqueLocation;
CREATE TABLE HistoriqueLocation (
    id_historique INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT NOT NULL,
    id_jeu INT NOT NULL,
    date_location DATE NOT NULL,
    date_retour_prevue DATE NOT NULL,
    date_retour_effective DATE,
    action VARCHAR(50) NOT NULL,
    date_enregistrement TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu)
);

USE Boardtrust;
DELIMITER //

CREATE PROCEDURE AddComment(
  IN p_id_utilisateur INT,
  IN p_id_jeu         INT,
  IN p_contenu        VARCHAR(200),
  IN p_note           FLOAT
)
BEGIN
  INSERT INTO Commentaire (
    id_jeu,
    id_utilisateur,
    contenu,
    note,
    date_creation
  ) VALUES (
    p_id_jeu,
    p_id_utilisateur,
    p_contenu,
    p_note,
    NOW()
  );
END;
//
DELIMITER ;

	
CALL AddComment(
  3,                 -- p_id_utilisateur
  13,                 -- p_id_jeu
  'Super fun game!',  -- p_contenu
  4.5                 -- p_note
);

SELECT * FROM Commentaire;


DELIMITER //

CREATE PROCEDURE ViewCommentsByGame(
  IN p_id_jeu INT
)
BEGIN
  SELECT
    c.id_commentaire,
    c.id_utilisateur,
    u.pseudo,
    c.contenu,
    c.note,
    c.date_creation
  FROM Commentaire AS c
  JOIN Utilisateur AS u
    ON u.id_utilisateur = c.id_utilisateur
  WHERE c.id_jeu = p_id_jeu
  ORDER BY c.date_creation DESC;
END;
//

DELIMITER ;

CALL ViewCommentsByGame(13);

SELECT * FROM Jeu;

SELECT * FROM JEU;

UPDATE Jeu
SET stock = '3'
WHERE stock IS NULL;


-- 1) Make sure the event scheduler is enabled
SET GLOBAL event_scheduler = ON;

-- 2) Create the yearly event
DROP EVENT IF EXISTS annual_stock_increment;
CREATE EVENT annual_stock_increment
  ON SCHEDULE
    EVERY 1 YEAR
    STARTS '2025-01-01 00:00:00'
  DO
    UPDATE Jeu
    SET stock = stock + 1;
