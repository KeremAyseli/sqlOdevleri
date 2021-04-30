--Yetkilinin kendi altında çalışanları görmek için kullanacağı prosedür.
--Yetkili kendi id kodunu girdiği zaman bu id ile yetkili_id sütununda eşleşen personel isimlerini getirir.
create procedure altlarıGetir(@id int)
as
begin
select per_adi from Personel where yetkili_id=@id
end
-----------------------------------------------
--Elemanların net kazançlarını getiren prosedür.Yetkili kendi id kodunu girdikten sonra,kendi altında çalışan tüm elemanların aylık net kazanlarını görür.
create procedure netKazanclarıGetir(@id int)
as 
begin
--Burada kullanılan isnull fonksiyonu maas değeri NULL ise yerine 0 değerini koyuyor ve işleme öyle devam ediyor.
select per_adi ,dbo.verilenSayıToplama(isnull(maas,0),isnull(0,kominsyon))as netKazanc from Personel where yetkili_id=@id
end
--Bu işlemi yapmak için böyle bir fonksiyon yazdım.Bu fonksiyon verilen iki sayıyı alıp topluyor ve geri int bir değer olarak döndürüyor.
create function verilenSayıToplama(@sayı1 int ,@sayi2 int)
returns int --fonksiyonun geri dönüş tipi.
as 
begin
declare @toplam int --fonksiyon içi değişken tanımlama.Fonksiyonun içinde değişken tanımlama şu şekilde oluyor: declare degişken_ismi değişken_tipi.
set @toplam=@sayı1+@sayi2 --Burada @toplam değişkenimizin içine yaptığımız işlemin sonucunu atıyoruz bunun için SET kullanıyoruz.
return @toplam --Çıkan değeri geri yolluyoruz.
end
-----------------------------------------------
--Seçilen elemandan daha az kıdemlileri getiren prosedür.Girilen eleman id kodunun alarak o elemandan daha az kıdemli olan elemanları getiriyor.
create procedure azKıdemlileriGetir(@id int)
as
begin
--DATEIFF fonksiyonu giris_tarihi sütunundaki tarihlere göre elemanların kıdemlerini hesaplıyor.
--alt sorguda ise seçilen elemanın kaç yıl çalıştığı hesaplanıyor ve ona göre giris_tarihi sütunundaki verilerle karşılaştırılıyor.
select per_adi from Personel where DATEDIFF(year,giris_tarihi,GETDATE())<( select  DATEDIFF(year,giris_tarihi,GETDATE())as kıdem1  from Personel where per_id=@id)
end
----------------------------------------------
--En yetkili elemanı getiren prosedür.Bu prosedürde yetkili kendi id kodunu girdikten sonra kendi altında çalışan en kıdemli elemanı görebiliyor.
create procedure enKıdemli(@id int)
as
begin
--alt sorguda giris_tarihi en eski kişi min fonksiyonu kullanılarak bulunuyor daha sonra üst sorguda bu tarihle eşleşen kişinin bilgileri çıkıyor,ve çıkan sonuçları per_id sütununa göre gruplanıyor.
select * from Personel where giris_tarihi=(select min(giris_tarihi)as kıdem from Personel where yetkili_id=@id) order by per_id 
end
-----------------------------------------------
--Bu prosedür günlük çalışma ücretleri 100 liradan daha fazla olan elemanları getiriyor.
create procedure Gunluk100LiradanFazlaMaas
as
begin
--oratalamaMaasHesaplama fonksiyonu kullanarak günlük ücretini bulduktan sonra geri dönen değerler arasında 100'den büyük olanları listeliyor.
select per_id,per_adi,maas,DATEDIFF(DAY,giris_tarihi,GETDATE())as sirketteCalıstığıGun,dbo.ortalamaMaasHesapla(maas)as GunlukMaas from Personel where dbo.ortalamaMaasHesapla(maas)>=100
end
--OrtalamaMaasHesaplama fonksiyonu alınan maas bilgisini aylık çalışma günü olan 26'ya böldükten sonra çıkan sonucu geri getirir.
create function ortalamaMaasHesapla(@maas int)
returns int
as
begin
declare @ortalamaMaas int 
set @ortalamaMaas=@maas/26
return @ortalamaMaas
end
------------------------------------------------
--İş yerinde altında eleman çalışan olamayanları getiren prosedür.
create procedure yetkisizOlanlarıGetir
as
begin
--burada outer join yaparak per_id ve yetkili_id sütunlarında aynı anda id kodu bulunan elemanlar dışındaki tüm elemanları listeliyoruz. 
select  Personel.per_id,Personel.per_adi  from Personel 
full outer join Personel b
on Personel.per_id=b.yetkili_id where b.per_id IS null 
end
-------------------------------------------------


--prosedürler ve kullanım şekli.Kullanım şekil exec prosedür_ismi prosedür_parametreleri
exec altlarıGetir 203
exec netKazanclarıGetir 201
exec azKıdemlileriGetir 304
exec enKıdemli 201
exec Gunluk100LiradanFazlaMaas
exec yetkisizOlanlarıGetir

