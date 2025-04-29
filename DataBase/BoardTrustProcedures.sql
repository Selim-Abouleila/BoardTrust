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

DELIMITER //
CREATE PROCEDURE RetournerJeu (
    IN p_id_jeu INT
)
BEGIN
    UPDATE Location
    SET date_retour_effective = CURDATE()
    WHERE id_jeu = p_id_jeu
      AND date_retour_effective IS NULL
    ORDER BY date_location ASC
    LIMIT 1;
END //

DELIMITER ;


DELIMITER ;


SELECT * FROM Jeu;
CALL LouerJeu(1, 13, '2025-05-01');
CALL LouerJeu(1, 13, '2025-05-03');

CALL RetournerJeu(13);

SELECT * FROM Location;
SELECT * FROM HistoriqueLocation;	