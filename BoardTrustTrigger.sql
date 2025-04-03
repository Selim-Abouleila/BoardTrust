USE BoardTrust;
DELIMITER $$

CREATE TRIGGER trg_location_ai_inventaire
AFTER INSERT
ON Location
FOR EACH ROW
BEGIN
    UPDATE Inventaire
    SET statut = 'loué'
    WHERE id_exemplaire = NEW.id_exemplaire;
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_location_au_retour
AFTER UPDATE
ON Location
FOR EACH ROW
BEGIN
    -- Si la date_fin vient d'être renseignée, on considère que l'utilisateur a rendu le jeu
    IF NEW.date_fin IS NOT NULL AND OLD.date_fin IS NULL THEN
        -- 1) On remet l'exemplaire à "disponible"
        UPDATE Inventaire
        SET statut = 'disponible'
        WHERE id_exemplaire = NEW.id_exemplaire;
        
        -- 2) On calcule la duree_location = date_fin - date_debut
        UPDATE Location
        SET duree_location = DATEDIFF(NEW.date_fin, NEW.date_debut)
        WHERE id_location = NEW.id_location;
    END IF;
END $$

DELIMITER ;
