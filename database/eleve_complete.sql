CREATE DATABASE IF NOT EXISTS eleveplatform
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE eleveplatform;
CREATE TABLE IF NOT EXISTS etudiants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    -- Identité
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    date_naissance DATE,
    lieu_naissance VARCHAR(150),
    numero_etudiant VARCHAR(50) UNIQUE,
    cin VARCHAR(20),
    email VARCHAR(150) UNIQUE NOT NULL,
    telephone VARCHAR(20),
    adresse_residence TEXT,
    adresse_postale TEXT,
    filiere VARCHAR(100) NOT NULL,
    cycle VARCHAR(50) NOT NULL, -- 'prepa' ou 'ingenieur'
    annee VARCHAR(10), -- '1A', '2A', '3A'
    niveau_scolaire VARCHAR(100),
    ecole VARCHAR(100) NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    photo_profil VARCHAR(255) DEFAULT 'default-avatar.png',
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_numero_etudiant (numero_etudiant)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- TABLE NOTES 
CREATE TABLE IF NOT EXISTS notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    etudiant_id INT NOT NULL,
    -- Module
    code_module VARCHAR(20) NOT NULL,
    nom_module VARCHAR(150) NOT NULL,
    -- Notes
    note_ds DECIMAL(5,2),
    note_examen DECIMAL(5,2),
    note_generale DECIMAL(5,2),
    -- Évaluation
    coefficient INT NOT NULL DEFAULT 1,
    type_evaluation VARCHAR(50) NOT NULL DEFAULT 'Standard',
    statut VARCHAR(20) NOT NULL, -- 'Validé' ou 'Rattrapage'
    FOREIGN KEY (etudiant_id) REFERENCES etudiants(id) ON DELETE CASCADE,
    INDEX idx_etudiant (etudiant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- table filieres
CREATE TABLE IF NOT EXISTS filieres (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    nom VARCHAR(150) NOT NULL,
    type VARCHAR(50), -- 'Cycle Préparatoire' ou 'Cycle Ingénieur'
    duree VARCHAR(50),
    nombre_etudiants INT,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- table modules
CREATE TABLE IF NOT EXISTS modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    filiere_id INT NOT NULL,
    code VARCHAR(20) NOT NULL,
    nom VARCHAR(150) NOT NULL,
    volume_horaire VARCHAR(50),
    professeur_responsable VARCHAR(100),
    semestre INT,
    FOREIGN KEY (filiere_id) REFERENCES filieres(id) ON DELETE CASCADE,
    INDEX idx_filiere (filiere_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- table absence
CREATE TABLE IF NOT EXISTS absences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    etudiant_id INT NOT NULL,
    module VARCHAR(100) NOT NULL,
    date_absence DATE NOT NULL,
    heure VARCHAR(50),
    filiere_id INT,
    FOREIGN KEY (etudiant_id) REFERENCES etudiants(id) ON DELETE CASCADE,
    FOREIGN KEY (filiere_id) REFERENCES filieres(id),
    INDEX idx_etudiant_absence (etudiant_id),
    INDEX idx_date (date_absence)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- table emploi
CREATE TABLE IF NOT EXISTS emploi (
    id INT AUTO_INCREMENT PRIMARY KEY,
    filiere_id INT NOT NULL,
    jour VARCHAR(20) NOT NULL,
    heure VARCHAR(50) NOT NULL,
    module VARCHAR(100) NOT NULL,
    type_seance VARCHAR(20), -- 'Cours', 'TD', 'TP'
    salle VARCHAR(50),
    professeur VARCHAR(100),
    FOREIGN KEY (filiere_id) REFERENCES filieres(id) ON DELETE CASCADE,
    INDEX idx_filiere_emploi (filiere_id),
    INDEX idx_jour (jour)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- table calendrier
CREATE TABLE IF NOT EXISTS calendrier_academique (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    date_debut DATE NOT NULL,
    date_fin DATE,
    type_evenement VARCHAR(50), -- 'examen', 'vacances', 'academique', 'ferie'
    description TEXT,
    INDEX idx_date (date_debut),
    INDEX idx_type (type_evenement)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- table contact
CREATE TABLE IF NOT EXISTS contact (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service VARCHAR(100) NOT NULL,
    responsable VARCHAR(100),
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(150) NOT NULL,
    bureau VARCHAR(50),
    reseaux_sociaux TEXT,
    horaires TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- INSERTION DES FILIÈRES

INSERT INTO filieres (code, nom, type, duree, nombre_etudiants, description) VALUES
('PREPA', 'Cycle Préparatoire Intégré', 'Cycle Préparatoire', '2 ans', 200, 'Formation scientifique fondamentale'),
('ITIRC', 'Informatique et Technologies des Réseaux', 'Cycle Ingénieur', '3 ans', 120, 'Formation en informatique et réseaux'),
('GTR', 'Génie des Télécommunications et Réseaux', 'Cycle Ingénieur', '3 ans', 90, 'Formation en télécommunications'),
('GI', 'Génie Informatique', 'Cycle Ingénieur', '3 ans', 150, 'Formation en génie informatique'),
('GE', 'Génie Électrique', 'Cycle Ingénieur', '3 ans', 80, 'Formation en génie électrique'),
('GM', 'Génie Mécanique', 'Cycle Ingénieur', '3 ans', 70, 'Formation en génie mécanique');

-- INSERTION DES MODULES

-- Modules pour ITIRC (filiere_id = 2)
INSERT INTO modules (filiere_id, code, nom, volume_horaire, professeur_responsable, semestre) VALUES
(2, 'INF301', 'Programmation Orientée Objet', '60h', 'Dr. Alami Hassan', 1),
(2, 'INF302', 'Bases de Données Avancées', '60h', 'Pr. Bennani Fatima', 1),
(2, 'INF303', 'Réseaux Informatiques', '50h', 'Dr. Mansouri Ahmed', 1),
(2, 'INF304', 'Génie Logiciel', '55h', 'Pr. Tazi Mohammed', 1),
(2, 'MAT301', 'Mathématiques Appliquées', '45h', 'Dr. Fassi Laila', 1),
(2, 'ANG301', 'Anglais Technique', '30h', 'Mrs. Smith Jennifer', 1),
(2, 'MGT301', 'Management de Projet', '40h', 'Dr. Lahlou Karim', 1),
(2, 'INF305', 'Développement Web', '50h', 'Dr. Rachid Omar', 1);
-- Modules pour GE - Génie Électrique (filiere_id = 5)
INSERT INTO modules (filiere_id, code, nom, volume_horaire, professeur_responsable, semestre) VALUES
(5, 'EL301', 'Électronique Analogique', '60h', 'Pr. El Amrani Mohamed', 1),
(5, 'EL302', 'Électronique Numérique', '55h', 'Dr. Benali Karim', 1),
(5, 'EL303', 'Machines Électriques', '65h', 'Pr. Alaoui Fatima', 1),
(5, 'EL304', 'Automatique et Régulation', '60h', 'Dr. Tazi Ahmed', 1),
(5, 'EL305', 'Réseaux Électriques', '50h', 'Pr. Mansouri Laila', 1),
(5, 'EL306', 'Énergies Renouvelables', '45h', 'Dr. Rachid Omar', 1),
(5, 'MAT301', 'Mathématiques Appliquées', '45h', 'Dr. Fassi Laila', 1),
(5, 'ANG301', 'Anglais Technique', '30h', 'Mrs. Smith Jennifer', 1),
(5, 'MGT301', 'Management de Projet', '40h', 'Dr. Lahlou Karim', 1);
-- Modules pour GINFO/GI - Génie Informatique (filiere_id = 4)
INSERT INTO modules (filiere_id, code, nom, volume_horaire, professeur_responsable, semestre) VALUES
(4, 'INF301', 'Programmation Orientée Objet', '60h', 'Dr. Alami Hassan', 1),
(4, 'INF302', 'Bases de Données Avancées', '60h', 'Pr. Bennani Fatima', 1),
(4, 'INF303', 'Réseaux Informatiques', '50h', 'Dr. Mansouri Ahmed', 1),
(4, 'INF304', 'Génie Logiciel', '55h', 'Pr. Tazi Mohammed', 1),
(4, 'MAT301', 'Mathématiques Appliquées', '45h', 'Dr. Fassi Laila', 1),
(4, 'ANG301', 'Anglais Technique', '30h', 'Mrs. Smith Jennifer', 1),
(4, 'MGT301', 'Management de Projet', '40h', 'Dr. Lahlou Karim', 1),
(4, 'INF305', 'Développement Web', '50h', 'Dr. Rachid Omar', 1);

-- CRÉATION DES 4 UTILISATEURS DE TEST

-- 1. UTILISATEUR TEST - Filière GINFO (Génie Informatique)
-- Email: test@ensa.ma
-- Mot de passe: tEST123
INSERT INTO etudiants (
    nom, prenom, date_naissance, lieu_naissance,
    numero_etudiant, cin,
    email, telephone, adresse_residence, adresse_postale,
    filiere, cycle, annee, niveau_scolaire, ecole,
    mot_de_passe, photo_profil
) VALUES (
    'TEST', 'Utilisateur', '2002-05-15', 'Oujda',
    'ENS2024001', 'BK123456',
    'test@ensa.ma', '+212 661-234567', '15 Rue Mohammed V, Oujda', 'BP 669, Oujda 60000',
    'GINFO', 'ingenieur', '2A', 'Cycle Ingénieur - 2ème Année', 'ENSAO',
    'tEST123', 'default-avatar.png'
);

-- 2. UTILISATEUR DOUAA - Filière ITIRC
-- Email: douaa.d@ensa.ma
-- Mot de passe: Douaa123
INSERT INTO etudiants (
    nom, prenom, date_naissance, lieu_naissance,
    numero_etudiant, cin,
    email, telephone, adresse_residence, adresse_postale,
    filiere, cycle, annee, niveau_scolaire, ecole,
    mot_de_passe, photo_profil, date_inscription
) VALUES (
    'DOUAE', 'DOUAE', '2003-08-15', 'Casablanca',
    'ENS2025001', 'AB123456',
    'douaa.d@ensa.ma', '+212 612-345678', '25 Avenue Mohammed V, Casablanca', 'BP 1000, Casablanca 20000',
    'ITIRC', 'ingenieur', '2A', 'Cycle ingénieur 2', 'ENSAO',
    'Douaa123', 'default-avatar.png', '2024-09-01'
);
-- 3. UTILISATEUR ASMAE - Filière GE (Génie Électrique)
-- Email: asmae.asma@ensa.ma
-- Mot de passe: Asmae123
INSERT INTO etudiants (
    nom, prenom, date_naissance, lieu_naissance,
    numero_etudiant, cin,
    email, telephone, adresse_residence, adresse_postale,
    filiere, cycle, annee, niveau_scolaire, ecole,
    mot_de_passe, photo_profil, date_inscription
) VALUES (
    'ASMAE', 'ASMAE', '2003-11-10', 'Fès',
    'ENS2025003', 'EF345678',
    'asmae.asma@ensa.ma', '+212 634-567890', '12 Avenue Allal Ben Abdellah, Fès', 'BP 3000, Fès 30000',
    'GE', 'ingenieur', '2A', 'Cycle ingénieur 2', 'ENSAO',
    'Asmae123', 'default-avatar.png', '2024-09-01'
);


-- NOTES POUR L'UTILISATEUR TEST (GINFO)

INSERT INTO notes (etudiant_id, code_module, nom_module, note_ds, note_examen, note_generale, coefficient, type_evaluation, statut) VALUES
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'INF301', 'Programmation Orientée Objet', 14.00, 15.00, 14.60, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'INF302', 'Bases de Données Avancées', 16.00, 17.00, 16.60, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'INF303', 'Réseaux Informatiques', 13.00, 14.00, 13.60, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'INF304', 'Génie Logiciel', 15.00, 16.00, 15.60, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'MAT301', 'Mathématiques Appliquées', 11.00, 12.00, 11.60, 2, 'DS + Examen', 'Rattrapage'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'ANG301', 'Anglais Technique', 17.00, 18.00, 17.60, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'MGT301', 'Management de Projet', 14.00, 15.00, 14.60, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'INF305', 'Développement Web', 18.00, 19.00, 18.60, 3, 'DS + Examen', 'Validé');
-- NOTES POUR DOUAA (ITIRC)
INSERT INTO notes (etudiant_id, code_module, nom_module, note_ds, note_examen, note_generale, coefficient, type_evaluation, statut) VALUES
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'INF301', 'Programmation Orientée Objet', 15.00, 16.00, 15.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'INF302', 'Bases de Données Avancées', 14.00, 15.00, 14.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'INF303', 'Réseaux Informatiques', 13.00, 14.00, 13.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'INF304', 'Génie Logiciel', 16.00, 17.00, 16.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'MAT301', 'Mathématiques Appliquées', 12.00, 13.00, 12.50, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'ANG301', 'Anglais Technique', 18.00, 19.00, 18.50, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'MGT301', 'Management de Projet', 15.00, 16.00, 15.50, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'douaa.d@ensa.ma'), 'INF305', 'Développement Web', 17.00, 18.00, 17.50, 3, 'DS + Examen', 'Validé');
-- NOTES POUR ASMAE (GE - Génie Électrique)
INSERT INTO notes (etudiant_id, code_module, nom_module, note_ds, note_examen, note_generale, coefficient, type_evaluation, statut) VALUES
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'EL301', 'Électronique Analogique', 14.00, 15.00, 14.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'EL302', 'Électronique Numérique', 13.00, 14.00, 13.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'EL303', 'Machines Électriques', 15.00, 16.00, 15.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'EL304', 'Automatique et Régulation', 12.00, 13.00, 12.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'EL305', 'Réseaux Électriques', 16.00, 17.00, 16.50, 3, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'EL306', 'Énergies Renouvelables', 11.00, 12.00, 11.50, 2, 'DS + Examen', 'Rattrapage'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'MAT301', 'Mathématiques Appliquées', 17.00, 18.00, 17.50, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'ANG301', 'Anglais Technique', 15.00, 16.00, 15.50, 2, 'DS + Examen', 'Validé'),
((SELECT id FROM etudiants WHERE email = 'asmae.asma@ensa.ma'), 'MGT301', 'Management de Projet', 13.00, 14.00, 13.50, 2, 'DS + Examen', 'Validé');
-- ABSENCES (pour l'utilisateur TEST)
INSERT INTO absences (etudiant_id, module, date_absence, heure, filiere_id) VALUES
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'Programmation Orientée Objet', '2024-12-15', '08h00-10h00', (SELECT id FROM filieres WHERE code = 'GI')),
((SELECT id FROM etudiants WHERE email = 'test@ensa.ma'), 'Mathématiques Appliquées', '2024-12-18', '10h00-12h00', (SELECT id FROM filieres WHERE code = 'GI'));
-- EMPLOI DU TEMPS (pour ITIRC)
INSERT INTO emploi (filiere_id, jour, heure, module, type_seance, salle, professeur) VALUES
(2, 'Lundi', '08h00-10h00', 'Programmation Orientée Objet', 'Cours', 'Amphi A', 'Dr. Alami'),
(2, 'Lundi', '10h00-12h00', 'Bases de Données Avancées', 'TD', 'Salle 12', 'Pr. Bennani'),
(2, 'Lundi', '14h00-16h00', 'Réseaux Informatiques', 'TP', 'Lab Info 1', 'Dr. Mansouri'),
(2, 'Lundi', '16h00-18h00', 'Développement Web', 'TP', 'Lab Info 2', 'Dr. Rachid'),
(2, 'Mardi', '08h00-10h00', 'Génie Logiciel', 'Cours', 'Amphi B', 'Pr. Tazi'),
(2, 'Mardi', '10h00-12h00', 'Mathématiques Appliquées', 'TD', 'Salle 8', 'Dr. Fassi'),
(2, 'Mardi', '14h00-16h00', 'Programmation Orientée Objet', 'TP', 'Lab Info 2', 'Dr. Alami'),
(2, 'Mercredi', '08h00-10h00', 'Anglais Technique', 'Cours', 'Salle 15', 'Mrs. Smith'),
(2, 'Mercredi', '10h00-12h00', 'Développement Web', 'TP', 'Lab Info 1', 'Dr. Rachid'),
(2, 'Jeudi', '08h00-10h00', 'Bases de Données Avancées', 'Cours', 'Amphi A', 'Pr. Bennani'),
(2, 'Jeudi', '14h00-16h00', 'Management de Projet', 'TD', 'Salle 10', 'Dr. Lahlou'),
(2, 'Vendredi', '08h00-10h00', 'Réseaux Informatiques', 'Cours', 'Amphi C', 'Dr. Mansouri'),
(2, 'Vendredi', '10h00-12h00', 'Développement Web', 'TP', 'Lab Info 3', 'Dr. Rachid'),
(2, 'Samedi', '08h00-10h00', 'Génie Logiciel', 'TD', 'Salle 7', 'Pr. Tazi');
-- CALENDRIER ACADÉMIQUE
INSERT INTO calendrier_academique (titre, date_debut, date_fin, type_evenement, description) VALUES
('Rentrée Universitaire', '2024-09-02', '2024-09-02', 'academique', 'Début des cours pour toutes les filières'),
('Examens Partiels', '2024-10-15', '2024-10-20', 'examen', 'Contrôles continus pour le premier semestre'),
('Examens Finaux S1', '2024-12-20', '2024-12-25', 'examen', 'Session d\'examens de fin de semestre'),
('Vacances d\'Hiver', '2024-12-26', '2025-01-05', 'vacances', 'Pause hivernale'),
('Début Semestre 2', '2025-01-06', '2025-01-06', 'academique', 'Reprise des cours'),
('Examens Partiels S2', '2025-03-10', '2025-03-15', 'examen', 'Contrôles continus pour le deuxième semestre'),
('Examens Finaux S2', '2025-05-20', '2025-05-25', 'examen', 'Session d\'examens de fin d\'année'),
('Session de Rattrapage', '2025-06-10', '2025-06-20', 'examen', 'Examens de rattrapage pour les deux semestres');
-- CONTACTS
INSERT INTO contact (service, responsable, telephone, email, bureau, reseaux_sociaux, horaires) VALUES
('Scolarité', 'Mme. Fatima', '+212 536-500-601', 'scolarite@ensao.ma', 'Bâtiment Administration - Bureau 12', '@ensao_scolarite', 'Lundi - Vendredi: 9h00 - 17h00'),
('Direction', 'Pr. Mohammed', '+212 536-500-600', 'direction@ensao.ma', 'Bâtiment Administration - Bureau 1', '@ensao_official', 'Sur rendez-vous'),
('Bibliothèque', 'M. Ahmed', '+212 536-500-620', 'bibliotheque@ensao.ma', 'Bâtiment Bibliothèque', '@ensao_biblio', 'Lundi - Samedi: 8h00 - 19h00'),
('Service Informatique', 'Dr. Hassan', '+212 536-500-630', 'informatique@ensao.ma', 'Bâtiment Technique - Bureau 25', NULL, 'Lundi - Vendredi: 8h30 - 16h30'),
('Chef Filière ITIRC', 'Pr. Mohammed', '+212 536-500-640', 'itirc@ensao.ma', 'Bâtiment Pédagogique - Bureau 8', '@ensao_itirc', 'Mardi et Jeudi: 14h00 - 16h00');
-- VÉRIFICATION
SELECT id, email, nom, prenom, filiere, mot_de_passe 
FROM etudiants 
ORDER BY id;

