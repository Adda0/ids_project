drop table pavilon;
drop table pozice;
drop table zivocisny_druh;
drop table jedinec;
drop table mereni;




create table pavilon (
    id number(10) primary key,
    druh varchar(20)
);

create table pozice (
    id number(20) primary key,
    typ varchar(30),
    prostredi varchar(30),
    datum_udrzby date,
    --
    -- specification | vybeh:
    plocha numeric(7, 2),
    --
    -- specification | klec:
    objem numeric(7, 2),
    pavilon number(10),
    foreign key (pavilon)
        references pavilon (id)
        on delete cascade
);

create table zivocisny_druh (
    nazev varchar(30) primary key,
    charakteristika varchar(1024)
);

create table jedinec (
    id number(20) primary key,
    jmeno varchar(30),
    datum_narozeni date not null,
    datum_umrti date,
    zastupce_druhu varchar(30) not null,
    foreign key (zastupce_druhu)
        references zivocisny_druh (nazev)
        on delete cascade, -- on update cascade
    pozice number(20), -- animal 'jedinec' is on position 'pozice'
    foreign key (pozice)
        references pozice (id)
);

create table mereni (
  id number(10) primary key,
  id_jedince number(10) not null
      references jedinec (id)
      on delete cascade,
  datum_mereni date,
  zdravotni_stav varchar(1024),
  hmotnost numeric(7, 2),
  vyska numeric(7, 2)
);