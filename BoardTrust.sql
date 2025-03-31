-- Drop the database if it exists and create a new one
DROP DATABASE IF EXISTS BoardTrust;
CREATE DATABASE BoardTrust;
USE BoardTrust;

-- Drop tables in reverse order of dependencies (if they exist)
DROP TABLE IF EXISTS UtilisateurBadge;
DROP TABLE IF EXISTS Badge;
DROP TABLE IF EXISTS JeuMetadata;
DROP TABLE IF EXISTS Metadata;
DROP TABLE IF EXISTS JeuContributeur;
DROP TABLE IF EXISTS Contributeur;
DROP TABLE IF EXISTS Commentaire;
DROP TABLE IF EXISTS Utilisateur;
DROP TABLE IF EXISTS Jeu;

-- Create table Jeu
CREATE TABLE Jeu (
    id_jeu INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255) NOT NULL,
    description TEXT,
    annee_publication INT,
    min_joueurs INT,
    max_joueurs INT,
    temps_jeu INT,
    age_min INT
) ENGINE=InnoDB;

-- Create table Utilisateur
CREATE TABLE Utilisateur (
    id_utilisateur INT AUTO_INCREMENT PRIMARY KEY,
    pseudo VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    date_inscription DATE
) ENGINE=InnoDB;

-- Create table Commentaire
CREATE TABLE Commentaire (
    id_commentaire INT AUTO_INCREMENT PRIMARY KEY,
    id_jeu INT NOT NULL,
    id_utilisateur INT NOT NULL,
    contenu TEXT,
    note FLOAT,
    date_creation DATETIME,
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu) ON DELETE CASCADE,
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create table Contributeur
CREATE TABLE Contributeur (
    id_contributeur INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL  -- Examples: 'editeur', 'artiste', 'designer'
) ENGINE=InnoDB;

-- Create table JeuContributeur (Association N:N between Jeu and Contributeur)
CREATE TABLE JeuContributeur (
    id_jeu INT NOT NULL,
    id_contributeur INT NOT NULL,
    PRIMARY KEY (id_jeu, id_contributeur),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu) ON DELETE CASCADE,
    FOREIGN KEY (id_contributeur) REFERENCES Contributeur(id_contributeur) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create table Metadata
CREATE TABLE Metadata (
    id_metadata INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    type_metadata VARCHAR(50) NOT NULL  -- Examples: 'categorie', 'mecanique', 'famille', 'tag'
) ENGINE=InnoDB;

-- Create table JeuMetadata (Association N:N for classifying games)
CREATE TABLE JeuMetadata (
    id_jeu INT NOT NULL,
    id_metadata INT NOT NULL,
    PRIMARY KEY (id_jeu, id_metadata),
    FOREIGN KEY (id_jeu) REFERENCES Jeu(id_jeu) ON DELETE CASCADE,
    FOREIGN KEY (id_metadata) REFERENCES Metadata(id_metadata) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Create table Badge (Optional: for gamification)
CREATE TABLE Badge (
    id_badge INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(100) NOT NULL,
    description TEXT
) ENGINE=InnoDB;

-- Create table UtilisateurBadge (Optional: Association N:N between Utilisateur and Badge)
CREATE TABLE UtilisateurBadge (
    id_utilisateur INT NOT NULL,
    id_badge INT NOT NULL,
    date_attribution DATE,
    PRIMARY KEY (id_utilisateur, id_badge),
    FOREIGN KEY (id_utilisateur) REFERENCES Utilisateur(id_utilisateur) ON DELETE CASCADE,
    FOREIGN KEY (id_badge) REFERENCES Badge(id_badge) ON DELETE CASCADE
) ENGINE=InnoDB;
