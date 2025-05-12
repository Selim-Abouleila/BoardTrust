DELIMITER //

CREATE PROCEDURE AddUser (
    IN p_name VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_mot_de_passe VARCHAR(100)
)
BEGIN
    INSERT INTO Utilisateur (pseudo, email, mot_de_passe, date_inscription)
    VALUES (p_name, p_email, p_mot_de_passe, CURDATE());
END //

DELIMITER ;

CALL AddUser('Selim Abouleila', 'selimabouleila@gmail.com','123');

DROP PROCEDURE LouerJeu;
DELIMITER //

CREATE PROCEDURE LouerJeu (
    IN p_id_utilisateur INT,
    IN p_id_jeu INT,
    IN p_date_retour_prevue DATE
)
BEGIN
    INSERT INTO Location (
        id_utilisateur,
        id_jeu,
        date_location,
        date_retour_prevue,
        date_retour_effective
    ) VALUES (
        p_id_utilisateur,
        p_id_jeu,
        CURDATE(),
        p_date_retour_prevue,
        NULL
    );
END //

DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS RetournerJeu;
DELIMITER //

CREATE PROCEDURE RetournerJeu (
    IN p_id_utilisateur INT,
    IN p_id_jeu         INT
)
BEGIN
    -- 1) Mark the earliest open rental as returned
    UPDATE Location
    SET date_retour_effective = CURDATE()
    WHERE id_jeu = p_id_jeu
      AND id_utilisateur = p_id_utilisateur
      AND date_retour_effective IS NULL
    ORDER BY date_location ASC
    LIMIT 1;

    -- 2) If we actually updated a row above, bump the stock
    IF ROW_COUNT() > 0 THEN
      UPDATE Jeu
      SET stock = stock + 1
      WHERE id_jeu = p_id_jeu;
    END IF;
END //
DELIMITER ;

CALL RetournerJeu(3, 13);

DELIMITER ;


SELECT * FROM Jeu;
CALL LouerJeu(1, 13, '2025-05-01');
CALL LouerJeu(1, 13, '2025-05-03');

CALL RetournerJeu(13);

SELECT * FROM Location;
SELECT * FROM HistoriqueLocation;	
USE Boardtrust;
SELECT * FROM Utilisateur WHERE email = 'amin@gmail.com';


SELECT * FROM 

DELIMITER //
CREATE PROCEDURE EstLoue(
    IN p_id_jeu INT,
    OUT p_estLoue BOOL
)
BEGIN
    DECLARE v_count INT;
    
    SELECT COUNT(*) INTO v_count
    FROM Location
    WHERE id_jeu = p_id_jeu
      AND date_retour_effective IS NULL;
    
    SET p_estLoue = (v_count > 0);
END //
DELIMITER ;
SELECT * FROM Location;


DELIMITER //

CREATE PROCEDURE EstLoueParUtilisateur(
    IN p_id_utilisateur INT,
    IN p_id_jeu INT,
    OUT p_estLoue BOOL
)
BEGIN
    DECLARE v_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_count
    FROM Location
    WHERE id_jeu = p_id_jeu
      AND id_utilisateur = p_id_utilisateur
      AND date_retour_effective IS NULL;

    SET p_estLoue = IF(v_count > 0, TRUE, FALSE);
END //

DELIMITER ;
SELECT @isRented AS rented;

CALL EstLoueParUtilisateur(3, 13, @isRented);
SELECT @isRented AS rented;
SELECT * FROM Utilisateur WHERE email = 'amin@gmail.com'


DELIMITER //
CREATE PROCEDURE ViewHistory(IN p_id_utilisateur INT)
BEGIN
  SELECT 
    j.nom AS game_name,
    l.date_location,
    l.date_retour_prevue,
    l.date_retour_effective
  FROM 
    Location l
    INNER JOIN Utilisateur u ON l.id_utilisateur = u.id_utilisateur
    INNER JOIN Jeu j ON l.id_jeu = j.id_jeu
  WHERE 
    l.id_utilisateur = p_id_utilisateur
  ORDER BY 
    l.date_location DESC;
END //

DELIMITER ;

CALL ViewHistory(3);



USE Boardtrust;

DELIMITER //

CREATE PROCEDURE ViewRentedGames(IN p_id_utilisateur INT)
BEGIN
  SELECT 
    l.id_location,
    l.id_jeu,  -- Added to include the game ID
    j.nom AS game_name,
    l.date_location,
    l.date_retour_prevue,
    u.pseudo AS user_pseudo
  FROM 
    Location l
    INNER JOIN Utilisateur u ON l.id_utilisateur = u.id_utilisateur
    INNER JOIN Jeu j ON l.id_jeu = j.id_jeu
  WHERE 
    l.id_utilisateur = p_id_utilisateur
    AND l.date_retour_effective IS NULL
  ORDER BY 
    l.date_location DESC;
END //

DELIMITER ;
CALL ViewHistory(3);

call ViewRentedGames(3);

CALL RetournerJeu(3, 13);
CALL RetournerJeu(3, 13);
CALL RetournerJeu(3, 13);
CALL RetournerJeu(3, 13);

SELECT * FROM Jeu;

USE Boardtrust;
DELIMITER //

CREATE PROCEDURE ViewAvailableGamesForUser(IN p_id_utilisateur INT)
BEGIN
  SELECT 
    j.id_jeu,
    j.nom,
    j.annee_publication,
    j.average,
    j.bayes_average,
    j.nb_users
  FROM Jeu AS j
  WHERE NOT EXISTS (
    SELECT 1
    FROM Location AS l
    WHERE l.id_jeu = j.id_jeu
      AND l.id_utilisateur = p_id_utilisateur
      AND l.date_retour_effective IS NULL
  )
  ORDER BY j.nom;
END;
//
DELIMITER ;

CALL ViewAvailableGamesForUser(3);


DELIMITER //

CREATE PROCEDURE LouerJeu (
    IN p_id_utilisateur INT,
    IN p_id_jeu         INT,
    IN p_date_retour_prevue DATE
)
BEGIN
    -- 1) Insert the new rental
    INSERT INTO Location (
        id_utilisateur,
        id_jeu,
        date_location,
        date_retour_prevue,
        date_retour_effective
    ) VALUES (
        p_id_utilisateur,
        p_id_jeu,
        CURDATE(),
        p_date_retour_prevue,
        NULL
    );

    -- 2) Decrement stock by 1
    UPDATE Jeu
    SET stock = stock - 1
    WHERE id_jeu = p_id_jeu;
END //

DELIMITER ;


ALTER TABLE Jeu
  DROP COLUMN stock,
  ADD COLUMN stock INT NOT NULL DEFAULT 3;
  
  CALL LouerJeu(
  1,               -- p_id_utilisateur (ex: user #1)
  42,              -- p_id_jeu         (ex: game #42)
  '2025-06-01'     -- p_date_retour_prevue
);



DROP PROCEDURE IF EXISTS LouerJeu;
DELIMITER //

CREATE PROCEDURE LouerJeu (
  IN p_id_utilisateur      INT,
  IN p_id_jeu              INT,
  IN p_date_retour_prevue  DATE
)
BEGIN
  DECLARE v_stock INT;

  -- get current stock
  SELECT stock
    INTO v_stock
    FROM Jeu
    WHERE id_jeu = p_id_jeu
    FOR UPDATE;  -- lock the row to avoid race conditions

  -- refuse if none left
  IF v_stock <= 0 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Jeu en rupture de stock';
  ELSE
    -- otherwise insert & decrement as before
    INSERT INTO Location (
      id_utilisateur,
      id_jeu,
      date_location,
      date_retour_prevue,
      date_retour_effective
    ) VALUES (
      p_id_utilisateur,
      p_id_jeu,
      CURDATE(),
      p_date_retour_prevue,
      NULL
    );

    UPDATE Jeu
      SET stock = stock - 1
      WHERE id_jeu = p_id_jeu;
  END IF;
END //
DELIMITER ;

