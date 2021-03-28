drop table pavilon cascade constraints;
drop table pozice cascade constraints;
drop table zivocisny_druh cascade constraints;
drop table jedinec cascade constraints;
drop table mereni cascade constraints;
drop table osoba cascade constraints;
drop table zamestnanec cascade constraints;
drop table navstevnik cascade constraints;
drop table kvalifikace cascade constraints;
drop table zamestnanec_kvalifikace cascade constraints;
drop table osetrovatel_jedinec cascade constraints;
drop table osetrovatel_mereni cascade constraints;
drop table udrzbar_pozice cascade constraints;

create table pavilon (
    id varchar(10) primary key,
    druh varchar(40)
);

create table pozice (
    id varchar(20) primary key,
    prostredi varchar(30),
    datum_udrzby date,
    typ varchar(30),
    --
    -- specification | vybeh:
    plocha numeric(7, 2) default null,
    --
    -- specification | klec:
    objem numeric(7, 2) default null,
    pavilon varchar(10) default null,
    foreign key (pavilon)
        references pavilon (id)
        on delete cascade
);

create table zivocisny_druh (
    nazev varchar(100) primary key,
    charakteristika varchar(1024)
);

create table jedinec (
    id varchar(20) primary key,
    jmeno varchar(30),
    datum_narozeni date not null,
    datum_umrti date default null,
    zastupce_druhu varchar(30) not null,
    foreign key (zastupce_druhu)
        references zivocisny_druh (nazev)
        on delete cascade, -- on update cascade
    pozice varchar(20) default null, -- animal 'jedinec' is on position 'pozice'
    foreign key (pozice)
        references pozice (id)
);

create table mereni (
  id number(5) generated by default on null as identity primary key,
  id_jedince varchar(20) not null
      references jedinec (id)
      on delete cascade,
  datum_mereni date,
  zdravotni_stav varchar(1024),
  hmotnost numeric(7, 2),
  vyska numeric(7, 2)
);

create table osoba (
    rodne_cislo int(10) primary key --TODO typ
    jmeno varchar(127)
    adresa varchar(127)
    email varchar(127)
);

create table zamestnanec (
    rodne_cislo int(10) primary key
    cislo_uctu varchar(63)
    telefon varchar(16)
    datum_nastupu date
    plat money
    nadrizeny int(10) default null
    typ varchar(15) not null check (typ in('spravce', 'osetrovatel', 'udrzbar'))
    foreign key (nadrizeny) references zamestnanec (id) default null -- nadrizeny
    foreign key (id) references osoba (id) on delete cascade
);

create table navstevnik (
    rodne_cislo int(10) primary key
    zustatek money
    platnost date
    pocet_nastev int(4)
    foreign key (id) references osoba (id) on delete cascade
);

create table kvalifikace (
    kod_kvalifikace varchar(15) primary key
);

create table zamestnanec_kvalifikace (
    zamestnanec_id int
    kvalifikace_id int
    foreign key (zamestnanec_id) references zamestnanec (id)
    foreign key (kvalifikace_id) references kvalifikace (kod_kvalifikace)
    unique (zamestnanec_id, kvalifikace_id)
);

create table osetrovatel_jedinec (
    osetrovatel_id int
    jedinec_id varchar(20)
    foreign key (osetrovatel_id) references zamestnanec (id)
    foreign key (jedinec_id) references jedinec (id)
    unique (osetrovatel_id, jedinec_id)
);

create table osetrovatel_mereni (
    osetrovatel_id int
    mereni_id number(5)
    foreign key (osetrovatel_id) references zamestnanec (id)
    foreign key (mereni_id) references mereni (id)
    unique (osetrovatel_id, mereni_id)
);

create table udrzbar_pozice (
    udrzbar_id int
    pozice_id varchar(20)
    foreign key (udrzbar_id) references zamestnanec (id)
    foreign key (pozice_id) references pozice (id)
    unique (udrzbar_id, pozice_id)
);

-- insert 'pavilon' records
insert into pavilon values ('PL102B', 'plazi');
insert into pavilon values ('PT012A', 'ptácí');
insert into pavilon values ('RY100G', 'ryby');
insert into pavilon values ('TR058R', 'tropický');
insert into pavilon values ('KO174H', 'kočky');

-- insert 'pozice' records
insert into pozice values ('KPT001M', 'Madagaskar', DATE '2005-05-10', 'klec', null, 50, 'PT012A');
insert into pozice values ('KKO402D', 'Asie', DATE '2010-04-26', 'klec', null, 30, 'KO174H');
insert into pozice values ('KTR123B', 'Brazílie', DATE '2002-05-30', 'klec', null, 25, 'TR058R');
insert into pozice values ('VLV075S', 'savana', DATE '2017-10-08', 'vybeh', 460, null, null);
insert into pozice values ('VME743A', 'arktický', DATE '2021-04-15', 'vybeh', 320, null, null);

-- insert 'zivocisny_druh' records
insert into zivocisny_druh values ('lev pustinný', 'Lev je po tygrovi druhá největší kočkovitá šelma. U lvů se projevuje výrazný pohlavní dimorfismus, hlavním a určujícím rysem lvích samců je jejich hříva. Samci váží 150–250 kg a samice 90–165 kg. V divočině se lvi dožívají 10–14 let, kdežto v zajetí se mohou dožít i věku 20 let. Dříve se lvi vyskytovali v celé Africe, ve velké části Asie, v Evropě a dokonce i v Americe, dnes se vyskytují pouze v Africe a v nevelké části Indie. Jsou to společenská zvířata a loví ve smečkách. Jejich nejčastější kořistí jsou velcí savci, především kopytníci. Mezinárodní svaz ochrany přírody hodnotí lva jako zranitelný druh.');
insert into zivocisny_druh values ('levhart skvrnitý', 'Levhart je statná kočkovitá šelma s velkou hlavou, středně dlouhými končetinami a dlouhým ocasem. Velmi se podobá jaguárovi, který je však robustnější, má relativně kratší ocas a větší rozety. Hmotnost dospělých jedinců se pohybuje od 17 kg do 90 kg, délka těla včetně ocasu od 140 cm do 240 cm, výjimečně i více.');
insert into zivocisny_druh values ('tygr ussurijský', 'Tygr je velká kočkovitá šelma žijící v Asii. Ze současných kočkovitých šelem je největší a díky charakteristickým tmavým pruhům na zlatožluté či rudohnědé srsti nezaměnitelný. Dříve byl druh rozdělován do 9 poddruhů, v současné době jsou rozeznávány pouze 2 poddruhy. Někteří tygři běžně dosahují délky trupu přes 2 m, délka ocasu bývá až 90 cm a váha samců mnohdy více než 200 kg; samice jsou výrazně menší, dosahují váhy maximálně kolem 130 kg.');

insert into zivocisny_druh values ('holub skalní', 'Středně velký pták s kratším ocasem, velký jako domácí holub, délka těla 31-35 cm. V původním divokém zbarvení je šedý s lesklou fialovou hrudí a lesklým zeleným krkem a s výraznými černými pruhy na křídlech. Ocas je modrošedý se širokým načernalým lemem na konci, kostřec je bílý, zobák je matně šedý s bělavým ozobím. Mezi samcem a samicí nejsou výrazné rozdíly ve vzhledu ani ve velikosti. Mláďata jsou více hnědá, prachový šat je smetanově žlutý.');
insert into zivocisny_druh values ('plameňák růžový', 'Mají dvě dlouhé růžové nohy, které mají mezi krátkými prsty plovací blány. Tělo je růžovobílé, s nohama průměrně 120 – 140 cm vysoké a dosahuje hmotnosti 2100-4100 g. Dlouhý krk a hlava jsou čistě růžové, mnohdy i dočervena. Je dokázáno, že mají oko větší než mozek. Mají také dlouhá, výrazně zbarvená křídla, která dosahují rozpětí 140-170 cm. Obě pohlaví se od sebe liší pouze velikostí, samec je v průměru o cca 1/5 větší. Jejich zvláštně vyvinutý a tvarovaný zobák jim umožňuje vyhledávat a filtrovat potravu z mělké vody. Zobák přitom drží tak, aby byl horizontálně ponořen do vody. Proud vody protéká zobákem a plameňák tiskne svůj masitý jazyk na vláknité lamely, jež zachytí částečky potravy, kterou se stává jak živočišný, tak rostlinný plankton; přijmutá voda poté odteče po stranách zobáku ven.');
insert into zivocisny_druh values ('perlička kropenatá', 'Dorůstá 53–63 cm a váží průměrně 1,3 kg. Má zavalité tělo, nápadně malou, neopeřenou hlavu s přilbicí, krátký ocas a krátká zakulacená křídla. Opeření je černé, bíle skvrnité, hlava a strany krku jsou modré, přilbice žlutohnědá a zobák červený se žlutým koncem.
Výzkum mechaniky pohybu tohoto ptáka a vlivu jeho chůze na substrát ukázal, že podobným způsobem se v období druhohor pohybovali také teropodní dinosauři.');

insert into zivocisny_druh values ('vlk arktický', 'Vlk arktický je poddruh vlka obecného, který žije na kanadském severu, především na Ostrovech královny Alžběty, kde teplota klesá až pod -50 °C. Délka těla samce je 90−150 cm, samice 90−120 cm, váží od 40 do 60 kg. Druh je pohlavně dimorfní, samec je výrazně větší a těžší nežli samice.');

-- insert 'jedinec' records
insert into jedinec values ('VLAR0001', 'Felix', DATE '2017-03-14', null, 'vlk arktický', 'VME743A');
insert into jedinec values ('VLAR0002', 'Tara', DATE '2018-07-26', null, 'vlk arktický', 'VME743A');

insert into jedinec values ('PLRU0003', 'Noam', DATE '2019-10-13', DATE '2021-03-28', 'plameňák růžový', null);
insert into jedinec values ('PLRU0004', 'Josef', DATE '2019-10-13', null, 'plameňák růžový', 'KPT001M');

insert into jedinec values ('TYUS0050', 'David', DATE '2016-06-29', null, 'tygr ussurijský', 'KKO402D');
insert into jedinec values ('LEPU0458', 'Martina', DATE '2018-04-19', null, 'lev pustinný', 'VLV075S');

insert into jedinec values ('HOSK1043', 'Petroslav', DATE '2019-05-24', DATE '2019-12-25', 'holub skalní', null);
insert into jedinec values ('HOSK1380', 'Petra', DATE '2020-08-14', null, 'holub skalní', 'KTR123B');
insert into jedinec values ('HOSK1489', 'Petr', DATE '2020-09-04', null, 'holub skalní', 'KTR123B');


-- insert 'mereni' records
insert into mereni values (null, 'VLAR0001', DATE '2019-12-30', 'vše v pořádku', 50.84, 1.20);
insert into mereni values (null, 'VLAR0001', DATE '2020-04-12', 'línající srst', 49.42, 1.25);
insert into mereni values (null, 'VLAR0001', DATE '2019-12-30', 'línající srst, poškozené oko', 47.30, 1.30);

insert into mereni values (null, 'HOSK1489', DATE '2021-01-01', 'vše v pořádku', 0.32, 0.16);
insert into mereni values (null, 'HOSK1489', DATE '2021-03-01', 'vše v pořádku', 0.35, 0.19);

insert into mereni values (null, 'HOSK1043', DATE '2019-06-30', 'vše v pořádku', 0.30, 1.20);
insert into mereni values (null, 'HOSK1043', DATE '2019-08-12', 'nechuť k jídlu', 0.22, 1.19);
insert into mereni values (null, 'HOSK1043', DATE '2019-11-30', 'nechuť k jídlu, špatné trávení', 0.20, 1.20);

-- insert 'zamestnanec' records
insert into osoba values (9910244245, 'David Mihola', 'Brno, 635 00', 'xmihol00@stud.fit.vutbr.cz');
insert into zamestnanec values (9910244245, '8521473667/0800', '+420774826266', DATE '2018-07-21', 42000, null, 'spravce');
insert into osoba values (8611067135, 'Marie Holá', 'Praha 1', 'holm@seznam.cz');
insert into zamestnanec values (8611067135, '4632598711/0400', '+420888555222', DATE '2020-02-04', 26263, 9106077256, 'osetrovatel');
insert into osoba values (9502233628, 'Jakub Beran', 'Znojmo 965 33', 'beran.jakub@google.cz');
insert into zamestnanec values (9502233628, '9962473356/0600', '+420965243312', DATE '2019-09-26', 32850, 9910244245, 'udrzbar');
insert into osoba values (9106077256, 'Vlasta Lajdová', 'Zlín, 168 36', 'vlajdova@volny.cz');
insert into zamestnanec values (9106077256, '2274668512/0800', '+420776225841', DATE '2017-11-03', 34009, 9910244245, 'osetrovatel');
insert into osoba values (7603242237, 'Pavel Okurka', 'Pardubice, 336 26', 'okurka@seznam.cz');
insert into zamestnanec values (7603242237, '7726984413/0900', '+420603215547', DATE '2016-07-21', 23986, 9910244245, 'udrzbar');

-- insert 'navstevnik' records
insert into osoba values (7911155214, 'Petr Ponožka', 'Liberec, 264 02', 'p.p@centrum.cz');
insert into navstevnik values (7911155214, 863, DATE '2021-09-13', 13);
insert into osoba values (5601308565, 'Libuše Baledová', 'Ostrava, 523 41', 'ba.li@google.cz');
insert into navstevnik values (5601308565, 65, DATE '2021-04-26', 8);
insert into osoba values (0112056772, 'Barbora Hranolová', 'Kladno, 746 82', 'ba.li@google.cz');
insert into navstevnik values (0112056772, 1366, DATE '2021-10-02', 16);

-- insert 'kvalifikace' records
insert into kvalifikace values ('OPRAVNENI_1');
insert into kvalifikace values ('OSETROVATEL_1');
insert into kvalifikace values ('OSETROVATEL_2');
insert into kvalifikace values ('OSETROVATEL_3');
insert into kvalifikace values ('UDRZBAR_1');
insert into kvalifikace values ('UDRZBAR_2');
insert into kvalifikace values ('UDRZBAR_3');

-- insert 'zamestnanec_kvalifikace' records
insert into zamestnanec_kvalifikace values (9910244245, 'OPRAVNENI_1');
insert into zamestnanec_kvalifikace values (8611067135, 'UDRZBAR_1');
insert into zamestnanec_kvalifikace values (8611067135, 'UDRZBAR_3');
insert into zamestnanec_kvalifikace values (9502233628, 'OSETROVATEL_1');
insert into zamestnanec_kvalifikace values (9502233628, 'OSETROVATEL_2');
insert into zamestnanec_kvalifikace values (9502233628, 'OSETROVATEL_3');

-- insert 'osetrovatel_jedinec' records
insert into osetrovatel_jedinec values (9502233628, 'VLAR0001');
insert into osetrovatel_jedinec values (9502233628, 'TYUS0050');
insert into osetrovatel_jedinec values (9502233628, 'LEPU0458');
insert into osetrovatel_jedinec values (9502233628, 'HOSK1043');
insert into osetrovatel_jedinec values (9106077256, 'VLAR0002');
insert into osetrovatel_jedinec values (9106077256, 'PLRU0003');
insert into osetrovatel_jedinec values (9106077256, 'PLRU0004');
insert into osetrovatel_jedinec values (9106077256, 'HOSK1489');

-- insert 'osetrovatel_mereni' records
insert into osetrovatel_mereni values (9502233628, null) --TODO

-- insert 'udrzbar_pozice' records
insert into udrzbar_pozice values (8611067135, 'KKO402D');
insert into udrzbar_pozice values (8611067135, 'VME743A');
insert into udrzbar_pozice values (7603242237, 'VLV075S');
insert into udrzbar_pozice values (7603242237, 'KPT001M');
insert into udrzbar_pozice values (7603242237, 'KTR123B');
