--Yetkilinin kendi alt�nda �al��anlar� g�rmek i�in kullanaca�� prosed�r.
--Yetkili kendi id kodunu girdi�i zaman bu id ile yetkili_id s�tununda e�le�en personel isimlerini getirir.
create procedure altlar�Getir(@id int)
as
begin
select per_adi from Personel where yetkili_id=@id
end
-----------------------------------------------
--Elemanlar�n net kazan�lar�n� getiren prosed�r.Yetkili kendi id kodunu girdikten sonra,kendi alt�nda �al��an t�m elemanlar�n ayl�k net kazanlar�n� g�r�r.
create procedure netKazanclar�Getir(@id int)
as 
begin
--Burada kullan�lan isnull fonksiyonu maas de�eri NULL ise yerine 0 de�erini koyuyor ve i�leme �yle devam ediyor.
select per_adi ,dbo.verilenSay�Toplama(isnull(maas,0),isnull(0,kominsyon))as netKazanc from Personel where yetkili_id=@id
end
--Bu i�lemi yapmak i�in b�yle bir fonksiyon yazd�m.Bu fonksiyon verilen iki say�y� al�p topluyor ve geri int bir de�er olarak d�nd�r�yor.
create function verilenSay�Toplama(@say�1 int ,@sayi2 int)
returns int --fonksiyonun geri d�n�� tipi.
as 
begin
declare @toplam int --fonksiyon i�i de�i�ken tan�mlama.Fonksiyonun i�inde de�i�ken tan�mlama �u �ekilde oluyor: declare degi�ken_ismi de�i�ken_tipi.
set @toplam=@say�1+@sayi2 --Burada @toplam de�i�kenimizin i�ine yapt���m�z i�lemin sonucunu at�yoruz bunun i�in SET kullan�yoruz.
return @toplam --��kan de�eri geri yolluyoruz.
end
-----------------------------------------------
--Se�ilen elemandan daha az k�demlileri getiren prosed�r.Girilen eleman id kodunun alarak o elemandan daha az k�demli olan elemanlar� getiriyor.
create procedure azK�demlileriGetir(@id int)
as
begin
--DATEIFF fonksiyonu giris_tarihi s�tunundaki tarihlere g�re elemanlar�n k�demlerini hesapl�yor.
--alt sorguda ise se�ilen eleman�n ka� y�l �al��t��� hesaplan�yor ve ona g�re giris_tarihi s�tunundaki verilerle kar��la�t�r�l�yor.
select per_adi from Personel where DATEDIFF(year,giris_tarihi,GETDATE())<( select  DATEDIFF(year,giris_tarihi,GETDATE())as k�dem1  from Personel where per_id=@id)
end
----------------------------------------------
--En yetkili eleman� getiren prosed�r.Bu prosed�rde yetkili kendi id kodunu girdikten sonra kendi alt�nda �al��an en k�demli eleman� g�rebiliyor.
create procedure enK�demli(@id int)
as
begin
--alt sorguda giris_tarihi en eski ki�i min fonksiyonu kullan�larak bulunuyor daha sonra �st sorguda bu tarihle e�le�en ki�inin bilgileri ��k�yor,ve ��kan sonu�lar� per_id s�tununa g�re gruplan�yor.
select * from Personel where giris_tarihi=(select min(giris_tarihi)as k�dem from Personel where yetkili_id=@id) order by per_id 
end
-----------------------------------------------
--Bu prosed�r g�nl�k �al��ma �cretleri 100 liradan daha fazla olan elemanlar� getiriyor.
create procedure Gunluk100LiradanFazlaMaas
as
begin
--oratalamaMaasHesaplama fonksiyonu kullanarak g�nl�k �cretini bulduktan sonra geri d�nen de�erler aras�nda 100'den b�y�k olanlar� listeliyor.
select per_id,per_adi,maas,DATEDIFF(DAY,giris_tarihi,GETDATE())as sirketteCal�st���Gun,dbo.ortalamaMaasHesapla(maas)as GunlukMaas from Personel where dbo.ortalamaMaasHesapla(maas)>=100
end
--OrtalamaMaasHesaplama fonksiyonu al�nan maas bilgisini ayl�k �al��ma g�n� olan 26'ya b�ld�kten sonra ��kan sonucu geri getirir.
create function ortalamaMaasHesapla(@maas int)
returns int
as
begin
declare @ortalamaMaas int 
set @ortalamaMaas=@maas/26
return @ortalamaMaas
end
------------------------------------------------
--�� yerinde alt�nda eleman �al��an olamayanlar� getiren prosed�r.
create procedure yetkisizOlanlar�Getir
as
begin
--burada outer join yaparak per_id ve yetkili_id s�tunlar�nda ayn� anda id kodu bulunan elemanlar d���ndaki t�m elemanlar� listeliyoruz. 
select  Personel.per_id,Personel.per_adi  from Personel 
full outer join Personel b
on Personel.per_id=b.yetkili_id where b.per_id IS null 
end
-------------------------------------------------


--prosed�rler ve kullan�m �ekli.Kullan�m �ekil exec prosed�r_ismi prosed�r_parametreleri
exec altlar�Getir 203
exec netKazanclar�Getir 201
exec azK�demlileriGetir 304
exec enK�demli 201
exec Gunluk100LiradanFazlaMaas
exec yetkisizOlanlar�Getir

