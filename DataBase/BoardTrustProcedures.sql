USE BoardTrust;

-- 1) Procédure "sp_louer_jeu"
---------------------------------------------------
DROP PROCEDURE IF EXISTS sp_louer_jeu;

DELIMITER $$
CREATE PROCEDURE sp_louer_jeu (
    IN p_id_exemplaire INT,
    IN p_id_utilisateur INT
)
BEGIN
    INSERT INTO Location (id_exemplaire, id_utilisateur, date_debut, date_fin)
    VALUES (p_id_exemplaire, p_id_utilisateur, CURRENT_DATE(), NULL);
    -- Les triggers (s'ils existent) mettront l’exemplaire à "loué" 
    -- et incrémenteront le compteur de l’utilisateur (si vous l'avez implémenté).
END $$
DELIMITER ;

-- Afficher le CREATE de la procédure
SHOW CREATE PROCEDURE sp_louer_jeu;


-- 2) Procédure "sp_retourner_jeu"
---------------------------------------------------
DROP PROCEDURE IF EXISTS sp_retourner_jeu;

DELIMITER $$
CREATE PROCEDURE sp_retourner_jeu (
    IN p_id_location INT
)
BEGIN
    UPDATE Location
    SET date_fin = CURRENT_DATE()
    WHERE id_location = p_id_location;
    -- Un trigger AFTER UPDATE (s’il existe) peut recalculer la duree_location
    -- et repasser le statut de l'exemplaire à "disponible".
END $$
DELIMITER ;

-- Afficher le CREATE de la procédure
SHOW CREATE PROCEDURE sp_retourner_jeu;


-- 3) Fonction "fn_get_average_rating"
---------------------------------------------------
DROP FUNCTION IF EXISTS fn_get_average_rating;

DELIMITER $$
CREATE FUNCTION fn_get_average_rating (
    p_id_jeu INT
)
RETURNS FLOAT
DETERMINISTIC
BEGIN
    DECLARE avg_note FLOAT;
    
    SELECT AVG(note) INTO avg_note
    FROM Commentaire
    WHERE id_jeu = p_id_jeu;
    
    RETURN IFNULL(avg_note, 0);  -- Renvoie 0 si aucune note.
END $$
DELIMITER ;

-- Afficher le CREATE de la fonction
SHOW CREATE FUNCTION fn_get_average_rating;


-- 4) Exemple d'utilisation
---------------------------------------------------
-- Appeler les procédures
CALL sp_louer_jeu(1, 2);       -- Loue l'exemplaire #1 pour l'utilisateur #2
CALL sp_retourner_jeu(5);      -- Rend la location #5 (si elle existe)

-- Appeler la fonction
SELECT FN_GET_AVERAGE_RATING(1) AS moyenne_catan;
