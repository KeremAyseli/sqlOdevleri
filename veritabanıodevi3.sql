--Kullanýcý giriþinin oluþturulmasý
create login "rektor" with password='rektör1'
create login "dekan" with password='dekan1'
create login "kayýtGorevlisi" with password='kayýtGorevlisi1'

--Kullanýcýlarýn oluþturulmasý.
create user "rektor" from login rektor
create user "dekan" from login dekan
create user "kayýtGorevlisi" from login kayýtGorevlisi

--Rektöre veri tabanýnda istediði iþlemi yapabilmesi için db_owner rolünü atadým,
--bu iþlem rektörün veritabanýnda veri ekleme,veri silme,veri güncelleme,veritabanýndaki rolleri yönetme ve veritabanýný silme yetkisini veriyor
exec sp_addrolemember 'db_owner','rektor';

--Dekan kullanýcýsýna sadece elektrik öðrencilerini görebilmesi için oluþturduðum view
create view elektrikOgrencileri
as
select * from ogrenci where b_id=1
--Dekan kullanýcýsýna elektrikOgrencileri view'nin üzerinde listeleme ve güncelleme yetkisini veren komut
--Bu izinleri grant komutunu kullanarak yapýyorum formülü ise grant <iþlemler> on tabloAdý to kullanýcýAdý
grant select,update on elektrikOgrencileri to dekan

--dekan kullanýcýsýna sadece elektrik öðretmenlerini görebilmesi için oluþturduðum view
create view elektrikOgretmenleri
as
select * from ogretmen where b_id=1
grant select,update on elektrikOgretmenleri to dekan

--kayýt gorevlisine ogrenci ve ogretmen tablosu üzerinde listeleme ve ekleme iþlemi yapmasý için verdiðim yetkiler.
grant select,insert on ogrenci to kayýtGorevlisi
grant select,insert on ogretmen to kayýtGorevlisi

--Cengiz tahir öðretmenin kendi öðrencilerini görebilmesi için oluþturuðduðum view
create view cengizTahir
as
select * from ogrenci_ders where d_id=(
select d_id from ogretmen_ders where o_id=2) 
--Derya seçkin öðretmenin kendi öðrencilerini görebilmesi için oluþturuðduðum view
create view deryaSeçkin
as
select * from ogrenci_ders where d_id=(
select d_id from ogretmen_ders where o_id=3) 
--Ayten kahraman öðretmenin kendi öðrencilerini görebilmesi için oluþturuðduðum view
create view aytenKahraman
as
select * from ogrenci_ders where d_id=(
select d_id from ogretmen_ders where o_id=5) 

--Derya seçkinin kendi öðrencilerinin notlarýný ve not ortalamasýný görebilmesi için yazýdðým kod 
--kodumda sum ile öðrencilerin öðrencilerinin toplam notlarýný gösteriyorum,fakat öðrenci notlarý içerisinde null olan deðerlerde var bunlar için ISNULL fonksiyonunu kullanýyorum
--bu fonksiyon null olan deðiþkenin yerine belirttiðim deðeri atýyor.
--Öðrenci not ortalamasý için ise avg fonksiyonunu kullanýyorum ,AVG fonksiyonunda sadece ilk 3 deðeri alabilmek için DISTINCT þartýný parametresini kullanýyorum
select SUM(ISNULL(notu,0)) as NotlarýnToplamý,AVG(DISTINCT ISNULL(notu,0))as NotOrtalamasý from deryaSeçkin


--Öðrenci tablosuna bir veri eklendiðinde yapýlacak iþlemleri bu triggerýn içerisinde yaptým.
--Trigger oluþturma
create trigger YeniVerileriGöstermeOgretmen
--Trigger tablosunu seçme
on dbo.ogretmen
--After ile iþlemin ne zaman yapýlacaðýna karar veriyorum.Insert iþlemi ile hangi iþlemden sonra yapýlacaðýna karar veriyorum  
after insert
as
--Trigger baþlangýcý
begin
--Yapýlacak iþlemi buraya yazýyorum
select * from ogretmen
--Trigger sonu
end


create trigger YeniVerileriGöstermeOgrenci
on dbo.ogrenci
after insert
as
begin 
select * from ogrenci
end

--Trggerlarý tablolar üzerinde aktif ediyorum.
enable TRIGGER YeniVerileriGöstermeOgrenci on ogrenci
enable TRIGGER YeniVerileriGöstermeOgretmen on ogretmen

--Ýþlem yapýlan kullanýcýyý deðiþtiriyorum.
setuser 'kayýtGorevlisi'
--Ogrenci tablosuna yeni bir veri ekliyorum ve triggerlarý bu iþlem sayesinde çalýþtýrýyorum.
insert into ogrenci values(12,'kerem','ayseli','istanbul',1) 

