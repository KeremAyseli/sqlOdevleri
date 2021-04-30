--Yetkilinin kendi altýnda çalýþanlarý görmek için kullanacaðý prosedür.
--Yetkili kendi id kodunu girdiði zaman bu id ile yetkili_id sütununda eþleþen personel isimlerini getirir.
create procedure altlarýGetir(@id int)
as
begin
select per_adi from Personel where yetkili_id=@id
end
-----------------------------------------------
--Elemanlarýn net kazançlarýný getiren prosedür.Yetkili kendi id kodunu girdikten sonra,kendi altýnda çalýþan tüm elemanlarýn aylýk net kazanlarýný görür.
create procedure netKazanclarýGetir(@id int)
as 
begin
--Burada kullanýlan isnull fonksiyonu maas deðeri NULL ise yerine 0 deðerini koyuyor ve iþleme öyle devam ediyor.
select per_adi ,dbo.verilenSayýToplama(isnull(maas,0),isnull(0,kominsyon))as netKazanc from Personel where yetkili_id=@id
end
--Bu iþlemi yapmak için böyle bir fonksiyon yazdým.Bu fonksiyon verilen iki sayýyý alýp topluyor ve geri int bir deðer olarak döndürüyor.
create function verilenSayýToplama(@sayý1 int ,@sayi2 int)
returns int --fonksiyonun geri dönüþ tipi.
as 
begin
declare @toplam int --fonksiyon içi deðiþken tanýmlama.Fonksiyonun içinde deðiþken tanýmlama þu þekilde oluyor: declare degiþken_ismi deðiþken_tipi.
set @toplam=@sayý1+@sayi2 --Burada @toplam deðiþkenimizin içine yaptýðýmýz iþlemin sonucunu atýyoruz bunun için SET kullanýyoruz.
return @toplam --Çýkan deðeri geri yolluyoruz.
end
-----------------------------------------------
--Seçilen elemandan daha az kýdemlileri getiren prosedür.Girilen eleman id kodunun alarak o elemandan daha az kýdemli olan elemanlarý getiriyor.
create procedure azKýdemlileriGetir(@id int)
as
begin
--DATEIFF fonksiyonu giris_tarihi sütunundaki tarihlere göre elemanlarýn kýdemlerini hesaplýyor.
--alt sorguda ise seçilen elemanýn kaç yýl çalýþtýðý hesaplanýyor ve ona göre giris_tarihi sütunundaki verilerle karþýlaþtýrýlýyor.
select per_adi from Personel where DATEDIFF(year,giris_tarihi,GETDATE())<( select  DATEDIFF(year,giris_tarihi,GETDATE())as kýdem1  from Personel where per_id=@id)
end
----------------------------------------------
--En yetkili elemaný getiren prosedür.Bu prosedürde yetkili kendi id kodunu girdikten sonra kendi altýnda çalýþan en kýdemli elemaný görebiliyor.
create procedure enKýdemli(@id int)
as
begin
--alt sorguda giris_tarihi en eski kiþi min fonksiyonu kullanýlarak bulunuyor daha sonra üst sorguda bu tarihle eþleþen kiþinin bilgileri çýkýyor,ve çýkan sonuçlarý per_id sütununa göre gruplanýyor.
select * from Personel where giris_tarihi=(select min(giris_tarihi)as kýdem from Personel where yetkili_id=@id) order by per_id 
end
-----------------------------------------------
--Bu prosedür günlük çalýþma ücretleri 100 liradan daha fazla olan elemanlarý getiriyor.
create procedure Gunluk100LiradanFazlaMaas
as
begin
--oratalamaMaasHesaplama fonksiyonu kullanarak günlük ücretini bulduktan sonra geri dönen deðerler arasýnda 100'den büyük olanlarý listeliyor.
select per_id,per_adi,maas,DATEDIFF(DAY,giris_tarihi,GETDATE())as sirketteCalýstýðýGun,dbo.ortalamaMaasHesapla(maas)as GunlukMaas from Personel where dbo.ortalamaMaasHesapla(maas)>=100
end
--OrtalamaMaasHesaplama fonksiyonu alýnan maas bilgisini aylýk çalýþma günü olan 26'ya böldükten sonra çýkan sonucu geri getirir.
create function ortalamaMaasHesapla(@maas int)
returns int
as
begin
declare @ortalamaMaas int 
set @ortalamaMaas=@maas/26
return @ortalamaMaas
end
------------------------------------------------
--Ýþ yerinde altýnda eleman çalýþan olamayanlarý getiren prosedür.
create procedure yetkisizOlanlarýGetir
as
begin
--burada outer join yaparak per_id ve yetkili_id sütunlarýnda ayný anda id kodu bulunan elemanlar dýþýndaki tüm elemanlarý listeliyoruz. 
select  Personel.per_id,Personel.per_adi  from Personel 
full outer join Personel b
on Personel.per_id=b.yetkili_id where b.per_id IS null 
end
-------------------------------------------------


--prosedürler ve kullaným þekli.Kullaným þekil exec prosedür_ismi prosedür_parametreleri
exec altlarýGetir 203
exec netKazanclarýGetir 201
exec azKýdemlileriGetir 304
exec enKýdemli 201
exec Gunluk100LiradanFazlaMaas
exec yetkisizOlanlarýGetir

