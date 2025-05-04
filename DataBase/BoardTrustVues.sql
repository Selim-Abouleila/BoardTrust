SELECT * FROM VueHistoriqueLocation;
USE Boardtrust;

DROP VIEW VueHistoriqueLocation;
CREATE VIEW VueJeuSansDescription AS
SELECT id_jeu, nom, annee_publication, average, bayes_average, nb_users
FROM Jeu;

SELECT * FROM VueJeuSansDescription;