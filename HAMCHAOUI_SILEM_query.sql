-- Insertion dans la table HJSL_Theatre avec une adresse fictive à Marseille

INSERT INTO HJSL_Theatre (Nom_theatre, Num_Rue, Nom_Rue, CP) VALUES ('Théâtre de la Mer', 25, 'Quai du Port', 13002);
INSERT INTO HJSL_Theatre (Nom_theatre, Num_Rue, Nom_Rue, CP) VALUES ('Le Théâtre Provençal', 42, 'Avenue de la Canebière', 13001);

SELECT * FROM hjsl_gestion_spectacles.hjsl_theatre;

-- Ajout de salles pour les théâtres

INSERT INTO HJSL_Salles (id_salle, nom_theatre, capacite, Pource_cat_A, Pource_cat_B, Pource_cat_C)
VALUES ('Salle1_TheatreProvençal', 'Le Théâtre Provençal', 150, 30, 40, 30),
       ('Salle2_TheatreProvençal', 'Le Théâtre Provençal', 100, 20, 50, 30);

INSERT INTO HJSL_Salles (id_salle, nom_theatre, capacite, Pource_cat_A, Pource_cat_B, Pource_cat_C)
VALUES ('Salle1_TheatreMer', 'Théâtre de la Mer', 200, 25, 45, 30),
       ('Salle2_TheatreMer', 'Théâtre de la Mer', 120, 15, 55, 30);

SELECT * FROM HJSL_Salles;
SELECT * FROM HJSL_places;
-- Ajout de spectacles pour les salles

INSERT INTO HJSL_Spectacles (date_spectacle, intitule_spectacle, id_salle, genre, public_cible, heur_debut, duree, placement_libre, Prix_initial_cat_A, Prix_initial_cat_B, Prix_initial_cat_C)
VALUES 
  ('2024-03-01', 'Comédie Musicale', 'Salle1_TheatreProvençal', 'Comédie Musicale', 'Tout public', '18:30:00', 120, 0, 60, 40, 30),
  ('2024-04-15', 'Drame', 'Salle2_TheatreProvençal', 'Drame', 'Adultes', '20:00:00', 90, 1, 70, 50, 40),
  ('2024-05-20', 'Théâtre Classique', 'Salle1_TheatreProvençal', 'Théâtre Classique', 'Tout public', '19:00:00', 110, 0, 50, 30, 20),
  ('2024-06-10', 'Comédie', 'Salle2_TheatreProvençal', 'Comédie', 'Tout public', '17:45:00', 100, 1, 55, 35, 25);

-- Tester le trigger avant_insertion_dans_spectacles en ajoutant un spectacle avec une catégorie sans places disponibles (doit échouer)
INSERT INTO HJSL_Spectacles (date_spectacle, intitule_spectacle, id_salle, genre, public_cible, heur_debut, duree, placement_libre, Prix_initial_cat_A, Prix_initial_cat_B, Prix_initial_cat_C)
VALUES ('2024-03-01', 'spectacle 4', 'Salle1_TheatreProvençal', 'Comédie', 'Tout public', '18:30:00', 120, 0, 60, 40, 30);


INSERT INTO HJSL_Spectacles (date_spectacle, intitule_spectacle, id_salle, genre, public_cible, heur_debut, duree, placement_libre, Prix_initial_cat_A, Prix_initial_cat_B, Prix_initial_cat_C)
VALUES 
  ('2024-03-05', 'Drame', 'Salle1_TheatreMer', 'Drame', 'Adultes', '19:30:00', 100, 0, 70, 50, 40),
  ('2024-04-18', 'Comédie Musicale', 'Salle2_TheatreMer', 'Comédie Musicale', 'Tout public', '20:15:00', 110, 1, 65, 45, 35),
  ('2024-05-25', 'Théâtre Classique', 'Salle1_TheatreMer', 'Théâtre Classique', 'Tout public', '18:45:00', 95, 0, 55, 35, 25),
  ('2024-06-15', 'Comédie', 'Salle2_TheatreMer', 'Comédie', 'Tout public', '18:00:00', 120, 1, 60, 40, 30);

SELECT * FROM hjsl_gestion_spectacles.hjsl_spectacles;

-- Ajout de spectateurs fictifs
INSERT INTO HJSL_Spectateurs (id_spectateur, nom, prenom, DDN, CP)
VALUES 
  ('Spectateur1', 'Dupont', 'Pierre', '1990-05-15', 13001),
  ('Spectateur2', 'Martin', 'Sophie', '1985-08-20', 13002),
  ('Spectateur3', 'Leclerc', 'Antoine', '1995-02-28', 13003),
  ('Spectateur4', 'Lefevre', 'Isabelle', '1980-11-10', 13004),
  ('Spectateur5', 'Leroy', 'Claire', '1992-07-22', 13005),
  ('Spectateur6', 'Girard', 'Lucas', '1988-04-17', 13006),
  ('Spectateur7', 'Moreau', 'Julie', '1999-01-09', 13007),
  ('Spectateur8', 'Fournier', 'Maxime', '1993-12-03', 13008),
  ('Spectateur9', 'Lemoine', 'Sophie', '1987-09-14', 13009),
  ('Spectateur10', 'Deschamps', 'Alexandre', '1994-06-28', 13010),
  ('Spectateur11', 'Caron', 'Camille', '1986-03-19', 13011),
  ('Spectateur12', 'Perrin', 'Antoine', '1998-08-12', 13012),
  ('Spectateur13', 'Roux', 'Émilie', '1984-05-26', 13013),
  ('Spectateur14', 'Fischer', 'Nicolas', '1990-10-31', 13014);

SELECT * FROM HJSL_Spectateurs;


-- Ajout de réservations pour quelques spectateurs et spectacles
INSERT INTO HJSL_Reservations (Id_reservation, Id_spectateur, Date_spectacle, Intitule_spectacle, numero_place, categorie_place, id_salle, Date_reservation, Prix)
VALUES 
  (1, 'Spectateur1', '2024-03-01', 'Comédie Musicale', 5, 'A', 'Salle1_TheatreProvençal', '2023-12-15', 60),
  (2, 'Spectateur2', '2024-03-05', 'Drame', 8, 'B', 'Salle1_TheatreMer', '2023-12-16', 50),
  (3, 'Spectateur3', '2024-04-15', 'Drame', 15, 'C', 'Salle2_TheatreProvençal', '2023-12-17', 40),
  (4, 'Spectateur4', '2024-04-18', 'Comédie Musicale', 12, 'A', 'Salle2_TheatreMer', '2023-12-18', 65),
  (5, 'Spectateur5', '2024-05-20', 'Théâtre Classique', 18, 'B', 'Salle1_TheatreProvençal', '2023-12-19', 30),
  (6, 'Spectateur6', '2024-05-25', 'Classique', 10, 'C', 'Salle1_TheatreMer', '2023-12-20', 25),
  (7, 'Spectateur7', '2024-06-10', 'Comédie', 9, 'B', 'Salle2_TheatreProvençal', '2023-12-21', 35),
  (8, 'Spectateur8', '2024-06-15', 'Comédie', 6, 'A', 'Salle2_TheatreMer', '2023-12-22', 60),
  (9, 'Spectateur9', '2024-06-15', 'Comédie', 6, 'A', 'Salle2_TheatreMer', '2023-12-22', 60);

SELECT * FROM hjsl_gestion_spectacles.hjsl_reservations;
-- Tester le trigger before_insert_reservation en ajoutant une réservation avec le même id_reservation mais une catégorie différente (doit échouer)
INSERT INTO HJSL_Reservations (Id_reservation, Id_spectateur, Date_spectacle, Intitule_spectacle, numero_place, categorie_place, id_salle, Date_reservation, Prix)
VALUES (1, 'Spectateur1', '2024-03-01', 'Nouveau Spectacle', 5, 'B', 'Salle1_TheatreProvençal', '2023-12-15', 60);

-- vue places categories
CREATE VIEW Vue_Places_Categorie AS
SELECT id_salle,
       SUM(CASE WHEN categorie_place = 'A' THEN 1 ELSE 0 END) AS Nombre_Places_Cat_A,
       SUM(CASE WHEN categorie_place = 'B' THEN 1 ELSE 0 END) AS Nombre_Places_Cat_B,
       SUM(CASE WHEN categorie_place = 'C' THEN 1 ELSE 0 END) AS Nombre_Places_Cat_C
FROM HJSL_Places
GROUP BY id_salle;

SELECT * FROM Vue_Places_Categorie;

-- Vue pour afficher les détails des spectacles avec le nombre de réservations
CREATE VIEW Vue_Spectacles_Reservations AS
SELECT s.*, COUNT(r.Id_reservation) AS Nombre_Reservations
FROM HJSL_Spectacles s
LEFT JOIN HJSL_Reservations r ON s.Date_spectacle = r.Date_spectacle AND s.Intitule_spectacle = r.Intitule_spectacle AND s.id_salle = r.id_salle
GROUP BY s.Date_spectacle, s.Intitule_spectacle, s.id_salle;

-- Afficher les informations détaillées sur les spectacles et les réservations
SELECT * FROM Vue_Spectacles_Reservations;

-- vu places disponible

CREATE VIEW Vue_Places_Disponibles AS
SELECT pc.id_salle,
       pc.Nombre_Places_Cat_A - COUNT(CASE WHEN r.categorie_place = 'A' THEN 1 ELSE NULL END) AS Places_Disponibles_Cat_A,
       pc.Nombre_Places_Cat_B - COUNT(CASE WHEN r.categorie_place = 'B' THEN 1 ELSE NULL END) AS Places_Disponibles_Cat_B,
       pc.Nombre_Places_Cat_C - COUNT(CASE WHEN r.categorie_place = 'C' THEN 1 ELSE NULL END) AS Places_Disponibles_Cat_C
FROM Vue_Places_Categorie pc
LEFT JOIN HJSL_Reservations r ON pc.id_salle = r.id_salle
GROUP BY pc.id_salle;

SELECT * FROM Vue_Places_Disponibles;

CREATE VIEW Vue_Tarification_Billets AS
SELECT r.Id_reservation, r.Date_spectacle, r.Intitule_spectacle, r.id_salle, r.categorie_place, r.numero_place,
    CASE
        WHEN s.heur_debut > '12:00:00' THEN r.Prix * 0.8
        WHEN (
            SELECT COUNT(*)
            FROM HJSL_Reservations r2
            WHERE r2.Date_spectacle = r.Date_spectacle
            AND r2.Intitule_spectacle = r.Intitule_spectacle
            AND r2.id_salle = r.id_salle
            AND r2.categorie_place = r.categorie_place
        ) * 100 / (
            SELECT COUNT(*)
            FROM HJSL_Places  WHERE id_salle = r.id_salle AND categorie_place = r.categorie_place ) >= 80 THEN r.Prix * 1.4
        WHEN ( SELECT COUNT(*) FROM HJSL_Reservations r2 WHERE r2.Date_spectacle = r.Date_spectacle AND r2.Intitule_spectacle = r.Intitule_spectacle AND r2.id_salle = r.id_salle AND r2.categorie_place = r.categorie_place
        ) * 100 / ( SELECT COUNT(*) FROM HJSL_Places  WHERE id_salle = r.id_salle AND categorie_place = r.categorie_place ) >= 60 THEN r.Prix * 1.3
        ELSE r.Prix
    END AS Prix_Calculé
FROM HJSL_Reservations r
JOIN HJSL_Spectacles s ON r.Date_spectacle = s.Date_spectacle AND r.Intitule_spectacle = s.Intitule_spectacle AND r.id_salle = s.id_salle;
SELECT * FROM Vue_Tarification_Billets;
