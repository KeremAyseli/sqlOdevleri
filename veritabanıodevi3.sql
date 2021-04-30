--Kullan�c� giri�inin olu�turulmas�
create login "rektor" with password='rekt�r1'
create login "dekan" with password='dekan1'
create login "kay�tGorevlisi" with password='kay�tGorevlisi1'

--Kullan�c�lar�n olu�turulmas�.
create user "rektor" from login rektor
create user "dekan" from login dekan
create user "kay�tGorevlisi" from login kay�tGorevlisi

--Rekt�re veri taban�nda istedi�i i�lemi yapabilmesi i�in db_owner rol�n� atad�m,
--bu i�lem rekt�r�n veritaban�nda veri ekleme,veri silme,veri g�ncelleme,veritaban�ndaki rolleri y�netme ve veritaban�n� silme yetkisini veriyor
exec sp_addrolemember 'db_owner','rektor';

--Dekan kullan�c�s�na sadece elektrik ��rencilerini g�rebilmesi i�in olu�turdu�um view
create view elektrikOgrencileri
as
select * from ogrenci where b_id=1
--Dekan kullan�c�s�na elektrikOgrencileri view'nin �zerinde listeleme ve g�ncelleme yetkisini veren komut
--Bu izinleri grant komutunu kullanarak yap�yorum form�l� ise grant <i�lemler> on tabloAd� to kullan�c�Ad�
grant select,update on elektrikOgrencileri to dekan

--dekan kullan�c�s�na sadece elektrik ��retmenlerini g�rebilmesi i�in olu�turdu�um view
create view elektrikOgretmenleri
as
select * from ogretmen where b_id=1
grant select,update on elektrikOgretmenleri to dekan

--kay�t gorevlisine ogrenci ve ogretmen tablosu �zerinde listeleme ve ekleme i�lemi yapmas� i�in verdi�im yetkiler.
grant select,insert on ogrenci to kay�tGorevlisi
grant select,insert on ogretmen to kay�tGorevlisi

--Cengiz tahir ��retmenin kendi ��rencilerini g�rebilmesi i�in olu�turu�du�um view
create view cengizTahir
as
select * from ogrenci_ders where d_id=(
select d_id from ogretmen_ders where o_id=2) 
--Derya se�kin ��retmenin kendi ��rencilerini g�rebilmesi i�in olu�turu�du�um view
create view deryaSe�kin
as
select * from ogrenci_ders where d_id=(
select d_id from ogretmen_ders where o_id=3) 
--Ayten kahraman ��retmenin kendi ��rencilerini g�rebilmesi i�in olu�turu�du�um view
create view aytenKahraman
as
select * from ogrenci_ders where d_id=(
select d_id from ogretmen_ders where o_id=5) 

--Derya se�kinin kendi ��rencilerinin notlar�n� ve not ortalamas�n� g�rebilmesi i�in yaz�d��m kod 
--kodumda sum ile ��rencilerin ��rencilerinin toplam notlar�n� g�steriyorum,fakat ��renci notlar� i�erisinde null olan de�erlerde var bunlar i�in ISNULL fonksiyonunu kullan�yorum
--bu fonksiyon null olan de�i�kenin yerine belirtti�im de�eri at�yor.
--��renci not ortalamas� i�in ise avg fonksiyonunu kullan�yorum ,AVG fonksiyonunda sadece ilk 3 de�eri alabilmek i�in DISTINCT �art�n� parametresini kullan�yorum
select SUM(ISNULL(notu,0)) as Notlar�nToplam�,AVG(DISTINCT ISNULL(notu,0))as NotOrtalamas� from deryaSe�kin


--��renci tablosuna bir veri eklendi�inde yap�lacak i�lemleri bu trigger�n i�erisinde yapt�m.
--Trigger olu�turma
create trigger YeniVerileriG�stermeOgretmen
--Trigger tablosunu se�me
on dbo.ogretmen
--After ile i�lemin ne zaman yap�laca��na karar veriyorum.Insert i�lemi ile hangi i�lemden sonra yap�laca��na karar veriyorum  
after insert
as
--Trigger ba�lang�c�
begin
--Yap�lacak i�lemi buraya yaz�yorum
select * from ogretmen
--Trigger sonu
end


create trigger YeniVerileriG�stermeOgrenci
on dbo.ogrenci
after insert
as
begin 
select * from ogrenci
end

--Trggerlar� tablolar �zerinde aktif ediyorum.
enable TRIGGER YeniVerileriG�stermeOgrenci on ogrenci
enable TRIGGER YeniVerileriG�stermeOgretmen on ogretmen

--��lem yap�lan kullan�c�y� de�i�tiriyorum.
setuser 'kay�tGorevlisi'
--Ogrenci tablosuna yeni bir veri ekliyorum ve triggerlar� bu i�lem sayesinde �al��t�r�yorum.
insert into ogrenci values(12,'kerem','ayseli','istanbul',1) 

