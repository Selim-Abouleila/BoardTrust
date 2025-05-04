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

CREATE TABLE Commentaire (
  id_commentaire INT PRIMARY KEY AUTO_INCREMENT,
  id_jeu INT NOT NULL,
  id_utilisateur INT NOT NULL,
  contenu TEXT,
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

