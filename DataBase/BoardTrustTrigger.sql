DELIMITER //

CREATE TRIGGER after_location_insert
AFTER INSERT ON Location
FOR EACH ROW
BEGIN
    INSERT INTO HistoriqueLocation (
        id_utilisateur,
        id_jeu,
        date_location,
        date_retour_prevue,
        date_retour_effective,
        action
    ) VALUES (
        NEW.id_utilisateur,
        NEW.id_jeu,
        NEW.date_location,
        NEW.date_retour_prevue,
        NULL,
        'Location créée'
    );
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER after_game_return
AFTER UPDATE ON Location
FOR EACH ROW
BEGIN
    -- Only insert into HistoriqueLocation if the game was just returned
    IF NEW.date_retour_effective IS NOT NULL AND OLD.date_retour_effective IS NULL THEN
        INSERT INTO HistoriqueLocation (
            id_utilisateur,
            id_jeu,
            date_location,
            date_retour_prevue,
            date_retour_effective,
            action
        ) VALUES (
            NEW.id_utilisateur,
            NEW.id_jeu,
            NEW.date_location,
            NEW.date_retour_prevue,
            NEW.date_retour_effective,
            'Retour du jeu'
        );
    END IF;
END //

DELIMITER ;

