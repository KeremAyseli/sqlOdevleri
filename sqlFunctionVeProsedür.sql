create procedure GunlukMaasHesapla2(@id varchar(11),@maas int)
 as
 Begin
 select per_adi from Personel where maas>(select maasHesaplat(@maas)>100)
 end

EXEC GunlukMaasHesapla2 '1',100

create function maasHesaplat(@maas int)
returns int 
as
begin
declare @otuzGunlukOrtalam int
set @otuzGunlukOrtalam=@maas+30
return @otuzGunlukOrtalam
end

