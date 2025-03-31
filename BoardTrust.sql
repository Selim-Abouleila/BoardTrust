
-- ===========================
-- Création de la base de données
-- ===========================

CREATE DATABASE IF NOT EXISTS JeuxSocieteDB;
USE JeuxSocieteDB;

-- ===========================
-- TABLE Utilisateur
-- ===========================

CREATE TABLE NiveauConfiance (
    id_niveau INT PRIMARY KEY AUTO_INCREMENT,
    libelle VARCHAR(50),
    seuil_min FLOAT,
    seuil_max FLOAT
);

CREATE TABLE Utilisateur (
    id_utilisateur INT PRIMARY KEY AUTO_INCREMENT,
    pseudo VARCHAR(50) UNIQUE,
    email VARCHAR(100) UNIQUE,
    mot_de_passe VARCHAR(255),
    date_inscription DATE,
    id_niveau INT,
    score_confiance FLOAT DEFAULT 0,
    is_admin BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_niveau) REFERENCES NiveauConfiance(id_niveau)
);

-- ===========================
-- TABLE Jeu
-- ===========================

CREATE TABLE Jeu (
    id_jeu INT PRIMARY KEY,
    nom VARCHAR(255),
    description TEXT,
    année_publication INT,
    min_joueurs INT,
    max_joueurs INT,
    temps_jeu INT,
    âge_min INT,
    url VARCHAR(500),
    miniature VARCHAR(500)
);

-- ===========================
-- TABLE Categorie, Mecanique, Famille
-- ===========================

CREATE TABLE Categorie (
    id_categorie INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100)
);

CREATE TABLE Mecanique (
    id_mecanique INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100)
);

CREATE TABLE Famille (
    id_famille INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100)
);

-- ===========================
-- TABLES d'association N:N
-- ===========================

CREATE TABLE JeuCategorie (
    id_jeu INT,
    id_categorie INT,
    PRIMARY KEY (id_jeu, id_categorie),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
    FOREIGN KEY (id_categorie) REFERENCES Categorie(id_categorie)
);

CREATE TABLE JeuMecanique (
    id_jeu INT,
    id_mecanique INT,
    PRIMARY KEY (id_jeu, id_mecanique),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
    FOREIGN KEY (id_mecanique) REFERENCES Mecanique(id_mecanique)
);

CREATE TABLE JeuFamille (
    id_jeu INT,
    id_famille INT,
    PRIMARY KEY (id_jeu, id_famille),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
    FOREIGN KEY (id_famille) REFERENCES Famille(id_famille)
);

-- ===========================
-- TABLES Editeur, Artiste, Designer
-- ===========================

CREATE TABLE Editeur (
    id_editeur INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100)
);

CREATE TABLE Artiste (
    id_artiste INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100)
);

CREATE TABLE Designer (
    id_designer INT PRIMARY KEY AUTO_INCREMENT,
    nom VARCHAR(100)
);

CREATE TABLE JeuEditeur (
    id_jeu INT,
    id_editeur INT,
    PRIMARY KEY (id_jeu, id_editeur),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
    FOREIGN KEY (id_editeur) REFERENCES Editeur(id_editeur)
);

CREATE TABLE JeuArtiste (
    id_jeu INT,
    id_artiste INT,
    PRIMARY KEY (id_jeu, id_artiste),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
    FOREIGN KEY (id_artiste) REFERENCES Artiste(id_artiste)
);

CREATE TABLE JeuDesigner (
    id_jeu INT,
    id_designer INT,
    PRIMARY KEY (id_jeu, id_designer),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu),
    FOREIGN KEY (id_designer) REFERENCES Designer(id_designer)
);

-- ===========================
-- TABLE Commentaire
-- ===========================

CREATE TABLE Commentaire (
    id_commentaire INT PRIMARY KEY AUTO_INCREMENT,
    contenu TEXT,
    date DATETIME,
    note FLOAT,
    id_utilisateur INT,
    id_jeu INT,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu)
);

-- ===========================
-- TABLE Proposition
-- ===========================

CREATE TABLE Proposition (
    id_proposition INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT,
    id_jeu INT,
    titre VARCHAR(255),
    contenu TEXT,
    date_proposition DATETIME,
    statut ENUM('en attente', 'acceptée', 'refusée'),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu)
);

-- ===========================
-- TABLE Vote
-- ===========================

CREATE TABLE Vote (
    id_vote INT PRIMARY KEY AUTO_INCREMENT,
    id_proposition INT,
    id_utilisateur INT,
    type_vote ENUM('up', 'down'),
    date_vote DATETIME,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
    FOREIGN KEY (id_proposition) REFERENCES Proposition(id_proposition)
);

-- ===========================
-- TABLE HistoriqueScore
-- ===========================

CREATE TABLE HistoriqueScore (
    id_historique INT PRIMARY KEY AUTO_INCREMENT,
    id_utilisateur INT,
    date_changement DATE,
    score_avant FLOAT,
    score_après FLOAT,
    raison TEXT,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur)
);

-- ===========================
-- TABLE Badge
-- ===========================

CREATE TABLE Badge (
    id_badge INT PRIMARY KEY AUTO_INCREMENT,
    titre VARCHAR(100),
    description TEXT
);

CREATE TABLE UtilisateurBadge (
    id_utilisateur INT,
    id_badge INT,
    date_attribution DATE,
    PRIMARY KEY (id_utilisateur, id_badge),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur),
    FOREIGN KEY (id_badge) REFERENCES Badge(id_badge)
);

-- ===========================
-- TABLE Signalement
-- ===========================

CREATE TABLE Signalement (
    id_signalement INT PRIMARY KEY AUTO_INCREMENT,
    type_contenu ENUM('commentaire', 'proposition'),
    id_contenu INT,
    id_utilisateur INT,
    raison TEXT,
    date_signalement DATETIME,
    statut ENUM('nouveau', 'en cours', 'traité'),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur)
);
