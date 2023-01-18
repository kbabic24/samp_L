BEGIN
   FOR cur_rec IN (SELECT object_name, object_type
                     FROM user_objects
                    WHERE object_type IN
                             ('TABLE',
                              'VIEW',
                              'PACKAGE',
                              'PROCEDURE',
                              'FUNCTION',
                              'SEQUENCE',
                              'SYNONYM',
                              'PACKAGE BODY'
                             ))
   LOOP
      BEGIN
         IF cur_rec.object_type = 'TABLE'
         THEN
            EXECUTE IMMEDIATE    'DROP '
                              || cur_rec.object_type
                              || ' "'
                              || cur_rec.object_name
                              || '" CASCADE CONSTRAINTS';
         ELSE
            EXECUTE IMMEDIATE    'DROP '
                              || cur_rec.object_type
                              || ' "'
                              || cur_rec.object_name
                              || '"';
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (   'FAILED: DROP '
                                  || cur_rec.object_type
                                  || ' "'
                                  || cur_rec.object_name
                                  || '"'
                                 );
      END;
   END LOOP;
END;

/

CREATE TABLE vrste_zaposlenja (
    id INT PRIMARY KEY,
    vrsta VARCHAR(50) NOT NULL
);

INSERT INTO vrste_zaposlenja (id, vrsta) VALUES (1, 'Puno radno vrijeme');
INSERT INTO vrste_zaposlenja (id, vrsta) VALUES (2, 'Pola radnog vremena');
INSERT INTO vrste_zaposlenja (id, vrsta) VALUES (3, 'Vanjski suradnik/ica');

CREATE TABLE smjerovi (
    id INT PRIMARY KEY,
    naziv_smjera VARCHAR(50) NOT NULL,
    otvoren_od INT,
    aktivan INT
);

INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (1, 'Održavanje ra?unalnih sustava', 2010, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (2, 'Upravljanje u kriznim uvjetima', 2019, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (3, 'Održavanje zrakoplova', 2020, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (4, 'O?na optika', 2021, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (5, 'Motorna vozila', 2019, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (6, 'Krizni menadžment', 2014, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (7, 'Informacijski sustavi', 2015, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (8, 'Logisti?ki menadžment', 2013, 1);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (9, 'Menadžment (neaktivno)', 2014, NULL);
INSERT INTO smjerovi (id, naziv_smjera, otvoren_od, aktivan) VALUES (10, 'Logistika (neaktivno)', NULL, 0);

CREATE TABLE statusi (
    id INT PRIMARY KEY,
    naziv_statusa VARCHAR(50) NOT NULL
);

INSERT INTO statusi (id, naziv_statusa) VALUES (1, 'Aktivni student/ica');
INSERT INTO statusi (id, naziv_statusa) VALUES (2, 'Zamrznuta godina');
INSERT INTO statusi (id, naziv_statusa) VALUES (3, 'Neaktivan');
INSERT INTO statusi (id, naziv_statusa) VALUES (4, 'Isklju?en');

CREATE TABLE uloge_profesora (
    id INT PRIMARY KEY,
    naziv_uloge VARCHAR(50) NOT NULL
);

INSERT INTO uloge_profesora (id, naziv_uloge) VALUES (1, 'Asistent');
INSERT INTO uloge_profesora (id, naziv_uloge) VALUES (2, 'Predava?');


CREATE TABLE studenti (
    id INT PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    jmbag CHAR(10) NOT NULL,
    datum_rodenja DATE,
    email VARCHAR(255),
    adresa VARCHAR(255),

    smjer_id INT NOT NULL,
    status_id INT NOT NULL,

    CONSTRAINT fk_studenti_status
    FOREIGN KEY (status_id)
    REFERENCES statusi(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_studenti_smjer
    FOREIGN KEY (smjer_id)
    REFERENCES smjerovi(id)
    ON DELETE CASCADE
);

CREATE TABLE predmeti (
    id INT PRIMARY KEY,
    naziv_predmeta VARCHAR(50) NOT NULL,
    otvoren_od INT,
    aktivan INT
);


CREATE TABLE profesori (
    id INT PRIMARY KEY,
    oib CHAR(11) NOT NULL,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    email VARCHAR(255),
    adresa VARCHAR(255),
    godina_rodenja INT,
    iban CHAR(21),
    datum_zaposlenja DATE,
    vrsta_zaposlenja_id INT,

    CONSTRAINT fk_profesori_vz
    FOREIGN KEY (vrsta_zaposlenja_id)
    REFERENCES vrste_zaposlenja(id)
    ON DELETE CASCADE
);


CREATE TABLE predaje (
    predaje_od INT,

    profesor_id INT NOT NULL,
    predmet_id INT NOT NULL,
    uloga_id INT NOT NULL,

    CONSTRAINT fk_predaje_profesor
    FOREIGN KEY (profesor_id)
    REFERENCES profesori(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_predaje_predmet
    FOREIGN KEY (predmet_id)
    REFERENCES predmeti(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_predaje_uloga
    FOREIGN KEY (uloga_id)
    REFERENCES uloge_profesora(id)
    ON DELETE CASCADE
);

CREATE TABLE ocjene (
    id INT PRIMARY KEY,
    datum_ocjene DATE,
    ocjena INT,

    profesor_id INT NOT NULL,
    predmet_id INT NOT NULL,
    student_id INT NOT NULL,

    CONSTRAINT fk_ocjene_profesor
    FOREIGN KEY (profesor_id)
    REFERENCES profesori(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_ocjene_predmet
    FOREIGN KEY (predmet_id)
    REFERENCES predmeti(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_ocjene_student
    FOREIGN KEY (student_id)
    REFERENCES studenti(id)
    ON DELETE CASCADE
);

CREATE TABLE upisano (
    predmet_id INT NOT NULL,
    student_id INT NOT NULL,
    upisan_od DATE,

    CONSTRAINT fk_upisano_predmet
    FOREIGN KEY (predmet_id)
    REFERENCES predmeti(id)
    ON DELETE CASCADE,

    CONSTRAINT fk_upisano_student
    FOREIGN KEY (student_id)
    REFERENCES studenti(id)
    ON DELETE CASCADE
);

CREATE TABLE sumirano (
    kljuc VARCHAR(255) PRIMARY KEY,
    vrijednost VARCHAR(255) NOT NULL
);

INSERT INTO sumirano VALUES ('broj_profesora', '0');
INSERT INTO sumirano VALUES ('broj_studenata', '0');
INSERT INTO sumirano VALUES ('broj_predmeta', '0');
INSERT INTO sumirano VALUES ('broj_smjerova', '0');
INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (1, 'Nursing 135', 2007, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (2, 'Biological Science 412', 2008, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (3, 'Teaching 319', 2017, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (4, 'Communications 220', 2014, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (5, 'Nursing 561', 2003, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (6, 'Engineering 481', 2020, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (7, 'Business 439', 2020, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (8, 'Business 595', 2011, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (9, 'Computer Science 323', 2013, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (10, 'Nursing 591', 2011, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (11, 'Commerce 332', 2020, 1);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (12, 'Law 585', 2000, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (13, 'Arts 354', 2007, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (14, 'Law 145', 2012, 0);


INSERT INTO predmeti (id, naziv_predmeta, otvoren_od, aktivan)
VALUES (15, 'Computer Science 122', 2011, 1);
INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (1, '3655232278', 'Merrill', 'Lockman', 'carey_okon@wolff.name', '38473 Wilkinson Springs', DATE '1973-09-06', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (2, '6773298283', 'Lady', 'Wuckert', 'sammie.grimes@hagenes-brown.biz', '6654 Nikolaus Tunnel', DATE '1994-08-05', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (3, '8176513279', 'Oliver', 'Cummerata', 'lauryn_boehm@watsica-champlin.io', '3980 Predovic Mountains', DATE '1991-06-07', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (4, '1466476222', 'Lonnie', 'Kertzmann', 'edwin_oconnell@bednar-volkman.net', '43034 Roberts Ports', DATE '1973-07-08', 1, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (5, '7763336186', 'Hiram', 'Quitzon', 'alix.larkin@mohr.info', '2294 Clair Underpass', DATE '1987-08-10', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (6, '2941782691', 'Elden', 'Hagenes', 'burt_cummerata@dubuque-becker.com', '53777 King Road', DATE '1997-03-08', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (7, '2333175913', 'Octavia', 'Green', 'petronila_cassin@boyer-reichert.com', '38667 Doyle Summit', DATE '1982-01-27', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (8, '7689252566', 'Jodie', 'Wolff', 'jared@dibbert.co', '53891 Marlin Mill', DATE '1994-06-26', 1, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (9, '7134991333', 'Maria', 'Homenick', 'ethelyn@klocko.io', '33927 Schowalter Rapid', DATE '1970-01-04', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (10, '8162645994', 'Etha', 'Jacobs', 'berenice@oreilly.com', '225 Greg Ways', DATE '1991-03-07', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (11, '1326483945', 'Ward', 'Schamberger', 'macy@waters-vonrueden.co', '322 Monica Cliffs', DATE '1993-03-03', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (12, '6149997921', 'Odell', 'Emard', 'miles_schimmel@oconnell.name', '7724 Wolf Wall', DATE '1981-10-14', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (13, '6188134347', 'Vickie', 'Jacobs', 'rachelle@altenwerth-wiza.io', '149 Felipe Path', DATE '1990-05-15', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (14, '4758774357', 'Fredrick', 'Dickinson', 'abraham@upton-yundt.org', '483 Cecille Forest', DATE '1996-08-07', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (15, '6467536413', 'Latonya', 'West', 'nelly_kessler@hansen.net', '402 Stamm Summit', DATE '1993-10-20', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (16, '8821791931', 'Frederic', 'Schiller', 'rey.schmeler@ferry.net', '235 Billy Stream', DATE '1988-04-14', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (17, '5692767699', 'Al', 'Littel', 'jill.abbott@tromp.net', '6753 Eddy Orchard', DATE '1995-03-06', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (18, '3592536239', 'Miriam', 'Schaefer', 'van@jenkins.org', '9355 Bahringer Parks', DATE '1985-04-06', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (19, '1255392462', 'Davis', 'Vandervort', 'caprice@jones.biz', '5623 Leffler Hill', DATE '1996-08-22', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (20, '6187478843', 'Rosemarie', 'Nolan', 'laquanda_robel@wuckert.biz', '8941 Sebastian Stravenue', DATE '1996-03-22', 1, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (21, '1911357112', 'Annette', 'Hilpert', 'raleigh.funk@schowalter.biz', '175 Karey Plain', DATE '1997-11-22', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (22, '3784199121', 'Caitlin', 'Walter', 'carlita.trantow@lakin-dooley.co', '1915 Karl Valleys', DATE '1975-06-08', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (23, '8961293617', 'Sabina', 'Quigley', 'nada.kling@stark.biz', '5256 Bibi Stravenue', DATE '2000-05-30', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (24, '2181233321', 'Olinda', 'Volkman', 'hwa.quitzon@kihn.org', '27598 Horacio Parkways', DATE '1970-06-02', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (25, '5461911361', 'Tommy', 'Cartwright', 'cleveland.spinka@rogahn.name', '685 Wiza Islands', DATE '1971-04-26', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (26, '2717747778', 'Corliss', 'Bradtke', 'joesph_ankunding@kshlerin.net', '570 Tony Extensions', DATE '1970-11-28', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (27, '7714294819', 'Toni', 'McLaughlin', 'ferdinand.dooley@thompson-hartmann.info', '243 Bins Mission', DATE '1987-10-02', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (28, '9434882489', 'Marcus', 'Mayer', 'theda@stokes-brown.net', '94870 Hansen Route', DATE '1986-06-04', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (29, '1386428582', 'Gisela', 'Runolfsdottir', 'stan_roob@heathcote.org', '163 Bertram Underpass', DATE '1972-01-09', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (30, '2912639382', 'Nathalie', 'MacGyver', 'bertram@mohr.io', '788 Jade Harbors', DATE '2000-06-11', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (31, '5356235898', 'Darrick', 'Reichel', 'sara@hermann-prosacco.info', '672 Baumbach Lights', DATE '1999-01-02', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (32, '2948954879', 'Malcom', 'Koelpin', 'lina@thompson.co', '230 Marguerite Tunnel', DATE '1973-09-19', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (33, '2722195448', 'Cecil', 'Goyette', 'clemente.lind@kuphal.info', '844 Aubrey Meadows', DATE '1975-04-26', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (34, '4147249538', 'Sharita', 'Prosacco', 'branden@swift.biz', '385 Effie Cliffs', DATE '1998-11-15', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (35, '3723423281', 'Dolly', 'Cremin', 'qiana@jones.com', '28001 Wiza Crest', DATE '1972-10-10', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (36, '5923586395', 'Marisha', 'Ullrich', 'lupita@rempel-goyette.org', '15071 Schmidt Roads', DATE '1983-03-15', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (37, '8283779565', 'Rosendo', 'Schowalter', 'gerardo.greenholt@white-sporer.org', '5711 Leta Village', DATE '1977-08-11', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (38, '5644353998', 'Remedios', 'Simonis', 'shan_hessel@emmerich.com', '799 Alphonse Square', DATE '1990-08-01', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (39, '3218961881', 'Cole', 'Wisozk', 'lenora@fisher-armstrong.net', '70035 Ilona Shores', DATE '1983-08-22', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (40, '5697169455', 'Chery', 'Kuphal', 'walter@becker.biz', '9434 Cynthia Isle', DATE '1985-10-26', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (41, '7423376322', 'Dion', 'Senger', 'bryan.reilly@kozey-swift.io', '695 Barrows Cliffs', DATE '1992-12-04', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (42, '8186761332', 'Kum', 'Ryan', 'maria@padberg.name', '10432 Spinka Spurs', DATE '2000-11-16', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (43, '2536816236', 'Darci', 'Streich', 'amos_okuneva@kutch.com', '570 Lebsack Lodge', DATE '1992-07-27', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (44, '7969581495', 'Sol', 'Medhurst', 'elfreda.mertz@parisian.org', '71297 Miyoko Tunnel', DATE '1977-06-23', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (45, '5921834371', 'Theo', 'Bashirian', 'solomon@bechtelar-kshlerin.name', '296 Stephen Shoal', DATE '1974-06-15', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (46, '7716491756', 'Esta', 'Breitenberg', 'rickie.quitzon@wolff.net', '69366 Considine Track', DATE '1970-01-10', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (47, '7276565529', 'Yong', 'Emmerich', 'brenton@pagac-towne.name', '5888 Will Falls', DATE '1985-12-01', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (48, '6112382614', 'Seymour', 'Smith', 'esteban@spinka-oconnell.net', '6206 Letha Valley', DATE '1975-08-16', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (49, '3634254216', 'Alfonso', 'Reilly', 'edelmira_hessel@ward.net', '43907 Kuphal Forks', DATE '1995-03-23', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (50, '2271995567', 'Ellyn', 'Turcotte', 'tammi_mclaughlin@treutel-willms.co', '632 Adelaida Pike', DATE '1977-04-27', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (51, '4373151975', 'Devon', 'Casper', 'glenn.bernier@koepp.io', '91450 Necole Course', DATE '2000-05-02', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (52, '9914284499', 'Lisette', 'OConnell', 'nanette@emard.name', '826 Andrea Junction', DATE '1980-05-31', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (53, '6144194346', 'Blake', 'McCullough', 'stephnie@pouros.com', '6411 Carrol Shoal', DATE '1993-11-02', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (54, '8624551544', 'Rigoberto', 'Rath', 'gudrun@hamill-prosacco.net', '7422 Predovic Forge', DATE '1985-01-25', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (55, '8788344895', 'Clair', 'Tremblay', 'erna.prohaska@emard.biz', '6853 Anitra Burg', DATE '1970-01-17', 1, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (56, '2867514134', 'Jaclyn', 'Hills', 'jayne.walsh@quigley.biz', '5773 Jasper Pine', DATE '1984-02-13', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (57, '5791161789', 'Jamey', 'Wintheiser', 'barney@klocko.info', '9023 Hyon Garden', DATE '1978-05-17', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (58, '3112896531', 'Kamilah', 'Jast', 'margarito@dubuque.io', '478 Kristi Squares', DATE '1977-11-30', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (59, '5666847718', 'Deadra', 'Schmeler', 'waldo@damore-renner.org', '79527 Swift Estate', DATE '1981-04-19', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (60, '2887422647', 'Hugh', 'Greenholt', 'thalia@ruecker.org', '59113 Tory Wells', DATE '1981-11-09', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (61, '7485588959', 'Carlee', 'Cummerata', 'marquita.williamson@lemke.co', '774 Frank Plains', DATE '1990-03-25', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (62, '6517154134', 'Will', 'Langosh', 'kenda@dubuque-gutmann.net', '277 Gaynelle Isle', DATE '1985-08-20', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (63, '7957193534', 'Honey', 'Cole', 'lonny@kilback.org', '749 Boehm Street', DATE '1982-03-28', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (64, '3554644226', 'Lawrence', 'Anderson', 'alecia.block@kemmer.net', '7280 Allyn Way', DATE '1980-03-03', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (65, '6172451679', 'Laine', 'Bergnaum', 'jacquie@sipes.name', '966 Schinner Rue', DATE '1996-12-04', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (66, '2931553694', 'Anton', 'Goodwin', 'randell@kuhlman-wiza.org', '93654 Nettie Cliffs', DATE '1974-07-05', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (67, '1867656976', 'Elke', 'Braun', 'heath.gorczany@ferry.name', '497 Dane Circles', DATE '1983-03-26', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (68, '9254435812', 'Twana', 'Reynolds', 'andre@stiedemann-botsford.com', '756 Charlie Crescent', DATE '1988-07-14', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (69, '2342412513', 'Jenice', 'Turcotte', 'caterina_hamill@bauch.com', '1707 Brett Track', DATE '1995-11-17', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (70, '2458763238', 'Lore', 'Frami', 'casimira.swift@funk.info', '53793 Trenton Highway', DATE '1994-07-17', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (71, '1792381441', 'Charmaine', 'Kuhlman', 'latricia@macejkovic-emard.io', '7159 Guy Fork', DATE '1973-06-19', 1, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (72, '6149755656', 'Humberto', 'Orn', 'mose@shields.info', '37836 Johnson Divide', DATE '1972-06-17', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (73, '4188318262', 'Emeline', 'Smitham', 'marcy@wehner.info', '846 Kovacek Mountain', DATE '1997-05-12', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (74, '3438695287', 'Haywood', 'Braun', 'hiroko.kirlin@sawayn-legros.name', '87245 Phylicia Parks', DATE '1992-01-11', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (75, '6698362598', 'Luana', 'Bradtke', 'merlin@armstrong-huels.io', '52302 Marcia Island', DATE '1981-11-17', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (76, '4113116547', 'Leandro', 'Gibson', 'cruz@sawayn.org', '25863 Grady Junctions', DATE '1997-06-16', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (77, '1896754349', 'Leandra', 'Kunde', 'valarie@konopelski.com', '62586 Johnson Mall', DATE '1986-10-13', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (78, '1332145445', 'Frederic', 'Upton', 'susann.schumm@rowe.net', '9759 Deonna Square', DATE '1996-01-18', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (79, '2841176913', 'Brain', 'Mante', 'chauncey@donnelly-marquardt.biz', '95173 Kuhn Run', DATE '1999-01-14', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (80, '5972195768', 'Josephine', 'Toy', 'song@goodwin.net', '2861 Bibi Ranch', DATE '1974-11-19', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (81, '5717425327', 'Harland', 'Harris', 'leopoldo.bahringer@rogahn.info', '70480 Goyette Prairie', DATE '1976-02-19', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (82, '8294278836', 'Hildred', 'Herman', 'jarod_rice@ziemann.co', '96369 Lubowitz Harbor', DATE '1976-05-11', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (83, '3712859425', 'Jim', 'Thiel', 'diedra@hayes-bailey.co', '37367 Cleveland Springs', DATE '2000-01-02', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (84, '4415221485', 'Starla', 'Fadel', 'fritz@farrell-block.org', '20093 Bradford Loop', DATE '1983-09-14', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (85, '3126793227', 'Evalyn', 'Dare', 'mohammed@leffler.io', '84434 Maxwell Greens', DATE '1974-05-28', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (86, '4418532996', 'Gerry', 'Will', 'damon@cole.com', '334 Bauch Inlet', DATE '1970-01-25', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (87, '3174994852', 'Clement', 'Von', 'cheryle.quitzon@stark.co', '84502 Wunsch Island', DATE '1977-08-20', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (88, '4828349532', 'Chung', 'Herman', 'travis_robel@swift-boehm.org', '481 Walker Ramp', DATE '1998-07-24', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (89, '2681855449', 'Zane', 'Koss', 'lamont@murray-upton.org', '8294 Rice Lights', DATE '1978-12-21', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (90, '8264574794', 'Nannette', 'Lemke', 'wes@schuster.biz', '278 Hegmann Rue', DATE '1979-01-11', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (91, '8936349738', 'Tonya', 'Leuschke', 'khadijah@powlowski.co', '177 Deloris Forest', DATE '1995-12-25', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (92, '6661884611', 'Ryan', 'Smitham', 'elton.zieme@jaskolski.com', '925 Louis Hollow', DATE '1990-07-26', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (93, '3923935815', 'Michale', 'Stamm', 'aundrea@frami-kuhic.name', '7505 Boyle Valleys', DATE '1989-11-01', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (94, '5143179792', 'Rena', 'Schamberger', 'vincent_anderson@nikolaus.io', '7855 Bins Haven', DATE '1981-11-05', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (95, '2358147414', 'Lynwood', 'Stanton', 'rubi@boyer.org', '4924 Schowalter Mall', DATE '1979-01-31', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (96, '3865598785', 'Tequila', 'Hoeger', 'raymundo.dubuque@wyman.com', '114 Legros Pines', DATE '1988-10-05', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (97, '9237666134', 'Evie', 'Grant', 'tracey@wisozk-monahan.co', '54257 Macejkovic Course', DATE '1971-09-29', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (98, '1396551953', 'Blair', 'Pacocha', 'jone@nader.info', '450 Gutkowski Brook', DATE '1989-03-17', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (99, '7371386451', 'Ferne', 'Muller', 'oleta@hammes-bosco.biz', '55195 Jordon Highway', DATE '1991-01-08', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (100, '8581479856', 'Freddie', 'Monahan', 'cristopher@windler-mosciski.name', '442 Marquardt Rapid', DATE '1974-10-13', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (101, '3449987351', 'Freeman', 'Lakin', 'timothy@beahan.biz', '113 Frank Land', DATE '1989-12-05', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (102, '4734721994', 'Eleni', 'Pagac', 'lala@marvin.info', '616 David Turnpike', DATE '1991-02-08', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (103, '3974567655', 'Shiela', 'Wilderman', 'lawrence.mertz@ryan.name', '951 Feest Bypass', DATE '1991-12-28', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (104, '7159863599', 'Larraine', 'Corwin', 'celestina@bernhard-mckenzie.info', '45979 Rocco Key', DATE '1994-09-23', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (105, '1995429634', 'Dino', 'Bartoletti', 'tegan_hintz@mraz-hoeger.name', '7327 Kiehn Common', DATE '1971-04-19', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (106, '3685697582', 'Odessa', 'Crist', 'arletta@murphy.com', '16916 Shields Fields', DATE '1993-10-16', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (107, '6477848752', 'Jewell', 'Kuphal', 'mellissa@trantow-barrows.name', '50640 Bahringer Rest', DATE '1991-09-10', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (108, '7651648814', 'Agustin', 'Runolfsson', 'garry@graham.name', '75567 Rickey Port', DATE '1970-04-11', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (109, '3328497272', 'Kiera', 'Lind', 'agustina.kutch@rutherford.co', '68893 Imelda Common', DATE '1984-02-14', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (110, '6462919763', 'Reuben', 'Bode', 'donovan@stanton.net', '253 Pa Trail', DATE '1974-10-22', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (111, '6668421219', 'Cornelius', 'Lehner', 'catrice@swaniawski-schaden.co', '9995 Abernathy Extension', DATE '1992-12-06', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (112, '4666666686', 'Evelin', 'Walter', 'cristin.jacobson@mueller.org', '47321 Emard Track', DATE '1987-07-08', 1, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (113, '8788443884', 'Terra', 'Strosin', 'thea.hoeger@cummerata.org', '4500 Timmy Stravenue', DATE '1995-10-11', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (114, '8899173893', 'Foster', 'Smith', 'aletha_armstrong@sipes.io', '127 Jin Forest', DATE '1985-04-01', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (115, '4437341141', 'Kasha', 'Glover', 'domingo@pollich.info', '817 Murazik Ridges', DATE '1972-02-27', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (116, '7785651212', 'Isiah', 'Kilback', 'dorla_klein@pfeffer-nicolas.org', '2575 Halina Drive', DATE '1984-11-06', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (117, '8841666384', 'Apryl', 'Farrell', 'norene@dibbert.info', '91943 Glenna Row', DATE '1979-10-19', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (118, '2177717594', 'Zelma', 'Braun', 'otto@bahringer.io', '640 Hahn Lake', DATE '1971-05-05', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (119, '1615531323', 'Trent', 'Marvin', 'vincenzo@reinger-johnson.name', '842 Leannon Canyon', DATE '1978-04-05', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (120, '7462518331', 'Bianca', 'Ritchie', 'chere@monahan.net', '72887 Fritsch Oval', DATE '1981-07-05', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (121, '9475581218', 'Linda', 'Wolf', 'dane@kuhn.info', '854 Jamal Circles', DATE '1981-07-09', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (122, '2212885191', 'Ross', 'Turcotte', 'travis_feest@reilly-skiles.co', '290 Jim Extension', DATE '1980-06-03', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (123, '7358462731', 'Madaline', 'Deckow', 'tomoko@gleichner-lesch.co', '6374 Freddy Coves', DATE '1991-12-04', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (124, '3113125999', 'Josue', 'Kshlerin', 'derrick@herman.biz', '5893 Hessel Key', DATE '1985-08-14', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (125, '3523385388', 'May', 'Wunsch', 'janita_schamberger@kub.io', '1625 Lemke Village', DATE '1997-07-29', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (126, '1881951551', 'Kurtis', 'Hamill', 'gustavo.pagac@willms-goldner.name', '3919 Kohler Park', DATE '1998-12-31', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (127, '4156459668', 'Cameron', 'Bergstrom', 'henry@rodriguez-johnston.io', '722 Albert Coves', DATE '1999-11-26', 1, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (128, '6485965632', 'Jackelyn', 'Homenick', 'clint@cormier.info', '9442 Felipe Mountains', DATE '1998-12-13', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (129, '5973538251', 'Merry', 'Muller', 'arnulfo.hagenes@muller.net', '3547 Felice Heights', DATE '1987-12-25', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (130, '3163812686', 'Reynaldo', 'Graham', 'margherita_bartoletti@reinger-beier.io', '96029 King Court', DATE '1996-04-24', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (131, '9418152832', 'Fatima', 'Parisian', 'florinda_grimes@batz.com', '12042 Elton Terrace', DATE '1988-04-16', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (132, '3219765928', 'Concetta', 'Lindgren', 'jefferey.larkin@gutmann.com', '6805 Yundt Common', DATE '1989-04-22', 4, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (133, '6966396679', 'Jacinto', 'Vandervort', 'maynard@mraz.co', '657 Latia Squares', DATE '1990-05-11', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (134, '8971337466', 'Franklin', 'Jones', 'eda.hauck@wiegand-beahan.net', '997 Darron Courts', DATE '1997-07-05', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (135, '2999722841', 'Rupert', 'Schmeler', 'laure@steuber.info', '2202 Frances Ranch', DATE '1989-04-28', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (136, '7938953855', 'Buck', 'Labadie', 'fredrick_hartmann@hettinger.io', '4876 Ernser Center', DATE '1978-02-05', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (137, '4766396141', 'Vance', 'Schmitt', 'daniel.gleason@borer.org', '3410 Grant Ramp', DATE '1999-06-13', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (138, '4332629881', 'Stephen', 'Corkery', 'kasey_torphy@kunde-jones.info', '8388 Donnelly Vista', DATE '1995-02-20', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (139, '1741319781', 'Trish', 'Altenwerth', 'reynaldo.turcotte@dooley.name', '141 Rosalba Way', DATE '1996-10-05', 1, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (140, '4411915519', 'Annita', 'Upton', 'eddie_koelpin@armstrong-schmitt.info', '466 Orville Ports', DATE '1999-12-23', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (141, '7244619134', 'Denae', 'Doyle', 'dalton.fritsch@smith-collins.co', '500 Bernhard Rue', DATE '1997-01-21', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (142, '1977912243', 'Jesus', 'Carroll', 'carmen@larson-fisher.net', '74044 Larkin Cliff', DATE '1983-01-20', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (143, '2165524519', 'Ferdinand', 'Hills', 'maurine_ferry@monahan-langosh.io', '20395 Corwin Light', DATE '1971-03-29', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (144, '9969431814', 'Melvin', 'Will', 'eloy@kautzer.org', '304 Cassin Skyway', DATE '1998-08-16', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (145, '3581967989', 'Kelsi', 'Marquardt', 'charles@johnston.org', '76716 Ronnie Squares', DATE '1981-06-11', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (146, '9461136147', 'Noble', 'Marquardt', 'nakia_russel@hills-parker.co', '569 Dorian Mission', DATE '1984-02-15', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (147, '7687763776', 'Boyd', 'Conn', 'britt_brown@walsh.net', '8202 Spinka Valleys', DATE '1995-04-17', 1, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (148, '4145129373', 'Noe', 'Smith', 'shamika_breitenberg@altenwerth.io', '63178 Maisie Harbor', DATE '2000-11-03', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (149, '2911665557', 'Lowell', 'Halvorson', 'rayna.harvey@carroll-maggio.net', '5691 Geneva Light', DATE '1989-10-07', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (150, '7945845989', 'Jeffrey', 'Beier', 'clement@walker.info', '927 Lesia Turnpike', DATE '1978-08-04', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (151, '1223634646', 'Jenice', 'Hackett', 'eulalia_howell@zulauf.io', '81434 Cronin Spring', DATE '1992-04-17', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (152, '1598768625', 'Heidi', 'Moen', 'garfield@braun-west.com', '629 Fisher Extensions', DATE '1983-12-25', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (153, '7526324749', 'Bobby', 'Walker', 'hortensia@ledner.org', '97087 Londa Center', DATE '1980-02-21', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (154, '9159696723', 'Desmond', 'Torp', 'harris@rohan.info', '84278 Stephania Glens', DATE '1971-03-25', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (155, '9317521341', 'Son', 'Graham', 'jarrod@heller.org', '97454 Elmer Throughway', DATE '1971-05-24', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (156, '7532148421', 'Corene', 'Toy', 'bret_quitzon@pagac.org', '169 Grant Passage', DATE '1996-08-27', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (157, '7143611617', 'Belia', 'Kub', 'bibi.king@hermiston.name', '8385 Yael Courts', DATE '1975-05-27', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (158, '1269641727', 'Alfred', 'Quigley', 'denna@bruen-cronin.info', '309 OReilly Corner', DATE '1984-04-20', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (159, '8116911289', 'Wallace', 'McCullough', 'marcellus@barton.io', '7726 Adena Isle', DATE '1979-09-21', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (160, '4525756481', 'Bruce', 'Franecki', 'brittaney.berge@rutherford-feil.org', '48219 Wehner Run', DATE '1994-03-27', 5, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (161, '5142372313', 'Valentine', 'Morar', 'myron_kuhn@jerde-bogan.co', '74189 Beer Burgs', DATE '1993-08-11', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (162, '6796311181', 'Sharleen', 'Satterfield', 'takako@jacobi.com', '2976 Georgiana Tunnel', DATE '1981-05-07', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (163, '2952644488', 'Winston', 'Morissette', 'teressa.kuphal@schroeder.io', '272 Loren Estates', DATE '1972-10-13', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (164, '5689642675', 'Rudy', 'Herzog', 'heath.ullrich@dooley.biz', '43867 Koch Path', DATE '1976-04-17', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (165, '6748493876', 'Linette', 'Haag', 'wayne@vandervort-kihn.info', '7662 Mark Turnpike', DATE '1986-09-17', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (166, '9648914768', 'Huey', 'Weissnat', 'josef@willms-lesch.biz', '6527 Tim Springs', DATE '1987-02-12', 4, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (167, '7481994877', 'Clarissa', 'Lowe', 'antonia@ferry.io', '8669 Ernser Village', DATE '1989-05-11', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (168, '2729365289', 'Terry', 'Trantow', 'wilbur@kulas.io', '71250 Hoyt Harbors', DATE '1993-08-11', 4, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (169, '4813614223', 'Blake', 'Nicolas', 'micki@sporer-cassin.io', '2396 Jacob Track', DATE '1988-06-01', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (170, '5134489881', 'Ma', 'Casper', 'felton@kub-koepp.io', '812 Selma Squares', DATE '1992-10-09', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (171, '9228415692', 'Cindi', 'Kiehn', 'keshia_fay@wolf-zboncak.biz', '1816 Lona View', DATE '1986-01-28', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (172, '3411553978', 'Aaron', 'Davis', 'patty.renner@schmidt.net', '3112 Domenic Roads', DATE '1984-06-28', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (173, '7175611123', 'Conchita', 'Erdman', 'boyd_lakin@funk-deckow.com', '4047 Alton Plaza', DATE '1977-06-04', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (174, '6922975597', 'Jarred', 'Stracke', 'isabell.waelchi@fadel.net', '505 Schmeler Union', DATE '1988-08-23', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (175, '2653537837', 'Angelina', 'Rodriguez', 'jeffry.conroy@walker.name', '354 Brown Forges', DATE '1993-09-20', 1, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (176, '4581955386', 'Philomena', 'Ritchie', 'loris_christiansen@kovacek.com', '5112 Balistreri Stravenue', DATE '1989-10-10', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (177, '6926561727', 'Jarrett', 'Dach', 'fatima@brakus.com', '1397 Kris Unions', DATE '1977-09-23', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (178, '9394131215', 'Palmer', 'Schulist', 'verline@renner.name', '351 Mitzi Parkway', DATE '1990-07-09', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (179, '4713639223', 'Louie', 'Macejkovic', 'sol@hand-anderson.biz', '20856 Vandervort Station', DATE '1997-02-13', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (180, '9814521396', 'Nadine', 'Boehm', 'verlene@franecki.info', '6894 Jacqualine Run', DATE '1990-11-11', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (181, '3375569155', 'Carter', 'Nienow', 'lezlie@mann.biz', '9808 Brendon Plaza', DATE '1990-08-29', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (182, '2441268221', 'Lavonna', 'Roob', 'elena_bogan@boehm-stokes.com', '86167 Mario Walks', DATE '1972-03-19', 3, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (183, '7284821152', 'Queenie', 'Morar', 'dee@lehner.biz', '762 Crist Rapids', DATE '2000-02-17', 3, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (184, '1292985282', 'Greg', 'Frami', 'carmine_bogisich@gutkowski.net', '300 Rubin Canyon', DATE '1989-03-15', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (185, '9967341931', 'Phebe', 'Stroman', 'wendell_terry@senger-corkery.co', '37485 Andree Trace', DATE '1993-04-04', 4, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (186, '9841694591', 'Cristobal', 'Hane', 'lloyd.heller@roob-mosciski.org', '654 Stiedemann Plaza', DATE '1973-08-08', 2, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (187, '8957917334', 'Cyndi', 'Metz', 'antoine@zboncak-barrows.name', '43308 Keebler Manors', DATE '1983-08-20', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (188, '5177373311', 'Rosanne', 'Zieme', 'lillia@goldner.io', '760 Damien Hill', DATE '1995-10-09', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (189, '4953124745', 'Elbert', 'Marks', 'loralee@kiehn.com', '7266 Funk Burgs', DATE '1978-06-26', 3, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (190, '9482999467', 'Iluminada', 'Buckridge', 'francesco@cronin.org', '12679 Gulgowski Brook', DATE '1992-10-04', 2, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (191, '1731621883', 'Mark', 'Herzog', 'malissa@oreilly-stokes.biz', '44949 Sha Square', DATE '1997-05-18', 1, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (192, '3979422626', 'Domingo', 'Schaefer', 'nelson@heller.net', '35056 Telma Meadows', DATE '1998-08-09', 3, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (193, '3168653155', 'Harris', 'Conroy', 'aron.brown@blanda.net', '76040 Preston Well', DATE '1976-10-04', 2, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (194, '7238542565', 'Austin', 'Koelpin', 'cindy_funk@nienow-schmitt.biz', '761 Hermann Row', DATE '1985-01-28', 5, 2);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (195, '1515139576', 'Ann', 'Purdy', 'chauncey.bayer@hagenes.name', '959 Xavier Key', DATE '1983-10-23', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (196, '5183565271', 'Jeremiah', 'Morissette', 'bong_howe@runolfsdottir-wiegand.org', '96879 Johnny Inlet', DATE '1987-09-12', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (197, '5985563622', 'Riva', 'Fisher', 'britt_hamill@bergnaum-jaskolski.info', '2373 Pedro Flat', DATE '1996-06-12', 5, 4);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (198, '6463617837', 'Margurite', 'Roob', 'nevada@johnston.biz', '84969 Carrie Lakes', DATE '1984-08-18', 5, 1);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (199, '5933749423', 'Leanne', 'Kunde', 'lacy@howell.biz', '68385 Schneider Flats', DATE '2000-12-19', 2, 3);

INSERT INTO studenti (id, jmbag, ime, prezime, email, adresa, datum_rodenja, smjer_id, status_id)
VALUES (200, '1934939547', 'Thaddeus', 'Roberts', 'thomas_lang@walter-kunze.net', '7947 Rodriguez Gardens', DATE '1990-01-30', 5, 3);

INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (1, '68255351144', 'Luvenia', 'Labadie', 'collin.romaguera@brekke-davis.biz', '5873 Silas Dam', '1962', 'HR9166298097476189165', DATE '2010-04-24', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (2, '95177448272', 'Kris', 'Braun', 'josh@schaden.io', '494 Glover Ville', '1968', 'HR6354103486349354480', DATE '2015-08-15', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (3, '49474584338', 'Kizzie', 'Zboncak', 'abel_frami@gutkowski.biz', '92544 Kuhlman Groves', '1983', 'HR6769567105737420602', DATE '2009-03-13', 3);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (4, '69116674651', 'Arden', 'Huel', 'zane@lowe.co', '1375 Toy Spring', '1996', 'HR5733873345768926658', DATE '2000-02-08', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (5, '19237529866', 'Shawnda', 'OKon', 'reggie@watsica.net', '404 Richard Trafficway', '1989', 'HR6178202057860399812', DATE '2014-03-01', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (6, '58639797178', 'Tammera', 'OReilly', 'elisha_windler@labadie-koch.io', '5060 Rogelio Skyway', '1997', 'HR7972604288587460655', DATE '2007-05-10', 3);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (7, '45191463172', 'Ali', 'Bailey', 'camie_schuster@denesik.co', '2485 Witting Drive', '1961', 'HR6516238637101946546', DATE '2000-04-28', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (8, '34442488251', 'Genevive', 'Bailey', 'shane.mclaughlin@torphy-veum.name', '8183 Smith Knoll', '1962', 'HR2749631968227493854', DATE '2015-08-18', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (9, '86343583735', 'Tod', 'Olson', 'annamarie_kihn@kautzer.name', '3929 Dustin Crest', '1987', 'HR5305190487486874231', DATE '2003-11-08', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (10, '57448662669', 'Jan', 'Fritsch', 'lanette@padberg.net', '1719 Kelsey Islands', '1993', 'HR1508032769988208086', DATE '2003-10-21', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (11, '91428736459', 'Hyon', 'Durgan', 'jolanda@bergnaum.name', '985 Rempel Pines', '1999', 'HR3056351960816240721', DATE '2018-03-08', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (12, '48212884153', 'Lesia', 'Koch', 'ingeborg@luettgen.biz', '8514 Herzog Path', '1992', 'HR8768424269805067139', DATE '2007-04-07', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (13, '91334855761', 'Johnie', 'Kassulke', 'lester.kunze@koch.info', '149 Brekke Knoll', '1972', 'HR7453706576073885737', DATE '2005-05-31', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (14, '77128947325', 'Cary', 'Beer', 'shirly_stoltenberg@klocko.co', '160 Kirk Center', '1987', 'HR3785432871828169848', DATE '2013-12-29', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (15, '56238937197', 'Carlita', 'Olson', 'jackqueline@parker.biz', '7199 Dietrich Islands', '1991', 'HR3145376516094584841', DATE '2005-03-26', 2);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (16, '98554523471', 'Hsiu', 'Dare', 'sterling.boyer@cummings.biz', '7015 Joan Bypass', '1964', 'HR3924447770011460461', DATE '2001-03-18', 3);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (17, '79953752355', 'Karena', 'Durgan', 'robbyn_paucek@grimes-kilback.biz', '986 Donita Greens', '1960', 'HR7397885051379771408', DATE '2015-07-18', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (18, '14532747874', 'Esther', 'Sanford', 'orlando.wolf@corkery.net', '22344 Weber Branch', '1998', 'HR5132859813265765518', DATE '2004-05-09', 3);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (19, '89451568654', 'Kristina', 'Ferry', 'corey@pfannerstill.co', '8345 Ike Plaza', '1962', 'HR0547088886745662485', DATE '2016-08-22', 1);


INSERT INTO profesori (id, oib, ime, prezime, email, adresa, godina_rodenja, iban, datum_zaposlenja, vrsta_zaposlenja_id)
VALUES (20, '64689246586', 'Roderick', 'Cummerata', 'allan.paucek@balistreri-gorczany.co', '389 Leo Parks', '1962', 'HR1438518806004726908', DATE '2018-01-07', 2);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (18, 11, 1, 2017);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (16, 6, 2, 2018);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (11, 7, 2, 2015);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (6, 9, 1, 2016);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (12, 15, 1, 2020);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (19, 4, 2, 2012);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (8, 9, 2, 2013);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (4, 5, 2, 2012);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (5, 10, 1, 2012);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (8, 3, 1, 2016);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (14, 8, 1, 2019);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (9, 15, 2, 2016);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (14, 2, 1, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (9, 13, 1, 2010);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (20, 14, 2, 2020);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (13, 9, 2, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (12, 15, 1, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (18, 11, 1, 2012);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (4, 1, 1, 2017);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (10, 6, 1, 2013);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (17, 1, 2, 2012);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (15, 5, 1, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (5, 14, 1, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (5, 3, 2, 2016);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (1, 12, 2, 2010);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (16, 11, 2, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (5, 14, 2, 2017);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (15, 5, 2, 2021);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (18, 2, 2, 2010);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (6, 11, 2, 2020);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (16, 1, 2, 2011);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (6, 11, 2, 2020);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (9, 10, 2, 2011);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (14, 9, 2, 2011);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (14, 1, 2, 2016);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (13, 5, 2, 2016);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (1, 11, 2, 2018);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (3, 1, 1, 2014);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (7, 2, 1, 2013);


INSERT INTO predaje (profesor_id, predmet_id, uloga_id, predaje_od)
VALUES (17, 3, 1, 2014);

INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 113, DATE '2012-07-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 50, DATE '2009-08-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 147, DATE '2016-06-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 198, DATE '2009-11-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 95, DATE '2013-02-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 13, DATE '2010-11-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 114, DATE '2013-05-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 92, DATE '2013-09-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 116, DATE '2013-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 22, DATE '2010-04-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 85, DATE '2016-07-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 42, DATE '2009-11-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 125, DATE '2018-09-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 198, DATE '2018-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 74, DATE '2020-08-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 200, DATE '2020-03-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 95, DATE '2015-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 110, DATE '2019-09-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 31, DATE '2013-10-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 127, DATE '2017-11-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 178, DATE '2019-04-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 64, DATE '2012-12-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 155, DATE '2013-01-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 45, DATE '2008-09-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 150, DATE '2013-06-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 143, DATE '2014-01-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 161, DATE '2010-10-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 84, DATE '2010-11-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 58, DATE '2016-05-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 130, DATE '2012-07-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 172, DATE '2012-09-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 183, DATE '2016-02-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 70, DATE '2009-06-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 60, DATE '2015-02-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 73, DATE '2012-07-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 197, DATE '2019-05-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 116, DATE '2010-10-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 153, DATE '2013-09-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 126, DATE '2017-07-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 102, DATE '2009-01-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 184, DATE '2014-11-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 3, DATE '2012-04-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 51, DATE '2011-11-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 73, DATE '2015-08-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 120, DATE '2011-10-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 149, DATE '2014-06-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 122, DATE '2010-04-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 152, DATE '2013-06-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 170, DATE '2013-04-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 29, DATE '2013-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 49, DATE '2012-09-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 2, DATE '2014-03-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 14, DATE '2013-06-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 105, DATE '2008-11-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 193, DATE '2010-12-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 10, DATE '2008-12-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 37, DATE '2012-12-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 116, DATE '2020-05-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 141, DATE '2018-10-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 84, DATE '2014-09-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 172, DATE '2011-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 44, DATE '2012-02-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 171, DATE '2010-03-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 46, DATE '2013-07-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 30, DATE '2013-09-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 27, DATE '2009-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 16, DATE '2019-10-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 179, DATE '2015-09-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 134, DATE '2014-10-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 3, DATE '2020-02-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 13, DATE '2015-11-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 4, DATE '2011-05-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 178, DATE '2017-09-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 23, DATE '2008-08-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 68, DATE '2012-06-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 135, DATE '2019-05-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 21, DATE '2018-09-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 2, DATE '2008-07-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 44, DATE '2020-03-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 150, DATE '2012-05-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 96, DATE '2016-12-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 129, DATE '2020-01-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 111, DATE '2015-07-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 12, DATE '2012-06-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 77, DATE '2019-06-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 110, DATE '2014-06-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 24, DATE '2010-03-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 2, DATE '2017-08-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 92, DATE '2012-01-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 173, DATE '2014-03-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 193, DATE '2013-08-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 144, DATE '2010-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 114, DATE '2012-03-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 150, DATE '2018-06-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 124, DATE '2013-07-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 9, DATE '2015-01-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 157, DATE '2011-04-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 119, DATE '2009-12-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 88, DATE '2011-10-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 169, DATE '2008-08-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 189, DATE '2017-11-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 112, DATE '2013-01-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 122, DATE '2015-02-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 22, DATE '2018-01-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 118, DATE '2020-11-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 56, DATE '2012-07-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 44, DATE '2013-06-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 72, DATE '2009-09-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 194, DATE '2010-01-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 68, DATE '2011-01-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 95, DATE '2016-11-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 13, DATE '2020-01-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 52, DATE '2012-02-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 185, DATE '2011-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 80, DATE '2017-07-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 199, DATE '2014-07-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 185, DATE '2009-09-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 160, DATE '2013-08-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 191, DATE '2014-06-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 18, DATE '2020-02-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 51, DATE '2010-04-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 113, DATE '2008-01-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 43, DATE '2013-02-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 62, DATE '2018-06-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 188, DATE '2012-04-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 182, DATE '2019-07-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 94, DATE '2009-09-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 138, DATE '2020-07-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 61, DATE '2010-04-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 175, DATE '2019-01-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 53, DATE '2019-01-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 157, DATE '2008-02-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 176, DATE '2012-01-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 96, DATE '2017-03-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 156, DATE '2015-10-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 184, DATE '2017-09-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 31, DATE '2009-04-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 27, DATE '2016-05-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 149, DATE '2020-07-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 107, DATE '2009-11-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 17, DATE '2008-05-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 1, DATE '2012-05-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 9, DATE '2015-03-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 154, DATE '2020-10-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 101, DATE '2017-11-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 141, DATE '2016-11-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 10, DATE '2012-12-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 75, DATE '2009-05-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 15, DATE '2012-11-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 115, DATE '2011-07-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 49, DATE '2018-06-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 145, DATE '2016-07-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 155, DATE '2014-10-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 59, DATE '2012-05-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 126, DATE '2014-12-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 70, DATE '2019-10-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 137, DATE '2013-12-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 184, DATE '2020-06-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 95, DATE '2015-07-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 52, DATE '2011-05-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 197, DATE '2013-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 124, DATE '2015-07-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 191, DATE '2017-07-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 60, DATE '2017-05-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 94, DATE '2008-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 82, DATE '2011-10-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 103, DATE '2015-09-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 60, DATE '2010-11-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 67, DATE '2018-03-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 174, DATE '2018-08-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 119, DATE '2019-04-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 35, DATE '2018-02-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 101, DATE '2017-09-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 198, DATE '2017-03-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 34, DATE '2020-10-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 25, DATE '2018-05-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 134, DATE '2008-07-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 82, DATE '2019-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 67, DATE '2013-11-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 154, DATE '2019-02-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 112, DATE '2013-03-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 150, DATE '2015-04-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 47, DATE '2018-02-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 128, DATE '2015-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 7, DATE '2010-06-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 87, DATE '2020-01-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 75, DATE '2016-04-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 93, DATE '2009-04-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 28, DATE '2015-07-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 74, DATE '2011-03-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 83, DATE '2019-12-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 11, DATE '2012-02-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 36, DATE '2020-12-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 87, DATE '2010-06-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 14, DATE '2015-06-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 160, DATE '2018-05-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 88, DATE '2018-05-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 144, DATE '2014-05-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 120, DATE '2017-11-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 62, DATE '2010-06-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 104, DATE '2009-07-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 199, DATE '2014-04-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 125, DATE '2011-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 184, DATE '2020-01-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 191, DATE '2010-12-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 36, DATE '2014-04-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 163, DATE '2008-07-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 172, DATE '2012-08-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 51, DATE '2013-03-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 37, DATE '2010-06-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 54, DATE '2012-08-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 177, DATE '2017-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 58, DATE '2014-05-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 169, DATE '2013-01-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 135, DATE '2010-07-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 151, DATE '2019-06-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 59, DATE '2008-01-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 152, DATE '2009-01-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 98, DATE '2008-04-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 77, DATE '2011-05-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 88, DATE '2013-06-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 192, DATE '2018-11-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 15, DATE '2008-03-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 115, DATE '2010-12-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 157, DATE '2018-12-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 13, DATE '2015-11-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 114, DATE '2012-01-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 15, DATE '2017-09-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 9, DATE '2014-12-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 173, DATE '2013-10-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 47, DATE '2020-06-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 131, DATE '2008-07-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 163, DATE '2019-11-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 164, DATE '2012-11-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 83, DATE '2009-06-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 193, DATE '2017-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 158, DATE '2010-04-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 128, DATE '2009-05-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 174, DATE '2008-09-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 139, DATE '2015-02-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 12, DATE '2017-05-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 103, DATE '2012-10-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 146, DATE '2009-09-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 83, DATE '2015-02-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 105, DATE '2020-02-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 73, DATE '2020-03-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 13, DATE '2014-09-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 21, DATE '2009-02-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 63, DATE '2008-07-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 188, DATE '2009-05-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 189, DATE '2012-04-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 65, DATE '2016-12-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 112, DATE '2009-10-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 194, DATE '2020-09-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 178, DATE '2016-12-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 171, DATE '2016-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 144, DATE '2015-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 141, DATE '2020-01-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 146, DATE '2012-10-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 35, DATE '2011-09-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 55, DATE '2019-10-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 63, DATE '2015-12-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 131, DATE '2014-06-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 75, DATE '2017-05-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 55, DATE '2012-03-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 111, DATE '2008-03-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 119, DATE '2009-02-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 137, DATE '2014-06-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 126, DATE '2015-03-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 63, DATE '2020-06-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 170, DATE '2012-02-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 70, DATE '2018-07-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 157, DATE '2020-01-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 17, DATE '2011-03-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 169, DATE '2012-02-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 87, DATE '2019-05-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 129, DATE '2014-07-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 121, DATE '2020-01-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 46, DATE '2011-07-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 154, DATE '2017-01-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 51, DATE '2018-07-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 106, DATE '2020-03-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 51, DATE '2018-10-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 171, DATE '2018-02-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 200, DATE '2017-10-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 44, DATE '2019-05-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 66, DATE '2012-04-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 111, DATE '2016-11-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 17, DATE '2008-07-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 81, DATE '2009-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 172, DATE '2016-08-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 94, DATE '2011-12-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 141, DATE '2010-04-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 139, DATE '2014-10-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 3, DATE '2013-03-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 102, DATE '2008-05-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 51, DATE '2018-12-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 19, DATE '2018-09-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 14, DATE '2009-07-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 108, DATE '2009-01-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 21, DATE '2010-02-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 193, DATE '2011-02-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 36, DATE '2015-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 173, DATE '2008-07-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 46, DATE '2016-01-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 78, DATE '2008-09-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 190, DATE '2019-10-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 130, DATE '2020-11-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 157, DATE '2010-03-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 150, DATE '2016-05-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 197, DATE '2014-10-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 138, DATE '2011-08-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 92, DATE '2008-07-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 156, DATE '2008-06-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 197, DATE '2014-11-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 88, DATE '2014-08-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 28, DATE '2015-01-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 50, DATE '2018-12-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 154, DATE '2009-05-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 110, DATE '2016-01-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 149, DATE '2017-12-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 158, DATE '2010-08-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 174, DATE '2018-04-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 169, DATE '2017-09-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 35, DATE '2019-10-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 38, DATE '2011-07-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 11, DATE '2015-07-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 97, DATE '2014-06-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 176, DATE '2015-02-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 88, DATE '2016-07-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 140, DATE '2014-10-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 125, DATE '2009-05-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 33, DATE '2008-02-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 155, DATE '2011-04-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 80, DATE '2016-11-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 64, DATE '2019-08-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 24, DATE '2018-05-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 197, DATE '2017-08-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 110, DATE '2018-06-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 188, DATE '2016-12-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 196, DATE '2008-09-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 54, DATE '2016-11-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 162, DATE '2009-08-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 114, DATE '2015-09-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 75, DATE '2009-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 58, DATE '2016-11-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 78, DATE '2011-02-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 59, DATE '2020-03-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 73, DATE '2014-05-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 27, DATE '2008-08-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 5, DATE '2013-07-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 176, DATE '2012-03-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 133, DATE '2011-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 19, DATE '2010-05-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 142, DATE '2018-05-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 20, DATE '2018-02-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 40, DATE '2010-12-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 168, DATE '2019-11-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 108, DATE '2018-03-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 116, DATE '2012-01-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 2, DATE '2009-09-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 138, DATE '2012-06-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 7, DATE '2017-05-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 42, DATE '2018-05-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 2, DATE '2012-07-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 177, DATE '2013-06-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 200, DATE '2008-08-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 149, DATE '2010-12-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 200, DATE '2013-04-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 127, DATE '2017-04-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 126, DATE '2020-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 27, DATE '2017-02-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 185, DATE '2012-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 124, DATE '2015-02-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 102, DATE '2008-02-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 192, DATE '2013-11-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 172, DATE '2009-10-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 167, DATE '2019-11-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 141, DATE '2013-07-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 149, DATE '2014-03-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 138, DATE '2010-06-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 114, DATE '2017-08-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 158, DATE '2020-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 51, DATE '2019-12-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 151, DATE '2011-07-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 170, DATE '2010-11-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 50, DATE '2012-11-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 151, DATE '2018-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 192, DATE '2014-02-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 103, DATE '2009-11-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 170, DATE '2017-10-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 193, DATE '2014-03-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 144, DATE '2014-04-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 42, DATE '2011-11-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 56, DATE '2012-12-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 10, DATE '2009-07-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 60, DATE '2020-01-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 172, DATE '2016-12-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 135, DATE '2015-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 92, DATE '2019-11-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 15, DATE '2010-03-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 62, DATE '2008-11-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 103, DATE '2018-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 113, DATE '2012-07-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 121, DATE '2012-04-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 61, DATE '2017-05-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 156, DATE '2017-12-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 89, DATE '2018-08-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 198, DATE '2019-11-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 137, DATE '2020-05-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 166, DATE '2015-05-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 179, DATE '2013-06-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 150, DATE '2018-11-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 102, DATE '2008-07-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 182, DATE '2011-08-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 12, DATE '2008-07-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 138, DATE '2013-09-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 189, DATE '2015-03-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 7, DATE '2014-02-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 20, DATE '2015-02-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 77, DATE '2010-10-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 156, DATE '2013-05-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 143, DATE '2013-10-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 91, DATE '2012-07-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 8, DATE '2013-06-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 134, DATE '2010-09-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 39, DATE '2018-07-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 108, DATE '2008-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 135, DATE '2011-12-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 192, DATE '2009-07-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 11, DATE '2018-05-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 127, DATE '2014-05-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 186, DATE '2017-07-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 126, DATE '2012-06-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 61, DATE '2018-07-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 190, DATE '2012-06-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 82, DATE '2011-10-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 111, DATE '2009-05-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 120, DATE '2009-05-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 39, DATE '2017-05-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 151, DATE '2014-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 82, DATE '2020-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 133, DATE '2008-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 122, DATE '2010-04-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 65, DATE '2018-07-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 163, DATE '2010-09-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 82, DATE '2011-04-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 38, DATE '2014-09-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 101, DATE '2016-10-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 70, DATE '2020-07-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 183, DATE '2019-01-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 20, DATE '2013-12-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 147, DATE '2012-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 34, DATE '2009-05-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 137, DATE '2020-09-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 117, DATE '2018-10-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 179, DATE '2012-12-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 12, DATE '2020-11-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 45, DATE '2014-10-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 150, DATE '2009-04-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 181, DATE '2010-07-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 121, DATE '2013-01-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 146, DATE '2015-12-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 30, DATE '2020-05-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 112, DATE '2014-08-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 175, DATE '2017-09-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 168, DATE '2015-08-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 150, DATE '2020-12-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 143, DATE '2016-03-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 50, DATE '2014-04-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 10, DATE '2011-12-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 77, DATE '2017-02-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 165, DATE '2016-04-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 19, DATE '2011-07-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 176, DATE '2010-10-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 41, DATE '2018-11-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 165, DATE '2010-08-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 126, DATE '2012-11-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 75, DATE '2015-12-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 119, DATE '2008-08-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 14, DATE '2015-06-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 185, DATE '2009-12-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 102, DATE '2013-01-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 114, DATE '2011-07-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 169, DATE '2017-08-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 164, DATE '2013-05-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 121, DATE '2014-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 184, DATE '2008-10-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 118, DATE '2011-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 154, DATE '2017-08-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 119, DATE '2011-07-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 114, DATE '2008-02-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 157, DATE '2019-12-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 37, DATE '2016-05-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 150, DATE '2008-04-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 176, DATE '2013-07-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 24, DATE '2013-07-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 150, DATE '2020-09-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 172, DATE '2013-09-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 191, DATE '2019-01-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 155, DATE '2018-02-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 102, DATE '2019-07-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 152, DATE '2019-12-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 89, DATE '2020-09-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 129, DATE '2014-04-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 3, DATE '2017-05-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 91, DATE '2009-02-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 65, DATE '2012-07-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 117, DATE '2019-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 158, DATE '2019-04-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 160, DATE '2012-11-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 200, DATE '2019-04-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 156, DATE '2015-04-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 57, DATE '2009-02-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 21, DATE '2012-01-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 4, DATE '2013-04-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 168, DATE '2012-07-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 74, DATE '2015-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 137, DATE '2009-10-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 17, DATE '2016-08-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 35, DATE '2018-08-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 154, DATE '2019-01-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 107, DATE '2019-04-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 200, DATE '2013-11-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 21, DATE '2017-04-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 48, DATE '2010-09-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 31, DATE '2013-06-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 34, DATE '2020-03-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 179, DATE '2009-02-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 54, DATE '2008-09-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 131, DATE '2018-12-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 133, DATE '2010-08-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 135, DATE '2014-12-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 7, DATE '2016-06-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 191, DATE '2014-06-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 200, DATE '2010-10-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 200, DATE '2013-12-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 83, DATE '2017-08-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 118, DATE '2019-06-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 154, DATE '2016-08-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 93, DATE '2010-05-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 157, DATE '2008-04-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 153, DATE '2011-04-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 18, DATE '2019-05-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 112, DATE '2008-11-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 60, DATE '2015-08-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 170, DATE '2017-01-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 109, DATE '2010-11-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 21, DATE '2016-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 124, DATE '2014-02-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 168, DATE '2015-11-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 122, DATE '2016-07-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 18, DATE '2017-11-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 170, DATE '2015-10-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 134, DATE '2016-05-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 152, DATE '2016-05-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 98, DATE '2014-12-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 33, DATE '2011-05-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 65, DATE '2009-10-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 90, DATE '2018-09-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 87, DATE '2019-01-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 62, DATE '2015-10-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 181, DATE '2015-02-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 16, DATE '2019-05-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 179, DATE '2020-08-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 164, DATE '2020-05-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 191, DATE '2018-10-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 75, DATE '2013-08-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 141, DATE '2014-07-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 131, DATE '2019-06-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 20, DATE '2018-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 130, DATE '2014-12-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 46, DATE '2008-04-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 177, DATE '2011-04-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 35, DATE '2018-05-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 9, DATE '2018-04-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 15, DATE '2018-10-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 163, DATE '2020-02-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 99, DATE '2012-05-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 83, DATE '2011-03-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 117, DATE '2011-01-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 36, DATE '2012-08-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 109, DATE '2016-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 41, DATE '2009-08-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 84, DATE '2010-03-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 63, DATE '2014-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 83, DATE '2017-11-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 159, DATE '2008-08-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 145, DATE '2010-12-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 1, DATE '2015-02-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 15, DATE '2017-06-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 24, DATE '2013-01-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 196, DATE '2009-06-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 57, DATE '2015-09-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 85, DATE '2014-10-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 125, DATE '2009-03-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 88, DATE '2010-05-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 106, DATE '2011-08-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 19, DATE '2015-02-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 140, DATE '2018-08-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 46, DATE '2019-07-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 163, DATE '2013-04-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 17, DATE '2015-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 119, DATE '2010-04-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 81, DATE '2020-07-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 141, DATE '2010-09-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 177, DATE '2020-09-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 184, DATE '2013-06-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 21, DATE '2018-01-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 32, DATE '2018-04-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 34, DATE '2010-12-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 181, DATE '2018-04-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 182, DATE '2011-01-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 27, DATE '2020-12-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 46, DATE '2017-11-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 45, DATE '2014-09-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 178, DATE '2019-01-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 137, DATE '2012-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 174, DATE '2017-08-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 79, DATE '2016-08-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 99, DATE '2011-01-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 193, DATE '2014-10-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 140, DATE '2019-09-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 89, DATE '2010-12-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 13, DATE '2013-08-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 14, DATE '2015-04-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 32, DATE '2017-06-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 70, DATE '2014-01-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 72, DATE '2008-07-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 161, DATE '2010-01-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 26, DATE '2017-11-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 18, DATE '2017-09-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 133, DATE '2016-03-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 146, DATE '2015-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 90, DATE '2014-04-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 149, DATE '2015-09-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 81, DATE '2019-06-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 166, DATE '2012-12-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 97, DATE '2014-08-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 89, DATE '2018-10-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 17, DATE '2009-09-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 153, DATE '2012-05-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 94, DATE '2014-08-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 114, DATE '2017-03-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 84, DATE '2017-02-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 96, DATE '2010-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 120, DATE '2010-03-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 28, DATE '2008-11-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 180, DATE '2011-03-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 178, DATE '2008-06-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 61, DATE '2014-09-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 85, DATE '2012-09-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 49, DATE '2019-12-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 159, DATE '2018-12-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 57, DATE '2014-07-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 193, DATE '2016-08-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 164, DATE '2009-03-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 22, DATE '2019-01-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 135, DATE '2014-02-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 105, DATE '2010-03-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 27, DATE '2015-01-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 101, DATE '2008-03-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 163, DATE '2014-05-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 99, DATE '2011-09-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 127, DATE '2017-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 42, DATE '2018-04-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 52, DATE '2009-08-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 9, DATE '2017-01-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 17, DATE '2017-10-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 62, DATE '2016-11-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 195, DATE '2013-11-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 10, DATE '2016-05-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 69, DATE '2019-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 70, DATE '2014-04-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 158, DATE '2014-12-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 112, DATE '2012-05-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 75, DATE '2011-11-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 138, DATE '2015-04-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 195, DATE '2011-05-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 142, DATE '2020-08-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 22, DATE '2014-10-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 115, DATE '2010-05-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 167, DATE '2012-10-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 106, DATE '2013-12-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 186, DATE '2012-11-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 33, DATE '2010-09-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 30, DATE '2015-09-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 113, DATE '2012-04-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 11, DATE '2015-06-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 52, DATE '2016-01-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 119, DATE '2008-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 112, DATE '2018-06-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 106, DATE '2010-12-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 130, DATE '2011-07-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 159, DATE '2009-08-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 89, DATE '2009-01-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 115, DATE '2009-04-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 95, DATE '2017-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 31, DATE '2019-04-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 182, DATE '2011-02-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 69, DATE '2017-03-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 14, DATE '2012-10-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 127, DATE '2011-12-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 14, DATE '2016-08-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 104, DATE '2008-10-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 61, DATE '2014-07-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 199, DATE '2018-12-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 134, DATE '2008-01-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 65, DATE '2016-02-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 76, DATE '2011-05-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 3, DATE '2017-12-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 189, DATE '2017-06-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 84, DATE '2018-02-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 22, DATE '2018-12-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 56, DATE '2008-07-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 45, DATE '2017-08-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 114, DATE '2012-01-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 178, DATE '2016-10-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 155, DATE '2018-03-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 24, DATE '2017-04-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 167, DATE '2011-07-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 101, DATE '2020-02-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 187, DATE '2018-09-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 139, DATE '2018-12-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 199, DATE '2011-02-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 154, DATE '2020-10-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 51, DATE '2010-10-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 190, DATE '2018-10-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 137, DATE '2009-07-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 21, DATE '2016-02-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 51, DATE '2012-06-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 176, DATE '2017-11-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 158, DATE '2010-02-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 158, DATE '2010-01-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 170, DATE '2008-11-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 146, DATE '2015-04-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 142, DATE '2010-03-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 165, DATE '2013-10-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 180, DATE '2019-02-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 200, DATE '2019-11-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 174, DATE '2018-11-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 73, DATE '2017-11-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 173, DATE '2011-01-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 127, DATE '2020-07-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 70, DATE '2015-02-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 97, DATE '2018-02-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 177, DATE '2019-05-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 103, DATE '2014-09-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 193, DATE '2015-10-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 129, DATE '2020-08-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 166, DATE '2010-03-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 132, DATE '2016-10-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 52, DATE '2019-08-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 195, DATE '2008-01-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 139, DATE '2019-09-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 48, DATE '2011-01-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 153, DATE '2015-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 82, DATE '2019-03-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 69, DATE '2016-12-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 140, DATE '2010-09-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 41, DATE '2015-01-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 36, DATE '2016-06-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 98, DATE '2009-03-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 1, DATE '2016-06-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 140, DATE '2019-01-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 192, DATE '2011-03-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 9, DATE '2008-02-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 173, DATE '2017-07-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 26, DATE '2018-06-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 23, DATE '2019-01-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 59, DATE '2009-10-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 44, DATE '2017-05-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 37, DATE '2011-02-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 130, DATE '2014-05-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 127, DATE '2017-09-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 168, DATE '2016-10-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 158, DATE '2008-05-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 21, DATE '2015-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 71, DATE '2010-04-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 38, DATE '2011-04-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 173, DATE '2020-09-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 162, DATE '2015-06-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 29, DATE '2009-12-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 116, DATE '2016-07-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 65, DATE '2009-10-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 125, DATE '2014-12-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 90, DATE '2011-10-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 18, DATE '2015-08-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 97, DATE '2016-01-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 85, DATE '2008-06-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 33, DATE '2013-03-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 26, DATE '2009-11-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 116, DATE '2008-06-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 80, DATE '2013-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 120, DATE '2013-03-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 176, DATE '2015-09-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 179, DATE '2017-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 99, DATE '2008-10-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 11, DATE '2017-09-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 191, DATE '2020-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 85, DATE '2016-08-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 131, DATE '2017-11-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 51, DATE '2012-10-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 42, DATE '2016-09-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 197, DATE '2014-03-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 114, DATE '2011-01-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 184, DATE '2015-12-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 50, DATE '2020-04-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 22, DATE '2020-05-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 182, DATE '2011-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 166, DATE '2015-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 168, DATE '2013-03-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 126, DATE '2020-06-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 130, DATE '2010-01-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 71, DATE '2012-04-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 175, DATE '2012-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 121, DATE '2014-09-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 27, DATE '2009-10-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 6, DATE '2009-11-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 63, DATE '2009-05-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 33, DATE '2011-10-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 61, DATE '2019-02-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 191, DATE '2015-11-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 69, DATE '2018-04-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 1, DATE '2017-05-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 46, DATE '2018-01-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 198, DATE '2018-07-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 68, DATE '2008-09-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 155, DATE '2009-08-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 30, DATE '2015-11-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 70, DATE '2018-10-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 155, DATE '2020-03-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 130, DATE '2020-12-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 185, DATE '2016-07-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 61, DATE '2019-09-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 79, DATE '2012-05-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 76, DATE '2014-04-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 192, DATE '2016-07-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 84, DATE '2010-02-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 174, DATE '2010-10-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 147, DATE '2016-03-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 150, DATE '2018-11-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 20, DATE '2018-03-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 180, DATE '2008-03-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 169, DATE '2015-05-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 21, DATE '2013-06-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 138, DATE '2020-11-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 62, DATE '2008-03-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 110, DATE '2011-12-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 50, DATE '2015-05-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 59, DATE '2008-10-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 25, DATE '2012-02-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 90, DATE '2011-06-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 49, DATE '2008-08-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 195, DATE '2020-01-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 65, DATE '2020-08-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 7, DATE '2014-07-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 140, DATE '2008-04-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 136, DATE '2009-12-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 133, DATE '2011-12-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 65, DATE '2011-12-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 197, DATE '2013-09-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 109, DATE '2012-12-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 38, DATE '2012-11-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 13, DATE '2018-02-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 140, DATE '2008-10-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 7, DATE '2013-07-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 198, DATE '2011-07-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 161, DATE '2019-06-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 42, DATE '2012-07-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 118, DATE '2012-09-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 32, DATE '2009-09-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 154, DATE '2011-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 35, DATE '2018-07-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 23, DATE '2017-08-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 188, DATE '2008-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 54, DATE '2011-01-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 86, DATE '2012-09-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 57, DATE '2008-11-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 119, DATE '2017-10-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 193, DATE '2016-02-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 75, DATE '2016-05-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 75, DATE '2008-10-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 177, DATE '2015-09-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 144, DATE '2017-11-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 102, DATE '2017-10-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 87, DATE '2019-06-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 59, DATE '2008-09-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 179, DATE '2014-05-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 87, DATE '2018-12-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 89, DATE '2011-03-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 55, DATE '2014-08-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 200, DATE '2020-07-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 164, DATE '2016-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 24, DATE '2014-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 129, DATE '2009-03-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 87, DATE '2009-02-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 30, DATE '2010-02-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 10, DATE '2016-12-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 65, DATE '2013-03-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 28, DATE '2012-06-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 149, DATE '2011-03-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 86, DATE '2014-03-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 133, DATE '2011-12-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 181, DATE '2020-02-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 165, DATE '2018-09-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 86, DATE '2016-07-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 134, DATE '2008-07-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 43, DATE '2012-05-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 167, DATE '2015-11-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 98, DATE '2014-08-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 77, DATE '2012-10-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 146, DATE '2009-02-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 34, DATE '2011-08-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 7, DATE '2019-07-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 120, DATE '2015-12-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 129, DATE '2012-06-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 82, DATE '2016-08-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 121, DATE '2015-12-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 177, DATE '2013-05-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 105, DATE '2014-11-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 140, DATE '2017-01-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 49, DATE '2009-02-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 75, DATE '2013-09-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 119, DATE '2019-10-19');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 11, DATE '2015-05-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 126, DATE '2014-12-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 42, DATE '2014-02-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 77, DATE '2014-10-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 8, DATE '2017-08-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (6, 74, DATE '2009-10-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 123, DATE '2017-06-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 68, DATE '2013-10-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 127, DATE '2012-04-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 148, DATE '2011-08-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 150, DATE '2010-05-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 137, DATE '2013-04-24');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 130, DATE '2009-03-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 55, DATE '2019-09-20');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 72, DATE '2008-06-03');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 184, DATE '2015-05-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 186, DATE '2015-01-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 163, DATE '2009-05-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 53, DATE '2016-02-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 45, DATE '2013-11-12');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 6, DATE '2019-11-01');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 25, DATE '2019-01-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 50, DATE '2017-10-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 8, DATE '2015-11-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 199, DATE '2020-04-26');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 123, DATE '2018-08-23');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 56, DATE '2016-05-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 190, DATE '2018-05-13');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 4, DATE '2008-11-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 165, DATE '2016-01-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 121, DATE '2016-05-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 124, DATE '2014-02-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 195, DATE '2011-03-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (4, 97, DATE '2017-12-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 56, DATE '2018-10-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 65, DATE '2019-10-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 77, DATE '2009-01-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 147, DATE '2017-02-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 134, DATE '2016-03-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 14, DATE '2012-08-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 135, DATE '2016-04-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 167, DATE '2015-05-14');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 178, DATE '2008-03-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 184, DATE '2017-01-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 112, DATE '2019-01-18');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 130, DATE '2013-05-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 92, DATE '2009-11-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 45, DATE '2011-05-07');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 163, DATE '2019-11-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 194, DATE '2016-06-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 141, DATE '2010-04-16');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 197, DATE '2008-02-29');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 28, DATE '2018-02-04');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (8, 191, DATE '2011-07-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 85, DATE '2018-11-27');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (15, 179, DATE '2009-12-05');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 5, DATE '2013-04-15');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (11, 199, DATE '2011-07-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 81, DATE '2017-04-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (10, 137, DATE '2011-10-11');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (3, 183, DATE '2020-07-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 112, DATE '2012-06-06');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (9, 94, DATE '2016-04-30');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 26, DATE '2020-02-21');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (2, 51, DATE '2017-03-25');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 141, DATE '2017-12-17');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (5, 191, DATE '2011-01-31');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (1, 35, DATE '2020-06-09');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 96, DATE '2017-02-28');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (14, 107, DATE '2009-10-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (7, 129, DATE '2019-01-22');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 52, DATE '2011-02-08');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (12, 10, DATE '2014-03-10');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 23, DATE '2018-06-02');



INSERT INTO upisano (predmet_id, student_id, upisan_od)
VALUES (13, 109, DATE '2018-10-25');


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (1, 66, 10, 6, DATE '2016-03-03', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (2, 127, 14, 11, DATE '2010-01-02', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (3, 63, 4, 3, DATE '2020-01-03', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (4, 70, 10, 20, DATE '2020-09-07', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (5, 119, 11, 14, DATE '2019-03-05', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (6, 141, 13, 16, DATE '2012-09-27', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (7, 17, 14, 19, DATE '2015-05-25', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (8, 7, 6, 11, DATE '2018-07-25', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (9, 98, 14, 7, DATE '2019-03-29', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (10, 19, 12, 14, DATE '2020-09-30', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (11, 18, 4, 6, DATE '2010-11-17', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (12, 200, 12, 9, DATE '2017-09-02', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (13, 52, 15, 14, DATE '2010-11-17', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (14, 191, 6, 1, DATE '2015-01-05', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (15, 141, 4, 2, DATE '2015-11-15', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (16, 165, 9, 5, DATE '2012-02-20', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (17, 139, 8, 12, DATE '2020-02-21', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (18, 10, 5, 18, DATE '2011-09-02', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (19, 100, 3, 16, DATE '2013-03-02', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (20, 102, 11, 1, DATE '2010-07-29', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (21, 180, 6, 2, DATE '2016-05-14', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (22, 83, 4, 1, DATE '2013-03-18', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (23, 47, 7, 11, DATE '2010-09-13', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (24, 45, 9, 19, DATE '2015-04-05', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (25, 13, 4, 20, DATE '2016-09-26', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (26, 185, 4, 16, DATE '2012-05-29', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (27, 112, 3, 5, DATE '2017-05-27', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (28, 179, 3, 1, DATE '2020-11-07', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (29, 161, 13, 17, DATE '2020-07-23', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (30, 149, 6, 17, DATE '2010-11-28', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (31, 46, 8, 8, DATE '2020-03-03', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (32, 65, 3, 18, DATE '2013-06-22', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (33, 166, 8, 20, DATE '2019-04-03', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (34, 138, 14, 5, DATE '2014-11-08', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (35, 165, 3, 8, DATE '2014-05-16', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (36, 104, 3, 3, DATE '2011-10-26', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (37, 151, 1, 14, DATE '2015-07-15', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (38, 6, 4, 11, DATE '2011-07-12', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (39, 152, 5, 19, DATE '2017-01-19', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (40, 193, 3, 9, DATE '2018-04-08', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (41, 56, 7, 11, DATE '2016-02-13', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (42, 162, 11, 16, DATE '2013-09-17', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (43, 113, 6, 8, DATE '2020-01-25', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (44, 43, 6, 5, DATE '2015-12-16', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (45, 65, 8, 7, DATE '2020-08-05', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (46, 152, 5, 9, DATE '2012-12-12', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (47, 108, 6, 4, DATE '2017-06-01', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (48, 140, 13, 17, DATE '2014-10-13', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (49, 195, 4, 17, DATE '2019-12-18', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (50, 19, 15, 20, DATE '2015-08-11', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (51, 9, 15, 5, DATE '2014-10-16', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (52, 34, 14, 18, DATE '2015-11-19', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (53, 117, 13, 20, DATE '2010-08-15', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (54, 99, 3, 11, DATE '2014-07-14', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (55, 118, 7, 9, DATE '2015-09-23', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (56, 81, 10, 5, DATE '2012-10-14', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (57, 194, 11, 4, DATE '2011-06-07', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (58, 24, 1, 6, DATE '2010-07-15', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (59, 158, 1, 8, DATE '2015-05-05', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (60, 78, 2, 3, DATE '2016-07-24', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (61, 198, 13, 19, DATE '2020-02-09', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (62, 142, 4, 2, DATE '2015-05-17', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (63, 25, 6, 14, DATE '2019-06-09', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (64, 27, 1, 10, DATE '2019-07-24', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (65, 28, 2, 11, DATE '2014-10-08', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (66, 131, 15, 1, DATE '2015-01-30', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (67, 126, 9, 20, DATE '2010-03-30', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (68, 199, 14, 10, DATE '2011-10-06', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (69, 87, 10, 17, DATE '2018-12-08', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (70, 6, 6, 3, DATE '2016-08-10', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (71, 57, 11, 17, DATE '2010-10-31', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (72, 47, 7, 15, DATE '2019-04-26', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (73, 95, 3, 8, DATE '2016-10-23', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (74, 30, 11, 20, DATE '2013-12-17', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (75, 139, 6, 18, DATE '2020-07-06', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (76, 20, 1, 4, DATE '2020-01-01', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (77, 159, 9, 11, DATE '2014-01-05', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (78, 10, 15, 19, DATE '2019-04-20', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (79, 140, 9, 9, DATE '2010-01-29', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (80, 8, 9, 10, DATE '2019-08-26', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (81, 36, 14, 9, DATE '2014-04-22', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (82, 147, 9, 17, DATE '2015-12-06', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (83, 189, 6, 2, DATE '2020-03-14', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (84, 171, 1, 18, DATE '2017-07-14', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (85, 102, 10, 15, DATE '2012-08-31', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (86, 11, 5, 11, DATE '2014-02-19', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (87, 49, 15, 16, DATE '2011-07-22', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (88, 68, 5, 15, DATE '2013-01-23', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (89, 20, 14, 10, DATE '2011-01-01', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (90, 16, 4, 13, DATE '2019-02-24', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (91, 174, 4, 20, DATE '2018-10-02', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (92, 72, 13, 9, DATE '2019-04-28', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (93, 145, 4, 12, DATE '2017-07-18', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (94, 11, 1, 17, DATE '2010-08-13', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (95, 77, 8, 5, DATE '2018-02-13', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (96, 40, 1, 16, DATE '2016-10-27', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (97, 114, 4, 12, DATE '2019-12-05', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (98, 152, 13, 19, DATE '2016-10-04', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (99, 93, 14, 3, DATE '2014-04-19', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (100, 132, 10, 5, DATE '2016-11-29', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (101, 104, 5, 9, DATE '2010-08-21', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (102, 49, 6, 12, DATE '2013-08-10', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (103, 15, 15, 13, DATE '2011-10-04', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (104, 144, 12, 8, DATE '2012-10-05', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (105, 89, 9, 2, DATE '2018-12-28', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (106, 40, 4, 11, DATE '2015-03-24', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (107, 140, 10, 6, DATE '2010-06-04', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (108, 194, 2, 6, DATE '2016-08-18', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (109, 177, 7, 8, DATE '2012-04-06', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (110, 130, 9, 4, DATE '2019-07-13', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (111, 33, 6, 1, DATE '2017-07-26', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (112, 147, 10, 2, DATE '2012-02-14', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (113, 46, 8, 12, DATE '2011-06-29', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (114, 33, 10, 4, DATE '2011-04-17', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (115, 87, 8, 16, DATE '2018-01-19', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (116, 17, 1, 5, DATE '2017-05-20', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (117, 180, 2, 8, DATE '2017-05-11', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (118, 109, 9, 2, DATE '2018-02-26', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (119, 139, 9, 2, DATE '2019-08-15', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (120, 137, 15, 11, DATE '2016-08-17', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (121, 157, 2, 14, DATE '2011-10-19', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (122, 140, 5, 17, DATE '2011-02-15', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (123, 179, 5, 5, DATE '2010-08-08', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (124, 77, 4, 16, DATE '2010-06-02', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (125, 29, 15, 2, DATE '2017-09-30', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (126, 30, 5, 2, DATE '2012-09-20', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (127, 182, 9, 4, DATE '2012-03-17', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (128, 124, 12, 3, DATE '2013-07-04', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (129, 62, 15, 13, DATE '2016-09-09', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (130, 83, 10, 16, DATE '2016-11-22', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (131, 26, 10, 11, DATE '2013-09-07', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (132, 84, 11, 12, DATE '2011-11-15', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (133, 43, 2, 5, DATE '2014-10-05', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (134, 96, 10, 20, DATE '2010-11-25', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (135, 97, 9, 15, DATE '2014-09-20', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (136, 154, 14, 4, DATE '2015-08-31', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (137, 159, 11, 18, DATE '2012-12-05', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (138, 31, 1, 2, DATE '2010-08-28', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (139, 136, 1, 12, DATE '2010-08-14', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (140, 109, 1, 10, DATE '2013-07-14', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (141, 51, 2, 8, DATE '2016-07-05', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (142, 68, 12, 10, DATE '2014-04-05', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (143, 4, 5, 16, DATE '2018-09-10', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (144, 50, 5, 8, DATE '2014-08-24', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (145, 133, 10, 13, DATE '2010-10-13', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (146, 171, 2, 14, DATE '2012-02-15', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (147, 69, 14, 7, DATE '2014-05-26', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (148, 13, 7, 7, DATE '2018-06-06', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (149, 107, 1, 16, DATE '2019-12-10', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (150, 187, 15, 6, DATE '2011-12-16', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (151, 57, 3, 10, DATE '2019-05-16', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (152, 22, 10, 10, DATE '2014-06-19', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (153, 132, 6, 1, DATE '2015-12-04', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (154, 20, 8, 17, DATE '2020-05-13', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (155, 22, 5, 14, DATE '2015-11-24', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (156, 64, 12, 16, DATE '2011-05-23', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (157, 49, 10, 20, DATE '2016-06-09', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (158, 87, 12, 13, DATE '2020-04-15', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (159, 118, 13, 10, DATE '2010-12-02', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (160, 81, 9, 7, DATE '2010-10-30', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (161, 198, 15, 8, DATE '2012-11-06', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (162, 127, 10, 8, DATE '2016-03-01', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (163, 67, 5, 19, DATE '2020-06-12', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (164, 154, 1, 17, DATE '2020-12-13', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (165, 49, 4, 3, DATE '2016-04-03', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (166, 61, 9, 11, DATE '2010-09-01', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (167, 154, 11, 9, DATE '2014-06-15', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (168, 132, 5, 12, DATE '2019-12-30', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (169, 55, 11, 3, DATE '2019-02-01', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (170, 154, 6, 20, DATE '2020-10-16', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (171, 25, 10, 20, DATE '2014-01-09', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (172, 152, 3, 9, DATE '2015-04-05', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (173, 47, 8, 16, DATE '2020-02-09', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (174, 161, 6, 15, DATE '2013-04-27', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (175, 110, 6, 16, DATE '2012-07-11', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (176, 13, 5, 7, DATE '2013-06-03', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (177, 22, 10, 13, DATE '2017-11-14', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (178, 200, 9, 2, DATE '2015-01-16', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (179, 172, 9, 12, DATE '2017-08-03', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (180, 17, 9, 14, DATE '2016-03-14', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (181, 56, 9, 3, DATE '2010-04-07', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (182, 161, 15, 3, DATE '2017-04-22', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (183, 198, 13, 1, DATE '2017-08-08', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (184, 142, 13, 18, DATE '2011-10-24', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (185, 19, 1, 4, DATE '2018-08-09', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (186, 141, 8, 19, DATE '2019-02-03', 2);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (187, 157, 4, 8, DATE '2019-08-20', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (188, 163, 7, 14, DATE '2019-06-19', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (189, 96, 6, 3, DATE '2015-05-24', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (190, 68, 4, 6, DATE '2012-10-17', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (191, 122, 8, 3, DATE '2017-02-22', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (192, 135, 8, 10, DATE '2019-08-23', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (193, 176, 4, 1, DATE '2018-11-16', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (194, 4, 1, 6, DATE '2010-07-17', 4);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (195, 161, 1, 8, DATE '2019-08-09', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (196, 135, 7, 20, DATE '2015-09-29', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (197, 190, 15, 17, DATE '2015-09-09', 5);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (198, 124, 3, 3, DATE '2013-11-27', 3);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (199, 173, 2, 9, DATE '2019-07-09', 1);


INSERT INTO ocjene (id, student_id, predmet_id, profesor_id, datum_ocjene, ocjena)
VALUES (200, 58, 7, 20, DATE '2010-04-16', 5);
COMMIT;


select 
count(studenti.id) as br_stud,
naziv_smjera as naziv_smjera
from studenti
inner join smjerovi
on studenti.smjer_id = smjerovi.id
where naziv_smjera like 'O%'
group by naziv_smjera
order by br_stud desc;



select 
count(studenti.id) as br_stud,
naziv_smjera as naziv_smjera
from studenti
right join smjerovi
on studenti.smjer_id = smjerovi.id
group by naziv_smjera
having count(studenti.id)<35 ;


select 
vrste_zaposlenja.vrsta as vrsta,
count(profesori.id) as broj_profesora
from profesori
inner join vrste_zaposlenja
on profesori.vrsta_zaposlenja_id = vrste_zaposlenja.id
group by vrste_zaposlenja.vrsta
order by count(profesori.id) desc;

select 
count(studenti.id) as br_stud,
predmeti.naziv_predmeta
from studenti 
inner join upisano 
on studenti.id = upisano.student_id
right join predmeti
on upisano.predmet_id = predmeti.id
group by naziv_predmeta
order by naziv_predmeta asc;

select 
extract(year from datum_ocjene) as godina,
round(avg(ocjena),2) as prosjek_ocjene
from ocjene
group by extract(year from datum_ocjene)
order by godina asc;


select 
extract(year from datum_ocjene) as godina,
extract(month from datum_ocjene) as mjesec,
count(ocjena) as broj_ocjena
from ocjene
group by extract(year from datum_ocjene), extract(month from datum_ocjene)
order by godina asc, mjesec asc;

select 
naziv_predmeta as naziv_predmeta,
naziv_uloge as uloga,
count(profesori.id) as broj_prof
from predaje
inner join  profesori
on profesori.id = predaje.profesor_id
inner join predmeti
on predaje.predmet_id = predmeti.id
inner join uloge_profesora
on predaje.uloga_id = uloge_profesora.id
group by naziv_uloge, naziv_predmeta
order by naziv_predmeta asc;

