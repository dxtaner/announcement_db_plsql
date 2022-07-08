--Duyuru Otomasyonu

--Tablolar

create table tur(
turno int not null,
turadi varchar(20),
constraint pkkey1 primary key(turno)
)

create table duyurusayisi(
sayi_id int not null,
adet int,
constraint pkkey2 primary key(sayi_id))

create table duyurutarihi(
tarih_id int not null,
tarih date,
turno int,
constraint pkkey3 primary key (tarih_id),
constraint fkkey1 foreign key(turno) references tur(turno))

create table istatistik(
is_id int not null,
toplam_bakan_sayisi int,
bugun_bakan_sayisi int,
sayi_id int,
constraint pkkey4 primary key (is_id),
constraint fkkey2 foreign key(sayi_id) references duyurusayisi(sayi_id))

create table birim(
birimno int not null,
baskan_ad varchar(15),
baskan_soyad varchar(15),
baskan_yas int,
kisi_sayisi int,
constraint pkkey5 primary key (birimno))

create table duyurubilgi(
bilgi_id int not null,
aciklama varchar(25),
constraint pkkey6 primary key (bilgi_id))

create table yapanbirim(
yapanbirim_id int not null,
birim_ad varchar(25),
bilgi_id int,
birimno int,
is_id int,
tarih_id int,
constraint pkkey7 primary key (yapanbirim_id),
constraint fkkey3 foreign key(bilgi_id) references duyurubilgi(bilgi_id),
constraint fkkey4 foreign key(birimno) references birim(birimno),
constraint fkkey5 foreign key(is_id) references istatistik(is_id),
constraint fkkey6 foreign key(tarih_id) references duyurutarihi(tarih_id))

--Ekleme işlemleri

insert into tur values(1,'önemli')
insert into tur values(2,'yeni')
insert into tur values(3,'arsiv')

select * from tur 

insert into duyurusayisi values(1,2)
insert into duyurusayisi values(2,5)
insert into duyurusayisi values(3,10)

select * from duyurusayisi 

insert into duyurutarihi values(1,sysdate,1)
insert into duyurutarihi values(2,sysdate,2)
insert into duyurutarihi values(3,sysdate,3)

select * from duyurutarihi

insert into istatistik values(1,150,15,1)
insert into istatistik values(2,250,155,2)
insert into istatistik values(3,750,3,3)

select * from istatistik

insert into birim values(1,'hasan','yıldız',35,13)
insert into birim values(2,'semih','soy',45,23)
insert into birim values(3,'zehra','yılmaz',25,5)

select * from birim

insert into duyurubilgi values(1,'1 nolu birim')
insert into duyurubilgi values(2,'2 nolu birim')
insert into duyurubilgi values(3,'3 nolu birim')

select * from duyurubilgi

insert into yapanbirim values(100,'trafik',1,1,1,1)
insert into yapanbirim values(200,'egitim',2,2,2,2)
insert into yapanbirim values(300,'havadurumu',3,3,3,3)

select * from yapanbirim


--Join sorgu işlemleri

--1-)Duyuru adet sayısı 3’ten büyük olan duyurun adetini ve birim başkan adını ve başkan soyadını yazdıran sql sorgu
 
select baskan_ad,baskan_soyad,adet from birim 
       join yapanbirim on birim.birimno=yapanbirim.birimno
       join istatistik on istatistik.is_id=yapanbirim.is_id
       join duyurusayisi on duyurusayisi.sayi_id=istatistik.sayi_id
       where duyurusayisi.adet>3





--2-)Bugün bakılmış olan ve toplam bakan sayısı 100’den fazla olan birimin adını, tur adını ve toplam bakan sayısını getiren sql sorgu

select birim_ad,turadi,toplam_bakan_sayisi from yapanbirim
       join istatistik on istatistik.is_id=yapanbirim.is_id
       join duyurutarihi on duyurutarihi.tarih_id=yapanbirim.tarih_id
       join tur on tur.turno=duyurutarihi.turno     
       where istatistik.bugun_bakan_sayisi>0 and istatistik.toplam_bakan_sayisi>100

--Procedure

--1-)Birim adını ve birim başkanlarını tabloya yazan procedure

create table birimbaskanlari(
birimad varchar(20),
birimbaskanad varchar(20)) 
-- birimbaskanlari tablosunu olusturdum

create or replace procedure birimbaskanlarim as
  cursor bilgim is select birim_ad,baskan_ad from birim
           join yapanbirim on birim.birimno=yapanbirim.birimno;
           begin
               for cursor1 in bilgim loop
               insert into birimbaskanlari values(cursor1.birim_ad,cursor1.baskan_ad);
               end loop;
end birimbaskanlarim;

begin 
birimbaskanlarim(); -- procedure calismasi
end;

select * from birimbaskanlari -- test 

--2-) tur adı girilmeyen duyuruya turadi olarak ‘yeni’ adını ekleme yapan procedure 

create or replace procedure turadiekle
as
begin
update tur set turadi='yeni'
where turadi is null;
commit;
end; 

insert into tur values(7,null) --ekleme 
insert into tur values(8,null) --ekleme 

select * from tur --test oncesi

begin
turadiekle(); --test procedure
end;

select * from tur --test

--Fonksiyon

--1-)Birim id’si verilen birimin adını bulan fonksiyon

create or replace function birimbul(birimid in int)
return varchar is
birimad varchar(25);
Begin 
select birim_ad into birimad from yapanbirim a where a.yapanbirim_id=birimid;
Return(birimad);
Exception
when no_data_found then
Return 'böyle bir birim yok';
End;

select birimbul(100) from dual; -- test fonksiyonu

--2-) Duyuru bilgi id’si verilen duyurun bilgilerini tablo şeklinde getiren fonksiyon

create or replace type bilgilerimtype as object
(
bilgino int,
aciklama varchar(25),
birimadi varchar(15),
birimbaskani varchar(15),
turadi varchar(15),
duyuruadeti int,
tarih date
);
--bilgilerimtype adında yapı olusturdum 

create or replace type bilgilerimigetirtype as table of bilgilerimtype
–-yapıyı tablo şeklinde dizayn ettim


create or replace function bilgilerim(duyurubilgi_id in int)
return bilgilerimigetirtype
is sonuc bilgilerimigetirtype:=new bilgilerimigetirtype();
begin
  for j in (select * from duyurubilgi b
       join yapanbirim on yapanbirim.bilgi_id=b.bilgi_id
       join birim on birim.birimno=yapanbirim.birimno
       join duyurutarihi on duyurutarihi.tarih_id=yapanbirim.tarih_id
       join tur on tur.turno=duyurutarihi.turno
       join istatistik on istatistik.is_id=yapanbirim.is_id
       join duyurusayisi on duyurusayisi.sayi_id=istatistik.sayi_id
       where b.bilgi_id=duyurubilgi_id)
    loop
      sonuc.extend;
      sonuc(sonuc.count):=new bilgilerimtype(duyurubilgi_id,j.aciklama,j.birim_ad,j.baskan_ad,j.turadi,j.adet,j.tarih);
    end loop;
    return sonuc;
end;

select * from table(bilgilerim(2)); -- test function bilgilerim

--Trigger

--1-) Yeni eklenen duyurubilgi tablosu değerlerini tabloya aktaran tetikleme

-- yeni eklenen duyurulari tabloya kaydetme
create table yenitablo(
bilgiid int,
aciklama varchar(20))

-- trigger olusumu
CREATE OR REPLACE trigger yeniduyuruekle
BEFORE INSERT ON  duyurubilgi
for each row
BEGIN
    INSERT INTO yenitablo(:new.bilgi_id,:new.aciklama);
END;

insert into duyurubilgi values(25,'25 nolu birim'); --test 

select * from yenitablo -- test 

--2-)  duyurutarihi tablosuna eklenen tarih değerini yeniden düzenleyen tetikleme

CREATE OR REPLACE TRIGGER tarih_atama
BEFORE INSERT ON duyurutarihi
FOR EACH ROW
DECLARE
BEGIN
:new.tarih:=SYSDATE;
END;

-- ekleme yapiyorum
insert into duyurutarihi(tarih_id,turno) values (5,1)
-- tarih girilmedi fakat trigger otomatik olrak tarih degerini atadi. 
-- trigger her zaman bu degeri atayacaktir.
 
--Raise appplcation error

-- duyuru no’su girilen id’nin kaç adet duyuru olduğunu yazdıran sql  

Declare
sayiid int:=&degeri_al;
bilgi duyurusayisi%rowtype;
begin
select * into bilgi from duyurusayisi where sayi_id=sayiid;
dbms_output.put_line(bilgi.sayi_id||'-'||bilgi.adet);
Exception
when No_data_found then
   raise_application_error(-20411,' böyle bir duyuru adeti
kaydı yoktur..!');
end;

--Exception

-- baglı tablo hatasi 
-- duyurutarihi id si verilen bilgiyi silme 

declare
tablohatasi exception;
Pragma exception_init(tablohatasi,-2292);
begin
delete duyurutarihi where tarih_id=1; 
Exception 
when tablohatasi then
     dbms_output.put_line('tablolar birlesik alt tablolari silmeniz lazim');
end;
—tablomuz digger tablolarla baglantili oldugu icin silinmiyor


--Job

--Job yapimi new job diyerek oluşturdum. What yerine:
begin
birimbaskanlarim();
turadiekle();
end;
yazdım. Interval yerine:
TRUNC(SYSDATE+1) +(1/24)
yazip apply dedim. Sonuçta asağidaki yapim oluştu :

begin
  sys.dbms_job.change(job => 2,
                      what => 'begin
birimbaskanlarim();
turadiekle();
end;',
                      next_date => to_date('11-06-2020 20:30:03', 'dd-mm-yyyy hh24:mi:ss'),
                      interval => 'TRUNC(SYSDATE+1) +(1/24)');
  commit;
end;
-- birimbaskanlarim() ve turadiekle()
 her 24 saate bir procedure calistiriliyor

--Package

--package ismim
create or replace package paketim
as 
procedure tbsdegis;
function duyuruaciklamasibul(bilgino in int) return varchar;
end;

--paket body’si
create or replace package body paketim
as
procedure tbsdegis as
begin
update istatistik set toplam_bakan_sayisi=50
where toplam_bakan_sayisi is null;
commit;
end;

--procedure yapim toplam_bakan_sayisi girisi yapilmamis olan istatistik tablosuna deger olarak 50 degerini atiyor

function duyuruaciklamasibul ( bilgino in int )
return varchar is
bilgi varchar(25);
Begin
Select aciklama into bilgi from duyurubilgi d where d.bilgi_id=bilgino;
Return (bilgi);
Exception
when no_data_found then
Return 'böyle bir duyuru yok';
End;
end;

–-fonksiyon yapim girilen bilgino degerine göre duyuru aciklamasini buluyor 

select paketim.duyuruaciklamasibul(3) from dual; -- test package 
