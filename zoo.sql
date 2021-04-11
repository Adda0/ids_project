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
    typ varchar(30) not null,
    constraint typ_list check ( typ in ('výběh', 'klec', 'terárium', 'akvárium')),
    --
    -- specification | výběh:
    plocha numeric(7, 2) default null,
    --
    -- specification | klec, terárium, akvárium:
    objem numeric(7, 2) default null,
    pavilon varchar(10) default null,
    foreign key (pavilon)
        references pavilon (id)
        on delete cascade,
    -- check 'výběh' XOR ('klec' OR 'terárium' OR 'akvárium')
    constraint typ_unique check ((typ='výběh' and plocha is not null and objem is null and pavilon is null) or
        (typ<>'výběh' and objem is not null and plocha is null))
);

create table zivocisny_druh (
    nazev varchar(100) primary key,
    charakteristika varchar(1024)
);

create table jedinec (
    id varchar(20) primary key,
    jmeno varchar(30) default null,
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
  id_jedince varchar(20)
      references jedinec (id)
      on delete cascade,
  id int generated by default on null as identity,
  constraint mereni_pk primary key (id_jedince, id),
  datum_mereni date not null,
  zdravotni_stav varchar(1024) not null,
  hmotnost numeric(7, 2) not null,
  vyska numeric(7, 2) not null
);

create table osoba (
    id int primary key,
    jmeno varchar(127),
    adresa varchar(127),
    email varchar(127)
);

create table zamestnanec (
    id int primary key,
    cislo_uctu varchar(20),
    constraint check_cislo_uctu check (regexp_like (cislo_uctu, '^(([0-9]{0,6})-)?([0-9]{2,10})\/([0-9]{4})$')),
    telefon varchar(16),
    datum_nastupu date,
    plat numeric(8, 2) default 0,
    nadrizeny int default 0,
    typ varchar(15) not null,
    constraint zamestnanec_typ check (typ in('spravce', 'osetrovatel', 'udrzbar')),
    foreign key (nadrizeny) references zamestnanec (id),
    foreign key (id) references osoba (id) on delete cascade
);

create table navstevnik (
    id int primary key,
    zustatek numeric(8, 2) default 0,
    platnost date,
    pocet_nastev int,
    foreign key (id) references osoba (id) on delete cascade
);

create table kvalifikace (
    kod_kvalifikace varchar(15) primary key
);

create table zamestnanec_kvalifikace (
    zamestnanec_id int,
    kvalifikace_id varchar(15),
    foreign key (zamestnanec_id) references zamestnanec (id),
    foreign key (kvalifikace_id) references kvalifikace (kod_kvalifikace),
    constraint pk_zamestnanec_kvalifikace primary key (zamestnanec_id, kvalifikace_id)
);

create table osetrovatel_jedinec (
    osetrovatel_id int,
    jedinec_id varchar(20),
    foreign key (osetrovatel_id) references zamestnanec (id),
    foreign key (jedinec_id) references jedinec (id),
    constraint pk_osetrovatel_jednice primary key (osetrovatel_id, jedinec_id)
);

create table osetrovatel_mereni (
    osetrovatel_id int,
    jedinec_id varchar(20),
    mereni_id int,
    foreign key (osetrovatel_id) references zamestnanec (id),
    foreign key (jedinec_id, mereni_id) references mereni (id_jedince, id),
    constraint pk_osetrovatel_mereni primary key (osetrovatel_id, jedinec_id, mereni_id)
);

create table udrzbar_pozice (
    udrzbar_id int,
    pozice_id varchar(20),
    foreign key (udrzbar_id) references zamestnanec (id),
    foreign key (pozice_id) references pozice (id),
    constraint pk_udrzbar_pozice primary key (udrzbar_id, pozice_id)
);

-- insert 'pavilon' records
insert into pavilon values ('PL102B', 'plazi');
insert into pavilon values ('PT012A', 'ptácí');
insert into pavilon values ('RY100G', 'ryby');
insert into pavilon values ('TR058R', 'tropický');
insert into pavilon values ('KO174H', 'kočky');

-- insert 'pozice' records
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('KPT001M', 'Madagaskar', DATE '2005-05-10', 'klec', 50, 'PT012A');
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('ARY141R', 'Amazonka', DATE '2023-09-24', 'akvárium', 10, 'RY100G');
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('TPL666E', 'Amazonka', DATE '2007-05-14', 'terárium', 4, 'PL102B');
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('Ann006K', 'Oceán', DATE '2007-05-14', 'akvárium', 6, 'RY100G');
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('KPT026N', 'Oceán', DATE '2007-05-14', 'klec', 12, null);
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('KKO402D', 'Asie', DATE '2010-04-26', 'klec', 30, 'KO174H');
insert into pozice (id, prostredi, datum_udrzby, typ, objem, pavilon)
    values ('KTR123B', 'Brazílie', DATE '2002-05-30', 'klec', 25, 'TR058R');
insert into pozice (id, prostredi, datum_udrzby, typ, plocha)
    values ('VLV075S', 'savana', DATE '2017-10-08', 'výběh', 460);
insert into pozice (id, prostredi, datum_udrzby, typ, plocha)
    values ('VME743A', 'arktický', DATE '2021-04-15', 'výběh', 320);
insert into pozice (id, prostredi, datum_udrzby, typ, plocha)
    values ('aVME743A', 'arktický', DATE '2021-04-15', 'výběh', 320);

-- insert 'zivocisny_druh' records
insert into zivocisny_druh values ('lev pustinný', 'Lev je po tygrovi druhá největší kočkovitá šelma. U lvů se projevuje výrazný pohlavní dimorfismus, hlavním a určujícím rysem lvích samců je jejich hříva. Samci váží 150–250 kg a samice 90–165 kg. V divočině se lvi dožívají 10–14 let, kdežto v zajetí se mohou dožít i věku 20 let. Dříve se lvi vyskytovali v celé Africe, ve velké části Asie, v Evropě a dokonce i v Americe, dnes se vyskytují pouze v Africe a v nevelké části Indie. Jsou to společenská zvířata a loví ve smečkách. Jejich nejčastější kořistí jsou velcí savci, především kopytníci. Mezinárodní svaz ochrany přírody hodnotí lva jako zranitelný druh.');
insert into zivocisny_druh values ('levhart skvrnitý', 'Levhart je statná kočkovitá šelma s velkou hlavou, středně dlouhými končetinami a dlouhým ocasem. Velmi se podobá jaguárovi, který je však robustnější, má relativně kratší ocas a větší rozety. Hmotnost dospělých jedinců se pohybuje od 17 kg do 90 kg, délka těla včetně ocasu od 140 cm do 240 cm, výjimečně i více.');
insert into zivocisny_druh values ('tygr ussurijský', 'Tygr je velká kočkovitá šelma žijící v Asii. Ze současných kočkovitých šelem je největší a díky charakteristickým tmavým pruhům na zlatožluté či rudohnědé srsti nezaměnitelný. Dříve byl druh rozdělován do 9 poddruhů, v současné době jsou rozeznávány pouze 2 poddruhy. Někteří tygři běžně dosahují délky trupu přes 2 m, délka ocasu bývá až 90 cm a váha samců mnohdy více než 200 kg; samice jsou výrazně menší, dosahují váhy maximálně kolem 130 kg.');

insert into zivocisny_druh values ('holub skalní', 'Středně velký pták s kratším ocasem, velký jako domácí holub, délka těla 31-35 cm. V původním divokém zbarvení je šedý s lesklou fialovou hrudí a lesklým zeleným krkem a s výraznými černými pruhy na křídlech. Ocas je modrošedý se širokým načernalým lemem na konci, kostřec je bílý, zobák je matně šedý s bělavým ozobím. Mezi samcem a samicí nejsou výrazné rozdíly ve vzhledu ani ve velikosti. Mláďata jsou více hnědá, prachový šat je smetanově žlutý.');
insert into zivocisny_druh values ('plameňák růžový', 'Mají dvě dlouhé růžové nohy, které mají mezi krátkými prsty plovací blány. Tělo je růžovobílé, s nohama průměrně 120 – 140 cm vysoké a dosahuje hmotnosti 2100-4100 g. Dlouhý krk a hlava jsou čistě růžové, mnohdy i dočervena. Je dokázáno, že mají oko větší než mozek. Mají také dlouhá, výrazně zbarvená křídla, která dosahují rozpětí 140-170 cm. Obě pohlaví se od sebe liší pouze velikostí, samec je v průměru o cca 1/5 větší. Jejich zvláštně vyvinutý a tvarovaný zobák jim umožňuje vyhledávat a filtrovat potravu z mělké vody. Zobák přitom drží tak, aby byl horizontálně ponořen do vody. Proud vody protéká zobákem a plameňák tiskne svůj masitý jazyk na vláknité lamely, jež zachytí částečky potravy, kterou se stává jak živočišný, tak rostlinný plankton; přijmutá voda poté odteče po stranách zobáku ven.');
insert into zivocisny_druh values ('perlička kropenatá', 'Dorůstá 53–63 cm a váží průměrně 1,3 kg. Má zavalité tělo, nápadně malou, neopeřenou hlavu s přilbicí, krátký ocas a krátká zakulacená křídla. Opeření je černé, bíle skvrnité, hlava a strany krku jsou modré, přilbice žlutohnědá a zobák červený se žlutým koncem.
Výzkum mechaniky pohybu tohoto ptáka a vlivu jeho chůze na substrát ukázal, že podobným způsobem se v období druhohor pohybovali také teropodní dinosauři.');

insert into zivocisny_druh values ('vlk arktický', 'Vlk arktický je poddruh vlka obecného, který žije na kanadském severu, především na Ostrovech královny Alžběty, kde teplota klesá až pod -50 °C. Délka těla samce je 90−150 cm, samice 90−120 cm, váží od 40 do 60 kg. Druh je pohlavně dimorfní, samec je výrazně větší a těžší nežli samice.');

insert into zivocisny_druh values ('rejnok ostnatý', 'Hřbetní strana je hnědošedá v různých odstínech, s tmavými skvrnami a světlými tečkami. Břišní strana těla je světle šedá. Hrudní ploutve se táhnou od rypce po obou stranách těla až k ocasu. Samičky i samci mají na hřbetě trny. Žije na dně moří s lehce písčitým až bahnitým dnem od 20 metrů hloubky. Lze se s nimi setkat na mělčinách a v ústí řek. ');
insert into zivocisny_druh values ('máčka skvrnitá', 'Je malý druh žraloka z čeledi máčkovitých vyskytující se na Zemi od mezozoika, který je rozšířen v severovýchodním Atlantiku včetně Středozemního moře, kde je občas pozorován rekreačními potápěči. Jedná se o druh žraloka, který není člověku nikterak nebezpečný. Živí se drobnými mořskými živočichy, které loví převážně v noci u mořského dna.');

insert into zivocisny_druh values ('ara arakanga', 'Je pestře zbarvený papoušek z rodu Ara. Ve volné přírodě žije v Mexiku, Střední Americe a na severu Jižní Ameriky po Brazílii. Jeho přirozeným biotopem jsou tropické deštné lesy, savany a plantáže.');
insert into zivocisny_druh values ('albatros stěhovavý', 'Je velký mořský pták z čeledi albatrosovití. Vyskytuje se na všech oceánech jižní polokoule. Albatros stěhovavý má poměrně velkou hlavu a dlouhý silný zobák. Tento druh má největší rozpětí křídel ze všech současných ptáků, v průměru kolem 3,1 m. Největší ověřené rozpětí křídel přitom činí 3,63 m. Větším rozpětím křídel disponovali pouze někteří vyhynulí ptáci, jako byl argentinský miocénní druh Argentavis magnificens, jehož rozpětí činilo až přes 6 metrů a hmotnost přes 70 kilogramů. Díky svým obrovským křídlům může albatros stěhovavý trávit dlouhé hodiny ve vzduchu. Při plachtění bez mávání křídel využívá klouzavosti až 27. Za den může nalétat až tisíc kilometrů.');

insert into zivocisny_druh values ('anakonda velká', 'je velký had z čeledi hroznýšovitých. Žije v tropických a subtropických oblastech Jižní Ameriky. Je přizpůsobena dlouhodobému pobytu ve vodním prostředí. Dosahuje nejčastěji délky 2,5 až 5 metrů, obzvláště velcí jedinci měří 5 až 6 metrů, přičemž se předpokládá, že ve výjimečných případech a za vhodných podmínek může dorůst až k 7 metrům. Zprávy o devítimetrových, desetimetrových či dokonce ještě delších jedincích nejsou považovány za věrohodné. Jelikož je robustně stavěná, jedná se o nejtěžšího hada světa, dosahuje hmotnosti i více než 100 kg. Ačkoliv je anakonda velmi populární jak mezi herpetology tak i laiky, o jejím životě se ví relativně málo informací. Živí se rozličnými živočichy až do velikosti kajmana či dospělé kapybary, které zabíjí udušením ve smyčkách svého těla.');

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

insert into jedinec values ('REOS044', 'Mak', DATE '2018-09-01', DATE '2020-10-17', 'rejnok ostnatý', null);
insert into jedinec values ('REOS045', 'Boko', DATE '2018-09-04', null, 'rejnok ostnatý', 'Ann006K');

insert into jedinec values ('MASK002', 'Macko', DATE '2019-06-30', null, 'máčka skvrnitá', 'Ann006K');

insert into jedinec values ('ARAR001', 'Petr', DATE '2020-06-15', null, 'ara arakanga', 'KTR123B');
insert into jedinec values ('ALST421', 'Petr', DATE '2019-07-24', null, 'albatros stěhovavý', 'KPT026N');
insert into jedinec values ('ALST422', 'Anna', DATE '2019-08-25', null, 'albatros stěhovavý', 'KPT026N');

insert into jedinec values ('ANVE015', 'Anaka', DATE '2018-11-10', null, 'anakonda velká', 'TPL666E');

-- insert 'zamestnanec' records
insert into osoba values (9910244245, 'David Mihola', 'Brno, 635 00', 'xmihol00@stud.fit.vutbr.cz');
insert into zamestnanec values (9910244245, '8521473667/0800', '+420774826266', DATE '2018-07-21', 42000, null, 'spravce');
insert into osoba values (9502233628, 'Jakub Beran', 'Znojmo 965 33', 'beran.jakub@gmail.com');
insert into zamestnanec values (9502233628, '9962473356/0600', '+420965243312', DATE '2019-09-26', 32850, 9910244245, 'udrzbar');
insert into osoba values (9106077256, 'Vlasta Lajdová', 'Zlín, 168 36', 'vlajdova@volny.cz');
insert into zamestnanec values (9106077256, '2274668512/0800', '+420776225841', DATE '2017-11-03', 34009, 9910244245, 'osetrovatel');
insert into osoba values (7603242237, 'Pavel Okurka', 'Pardubice, 336 26', 'okurka@seznam.cz');
insert into zamestnanec values (7603242237, '7726984413/0900', '+420603215547', DATE '2016-07-21', 23986, 9910244245, 'udrzbar');
insert into osoba values (8611067135, 'Marie Holá', 'Praha 1', 'holm@seznam.cz');
insert into zamestnanec values (8611067135, '4632598711/0400', '+420888555222', DATE '2020-02-04', 26263, 9106077256, 'osetrovatel');
insert into osoba values (7663214164, 'Jaroslava Mladá', 'Znojmo 412 01', 'mlada.jaroslava@centrum.cz');
insert into zamestnanec values (7663214164, '5638169742/0102', '+420556412874', DATE '2014-11-10', 31270, 9106077256, 'osetrovatel');
insert into osoba values (9611251334, 'Milan Lander', 'Jihlava 512 34', 'milander@seznam.cz');
insert into zamestnanec values (9611251334, '1126648792/0700', '+420135879624', DATE '2018-02-03', 28762, 9502233628, 'udrzbar');
insert into osoba values (9862038563, 'Ludmila Pakostová', 'Zlín, 168 36', 'pakostovaludmila@seznam.cz');
insert into zamestnanec values (9862038563, '5569218423/0620', '+420742698531', DATE '2021-03-20', 22671, 7663214164, 'osetrovatel');

-- insert 'navstevnik' records
insert into osoba values (1, 'Petr Ponožka', 'Liberec, 264 02', 'p.p@centrum.cz');
insert into navstevnik values (1, 863, DATE '2021-09-13', 13);
insert into osoba values (2, 'Libuše Baledová', 'Ostrava, 523 41', 'ba.li@gmail.com');
insert into navstevnik values (2, 65, DATE '2021-04-26', 8);
insert into osoba values (3, 'Barbora Hranolová', 'Kladno, 746 82', 'hranolka@gmail.com');
insert into navstevnik values (3, 1366, DATE '2021-10-02', 16);
insert into osoba values (4, 'Marek Brambora', 'Plzeň, 234 11', 'bramboram@volny.cz');
insert into navstevnik values (4, 733, DATE '2021-08-26', 12);
-- osoba Pavel Okurka
insert into navstevnik values (7603242237, 159, DATE '2021-06-19', 4);

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
insert into zamestnanec_kvalifikace values (9502233628, 'UDRZBAR_1');
insert into zamestnanec_kvalifikace values (9502233628, 'UDRZBAR_2');
insert into zamestnanec_kvalifikace values (9502233628, 'UDRZBAR_3');
insert into zamestnanec_kvalifikace values (9106077256, 'OSETROVATEL_1');
insert into zamestnanec_kvalifikace values (9106077256, 'OSETROVATEL_2');
insert into zamestnanec_kvalifikace values (9106077256, 'OSETROVATEL_3');
insert into zamestnanec_kvalifikace values (8611067135, 'OSETROVATEL_1');
insert into zamestnanec_kvalifikace values (7663214164, 'OSETROVATEL_1');
insert into zamestnanec_kvalifikace values (7663214164, 'OSETROVATEL_2');
insert into zamestnanec_kvalifikace values (7603242237, 'UDRZBAR_1');
insert into zamestnanec_kvalifikace values (7603242237, 'UDRZBAR_2');

-- insert 'osetrovatel_jedinec' records
insert into osetrovatel_jedinec values (8611067135, 'VLAR0001');
insert into osetrovatel_jedinec values (8611067135, 'TYUS0050');
insert into osetrovatel_jedinec values (8611067135, 'LEPU0458');
insert into osetrovatel_jedinec values (8611067135, 'HOSK1043');
insert into osetrovatel_jedinec values (8611067135, 'REOS044');
insert into osetrovatel_jedinec values (8611067135, 'ANVE015');
insert into osetrovatel_jedinec values (9106077256, 'VLAR0002');
insert into osetrovatel_jedinec values (9106077256, 'PLRU0003');
insert into osetrovatel_jedinec values (9106077256, 'PLRU0004');
insert into osetrovatel_jedinec values (9106077256, 'HOSK1489');
insert into osetrovatel_jedinec values (9106077256, 'ANVE015');
insert into osetrovatel_jedinec values (7663214164, 'REOS044');
insert into osetrovatel_jedinec values (7663214164, 'ARAR001');
insert into osetrovatel_jedinec values (7663214164, 'ALST421');
insert into osetrovatel_jedinec values (7663214164, 'ALST422');

-- insert 'udrzbar_pozice' records
insert into udrzbar_pozice values (9502233628, 'KKO402D');
insert into udrzbar_pozice values (9502233628, 'VME743A');
insert into udrzbar_pozice values (7603242237, 'VLV075S');
insert into udrzbar_pozice values (7603242237, 'KPT001M');
insert into udrzbar_pozice values (7603242237, 'KTR123B');
insert into udrzbar_pozice values (9611251334, 'VME743A');
insert into udrzbar_pozice values (9611251334, 'VLV075S');
insert into udrzbar_pozice values (9611251334, 'KTR123B');
insert into udrzbar_pozice values (9611251334, 'KPT001M');

-- insert 'mereni' and 'osetrovatel_mereni' records
DECLARE
    type mereni_record_t is record (
        id_jedince mereni.id_jedince%TYPE,
        id mereni.id%TYPE
    );
    mereni_record mereni_record_t;
BEGIN
    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('HOSK1043', DATE '2019-06-30', 'vše v pořádku', 0.30, 1.20)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (7663214164, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('HOSK1043', DATE '2019-08-12', 'nechuť k jídlu', 0.22, 1.19)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (9106077256, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('HOSK1043', DATE '2019-11-30', 'nechuť k jídlu, špatné trávení', 0.20, 1.20)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (7663214164, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('VLAR0001', DATE '2020-04-12', 'vše v pořádku', 49.42, 1.25)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (7663214164, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('VLAR0001', DATE '2019-12-30', 'línající srst, poškozené oko', 47.30, 1.30)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (9106077256, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('HOSK1489', DATE '2021-01-01', 'vše v pořádku', 0.32, 0.16)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (9106077256, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('PLRU0003', DATE '2021-01-01', 'vše v pořádku', 3.1, 115)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (7663214164, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('PLRU0003', DATE '2021-02-05', 'bolest křídla', 3.0, 110)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (9106077256, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('PLRU0003', DATE '2021-03-09', 'vše v pořádku', 2.6, 110)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (7663214164, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('PLRU0003', DATE '2021-03-13', 'vše v pořádku', 2.0, 100)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (7663214164, mereni_record.id_jedince, mereni_record.id);

    insert into mereni (id_jedince, datum_mereni, zdravotni_stav, hmotnost, vyska)
        values ('PLRU0003', DATE '2021-03-23', 'ztráta váhy, nechuť k jídlu, nečinnost, poškozené křídlo, vypadávající peří', 1.9, 109)
        returning id_jedince, id into mereni_record;
    insert into osetrovatel_mereni values (9106077256, mereni_record.id_jedince, mereni_record.id);
END;
/
----------------------------------------------------------
-- Patrani: Uhynuli jedinci

-- select: Zjisti, kteri jedinci uhynuli.
select j.id, j.jmeno, zd.nazev, j.datum_narozeni, j.datum_umrti
    from jedinec j, zivocisny_druh zd
    where j.datum_umrti is not null and j.zastupce_druhu = zd.nazev
order by j.datum_umrti;
-- Zkusme zjistit, proc jedinec 'HOSK1043' uhynul.
-- select: Zobraz mereni jedince 'HOSK1043'
select m.*
    from jedinec j, mereni m
    where j.id = m.id_jedince and j.id = 'HOSK1043';

-- select: Zjisti, kdo byl primarnim osetrovatelem jedince 'HOSK1043' a jak ho je mozne kontaktovat.
select oj.osetrovatel_id, o.jmeno, o.email, z.telefon
    from jedinec j, osetrovatel_jedinec oj, zamestnanec z, osoba o
    where j.id = oj.jedinec_id and j.id = 'HOSK1043' and z.id = oj.osetrovatel_id and o.id = oj.osetrovatel_id;

-- select: Zjisti, kteri osetrovatele provadeli mereni jedince 'HOSK1043' a kontakt na ne.
select unique om.osetrovatel_id, o.jmeno, o.email, z.telefon
    from jedinec j, osetrovatel_mereni om, zamestnanec z, osoba o
    where j.id = om.jedinec_id and j.id = 'HOSK1043' and z.id = om.osetrovatel_id and o.id = om.osetrovatel_id;

-- select: Zjisti, kteri ze zamestnancu provadejicich mereni na 'HOSK1043' provadeli take mereni na ostatnich uhynulych zviratech
select unique om.osetrovatel_id, o.jmeno, o.email, z.telefon, j.id, j.jmeno, j.datum_narozeni, j.datum_umrti
    from jedinec j, osetrovatel_mereni om, zamestnanec z, osoba o
    where j.datum_umrti is not null and j.id<>'HOSK1043' and om.jedinec_id = j.id and om.osetrovatel_id = z.id and
          z.id = o.id and om.osetrovatel_id in (
            select unique om2.osetrovatel_id
                from jedinec j2, osetrovatel_mereni om2, zamestnanec z2, osoba o2
                where j2.id = om2.jedinec_id and j2.id = 'HOSK1043' and z2.id = om2.osetrovatel_id and o2.id = om2.osetrovatel_id
        );

-- select: Podivejme se na dana mereni jedince 'PLRU0003'.
select m.*, om.osetrovatel_id, o.jmeno
    from jedinec j, mereni m, osetrovatel_mereni om, osoba o
    where j.datum_umrti is not null and j.id<>'HOSK1043' and m.id_jedince = j.id and om.jedinec_id = j.id and
          om.mereni_id = m.id and om.osetrovatel_id = o.id and om.osetrovatel_id in (
            select unique om2.osetrovatel_id
                from jedinec j2, osetrovatel_mereni om2, zamestnanec z2, osoba o2
                where j2.id = om2.jedinec_id and j2.id = 'HOSK1043' and z2.id = om2.osetrovatel_id and o2.id = om2.osetrovatel_id
        )
    order by m.datum_mereni;

-- Pockat, proc si osetrovatel '7663214164' nevsiml vyrazne ztraty vahy, zrejmych potizi s kridlem a dalsich problemu?
-- To vypada na zanedbani pracovnich povinonsti vedoucich az k uhynuti jedince 'PLRU0003'.

-- select: Kolik dalsich mereni provedl zamestnanec '7663214164' u kterych jedincu?
select j.id, j.jmeno, j.zastupce_druhu, count(*) as pocet_mereni
    from jedinec j, zivocisny_druh zd, mereni m, osetrovatel_mereni om
    where j.id<>'HOSK1043' and j.zastupce_druhu = zd.nazev and m.id_jedince = j.id and om.jedinec_id = j.id and om.mereni_id = m.id and
          om.osetrovatel_id = '7663214164'
    group by j.id, j.jmeno, j.zastupce_druhu;
-- select: Pro kolik zivych jedincu je osetrovatel '7663214164' jejich primarnim osetrovatelem?
select count(*) as pocet_jedincu
    from jedinec j, osetrovatel_jedinec oj
    where j.datum_umrti is null and oj.osetrovatel_id = '7663214164' and oj.jedinec_id = j.id;

-- select: Ktere jedince osetrovatel '7663214164' meri nebo je jejich primarnim osetrovatelem?
select unique j.id, j.jmeno, j.zastupce_druhu
    from jedinec j, zivocisny_druh zd, mereni m, osetrovatel_mereni om, osetrovatel_jedinec oj
    where j.datum_umrti is null and j.zastupce_druhu = zd.nazev and ((m.id_jedince = j.id and om.jedinec_id = j.id and om.mereni_id = m.id and
          om.osetrovatel_id = '7663214164') or (oj.osetrovatel_id = '7663214164' and oj.jedinec_id = j.id));
-- Mozna by se o tyto jedince mel postarat nekdo jiny...

-- Konec patrani: Uhynuli jedinci
----------------------------------------------------------

-- select: Kolik kleci/akvarii/terarii se celkem nachazi ve vsech pavilonech?
select typ, count(*) as pocet_pozic_daneho_typu
    from pozice
    where typ<>'vybeh' and pavilon is not null
    group by typ
    order by pocet_pozic_daneho_typu desc;

-- select: zamestnanec
SELECT * 
FROM zamestnanec
join osoba on osoba.ID = zamestnanec.ID;

-- select: vsechny osetrovatele
SELECT * 
FROM zamestnanec
join osoba on osoba.ID = zamestnanec.ID
where zamestnanec.TYP = 'osetrovatel';

-- select: vsechny udrzbare
SELECT * 
FROM zamestnanec
join osoba on osoba.ID = zamestnanec.ID
where zamestnanec.TYP = 'udrzbar';

-- select: spravce
SELECT * 
FROM zamestnanec
join osoba on osoba.ID = zamestnanec.ID
where zamestnanec.TYP = 'spravce';

-- select: jmeno a typ zamestnancu, jejich nadrizeny je David Mihola a serad je podle typu (predpokladame, ze David Mihola je jedniny)
SELECT osoba.JMENO, zamestnanec.TYP
FROM zamestnanec
join osoba on osoba.ID = zamestnanec.ID
where zamestnanec.NADRIZENY = 
    (SELECT zamestnanec.ID
     FROM osoba
     join zamestnanec on osoba.ID = zamestnanec.ID
     where osoba.JMENO = 'David Mihola')
order by zamestnanec.TYP ASC;

-- select: pocet zamestnancu, kteri maji email u seznam.cz nebo gmail.com
SELECT COUNT(*) AS pocet
from zamestnanec
join osoba on osoba.ID = zamestnanec.ID
where osoba.EMAIL LIKE '%@seznam.cz' or osoba.EMAIL LIKE '%@gmail.com';

-- select: jmeno zamestnance a zivosicha, u ktereho zamestnanec provadel mereni a datum tohoto mereni
SELECT DISTINCT osoba.JMENO as "jmeno osoby", jedinec.JMENO as "jmeno jedince", mereni.DATUM_MERENI
from osoba
join osetrovatel_mereni on osetrovatel_mereni.OSETROVATEL_ID = osoba.ID
join jedinec on jedinec.ID = osetrovatel_mereni.JEDINEC_ID
join mereni on mereni.ID = osetrovatel_mereni.MERENI_ID
order by osoba.JMENO;

-- select: jmena zamestnancu, zivocihu a data mereni u zamestnancu, kteri provedli aspon 3 mereni (mohla byt na stejnem zivocichovi)
SELECT DISTINCT osoba.JMENO as "jmeno osoby", jedinec.JMENO as "jmeno jedince", mereni.DATUM_MERENI
from osoba
join osetrovatel_mereni on osetrovatel_mereni.OSETROVATEL_ID = osoba.ID
join jedinec on jedinec.ID = osetrovatel_mereni.JEDINEC_ID
join mereni on mereni.ID = osetrovatel_mereni.MERENI_ID
where osoba.ID in 
    (SELECT OSETROVATEL_ID
    from osetrovatel_mereni
    GROUP by OSETROVATEL_ID
    HAVING COUNT(osetrovatel_mereni.OSETROVATEL_ID) > 2)
order by osoba.JMENO;

-- select: jmena zamestnancu, jmena jedincu a data mereni u zivocichu, kteri byli mereni aspon 3 osetrovateli
SELECT DISTINCT osoba.JMENO as "jmeno osoby", jedinec.JMENO as "jmeno jedince", mereni.DATUM_MERENI
from jedinec
join osetrovatel_mereni on osetrovatel_mereni.JEDINEC_ID = jedinec.ID
join osoba on osoba.ID = osetrovatel_mereni.OSETROVATEL_ID
join mereni on mereni.ID = osetrovatel_mereni.MERENI_ID
where jedinec.ID in 
    (SELECT JEDINEC_ID
    from osetrovatel_mereni
    GROUP by JEDINEC_ID
    HAVING COUNT(osetrovatel_mereni.JEDINEC_ID) > 2)
order by osoba.JMENO;

-- select: jmena zamestnancu, jmena jedincu a data mereni u zamestnancu, kteri provedli mereni aspon na 3 zivocisich
SELECT DISTINCT osoba.JMENO as "jmeno osoby", jedinec.JMENO as "jmeno jedince", mereni.DATUM_MERENI
from osoba
join osetrovatel_mereni on osetrovatel_mereni.OSETROVATEL_ID = osoba.ID
join jedinec on jedinec.ID = osetrovatel_mereni.JEDINEC_ID
join mereni on mereni.ID = osetrovatel_mereni.MERENI_ID
where osoba.ID in 
    (SELECT OSETROVATEL_ID
    from osetrovatel_mereni
    GROUP by OSETROVATEL_ID
    HAVING COUNT(DISTINCT osetrovatel_mereni.JEDINEC_ID) > 2)
order by osoba.JMENO;

-- select: castku, kterou zoo vyplati mesicne zamestnancum
SELECT SUM(zamestnanec.PLAT) as vyplaty
from zamestnanec;

-- select: castku, kterou zoo vyplati mesicne vsem zamestnancum dohromady, udrzbarum zvast, osetrovatelum zvlast a spravci zvlast
SELECT SUM(zamestnanec.PLAT) as "vyplaty", SUM(udrzbar.PLAT) as "vypalty udrzbaru", SUM(osetrovatel.PLAT) as "vyplaty osetrovatelu", SUM(spravce.PLAT) as "plat spravce"
from zamestnanec
left join (SELECT zamestnanec.ID, zamestnanec.PLAT
      from zamestnanec
      where zamestnanec.TYP = 'udrzbar') udrzbar on udrzbar.ID = zamestnanec.ID
left join (SELECT zamestnanec.ID, zamestnanec.PLAT
      from zamestnanec
      where zamestnanec.TYP = 'osetrovatel') osetrovatel on osetrovatel.ID = zamestnanec.ID
left join (SELECT zamestnanec.ID, zamestnanec.PLAT
      from zamestnanec
      where zamestnanec.TYP = 'spravce') spravce on spravce.ID = zamestnanec.ID;

-- select: vsechny zamestnance, kteri nemaji zadnou kvalifikaci
SELECT osoba.JMENO, zamestnanec.TYP as "pozice"
from osoba
join zamestnanec on zamestnanec.ID = osoba.ID
WHERE not EXISTS (
    SELECT *
    from zamestnanec_kvalifikace
    WHERE zamestnanec_kvalifikace.zamestnanec_id = osoba.ID
);

-- select: jmena zamestnanecu a jejich pracovni pozice, u osetrovatelu jmena jedincu, ktere osetruji, a u udrzbaru ID pozic, ktere udrzuji
SELECT osoba.JMENO, zamestnanec.TYP as "pozice", udrzbar_pozice.POZICE_ID as "udrzuje", jedinec.JMENO as "osetruje"
from osoba
left join udrzbar_pozice on udrzbar_pozice.UDRZBAR_ID = osoba.ID
left join osetrovatel_jedinec on osetrovatel_jedinec.OSETROVATEL_ID = osoba.ID
left join jedinec on jedinec.ID = osetrovatel_jedinec.JEDINEC_ID
join zamestnanec on zamestnanec.ID = osoba.ID;

-- select: jmena zamestnanecu a jejich pracovni pozice, u osetrovatelu jmena jedincu, ktere osetruji, spojenych do jednoho radku 
-- a u udrzbaru ID pozic, ktere udrzuji, spojenych do jednoho radku
SELECT tab.JMENO, tab.pozice, LISTAGG(tab.osetruje, ', ') WITHIN GROUP (ORDER BY tab.osetruje) as "osetruje",
LISTAGG(tab.udrzuje, ', ') WITHIN GROUP (ORDER BY tab.udrzuje) as "udrzuje"
from (SELECT DISTINCT osoba.JMENO, zamestnanec.TYP as pozice, jedinec.JMENO as osetruje, udrzbar_pozice.POZICE_ID as udrzuje
      from osoba
      left join osetrovatel_jedinec on osetrovatel_jedinec.OSETROVATEL_ID = osoba.ID
      left join jedinec on jedinec.ID = osetrovatel_jedinec.JEDINEC_ID
      left join udrzbar_pozice on udrzbar_pozice.UDRZBAR_ID = osoba.ID
      join zamestnanec on zamestnanec.ID = osoba.ID) tab
GROUP by tab.jmeno, tab.pozice;

-- select: vsechny navstevniky
SELECT * 
FROM navstevnik
join osoba on osoba.ID = navstevnik.ID;

-- select: id a jmena zamestnancu, kteri jsou zaroven registrovani i jako zakaznici
SELECT osoba.ID, osoba.JMENO
from zamestnanec
join osoba on osoba.ID = zamestnanec.ID
where EXISTS (SELECT *
              from navstevnik
              where zamestnanec.ID = navstevnik.ID);
