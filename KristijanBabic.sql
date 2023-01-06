-- obriši tablicu gradovi ako postoji
DROP TABLE gradovi;

-- napravi tablicu gradovi
CREATE TABLE gradovi (
    id INT PRIMARY KEY,
    naziv_grada VARCHAR(50) NOT NULL,
    postbr CHAR(5) UNIQUE
);

-- dodaj 2 retka u tablicu gradovi
INSERT INTO gradovi (id, naziv_grada, postbr)
    VALUES (1, 'Zagreb', '10000');
INSERT INTO gradovi (id, naziv_grada, postbr)
    VALUES (2, 'Osijek', '31000');

-- obriši tablicu zaposlenici ako postji
DROP TABLE zaposlenici;

-- napravi tablicu zaposlenici
CREATE TABLE zaposlenici (
    id INT PRIMARY KEY,
    ime VARCHAR(50) NOT NULL,
    prezime VARCHAR(50) NOT NULL,
    oib CHAR(11) UNIQUE,
    datum_rodenja DATE DEFAULT SYSDATE,
    neto_placa NUMBER(8, 2) DEFAULT 0,
    broj_telefona VARCHAR(50) DEFAULT '-- nije uneseno --',
    aktivan INT DEFAULT 0,
    visina FLOAT
);

-- dodaj 2 retka u tablicu zaposlenici
INSERT INTO zaposlenici (id, ime, prezime, oib, datum_rodenja)
    VALUES (1, 'Pero', 'Peric', '12321232123', DATE '1991-01-01');

INSERT INTO zaposlenici (id, ime, prezime, oib, datum_rodenja)
    VALUES (2, 'Ivana', 'Peric', '22321232123', SYSDATE);