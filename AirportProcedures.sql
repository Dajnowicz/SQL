


--1a) Tworzy widok o nazwie "pasazer_informacje", kt�ry wy�wietla o ka�dym pasa�erze takie informacje jak:
--id_pracownik, imie, nazwisko, kolumna wyliczeniowa "ilosc_lat",
--kolumna wyliczeniowa "ilosc_rez", czyli ca�kowita ilo�� rezerwacji samolotwych, kolumna wyliczeniowa
--"czy_wyda�_w_liniach" z warto�ciami TAK/NIE/BRAK (TAK gdy pasa�er wyda� co� na pok�adzie, NIE gdy nigdy nic nie kupuil, BRAK w pozosta�ych przypadkach).
--(U�YCIE CASE)
CREATE VIEW pasazer_informacje AS
SELECT p.id_pasazer,p.imie,p.nazwisko, DATEDIFF(YY,p.data_urodzenia,GETDATE()) AS "ilosc_lat", COUNT(r.pasazer_id) AS "ilosc_rez",
CASE WHEN p.czy_wyda�_w_liniach>0 THEN 'TAK' WHEN p.czy_wyda�_w_liniach=0 THEN 'NIE' else 'BRAK' END AS czy_kupowal FROM pasazer p LEFT JOIN rezerwacja r ON p.id_pasazer=r.pasazer_id 
GROUP BY p.id_pasazer,p.imie,p.nazwisko,p.data_urodzenia,p.czy_wyda�_w_liniach;
GO

--1b) Sprawdzenie, �e widok dzia�a dla os�b, kt�re kupi�y wi�cej bielet�w ni� srednia kupionych oraz kt�rzy s� pe�noletni i co� kiedy� kupili na pok�adzie
SELECT * FROM pasazer_informacje GROUP BY id_pasazer,imie, nazwisko, ilosc_rez, ilosc_lat,czy_kupowal  HAVING ilosc_rez>(SELECT AVG(ilosc_rez) FROM pasazer_informacje WHERE ilosc_lat > 18 AND czy_kupowal = 'TAK') ;
Go

--2a) Tworzymy funkcj� 1 o nazwie producent_ile_samolot�w, kt�ra b�dzie zwraca� ilo�c samolot�w kt�re wyprodukowa� dany producent.
--(U�YCIE IF-ELSE)
CREATE FUNCTION dbo.producent_ile_samolot�w (
 @id_producent_samolotu INT
) RETURNS INT
BEGIN
IF (SELECT COUNT(*) FROM samolot WHERE producent_samolotu_id=@id_producent_samolotu) =0 
RETURN 0
ELSE
RETURN (SELECT COUNT(*) FROM samolot
 WHERE producent_samolotu_id=@id_producent_samolotu)
RETURN 0
END;
GO

--2b) Sprawdzenie, �e funkcja 1 dzia�a poprzez przyk�ad producenta "Ferrari".
SELECT dbo.producent_ile_samolot�w(1) AS ile_samolot�w;

--3a) Tworzymy funkcj� 2 o nazwie ile_samolot�w posiadaj�c� dwa parametry czas_wylot i czas_przylotu. Funkcja powinna
--zwr�ci� ilo�� lot�w samolotowych w zadanym przedziale czasowym. 
CREATE FUNCTION dbo.ile_samolot�w (
    @czas_wylotu DATE, @czas_przylotu DATE
    ) RETURNS INT
    BEGIN RETURN (SELECT COUNT(*) FROM plan_lotu
                            WHERE czas_przylotu<=@czas_przylotu AND czas_wylotu >=@czas_wylotu )
END;
GO

--3b) Sprawdzenie, �e funkcja 2 dzia�a poprzez sprawdzenie ile samalot�w lata�o w Maju.
SELECT dbo.ile_samolot�w('2018-05-01', '2018-05-29') AS ile_samolot�w_w_maju;
GO

SELECT * FROM pasazer

--4a) Tworzymy procedur� 1, kt�ra obni�a cene dla pasa�era kt�ry najcz�sciej podr�uje.
CREATE PROC obni�ka_op�at_dla_najczesciej_podrozujacych
@obnizka MONEY
AS BEGIN
DECLARE @id_najczestszego_pasazera INT
SET @id_najczestszego_pasazera=(SELECT TOP 1 p.id_pasazer FROM pasazer p JOIN rezerwacja r ON p.id_pasazer=r.pasazer_id GROUP BY p.id_pasazer
ORDER BY COUNT(p.id_pasazer ) DESC)
UPDATE pasazer SET czy_wyda�_w_liniach=czy_wyda�_w_liniach-@obnizka WHERE id_pasazer=@id_najczestszego_pasazera;
END

--4b) Sprawdzenie, �e procedura 1 dzia�a
EXEC obni�ka_op�at_dla_najczesciej_podrozujacych 500;
GO

--5a) Tworzymy procedur� 2, kt�ra t�ra z bie��cej bazy danych usunie wszystkie klucze obce.
--(U�YCIE IF EXISTS)
CREATE PROCEDURE usun_klucze_obce AS
BEGIN
    WHILE(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE='FOREIGN KEY'))
    BEGIN
        DECLARE @sql NVARCHAR(2000)
        SELECT TOP 1 @sql=('ALTER TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME
        + '] DROP CONSTRAINT [' + CONSTRAINT_NAME + ']')
        FROM information_schema.table_constraints
        WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
        EXEC (@sql)
    END
END

--5b) Sprawdzenie, �e procedura 2 dzia�a
EXEC usun_klucze_obce

SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS;
GO

--6a) Tworzymy wyzwalacz 1 kt�ry po dodaniu kolejnego zakupu pasazera zmniejszy jego d�ug o 10% wraz z zakupionym ostatnio produktem(Milionowy Klient).
--(U�YCIE WHILE)
CREATE TRIGGER obnizka ON pasazer
FOR UPDATE AS
BEGIN
    DECLARE kursor_pasazer_update CURSOR
    FOR SELECT czy_wyda�_w_liniach, id_pasazer FROM DELETED;
    OPEN kursor_pasazer_update
    DECLARE @czy_wyda�_w_liniach MONEY, @id_pasazer INT
    FETCH NEXT FROM kursor_pasazer_update INTO @czy_wyda�_w_liniach, @id_pasazer
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE pasazer SET czy_wyda�_w_liniach=czy_wyda�_w_liniach*0.90 WHERE id_pasazer=@id_pasazer
        FETCH NEXT FROM kursor_pasazer_update INTO @czy_wyda�_w_liniach, @id_pasazer
    END
    CLOSE kursor_pasazer_update
    DEALLOCATE kursor_pasazer_update
END
GO

--6b) Sprawdzenie, �e wyzwalacz 1 dzia�a
UPDATE pasazer SET czy_wyda�_w_liniach=10000 WHERE id_pasazer IN(1);

--7a) Tworzymy wyzwalacz 2, kt�ry zablokuje nam dodanie nowego pasa�era z d�ugiem.
CREATE TRIGGER pasazer_ins ON pasazer
AFTER INSERT AS
BEGIN
    DECLARE @czy_wyda�_w_liniach MONEY
    SET @czy_wyda�_w_liniach=-1
    SELECT @czy_wyda�_w_liniach=czy_wyda�_w_liniach FROM INSERTED WHERE czy_wyda�_w_liniach>0
    IF @czy_wyda�_w_liniach>0 
    BEGIN
        RAISERROR('nowy pasazer nie moze miec dlugu', 1, 2);
        ROLLBACK
    END
END
GO

--7b) Sprawdzenie, �e wyzwalacz 2 dzia�a
INSERT INTO pasazer(imie,drugie_imie,nazwisko, numer_telefonu, adres_email, numer_paszportu, data_urodzenia, czy_wyda�_w_liniach, kraj_id) VALUES ('Dagmara','Iwona','Kowalska','129371','dagmara@wp.pl','1241244','1963-12-03',124,1);

--8a) Tworzymy wzywalacz 3, kt�ry przy usuwaniu producenta samolotu daje nam informacje o jego za�ozycielu i nazwie.
--(UZYCIE KURSORA)
CREATE TRIGGER usun_producenta_samolotu ON producent_samolotu
AFTER DELETE
AS
BEGIN
    DECLARE kursor__producent_samolot_delete CURSOR
    FOR SELECT nazwa_producenta, ceo  FROM DELETED;
    DECLARE @nazwa_producenta VARCHAR(10), @ceo VARCHAR(20)

	OPEN kursor__producent_samolot_delete
    FETCH NEXT FROM kursor__producent_samolot_delete INTO @nazwa_producenta, @ceo
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'Usunieto ' + @nazwa_producenta+ ' zalozonego przez ' + @ceo
        FETCH NEXT FROM kursor__producent_samolot_delete INTO @nazwa_producenta, @ceo
	END
    CLOSE kursor__producent_samolot_delete
    DEALLOCATE kursor__producent_samolot_delete
END
 
--8b) Sprawdzenie, �e wyzwalacz 3 dzia�a
DELETE FROM producent_samolotu WHERE id_producent_samolotu IN(6, 7);
GO

SELECT * FROM producent_samolotu;

--9a) Tworzymy wyzwalacz 4, kt�ry nie pozwala nam dodawac zmieniac i usuwac informacji o typach samolot�w.
CREATE TRIGGER typ_samolotu_blokada ON typ_samolotu
INSTEAD OF INSERT, UPDATE, DELETE
AS
    PRINT('NIE MOZNA ZMIENIAC TYPU SAMOLOTU')
GO

--9b) Sprawdzenie, �e wyzwalacz 4 dzia�a
DELETE FROM typ_samolotu WHERE id_typ_samolotu IN(1,2)

--10) Tworz� tabel� przestawn�, kt�ra przedstawia sume wp�at dla trzech ostatnich lat na trzy stanowiska.
SELECT nazwa_terminala, [2018] as ROK2018, [2017] AS ROK2017, [2016] AS ROK2016
FROM
(
	SELECT nazwa_terminala, YEAR(data) as wplata, kwota
	FROM oplata
) tabela
PIVOT
(
	SUM(kwota)
	FOR wplata IN ([2018],[2017],[2016])
) AS p
ORDER BY nazwa_terminala

--KONIEC

--DROPS

drop view pasazer_informacje;
drop function dbo.producent_ile_samolot�w;
drop function dbo.ile_samolot�w 
drop proc obni�ka_op�at_dla_najczesciej_podrozujacych
drop proc usun_klucze_obce
drop trigger obnizka
drop trigger double_lotnisko
drop trigger usun_producenta_samolotu
drop trigger usun_producenta_samolotu
drop trigger typ_samolotu_blokada






