create table tblEmployed (
            sugangSeq number not null references tblSugang(sugangSeq),
          	firmname varchar2(60) not null,
            buseo varchar2(60) not null,
          	jikwi varchar2(60) not null,
          	ibsadate date not null,
            pay number
);

drop table tblEmployed;


insert into tblEmployed values (169,'엔코아','모바일 개발부','사원', '2019-03-14', 2800);
insert into tblEmployed values (170,'엔쓰라엔','임베디드 개발부','사원', '2019-12-09', 3500);
insert into tblEmployed values (171,'시큐브','모바일 개발부','사원', '2019-01-27', 2900);
insert into tblEmployed values (172,'엑셈','데이터베이스 관리부','사원', '2020-11-10', 4000);
insert into tblEmployed values (173,'솔트룩스','임베디드 개발부','사원', '2021-04-01', 3700);
insert into tblEmployed values (174,'수산아이앤티','웹 개발부','사원', '2020-06-07', 2800);
insert into tblEmployed values (175,'드림시큐리티','임베디드 개발부','사원', '2019-01-03', 2700);
insert into tblEmployed values (176,'시큐브','응용소프트웨어 개발부','사원', '2020-11-02', 3000);
insert into tblEmployed values (177,'엔코아','데이터베이스 관리부','사원', '2021-05-01', 3600);
insert into tblEmployed values (178,'라온시큐어','모바일 개발부','사원', '2020-11-21', 2600);
insert into tblEmployed values (179,'씨제이올리브네트웍스','응용소프트웨어 개발부','사원', '2021-08-21', 3300);
insert into tblEmployed values (180,'에자일소다','데이터베이스 관리부','사원', '2021-10-20', 3600);
insert into tblEmployed values (181,'알서포트','데이터베이스 관리부','사원', '2020-11-16', 3800);
insert into tblEmployed values (182,'소프트캠프','데이터베이스 관리부','사원', '2019-05-18', 2500);
insert into tblEmployed values (183,'시큐브','시스템소프트웨어 개발부','사원', '2019-01-06', 3400);
insert into tblEmployed values (184,'쌍용정보통신','데이터베이스 관리부','사원', '2020-04-12', 3300);
insert into tblEmployed values (185,'나무기술','시스템소프트웨어 개발부','사원', '2020-02-18', 2800);
insert into tblEmployed values (186,'시큐브','모바일 개발부','사원', '2020-09-20', 2900);
insert into tblEmployed values (187,'가비아','데이터베이스 관리부','사원', '2020-10-01', 3200);


commit;

select * from tblEmployed;