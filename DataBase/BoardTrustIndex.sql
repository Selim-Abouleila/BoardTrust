USE BoardTrust;

-- 1) Index sur le pseudo de l'utilisateur pour les recherches rapides
CREATE INDEX idx_utilisateur_pseudo
    ON Utilisateur (pseudo);

-- 2) Index sur l'id_jeu dans la table Commentaire
--    utile si on fait souvent des "SELECT ... FROM Commentaire WHERE id_jeu = ..."
CREATE INDEX idx_commentaire_id_jeu
    ON Commentaire (id_jeu);

-- 3) Index composite (multiple colonnes) dans la table Location
--    pour optimiser la recherche des locations d'un utilisateur par date
CREATE INDEX idx_location_utilisateur_date
    ON Location (id_utilisateur, date_debut);
