--MSSQL, baza danych na zadanie projektowe 2: lotnisko
--Marcel Dajnowicz 03.05.2018 r.

--Zmiana formatu daty (polecenie zgodne z MSSQL)
SET DATEFORMAT ymd;
GO

--Utworzenie wymaganych tabel
CREATE TABLE oplata (
  id_oplata int IDENTITY(1,1) PRIMARY KEY,
  data DATETIME NOT NULL,
  kwota MONEY NOT NULL CHECK(kwota>=0),
);
GO

INSERT INTO oplata(data,kwota) VALUES ('2018-09-02','200');
INSERT INTO oplata(data,kwota) VALUES ('2018-5-22','2350');
INSERT INTO oplata(data,kwota) VALUES ('2018-12-12','350');
INSERT INTO oplata(data,kwota) VALUES ('2018-03-02','256');
INSERT INTO oplata(data,kwota) VALUES ('2018-04-22','3250');


CREATE TABLE typ_oplaty (
  id_typ_oplaty int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(30) NOT NULL,
  oplata_id INTEGER NOT NULL REFERENCES oplata(id_oplata) ON UPDATE CASCADE,
);
GO

INSERT INTO typ_oplaty(nazwa,oplata_id) VALUES ('Gotówka',1);
INSERT INTO typ_oplaty(nazwa,oplata_id) VALUES ('Gotówka',2);
INSERT INTO typ_oplaty(nazwa,oplata_id) VALUES ('Karta Kredytowa',3);
INSERT INTO typ_oplaty(nazwa,oplata_id) VALUES ('Krata Kredytowa',4);
INSERT INTO typ_oplaty(nazwa,oplata_id) VALUES ('Gotówka',5);

CREATE TABLE klasa_samolotowa (
  id_klasa_samolotowa int IDENTITY(1,1) PRIMARY KEY,
  nazwa_klasy VARCHAR(20) NOT NULL,
  opis_klasy VARCHAR(20) NULL,
);
GO

INSERT INTO klasa_samolotowa(nazwa_klasy,opis_klasy) VALUES ('Economic','tanie');
INSERT INTO klasa_samolotowa(nazwa_klasy,opis_klasy) VALUES ('Super-economic','super tanie');
INSERT INTO klasa_samolotowa(nazwa_klasy,opis_klasy) VALUES ('luxary','dla bogaczy');
INSERT INTO klasa_samolotowa(nazwa_klasy,opis_klasy) VALUES ('super-luxary','dla super bogaczy');
INSERT INTO klasa_samolotowa(nazwa_klasy,opis_klasy) VALUES ('normal','dla sredniakow');


CREATE TABLE posilek (
  id_posilek int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(30) NOT NULL,
  klasa_samolotowa_id INTEGER NOT NULL REFERENCES klasa_samolotowa(id_klasa_samolotowa) ON UPDATE CASCADE,
);
GO

INSERT INTO posilek(nazwa,klasa_samolotowa_id) VALUES ('zupa',1);
INSERT INTO posilek(nazwa,klasa_samolotowa_id) VALUES ('drugie danie',2);
INSERT INTO posilek(nazwa,klasa_samolotowa_id) VALUES ('hot dog',3);
INSERT INTO posilek(nazwa,klasa_samolotowa_id) VALUES ('napoj',4);
INSERT INTO posilek(nazwa,klasa_samolotowa_id) VALUES ('pelny posilek',5);

CREATE TABLE typ_samolotu (
  id_typ_samolotu int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(10) NOT NULL,
  opis VARCHAR(100) NOT NULL,
);
GO

INSERT INTO typ_samolotu(nazwa, opis) VALUES ('BOJING','potwor');
INSERT INTO typ_samolotu(nazwa, opis) VALUES ('Posejdon','przewozi czolgi');
INSERT INTO typ_samolotu(nazwa, opis) VALUES ('Mars','leci na wojne');
INSERT INTO typ_samolotu(nazwa, opis) VALUES ('Copter','maly');
INSERT INTO typ_samolotu(nazwa, opis) VALUES ('AIRFORCE 1','malo-wazny');




CREATE TABLE producent_samolotu (
  id_producent_samolotu int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(10) NOT NULL,
  rok_zalozenia DATETIME NULL,
);
GO

INSERT INTO producent_samolotu(nazwa, rok_zalozenia) VALUES ('Ferrari','2008-05-09');
INSERT INTO producent_samolotu(nazwa, rok_zalozenia) VALUES ('Bugatti','2010-03-29');
INSERT INTO producent_samolotu(nazwa, rok_zalozenia) VALUES ('Maluch','2007-03-19');
INSERT INTO producent_samolotu(nazwa, rok_zalozenia) VALUES ('Amrix','1997-12-01');
INSERT INTO producent_samolotu(nazwa, rok_zalozenia) VALUES ('Intel','1997-09-19');



CREATE TABLE samolot (
  id_samolot int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(20) NOT NULL UNIQUE,
  numer VARCHAR(20) NOT NULL UNIQUE,
  model VARCHAR(20) NOT NULL UNIQUE,
  pojemnosc VARCHAR(10) NOT NULL,
  producent_samolotu_id INTEGER NOT NULL REFERENCES producent_samolotu(id_producent_samolotu) ON UPDATE CASCADE,
  typ_samolotu_id INTEGER NOT NULL REFERENCES typ_samolotu(id_typ_samolotu) ON UPDATE CASCADE,
);
GO

INSERT INTO samolot(nazwa,numer,model, pojemnosc, producent_samolotu_id, typ_samolotu_id) VALUES ('Markotny','23','1 Generacja','201',4,5);
INSERT INTO samolot(nazwa,numer,model, pojemnosc, producent_samolotu_id, typ_samolotu_id) VALUES ('Latajacy','223','X1X','5',5,4);
INSERT INTO samolot(nazwa,numer,model, pojemnosc, producent_samolotu_id, typ_samolotu_id) VALUES ('Nurek','1','Supreme','566',3,3);
INSERT INTO samolot(nazwa,numer,model, pojemnosc, producent_samolotu_id, typ_samolotu_id) VALUES ('SuperSlim','235','Stealth','23',2,2);
INSERT INTO samolot(nazwa,numer,model, pojemnosc, producent_samolotu_id, typ_samolotu_id) VALUES ('Pitchfork','2','Short','1',1,1);


CREATE TABLE miejsce_samolotowe (
  id_miejsce_samolotowe int IDENTITY(1,1) PRIMARY KEY,
  numer_miejsca VARCHAR(5) NOT NULL UNIQUE,
  klasa_samolotowa_id INTEGER NOT NULL REFERENCES klasa_samolotowa(id_klasa_samolotowa),
  samolot_id INTEGER NOT NULL REFERENCES samolot(id_samolot),
);
GO

INSERT INTO miejsce_samolotowe(numer_miejsca,klasa_samolotowa_id,samolot_id) VALUES ('56',1,1);
INSERT INTO miejsce_samolotowe(numer_miejsca,klasa_samolotowa_id,samolot_id) VALUES ('78',2,2);
INSERT INTO miejsce_samolotowe(numer_miejsca,klasa_samolotowa_id,samolot_id) VALUES ('101',3,3);
INSERT INTO miejsce_samolotowe(numer_miejsca,klasa_samolotowa_id,samolot_id) VALUES ('523',4,4);
INSERT INTO miejsce_samolotowe(numer_miejsca,klasa_samolotowa_id,samolot_id) VALUES ('23',5,5);


CREATE TABLE status_lotu (
  id_status_lotu int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(20) NOT NULL UNIQUE,
  opis VARCHAR(30) NOT NULL,
  data DATETIME NOT NULL DEFAULT GETDATE(),
  opoznienia VARCHAR(20) NULL,
  );
GO

INSERT INTO status_lotu(nazwa, opis,data,opoznienia) VALUES ('Great Line','papieros na pokaldzie','2012-02-03','');
INSERT INTO status_lotu(nazwa, opis,data,opoznienia) VALUES ('MAGA','cos nie tak','2016-11-14','');
INSERT INTO status_lotu(nazwa, opis,data,opoznienia) VALUES ('InterCont','atak','2017-10-25','2 godziny');
INSERT INTO status_lotu(nazwa, opis,data,opoznienia) VALUES ('WOHO','wszystko w normie','2014-01-12','');
INSERT INTO status_lotu(nazwa, opis,data,opoznienia) VALUES ('LETSGO','wszystko w normie','2018-12-03','dwa dni');


CREATE TABLE lot (
  id_lot int IDENTITY(1,1) PRIMARY KEY,
  opis VARCHAR(20) NULL,
  status_lotu_id INTEGER NOT NULL REFERENCES status_lotu(id_status_lotu) ON UPDATE CASCADE,
  typ_samolotu_id INTEGER NOT NULL REFERENCES typ_samolotu(id_typ_samolotu) ON UPDATE CASCADE,
);
GO

INSERT INTO lot(opis, status_lotu_id,typ_samolotu_id) VALUES ('fajny',1,1);
INSERT INTO lot(opis, status_lotu_id,typ_samolotu_id) VALUES ('niebezpieczny',1,1);
INSERT INTO lot(opis, status_lotu_id,typ_samolotu_id) VALUES ('wszystko-ok',1,2);
INSERT INTO lot(opis, status_lotu_id,typ_samolotu_id) VALUES ('',2,3);
INSERT INTO lot(opis, status_lotu_id,typ_samolotu_id) VALUES ('zderzenie',3,4);


CREATE TABLE cena_za_bilet (
  id_cena_za_bilet int IDENTITY(1,1) PRIMARY KEY,
  cena_za_bilet VARCHAR(10) NOT NULL,
  miejsce_samolotowe_id INTEGER NOT NULL REFERENCES miejsce_samolotowe(id_miejsce_samolotowe) ON UPDATE CASCADE,
  lot_id INTEGER NOT NULL REFERENCES lot(id_lot) ON UPDATE CASCADE,
);
GO

INSERT INTO cena_za_bilet(cena_za_bilet, miejsce_samolotowe_id,lot_id) VALUES ('123',1,1);
INSERT INTO cena_za_bilet(cena_za_bilet, miejsce_samolotowe_id,lot_id) VALUES ('1232',2,2);
INSERT INTO cena_za_bilet(cena_za_bilet, miejsce_samolotowe_id,lot_id) VALUES ('745',3,3);
INSERT INTO cena_za_bilet(cena_za_bilet, miejsce_samolotowe_id,lot_id) VALUES ('235',4,4);
INSERT INTO cena_za_bilet(cena_za_bilet, miejsce_samolotowe_id,lot_id) VALUES ('3462',5,5);


CREATE TABLE kraj (
  kraj_id int IDENTITY(1,1) PRIMARY KEY,
  nazwa VARCHAR(20) NOT NULL,
);
GO

INSERT INTO kraj(nazwa) VALUES ('Polska');
INSERT INTO kraj(nazwa) VALUES ('USA');
INSERT INTO kraj(nazwa) VALUES ('Argentyna');
INSERT INTO kraj(nazwa) VALUES ('Niemcy');
INSERT INTO kraj(nazwa) VALUES ('UK');


CREATE TABLE pasazer (
  id_pasazer int IDENTITY(1,1) PRIMARY KEY,
  imie VARCHAR(20) NOT NULL CHECK(LEN(imie)>2),
  drugie_imie VARCHAR(20) NOT NULL,
  nazwisko VARCHAR(30) NOT NULL CHECK(LEN(nazwisko)>2),
  numer_telefonu VARCHAR(20) NOT NULL,
  adres_email VARCHAR(30) NOT NULL,
  numer_paszportu VARCHAR(30) NOT NULL UNIQUE,
  kraj_id INTEGER NOT NULL REFERENCES kraj(kraj_id) ON UPDATE CASCADE,
);
GO

INSERT INTO pasazer(imie,drugie_imie,nazwisko, numer_telefonu, adres_email, numer_paszportu, kraj_id) VALUES ('Marcel','Michal','Dajnowicz','12345678','dajnowiczmarcel@wp.pl','12312',1);
INSERT INTO pasazer(imie,drugie_imie,nazwisko, numer_telefonu, adres_email, numer_paszportu, kraj_id) VALUES ('Julia','Blanka','Zubka','71727364','powazny@.pl','41245',2);
INSERT INTO pasazer(imie,drugie_imie,nazwisko, numer_telefonu, adres_email, numer_paszportu, kraj_id) VALUES ('Magda','Aga','Czekalska','3252345','buziaczek@.wp.pl','512512',2);
INSERT INTO pasazer(imie,drugie_imie,nazwisko, numer_telefonu, adres_email, numer_paszportu, kraj_id) VALUES ('Jakub','Pawe³','Nowak','25323523','hejka@wp.pl','125125',4);
INSERT INTO pasazer(imie,drugie_imie,nazwisko, numer_telefonu, adres_email, numer_paszportu, kraj_id) VALUES ('Jakub','Mateusz','Rachwa³','745457','lekarz@.pl','421245',5);


CREATE TABLE rezerwacja (
  id_rezerwacja int IDENTITY(1,1) PRIMARY KEY,
  cena_za_bilet_id INTEGER NOT NULL REFERENCES cena_za_bilet(id_cena_za_bilet) ON UPDATE CASCADE,
  pasazer_id INTEGER NOT NULL REFERENCES pasazer(id_pasazer) ON UPDATE CASCADE,
  uwagi VARCHAR(30) NULL,
);
GO

INSERT INTO rezerwacja(cena_za_bilet_id,pasazer_id,uwagi) VALUES (1,1,'meh');
INSERT INTO rezerwacja(cena_za_bilet_id,pasazer_id,uwagi) VALUES (2,2,'zly system');
INSERT INTO rezerwacja(cena_za_bilet_id,pasazer_id,uwagi) VALUES (3,3,'genialny system');
INSERT INTO rezerwacja(cena_za_bilet_id,pasazer_id,uwagi) VALUES (4,4,'SUPER BAZA DANYCH');
INSERT INTO rezerwacja(cena_za_bilet_id,pasazer_id,uwagi) VALUES (5,5,'ok');

CREATE TABLE kierunek (
  id_kierunek int IDENTITY(1,1) PRIMARY KEY,
  kierunek_swiata VARCHAR(20) NOT NULL,
);
GO

INSERT INTO kierunek(kierunek_swiata) VALUES ('polnoc');
INSERT INTO kierunek(kierunek_swiata) VALUES ('poludnie');
INSERT INTO kierunek(kierunek_swiata) VALUES ('wschod');
INSERT INTO kierunek(kierunek_swiata) VALUES ('polnocny-zachod');
INSERT INTO kierunek(kierunek_swiata) VALUES ('zachod');


CREATE TABLE lotnisko (
  id_lotnisko int IDENTITY(1,1) PRIMARY KEY,
  nazwa_lotniska VARCHAR(20) NOT NULL,
  miasto VARCHAR(20) NOT NULL,
  ulica VARCHAR(30) NOT NULL,
  numer_ulicy VARCHAR(10) NOT NULL,
  kod_pocztowy VARCHAR(10) NOT NULL,
  kraj_id INTEGER NOT NULL REFERENCES kraj(kraj_id) ON UPDATE CASCADE,
  kierunek_id INTEGER NOT NULL REFERENCES kierunek(id_kierunek) ON UPDATE CASCADE,
);
GO

INSERT INTO lotnisko(nazwa_lotniska,miasto,ulica, numer_ulicy, kod_pocztowy, kraj_id, kierunek_id) VALUES ('Lech Walesa','Gdansk','legionow','201','12-344',1,4);
INSERT INTO lotnisko(nazwa_lotniska,miasto,ulica, numer_ulicy, kod_pocztowy, kraj_id, kierunek_id) VALUES ('Marcel Airport','Marcelolandia','Marcela','1','57-784',1,4);
INSERT INTO lotnisko(nazwa_lotniska,miasto,ulica, numer_ulicy, kod_pocztowy, kraj_id, kierunek_id) VALUES ('Okecie','Warszawa','legionow','201','12-344',1,1);
INSERT INTO lotnisko(nazwa_lotniska,miasto,ulica, numer_ulicy, kod_pocztowy, kraj_id, kierunek_id) VALUES ('Luton','London','legionow','201','12-344',5,3);
INSERT INTO lotnisko(nazwa_lotniska,miasto,ulica, numer_ulicy, kod_pocztowy, kraj_id, kierunek_id) VALUES ('Dutch','Amsterdam','legionow','201','12-344',4,2);


CREATE TABLE plan_lotu (
  id_plan_lotu int IDENTITY(1,1) PRIMARY KEY,
  czas_wylotu DATETIME NOT NULL,
  czas_przylotu DATETIME NOT NULL,
  kierunek_id INTEGER NOT NULL REFERENCES kierunek(id_kierunek) ON UPDATE CASCADE,
  lot_id INTEGER NOT NULL REFERENCES lot(id_lot) ON UPDATE CASCADE,
);
GO

INSERT INTO plan_lotu(czas_wylotu, czas_przylotu,kierunek_id,lot_id) VALUES ('2018-12-03','2018-12-03',3,5);
INSERT INTO plan_lotu(czas_wylotu, czas_przylotu,kierunek_id,lot_id) VALUES ('2014-01-12','2014-01-12',1,3);
INSERT INTO plan_lotu(czas_wylotu, czas_przylotu,kierunek_id,lot_id) VALUES ('2017-10-25','2017-10-25',1,3);
INSERT INTO plan_lotu(czas_wylotu, czas_przylotu,kierunek_id,lot_id) VALUES ('2016-11-13','2016-11-14',2,3);
INSERT INTO plan_lotu(czas_wylotu, czas_przylotu,kierunek_id,lot_id) VALUES ('2012-02-03','2012-02-04',2,3);













