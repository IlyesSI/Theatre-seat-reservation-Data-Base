drop database if exists HJSL_Gestion_spectacles;
create database HJSL_Gestion_spectacles;
use HJSL_Gestion_spectacles;


drop table if exists HJSL_Reservations;
drop table if exists HJSL_Spectateurs;
drop table if exists HJSL_Spectacles;
drop table if exists HJSL_Places;
drop table if exists HJSL_Salles;
drop table if exists HJSL_theatre;

create table HJSL_Theatre (
	Nom_theatre varchar(80) primary key
    , Num_Rue int
    , Nom_Rue varchar(80)
    , CP int
);

create table HJSL_Salles (
	id_salle varchar(30) primary key
    , nom_theatre varchar(80) 
    , capacite int
    , Pource_cat_A int check (Pource_cat_A >= 0 and Pource_cat_A <= 100)
    , Pource_cat_B int check (Pource_cat_B >= 0 and Pource_cat_B <= 100)
    , Pource_cat_C int check (Pource_cat_C >= 0 and Pource_cat_C <= 100)
    , foreign key fk_nom_theatre (nom_theatre) references HJSL_theatre(nom_theatre)
);
    
create table HJSL_Places (
	categorie_place char(1) check (categorie_place in ('A', 'B', 'C'))
	, numero_place int
    , id_salle  varchar(30)
    , foreign key fk_id_salle (id_salle) references HJSL_Salles(id_salle)
    , primary key (categorie_place, numero_place ,id_salle)
); 
 
create table HJSL_Spectacles (
	date_spectacle date
    , intitule_spectacle varchar(120)
    , id_salle varchar(30)
    , genre varchar(80)
    , public_cible varchar(80)
    , heur_debut time
    , duree int 
    , placement_libre boolean
    , Prix_initial_cat_A int
	, Prix_initial_cat_B int
    , Prix_initial_cat_C int
    , foreign key fk_id_salle (id_salle) references HJSL_Salles (id_salle)
    , primary key (date_spectacle, intitule_spectacle, id_salle)
    , unique key (date_spectacle, intitule_spectacle)
);
CREATE INDEX idx_spectacles_date_intitule ON HJSL_Spectacles (date_spectacle, intitule_spectacle);

    
create table HJSL_Spectateurs (
	id_spectateur varchar(50) primary key
    , nom varchar(50)
    , prenom varchar(50)
    , DDN date
    , CP int
);

create table HJSL_Reservations (
	Id_reservation int
	, Id_spectateur varchar(50)
	, Date_spectacle date
	, Intitule_spectacle varchar(120)
    , numero_place int
    , categorie_place char(1) check (categorie_place in ('A', 'B', 'C'))
    , id_salle varchar(30)
	, Date_reservation date
	, Prix double
    , foreign key (Id_spectateur) references HJSL_Spectateurs (Id_spectateur)
    , foreign key (Date_spectacle, intitule_spectacle, id_salle) references HJSL_Spectacles (Date_spectacle, intitule_spectacle, id_salle)
    , foreign key (categorie_place, numero_place, id_salle) references HJSL_Places(categorie_place, numero_place, id_salle)
    , primary key (Id_reservation, Date_spectacle, Intitule_spectacle, id_salle, categorie_place, numero_place)
    -- , unique key (id_reservation, categorie_place)
);


drop trigger if exists avant_insertion_dans_spectacles;

DELIMITER //

CREATE TRIGGER avant_insertion_dans_spectacles
BEFORE INSERT ON HJSL_Spectacles
FOR EACH ROW
BEGIN
    DECLARE capacite_cat_A INT;
    DECLARE capacite_cat_B INT;
    DECLARE capacite_cat_C INT;

    -- Vérifier la disponibilité des places pour chaque catégorie
    IF NEW.Prix_initial_cat_A IS NOT NULL THEN
        SELECT Pource_cat_A INTO capacite_cat_A FROM HJSL_Salles WHERE id_salle = NEW.id_salle;
        IF capacite_cat_A IS NULL OR capacite_cat_A < 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erreur : La salle ne dispose pas de places dans la catégorie A.';
        END IF;
    END IF;

    IF NEW.Prix_initial_cat_B IS NOT NULL THEN
        SELECT Pource_cat_B INTO capacite_cat_B FROM HJSL_Salles WHERE id_salle = NEW.id_salle;
        IF capacite_cat_B IS NULL OR capacite_cat_B < 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erreur : La salle ne dispose pas de places dans la catégorie B.';
        END IF;
    END IF;

    IF NEW.Prix_initial_cat_C IS NOT NULL THEN
        SELECT Pource_cat_C INTO capacite_cat_C FROM HJSL_Salles WHERE id_salle = NEW.id_salle;
        IF capacite_cat_C IS NULL OR capacite_cat_C < 1 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Erreur : La salle ne dispose pas de places dans la catégorie C.';
        END IF;
    END IF;

    -- Vérifier l'existence d'un autre spectacle programmé dans la même salle pendant le même intervalle horaire
    IF EXISTS (
        SELECT 1
        FROM HJSL_Spectacles s
        WHERE s.date_spectacle = NEW.date_spectacle
            AND s.id_salle = NEW.id_salle
            AND (
                (s.heur_debut <= NEW.heur_debut AND ADDTIME(s.heur_debut, SEC_TO_TIME(s.duree * 60)) > NEW.heur_debut)
                OR (NEW.heur_debut <= s.heur_debut AND ADDTIME(NEW.heur_debut, SEC_TO_TIME(NEW.duree * 60)) > s.heur_debut)
            )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Erreur : Un autre spectacle est déjà programmé dans la même salle pendant cet intervalle horaire.';
    END IF;
END;

//
DELIMITER ;


drop trigger if exists after_insert_salle;

-- debut ----- créer automatiquement des places lors de la création d'une nouvelle salle 
DELIMITER //

CREATE TRIGGER after_insert_salle
AFTER INSERT ON HJSL_Salles
FOR EACH ROW
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE total_places INT;
    DECLARE places_cat_A INT;
    DECLARE places_cat_B INT;
    DECLARE places_cat_C INT;
    
    -- Calcul du nombre de places pour chaque catégorie
    SET places_cat_A = ROUND(new.capacite * new.Pource_cat_A / 100);
    SET places_cat_B = ROUND(new.capacite * new.Pource_cat_B / 100);
    SET places_cat_C = ROUND(new.capacite * new.Pource_cat_C / 100);
    SET total_places = places_cat_A + places_cat_B + places_cat_C;
    
    -- Ajouter les places à la table 'places'
    WHILE i <= total_places DO
        IF i <= places_cat_A THEN
            INSERT INTO HJSL_Places(categorie_place, numero_place, id_salle) VALUES ('A', i, new.id_salle);
        ELSEIF i <= places_cat_A + places_cat_B THEN 
            INSERT INTO HJSL_Places(categorie_place, numero_place, id_salle) VALUES ('B', i - places_cat_A, new.id_salle);
        ELSE
            INSERT INTO HJSL_Places(categorie_place, numero_place, id_salle) VALUES ('C', i - places_cat_A - places_cat_B, new.id_salle);
        END IF;
        
        SET i = i + 1;
    END WHILE;
END //

DELIMITER ;
-- fin ------- créer automatiquement des places lors de la création d'une nouvelle salle 


drop TRIGGER if exists before_insert_reservation;

-- restreindre l'ajout d'une nouvelle réservation avec le même id_reservation uniquement lorsque la catégorie de place est la même pour les deux réservations ayant le même id
DELIMITER //

CREATE TRIGGER before_insert_reservation
BEFORE INSERT ON HJSL_Reservations
FOR EACH ROW
BEGIN
    DECLARE count_same_category INT;

    SELECT COUNT(*) INTO count_same_category
    FROM HJSL_Reservations
    WHERE id_reservation = NEW.id_reservation
    AND categorie_place <> NEW.categorie_place;

    IF count_same_category > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Impossible d insérer une réservation avec le même id_reservation et une catégorie_place différente.';
    END IF;
END //

DELIMITER ;


drop procedure if exists Calcule_prix_reservation;

DELIMITER //

CREATE PROCEDURE Calcule_prix_reservation (
    IN p_Date_spectacle DATE,
    IN p_Intitule_spectacle VARCHAR(120),
    IN p_id_salle VARCHAR(30),
    IN p_categorie_place CHAR,
    OUT prix_calcul DOUBLE
)
BEGIN
    DECLARE nbr_places_total INT;
    DECLARE nbr_places_reservees INT;
    DECLARE heur_debut_spectacle TIME;
    DECLARE pourcentage_places_reservees DOUBLE;
    DECLARE prix_initial DOUBLE;

    -- Compter le nombre de places dans la catégorie
    SELECT COUNT(*) INTO nbr_places_total FROM HJSL_Places WHERE id_salle = p_id_salle AND categorie_place = p_categorie_place;

    -- Compter le nombre de places réservées dans une catégorie pour un spectacle donné
    SELECT COUNT(*) INTO nbr_places_reservees FROM HJSL_Reservations WHERE Date_spectacle = p_Date_spectacle AND Intitule_spectacle = p_Intitule_spectacle;

    -- Récupérer l'heure de début du spectacle
    SELECT Heur_debut INTO heur_debut_spectacle FROM HJSL_Spectacles WHERE Date_spectacle = p_Date_spectacle AND Intitule_spectacle = p_Intitule_spectacle;

    -- Récupérer le prix initial
    IF p_categorie_place = 'A' THEN
        SELECT Prix_initial_cat_A INTO prix_initial FROM HJSL_Spectacles WHERE Date_spectacle = p_Date_spectacle AND Intitule_spectacle = p_Intitule_spectacle;
    ELSEIF p_categorie_place = 'B' THEN
        SELECT Prix_initial_cat_B INTO prix_initial FROM HJSL_Spectacles WHERE Date_spectacle = p_Date_spectacle AND Intitule_spectacle = p_Intitule_spectacle;
    ELSE
        SELECT Prix_initial_cat_C INTO prix_initial FROM HJSL_Spectacles WHERE Date_spectacle = p_Date_spectacle AND Intitule_spectacle = p_Intitule_spectacle;
    END IF;

    -- Calculer le pourcentage de places réservées
    SET pourcentage_places_reservees = (nbr_places_reservees * 100) / nbr_places_total;

    -- Calculer le prix
    IF heur_debut_spectacle > '12:00:00' THEN
        SET prix_initial = prix_initial * 0.8;
    END IF;

    IF pourcentage_places_reservees >= 60 AND pourcentage_places_reservees < 80 THEN
        SET prix_initial = prix_initial * 1.3;
    ELSEIF pourcentage_places_reservees >= 80 THEN
        SET prix_initial = prix_initial * 1.4;
    END IF;

    -- Renvoyer le résultat
    SET prix_calcul = prix_initial;

END;

//
DELIMITER ;
