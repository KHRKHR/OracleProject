


/*

1. 관리자 계정

    1. 관리자는 시스템의 모든 기능을 로그인 과정을 거친 후에 사용할 수 있다.
    2. 관리자 계정은 사전에 데이터베이스에 등록된 것으로 간주한다.(가입 절차를 따로 거치지 않는다.)
    3. 모든 기능에느 기초 정보 관리, 교사 계정 관리, 개설 과정 관리, 개설 과목 관리, 교육생 관리,
     성적 조회를 포함한다.

*/




------------------------------------------------------------------------------------------------------------


/*

2. 기초 정보 관리

    1. 관리자는 교사 계정 관리 및 개설 과정, 개설 과목에 사용하게될 기초 정보를 등록 및
   관리할 수 있어야 한다.
    2. 기초 정보에는 과정명, 과목명, 강의실명(정원 포함), 교재명(출판사명 포함) 등이 포함된다.
    3. 기초 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야 한다.

*/


-- 기초정보
create or replace view vwBasicInfo
as
select
    tc.coursename as "과정명",
    tsb.subjectname as "과목명",
    tcr.classroomname || ' ' || tcr.personnel || '명' as "강의실명 (정원)",
    tb.bookName || ' (' || tb.publisher || ')' as "교재명 (출판사명)"
from tblCourse tc
    inner join tblOpenCourse toc
        on tc.courseseq = toc.courseseq
            inner join tblOpenSubject tos
                on tos.opencourseseq = toc.opencourseseq
                    inner join tblSubject tsb
                        on tos.subjectseq = tsb.subjectseq
                            inner join tblBookSubject tbc
                                on tsb.subjectseq = tbc.subjectseq
                                    inner join tblBook tb
                                        on tbc.bookseq = tb.bookseq
                                            inner join tblClassroom tcr
                                                on toc.classroomseq = tcr.classroomseq;



select * from vwBasicInfo;


-- 입력
insert into tblCourse values (13, 'test', '5.5', 300, 26); -- 1
insert into tblSubject values (31, 'test과목', '개별'); -- 2
insert into tblBook values (31, 'test교재', 'test출판사'); -- 3
insert into tblClassroom values (7, '807호', 26); -- 4
insert into tblOpenCourse values (43, 13, 7, '2021-12-01', '2021-12-31'); -- 5
insert into tblOpenSubject values (51, 43, 6, 31, '2021-12-02', '2021-12-10'); -- 6
insert into tblBookSubject values (31, 31); -- 7




-- 수정
update tblCourse set coursename = 'test' where courseseq = 1;
update tblOpenCourse set classroomseq = 5 where courseseq = 1;
update tblOpenSubject set teacherseq = 12 where opensubjectseq = 3;
update tblSubject set subjectname = 'test' where subjectseq = 1;
update tblBookSubject set bookseq = 3 where subjectseq = 1;
update tblBook set bookname = 'test' where bookseq = 3;
update tblClassroom set classroomname = '809호' where classroomseq = 3;


rollback;

commit;


------------------------------------------------------------------------------------------------------------


/*

3. 교사 계정 관리

1. 관리자는 여러 명의 교사 정보를 등록 및 관리할 수 있어야 한다.
2. 교사 정보는 교사 이름, 주민번호 뒷자리, 전화번호, 강의 가능 과목을 기본으로 등록하고,
   주민번호 뒷자리는 교사 본인이 로그인시 패스워드로 사용되도록 한다.
3. 교사의 강의 가능 과목은 기초 정보 과목명을 이용해서 선택적으로 추가할 수 있어야 한다.
4. 교사 정보 출력시 교사 전체 명단의 교사명, 주민번호 뒷자리, 전화번호, 강의 가능 과목을
   출력하고, 특정 교사를 선택한 경우 배정된 개설 과목명, 개설 과목기간(시작 년월일, 끝 년월일),
   과정명, 개설 과정기간(시작 년월일, 끝 년월일), 교재명, 강의실, 강의진행여부(강의 예정,
   강의중, 강의종료)를 확인할 수 있어야 한다. 강의진행여부는 날짜를 기준으로 확인한다.
5. 교사 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야 한다.

*/


-- 교사 기초 정보
select
    tm.name as "교사 이름",
    substr(tm.jumin, 8) as "주민번호 뒷자리",
    tm.tel as "전화번호",
    tsb.subjectname as "강의 가능 과목"
from tblTeacher tt
    inner join tblMember tm
        on tt.teacherseq = tm.memberseq
            inner join tblPossibleSubject tps
                on tt.teacherseq = tps.teacherseq
                    inner join tblSubject tsb
                        on tps.subjectseq = tsb.subjectseq;


-- 특정 교사 선택시
create or replace view vwChoiceTeacher
as
select
    tt.teacherseq as "강사번호",
    tsb.subjectname as "개설과목명",
    tos.startdate || ' ~ ' || tos.enddate as "과목기간",
    tc.coursename as "개설과정명",
    toc.startdate || ' ~ ' || toc.enddate as "과정기간",
    tb.bookname as "교재명",
    tcr.classroomname as "강의실",
    (case
        when sysdate between toc.startdate and toc.enddate then '강의중'
        when sysdate > toc.enddate then '강의종료'
        when sysdate < toc.startdate then '강의예정'
    end) as "강의상태"
from tblTeacher tt
    inner join tblMember tm
        on tt.teacherseq = tm.memberseq
            inner join tblPossibleSubject tps
                on tt.teacherseq = tps.teacherseq
                    inner join tblSubject tsb
                        on tps.subjectseq = tsb.subjectseq
                            inner join tblOpenSubject tos
                                on tps.subjectseq = tos.subjectseq
                                    inner join tblOpenCourse toc
                                        on tos.opencourseseq = toc.opencourseseq
                                            inner join tblCourse tc
                                                on toc.courseseq = tc.courseseq
                                                    inner join tblBookSubject tbs
                                                        on tbs.subjectseq = tsb.subjectseq
                                                            inner join tblBook tb
                                                                on tbs.bookseq = tb.bookseq
                                                                    inner join tblClassroom tcr
                                                                        on toc.classroomseq = tcr.classroomseq
    where tos.subjectseq = tsb.subjectseq
        and tt.teacherseq = 6;


select * from vwChoiceTeacher;

drop view vwChoiceTeacher;


-- 입력
insert into tblCourse values (13, 'test', '5.5', 300, 26); -- 1
insert into tblSubject values (31, 'test과목', '개별'); -- 2
insert into tblBook values (31, 'test교재', 'test출판사'); -- 3
insert into tblClassroom values (7, '807호', 26); -- 4
insert into tblMember values (201, '테스트', '920602-1990435', '031-123-9876', 'ffyaudsf@naver.com'); -- 5
insert into tblTeacher values (201); -- 6

insert into tblPossibleSubject values (201, 1);
insert into tblPossibleSubject values (201, 2);
insert into tblPossibleSubject values (201, 3);
insert into tblPossibleSubject values (201, 4);
insert into tblPossibleSubject values (201, 5);
insert into tblPossibleSubject values (201, 13); -- 7

insert into tblOpenCourse values (43, 13, 7, '2021-12-01', '2021-12-31'); -- 8
insert into tblOpenSubject values (51, 43, 201, 31, '2021-12-02', '2021-12-10'); -- 9
insert into tblBookSubject values (31, 31); -- 10



-- 수정
update tblCourse set coursename = 'test' where courseseq = 1;
update tblOpenCourse set classroomseq = 5 where courseseq = 1;
update tblOpenSubject set teacherseq = 12 where opensubjectseq = 3;
update tblSubject set subjectname = 'test' where subjectseq = 1;
update tblBookSubject set bookseq = 3 where subjectseq = 1;
update tblBook set bookname = 'test' where bookseq = 3;
update tblClassroom set classroomname = '809호' where classroomseq = 3;

update tblMember set name = '테스트' where memberseq = 12;



rollback;

commit;



------------------------------------------------------------------------------------------------------------



/*
--4. 개설과정관리 ---------------------
- 관리자는 여러개의 개설 과정을 등록 및 관리할 수 있어야한다.
- 과정 정보는 과정명, 과정기간(시작년월일, 끝년월일), 강의실 정보를 입력한다.
- 강의실 정보는 기초 정보 강의실명에서 선택적으로 추가할 수 있어야한다
- 개설과정정보 출력시 개설 과정명, 개설 과정기간(시간 년월일, 끝 년월일), 강의실명, 개설 과목 등록 여부, 교육생 등록인원을 출력한다.
- 특정 개설 과정 선택시 개설 과정에 등록된 개설 과목정보(과목명,과목기간(시간년월일,끝년월), 교재명,교사명) 및 등록된 교육생 정보
    (교육생이름, 주민뒷자리, 전화번호, 등록일, 수료및 중도탈락)을 확인할 수 있어야한다.
- 특정 개설 과정이 수료한 경우 등록된 교육생 전체에 대해서 수료날짜를 지정할 수 있어야한다. 단, 중도 탈락자는 제외한다
- 개설 과정 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야한다.
*/

-- 관리자는 여러개의 개설 과정을 등록 및 관리할 수 있어야한다.


--등록
create or replace procedure procAddOpenCourse(
    pcoursename varchar2,
    pcoursedate varchar2,
    pcoursetuition number,
    pcourserecruit number,
    presult out number
)
is
begin
    insert into TBLCOURSE (COURSESEQ, COURSENAME, COURSEDATE, COURSETUITION, COURSERECRUIT) VALUES
    ((select max(courseseq)+1 from TBLCOURSE),pcoursename,pcoursedate,pcoursetuition,pcourserecruit);
    presult :=1;
    exception when others then presult :=0;
end procAddOpenCourse;

declare
    vresult number;
begin
    procAddOpenCourse('과정명','5.5',500,30,vresult);

    if vresult =1 then DBMS_OUTPUT.PUT_LINE('완료');
    else DBMS_OUTPUT.PUT_LINE('실패');
    end if;
end;
select * from TBLCOURSE;


--수정
create or replace procedure procUpdateCourse(
    pcoursename varchar2,
    pcourseseq number,
    presult out number
)
is
begin
    update TBLCOURSE set COURSENAME = pcoursename where COURSESEQ = pcourseseq;
    presult:=1;
    exception when others then presult:=0;
end;

declare
    vresult number;
begin
    procUpdateCourse('Java언어 기반의 스마트 웹 Full-Stack 개발자 양성 과정',2,vresult);
    if vresult=1 then
        DBMS_OUTPUT.PUT_LINE('성공');
    else
        DBMS_OUTPUT.PUT_LINE('실패');
    end if;
end;
select * from TBLCOURSE;



insert into TBLCOURSE (COURSESEQ, COURSENAME, COURSEDATE, COURSETUITION, COURSERECRUIT) VALUES
    ((select max(COURSESEQ) from tblcourse),'원하는 과정','5.5',550,30); --등록




-- 과정 정보는 과정명, 과정기간(시작년월일, 끝년월일), 강의실 정보를 입력한다.
select tc.COURSENAME,t.STARTDATE,t.ENDDATE,tcr.CLASSROOMNAME,tcr.PERSONNEL from TBLCOURSE tc
    inner join TBLOPENCOURSE T on tc.COURSESEQ = T.COURSESEQ inner join TBLCLASSROOM Tcr on T.CLASSROOMSEQ = Tcr.CLASSROOMSEQ;
    --where STARTDATE between '2021-01-01' and '2021-12-31';


-- 강의실 정보는 기초 정보 강의실명에서 선택적으로 추가할 수 있어야한다
create or replace procedure procAddClassroom(
    pclassroomName varchar2,
    ppsersonnel number,
    presult out number
)
is
begin
    insert into TBLCLASSROOM (CLASSROOMSEQ, CLASSROOMNAME, PERSONNEL) VALUES ((select max(classroomseq)+1),pclassroomName,ppsersonnel);
    presult:=1;
    exception when others then presult:=0;
end procAddClassroom;

declare
    vresult number;
begin
    procAddClassroom('강의실명',30,vresult);
    if vresult =1 then
        DBMS_OUTPUT.PUT_LINE('성공');
    else
        DBMS_OUTPUT.PUT_LINE('실패');
    end if;
end;



select * from TBLOPENCOURSE;
-- 개설과정정보 출력시 개설 과정명, 개설 과정기간(시작 년월일, 끝 년월일), 강의실명, 개설 과목 등록 여부, 교육생 등록인원을 출력한다.
select tc.COURSENAME as "개설 과정명",t.STARTDATE as 시작년월일,t.ENDDATE as 끝년월일,tcr.CLASSROOMNAME as 강의실명
,toc.CHECKOPEN as 개설과목등록여부
from TBLCOURSE tc
    inner join TBLOPENCOURSE T on tc.COURSESEQ = T.COURSESEQ inner join TBLOPENCHECK TOC on T.OPENCOURSESEQ = TOC.OPENCOURSESEQ
    inner join TBLCLASSROOM Tcr on T.CLASSROOMSEQ = Tcr.CLASSROOMSEQ;


-- 특정 개설 과정 선택시 개설 과정에 등록된 개설 과목정보(과목명,과목기간(시간년월일,끝년월), 교재명,교사명)
-- 및 등록된 교육생 정보(교육생이름, 주민뒷자리, 전화번호, 등록일, 수료및 중도탈락)을 확인할 수 있어야한다.

select ts.SUBJECTNAME as 과목명, tos.STARTDATE as 개강일, tos.ENDDATE as 종강일, tb.BOOKNAME as 교재명, tm.NAME as 교사명 from TBLOPENCOURSE toc inner join TBLOPENSUBJECT tos on toc.OPENCOURSESEQ = tos.OPENCOURSESEQ
inner join TBLTEACHER tch on tos.TEACHERSEQ = tch.TEACHERSEQ inner join TBLMEMBER tm on tch.TEACHERSEQ = tm.MEMBERSEQ
inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ inner join TBLBOOKSUBJECT tbs on ts.SUBJECTSEQ = tbs.SUBJECTSEQ
inner join tblbook tb on tbs.BOOKSEQ = tb.BOOKSEQ inner join TBLCOURSE tcc on toc.COURSESEQ = tcc.COURSESEQ
where toc.OPENCOURSESEQ = 37 order by tos.STARTDATE; --openCourseSeq가 37인 과정의등록된 과목정보

select ts.SUBJECTNAME as 과목명, tm.NAME as 교육생이름, substr(tm.JUMIN,8) as 주민뒷자리, tm.tel as 전화번호, tst.JOINDATE as 가입일 from TBLMEMBER tm inner join TBLSTUDENT tst on tm.MEMBERSEQ = tst.MEMBERSEQ
inner join TBLSUGANG tsg on tst.MEMBERSEQ = tsg.MEMBERSEQ inner join TBLOPENCOURSE toc on tsg.OPENCOURSESEQ = toc.OPENCOURSESEQ
inner join TBLOPENSUBJECT tos on toc.OPENCOURSESEQ = tos.OPENCOURSESEQ inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ
where ts.SUBJECTNAME='데이터베이스 구조설계 및 활용';

-- 특정 개설 과정이 수료한 경우 등록된 교육생 전체에 대해서 수료날짜를 지정할 수 있어야한다. 단, 중도 탈락자는 제외한다 **
select * from TBLOPENCOURSE;
begin
    for sugangseq in 1..30 loop
        insert into TBLCOMPLETEDATE (COMPLETESEQ, SUGANGSEQ, COMPLETEDATE) VALUES (SEQCOMPLETE.nextval,SUGANGSEQ,'2021-12-11');
end loop;
end;  --1~30번까지 수료날짜 넣기
select * from TBLCOMPLETEDATE;

begin
    for sugangseq in 61..90 loop
        insert into TBLCOMPLETEDATE (COMPLETESEQ, SUGANGSEQ, COMPLETEDATE) VALUES (SEQCOMPLETE.nextval,SUGANGSEQ,'2021-12-27');
end loop;
end; --61~90번까지 수료날짜 넣기
commit;
select * from TBLCOMPLETEDATE;



-- 개설 과정 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야한다.

--입력
--개설과정정보만
select * from TBLOPENCOURSE;
select * from TBLCOURSE;
create or replace procedure procAddCourseInfo(
    pcourseseq number,
    pclassroomseq number,
    pstartdate date,
    penddate date,
    presult out number
)
is begin
    insert into TBLOPENCOURSE (OPENCOURSESEQ, COURSESEQ, CLASSROOMSEQ, STARTDATE, ENDDATE) VALUES (SEQOPENCOURSE.nextval,pcourseseq,pclassroomseq,pstartdate,penddate);
    presult :=1;
    exception when others then presult:=0;
end procAddCourseInfo;

declare
    vresult;
begin
    procAddCourseInfo(7,5,'2021-12-28','2021-06-21',vresult);
    if vresult := 1 then
        DBMS_OUTPUT.PUT_LINE('성공');
    else
        DBMS_OUTPUT.PUT_LINE('실패');
    end if;
end;


--새로운 과정추가 후 개설**
create or replace procedure procAddCourseInfo(
    pcoursename varchar2,
    pcoursedate varchar2,
    pcoursetuition number,
    pcourserecruit number,
    pclassroomseq number,
    pstartdate date,
    penddate date,
    presult out number
)
is begin
    insert into TBLCOURSE (COURSESEQ, COURSENAME, COURSEDATE, COURSETUITION, COURSERECRUIT) VALUES (SEQCOURSE.nextval,pcoursename,pcoursedate,pcoursetuition,pcourserecruit);
    insert into TBLOPENCOURSE (OPENCOURSESEQ, COURSESEQ, CLASSROOMSEQ, STARTDATE, ENDDATE) VALUES (SEQOPENCOURSE.nextval,(select max(COURSESEQ) from TBLCOURSE),
                                                                                                   pclassroomseq,pstartdate,penddate);
    presult :=1;
    exception when others then presult:=0;
end procAddCourseInfo;

commit;

declare
    vresult number;
begin
    procAddCourseInfo('과정명',5.5,450,30,3,'2021-12-03','2022-06-02',vresult);
    if vresult = 1 then
        DBMS_OUTPUT.PUT_LINE('성공');
    else
        DBMS_OUTPUT.PUT_LINE('실패');
    end if;
end;
select * from TBLCOURSE;
select * from TBLOPENCOURSE;





--출력
create or replace view vwCourseInfo as
select tc.COURSENAME as "개설 과정명",t.STARTDATE as 시작년월일,t.ENDDATE as 끝년월일,tcr.CLASSROOMNAME as 강의실명
,toc.CHECKOPEN as 개설과목등록여부
from TBLCOURSE tc
    inner join TBLOPENCOURSE T on tc.COURSESEQ = T.COURSESEQ inner join TBLOPENCHECK TOC on T.OPENCOURSESEQ = TOC.OPENCOURSESEQ
    inner join TBLCLASSROOM Tcr on T.CLASSROOMSEQ = Tcr.CLASSROOMSEQ;
select * from vwCourseInfo;


--수정**

select * from TBLOPENCOURSE;

create or replace trigger trgUpdateOpenCourse
    after update on TBLOPENCOURSE
    for each row
begin
    DBMS_OUTPUT.PUT_LINE('수정 전 과정번호:'||:old.COURSESEQ);
    DBMS_OUTPUT.PUT_LINE('수정 후 과정번호:'||:new.COURSESEQ);
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    DBMS_OUTPUT.PUT_LINE('수정 전 강의실번호:'||:old.CLASSROOMSEQ);
    DBMS_OUTPUT.PUT_LINE('수정 후 강의실번호:'||:new.CLASSROOMSEQ);
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    DBMS_OUTPUT.PUT_LINE('수정 전 개강날짜:'||:old.STARTDATE);
    DBMS_OUTPUT.PUT_LINE('수정 후 개강날짜:'||:new.STARTDATE);
    DBMS_OUTPUT.PUT_LINE('-------------------------');
    DBMS_OUTPUT.PUT_LINE('수정 전 종강날짜:'||:old.ENDDATE);
    DBMS_OUTPUT.PUT_LINE('수정 후 종강날짜:'||:new.ENDDATE);
end;



create or replace procedure procUpdateOpenCourse(
    popencourseseq number, --변경하고싶은 개설과정코드
    pcourseseq number,
    pclassroomseq number,
    pstartdate date,
    penddate date,
    presult out number
)
is begin
    update TBLOPENCOURSE set courseseq = pcourseseq, CLASSROOMSEQ=pclassroomseq,STARTDATE=pstartdate,ENDDATE=penddate where OPENCOURSESEQ=popencourseseq;
    presult :=1;
    --exception when others then presult:=0;
end procUpdateOpenCourse;

declare
    vresult number;
begin
   procUpdateOpenCOurse(42,6,6,'2021-07-01','2022-01-26',vresult);
    if vresult = 1 then
        DBMS_OUTPUT.PUT_LINE('성공');
    else
        DBMS_OUTPUT.PUT_LINE('실패');
    end if;
end;

select * from TBLOPENCOURSE;
--삭제



--5. 개설과목관리
-- 관리자는 개설 과정에 대해서 종속적으로 여러개의 개설 과목을 등록 및 관리할 수 있어야한다.
-- 특정 개설 과정 선택시 개설 과목 정보 출력 및 개설 과목 신규 등록을 할 수 있도록 한다.
-- 개설 과목 정보 입력시 과목명, 과목기간(시작 년월일, 끝 년월일), 교재명, 교사명을 입력할 수 있어야한다.
-- 교재명은 기초 정보 교재명에서 선택적으로 추가할 수 있어야한다.
-- 교사명은 교사명단에 선택적으로 추가할 수 있어야한다.
-- 교사 명단은 현재 과목과 강의 가능 과목이 일치하는 교사명단만 보여야한다.
-- 개설 과목 출력시 개설 과정정보 (과정명,과정기간(시작 년월일, 끝 년월일), 강의실)와 과목명, 과목기간(시작 년월일, 끝년월일), 교재명, 교사명을 출력한다.
-- 개설 과목 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야한다.




-- 특정 개설 과정 선택시 개설 과목 정보 출력 및 개설 과목 신규 등록을 할 수 있도록 한다.
--출력**
create or replace procedure procPrintSubjectInfo(
    popencourseseq number,
    presult out sys_refcursor
)
is begin
    open presult for select * from VWPRINTSUBJECTINFO where OPENCOURSESEQ=popencourseseq;
end procPrintSubjectInfo;

declare
    vopencourseseq number := 37;
    vresult sys_refcursor;
    vrow vwPrintSubjectInfo%rowtype;
begin
    procPrintSubjectInfo(vopencourseseq,vresult);

    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        DBMS_OUTPUT.PUT_LINE(vrow.COURSENAME||' - '||vrow.SUBJECTNAME);
    end loop;
end;



create or replace view vwPrintSubjectInfo as select tc.COURSENAME,ts.SUBJECTNAME,toc.OPENCOURSESEQ from TBLOPENCOURSE toc inner join TBLOPENSUBJECT tos on toc.OPENCOURSESEQ = tos.OPENCOURSESEQ
                                inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ
                                inner join TBLCOURSE tc on toc.COURSESEQ = tc.COURSESEQ; where toc.OPENCOURSESEQ=39;
select * from VWPRINTSUBJECTINFO;

--등록
insert into TBLOPENSUBJECT (OPENSUBJECTSEQ, OPENCOURSESEQ, TEACHERSEQ, SUBJECTSEQ, STARTDATE, ENDDATE) VALUES
    (SEQOPENSUBJECT.nextval,39 ,5, 25 , '2021-12-03','2022-01-02');



-- 개설 과목 정보 입력시 과목명, 과목기간(시작 년월일, 끝 년월일), 교재명, 교사명을 입력할 수 있어야한다.
insert into TBLSUBJECT (SUBJECTSEQ, SUBJECTNAME, SUBJECTTYPE) VALUES (SEQSUBJECT.nextval,'원하는 과목명','개별'); --새로운과목생성
insert into TBLBOOKSUBJECT (SUBJECTSEQ, BOOKSEQ) VALUES  ((select max(SUBJECTSEQ) from TBLSUBJECT),30); --30번책 연결
insert into TBLOPENSUBJECT (OPENSUBJECTSEQ, OPENCOURSESEQ, TEACHERSEQ, SUBJECTSEQ, STARTDATE, ENDDATE) VALUES
    (SEQOPENSUBJECT.nextval,39 ,5, (select max(SUBJECTSEQ) from TBLSUBJECT) , '2021-12-03','2022-01-02'); --39번 개설과정에 5번선생님 새로운과목 시작일 마감일

--삭제
delete from TBLSUBJECT where SUBJECTSEQ = 31;
delete from TBLBOOKSUBJECT where BOOKSEQ = 31;
delete from TBLOPENSUBJECT where OPENCOURSESEQ=51;


select ts.SUBJECTNAME,tos.STARTDATE,tos.ENDDATE,tb.BOOKNAME,tm.NAME from TBLOPENSUBJECT tos inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ
                                inner join TBLBOOKSUBJECT tbs on ts.SUBJECTSEQ = tbs.SUBJECTSEQ
                                inner join TBLTEACHER tt on tos.TEACHERSEQ = tt.TEACHERSEQ
                                inner join TBLMEMBER tm on tt.TEACHERSEQ = tm.MEMBERSEQ
                                inner join TBLBOOK tb on tbs.BOOKSEQ = tb.BOOKSEQ order by startdate asc;







-- 교사 명단은 현재 과목과 강의 가능 과목이 일치하는 교사명단만 보여야한다.
--현재 진행중인 과목을 담당하는 교사
select tm.NAME as 강사명,ts.SUBJECTNAME as 강의명 from TBLTEACHER tt inner join TBLOPENSUBJECT tos on tt.TEACHERSEQ = tos.TEACHERSEQ
                            inner join TBLMEMBER tm on tt.TEACHERSEQ = tm.MEMBERSEQ
                            inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ where sysdate between tos.STARTDATE and tos.ENDDATE;
--현재 진행중인 과목을 담당할 수 있는 교사
select tm.NAME,ts.SUBJECTNAME from TBLTEACHER tt inner join TBLPOSSIBLESUBJECT tps on tt.TEACHERSEQ = tps.TEACHERSEQ
inner join TBLMEMBER tm on tt.TEACHERSEQ = tm.MEMBERSEQ inner join TBLSUBJECT ts on tps.SUBJECTSEQ = ts.SUBJECTSEQ
inner join TBLOPENSUBJECT tos on ts.SUBJECTSEQ = tos.SUBJECTSEQ where sysdate between tos.STARTDATE and tos.ENDDATE;


-- 개설 과목 출력시 개설 과정정보 (과정명,과정기간(시작 년월일, 끝 년월일), 강의실)와 과목명,
-- 과목기간(시작 년월일, 끝년월일), 교재명, 교사명을 출력한다.
create or replace view vwOpenSubjectInfo as --개설과목정보
select tc.COURSENAME as 과정명, toc.STARTDATE as 개강, toc.ENDDATE as 종강,tcr.CLASSROOMNAME as 강의실,ts.SUBJECTNAME as 과목명,
        tos.STARTDATE as 과목시작, tos.ENDDATE as 과목끝, tb.BOOKNAME as 교재명, tm.name as 교사명
from TBLOPENSUBJECT tos inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ
                                inner join TBLBOOKSUBJECT tbs on ts.SUBJECTSEQ = tbs.SUBJECTSEQ
                                inner join TBLTEACHER tt on tos.TEACHERSEQ = tt.TEACHERSEQ
                                inner join TBLMEMBER tm on tt.TEACHERSEQ = tm.MEMBERSEQ
                                inner join TBLBOOK tb on tbs.BOOKSEQ = tb.BOOKSEQ
                                inner join TBLOPENCOURSE toc on tos.OPENCOURSESEQ = toc.OPENCOURSESEQ
                                inner join TBLCOURSE tc on toc.COURSESEQ = tc.COURSESEQ
                                inner join TBLCLASSROOM tcr on toc.CLASSROOMSEQ = tcr.CLASSROOMSEQ order by toc.STARTDATE, tc.COURSENAME;
select * from vwOpenSubjectInfo;
select * from TBLCOURSE;
select * from TBLOPENCOURSE toc inner join TBLCOURSE tc on toc.COURSESEQ = tc.COURSESEQ;
select * from TBLSUBJECT;
select * from TBLOPENCOURSE toc inner join TBLOPENSUBJECT on toc.OPENCOURSESEQ = TBLOPENSUBJECT.OPENCOURSESEQ where toc.OPENCOURSESEQ = 40;


-- 개설 과목 정보에 대한 입력, 출력, 수정, 삭제 기능을 사용할 수 있어야한다.
--출력
select ts.SUBJECTNAME as 개설과목명,tos.STARTDATE as 시작일, tos.ENDDATE as 끝난일 from TBLSUBJECT ts inner join TBLOPENSUBJECT tos on ts.SUBJECTSEQ = tos.SUBJECTSEQ;
create or replace view vwSubjectInfo as
select ts.SUBJECTSEQ,ts.SUBJECTNAME,tos.STARTDATE,tos.ENDDATE,tb.BOOKNAME,tm.NAME from TBLOPENSUBJECT tos inner join TBLSUBJECT ts on tos.SUBJECTSEQ = ts.SUBJECTSEQ
                                inner join TBLBOOKSUBJECT tbs on ts.SUBJECTSEQ = tbs.SUBJECTSEQ
                                inner join TBLTEACHER tt on tos.TEACHERSEQ = tt.TEACHERSEQ
                                inner join TBLMEMBER tm on tt.TEACHERSEQ = tm.MEMBERSEQ
                                inner join TBLBOOK tb on tbs.BOOKSEQ = tb.BOOKSEQ order by startdate asc;
select * from vwSubjectInfo;
--수정**
select * from TBLSUBJECT;
create or replace trigger trgSubject
    after update on TBLSUBJECT
    for each row
begin
    DBMS_OUTPUT.PUT_LINE('수정전:'||:old.SUBJECTNAME);
    DBMS_OUTPUT.PUT_LINE('수정후:'||:new.SUBJECTNAME);
end;

update TBLSUBJECT set SUBJECTNAME = '머신러닝 기반 데이터 분석33' where subjectseq = 30; --30번 수정


select * from TBLOPENSUBJECT;
select * from vwSubjectInfo;






--[관리자 6 : 교육생 관리]
-- tblMember, tblStudent, tblSugang에 201~203 교육생 추가 완료한 상태

--▶교육생 정보 출력 : 교육생 이름, 주민번호 뒷자리, 전화번호, 등록일, 수강(신청) 횟수 출력
create view vwStudentAll
as
select
    tm.name as "교육생 이름",
    substr(tm.jumin,8,7) as "주민번호 뒷자리",
    tm.tel as "전화번호",
    tsd.joindate as "등록일",
    (select count(*) from tblSugang tsg where tsg.memberSeq = tm.memberSeq) as "수강횟수"
from tblMember tm
    left outer join tblStudent tsd
       on tm.memberSeq = tsd.memberSeq
            left outer join tblSugang tsg
                on tsg.memberSeq = tm.memberSeq
                    where tm.memberSeq >= 14;    --14부터 교육생

select * from vwStudentAll;

-- ▶특정 교육생 선택 시
--   : 수강 신청/수강중/수강했던 개설과정 정보(과정명, 과정기간(시작일자, 동료일자), 강의실, 수료 및 중도탈락 여부,  수료 및 중도탈락 날짜) 출력
select
    tm.name as "교육생 이름",
    tco.coursename as "개설 과정명",
    tocou.startDate || ' ~ ' || tocou.endDate as "과정기간",
    tcr.classroomName as "강의실",      --tblClassroom
    case
        when tsg.sugangseq = td.sugangseq then '중도탈락'
        else '수료'
    end as "수료 및 중도탈락 여부",
    td.dropDate as "중도탈락 날짜" --tblDrop
from tblMember tm
  left outer join tblSugang tsg
    on tm.memberSeq = tsg.memberSeq
         left outer join tblDrop td
           on tsg.sugangSeq = td.sugangSeq
                 left outer join tblOpenCourse tocou
                  on tsg.opencourseSeq = tocou.opencourseSeq
                     left outer join tblCourse tco
                         on tocou.courseseq = tco.courseseq
                              left outer join tblClassroom tcr
                                on tocou.classroomSeq = tcr.classroomSeq
     where
          tm.memberSeq = 179;

-- ▶교육생 검색하기(14번 부터 교육생임)
select
    tm.name as "교육생 이름",
    substr(tm.jumin,8,7) as "주민번호 뒷자리",
    tm.tel as "전화번호",
    tm.email as "이메일",
    ts.joindate as "등록일",
    (select count(*) from tblSugang tsg where tsg.memberSeq = tm.memberSeq) as "수강횟수"
from tblMember tm
    left outer join tblStudent ts
       on tm.memberSeq = ts.memberSeq
            left outer join tblSugang tsg
                on tsg.memberSeq = tm.memberSeq
                    where tm.memberSeq = 203;    --14부터 교육생

-- ▶교육생에 대한 중도탈락 여부 입력 -> 중도탈락 날짜 입력
--예]170번학생이 중도탈락했다고 가정 (아래 insert문 실행)
insert into tblDrop (openCourseSeq, dropDate, sugangSeq) VALUES (42,'2021-12-02',157); --예]170번학생 중도탈락

-- 170번 학생의 중도탈락 처리가 되어있는지 확인
select
    tm.name as "교육생 이름",
    case
    when td.dropDate is not null then '중도 탈락'
    else  '수강중'
    end as "중도탈락 여부",
    td.dropDate as "중도탈락 일자"
from tblMember tm
    left outer join tblSugang ts
        on ts.memberSeq = tm.memberSeq
            left outer join tblDrop td
                on ts.sugangSeq = td.sugangSeq
        where tm.memberSeq = 170;

rollback;

-- ▶교육생 정보 > 입력, 출력, 수정, 삭제
 -- 수정
  update tblMember
    set
    name = '김지렁',
    jumin = '790914-2017111',
    tel = '063-222-1234',
    email = 'jireng@naver.com'
    where memberSeq = 14;

 select name, jumin, tel, email
 from tblMember
 where memberSeq = 14;

 rollback;

 -- 삭제 :  201~203번 교육생 삭제 가능(tblMember/tblStudent/tblSugang으로만 연결시켜놨음)
delete from tblSugang where memberSeq = 201;
delete from tblStudent where memberSeq = 201;
delete from tblMember where memberSeq = 201;

delete from tblSugang where memberSeq = 202;
delete from tblStudent where memberSeq = 202;
delete from tblMember where memberSeq = 202;

delete from tblSugang where memberSeq = 203;
delete from tblStudent where memberSeq = 203;
delete from tblMember where memberSeq = 203;

commit;


--=====================================================================================================--
--[관리자 7 : 시험 관리 및 성적 조회]

-- ▶특정 개설 과정 선택
-- : 개설 과목 정보 출력(개설 과목명, 개설 과목 시작일+종료일, 개설 과목 기간,강의실), 개설 과목별 성적 등록 여부, 시험 문제 파일 등록 여부 확인
select
     tsj.subjectName as "개설 과목명",
     tos.startDate || ' ~ ' || tos.endDate as "개설 과목기간",
     tcr.classroomName as "강의실",
     case
     when  twts.writtentestscore is not null then 1
     when  tpts.practicaltestscore is not null then 1
     end as "성적 등록 여부",
     twt.testQuestion as "필기문제 등록",
     tpt.testQuestion as "실기문제 등록"
 from tblOpenSubject tos
    left outer join tblOpenCourse tocou
        on tocou.opencourseseq = tos.opencourseseq
            left outer join tblPracticalTest tpt
                on tos.opensubjectseq = tpt.opensubjectseq
                    left outer join tblWrittenTest twt
                        on tos.opensubjectseq = twt.opensubjectseq
                            left outer join tblSubject tsj
                                on tos.subjectseq = tsj.subjectseq
                                    left outer join tblCourse tc
                                        on tocou.courseseq = tc.courseseq
                                            left outer join tblClassroom tcr
                                                on tocou.classroomSeq = tcr.classroomSeq
                                                    left outer join tblSugang tsg
                                                        on tos.opencourseseq = tsg.opencourseseq
                                                            left outer join tblWrittenTestScore twts
                                                                on tsg.sugangseq = twts.sugangseq
                                                                    left outer join tblPracticalTestScore tpts
                                                                        on tsg.sugangseq = tpts.sugangseq
    where tocou.opencourseseq = 37;

 -- ▶개설 과목별 출력 > 개설 과정명, 개설 과정기간, 강의실명, 개설 과목명, 교사명, 교재명 출력
 --              + 해당 개설 과목을 수강한 모든 교육생들의 성적 정보(이름, 주민번호 뒷자리, 필기 점수, 실기 점수)
set serverout on;
 -- 과정 - 과목 - 학생정보 뷰
create view vwstudentInfo
as
select
    oc.opencourseseq as "개설과정번호",
    c.courseName as "개설 과정명",
    oc.startDate || ' ~ ' || oc.endDate as "개설 과정기간",
    cr.classroomName as "강의실",
    os.opensubjectSeq as "강의과목번호",
    s.subjectName as "개설 과목명",
    os.startDate || ' ~ ' || os.endDate as "개설 과목기간",
    tm.name  as "교사명",
    b.bookName as "교재명",
    sg.sugangseq as "수강생번호",
    tmb.memberseq as "교육생 번호",
    tmb.name as "교육생 이름",
    substr(tmb.jumin,8,7) as "주민번호 뒷자리"
from tblopencourse oc
    left outer join tblCourse c
        on oc.courseseq = c.courseseq
    left outer join tblClassRoom cr
        on oc.classroomseq = cr.classroomseq
    inner join tblopensubject os
        on oc.opencourseseq = os.opencourseseq
    left outer join tblsubject s
        on os.subjectseq = s.subjectseq
    left outer join tblmember tm
        on os.teacherseq = tm.memberseq
    left outer join tblbooksubject bs
        on s.subjectseq =  bs.subjectseq
    left outer join tblbook b
        on bs.bookSeq = b.bookseq
    left outer join tblSugang sg
        on oc.opencourseseq = sg.opencourseseq
    left outer join tblMember tmb
        on sg.memberseq = tmb.memberseq
    order by oc.opencourseseq;

SELECT * FROM vwstudentInfo;


select * from tblattendancescore;

-- 출결점수 뷰
create view vwSIA
as
select
    s.*,
    a.attendancescore
from vwStudentInfo s
    left outer join tblattendancescore a
                on s."강의과목번호" = a.opensubjectseq and s."수강생번호" = a.sugangseq;

--필기점수 뷰
create view vwSIW
as
select
    s.*,
    wts.writtentestscore
from vwStudentInfo s
    left outer join tblwrittentest w
        on s."강의과목번호" = w.opensubjectseq
            left outer join tblwrittentestscore wts
                on s."수강생번호" = wts.sugangseq and w.testseq = wts.writtentestseq;

--실기점수 뷰
create view vwSIP
as
select
    s.*,
    pts.practicaltestscore
from vwStudentInfo s
    left outer join tblPracticalTest p
        on s."강의과목번호" = p.opensubjectseq
            left outer join tblPracticalTestScore pts
                on s."수강생번호" = pts.sugangseq and p.practicaltestseq = pts.practicaltestseq;


--강의과목번호별 출력 프로시저
drop procedure procSIsubjectSert;
create or replace procedure procSIsubjectSert(
    psubjectseq number,
    presult out sys_refcursor,
    presult2 out sys_refcursor
)
is
begin
     open presult
        for select * from vwSIW
                where "강의과목번호"= psubjectseq;

    open presult2
        for select * from vwSIP
                where "강의과목번호"= psubjectseq;
end;

-- 과목별 성적 출력 : 4번 과목
declare
    vsubjectseq number := 4;
    vresult sys_refcursor;
    vrow vwSIW%rowtype;
    vresult2 sys_refcursor;
    vrow2 vwSIP%rowtype;
begin
    procSIsubjectSert(vsubjectseq, vresult, vresult2);

    loop
        fetch vresult into vrow;
        fetch vresult2 into vrow2;
        exit when vresult%notfound;

        dbms_output.put_line(
            vrow."개설 과정명" || '-' ||
            vrow."개설 과정기간" || '-' ||
            vrow."강의실" || '-' ||
            vrow."개설 과목명" || '-' ||
            vrow."교사명" || '-' ||
            vrow."교재명" || '-' ||
            vrow."교육생 이름" || '-' ||
            vrow."주민번호 뒷자리"|| '-' ||
            vrow.writtentestscore || '-' ||
            vrow2.practicaltestscore);

    end loop;
end;

  -- ▶교육생 개인별 출력 > 교육생 이름, 주민번호 뒷자리, 개설 과정명, 개설 과정기간, 강의실명
 --              + 교육생 개인이 수강한 모든 개설 과목에 대한 성적 정보(개설 과목명, 개설 과목 기간, 교사명, 필기 점수, 실기 점수)

--교육생번호 별 출력 프로시저
create or replace procedure procSIStudentSert(
    pstudentseq number,
    presult out sys_refcursor,
    presult2 out sys_refcursor,
    presult3 out sys_refcursor
)
is
begin
     open presult
        for select * from vwSIW
                where "교육생 번호"=  pstudentseq;

    open presult2
        for select * from vwSIP
                where "교육생 번호"= pstudentseq;

    open presult3
        for select * from vwSIA
                where "교육생 번호"=  pstudentseq;
end;



--교육생 개인별 성적 출력 : 14번 학생
declare
    vsubjectseq number := 14;
    vresult sys_refcursor;
    vrow vwSIW%rowtype;
    vresult2 sys_refcursor;
    vrow2 vwSIP%rowtype;
    vresult3 sys_refcursor;
    vrow3 vwSIA%rowtype;
begin
    procSIStudentSert(vsubjectseq, vresult, vresult2, vresult3);

    loop
        fetch vresult into vrow;
        fetch vresult2 into vrow2;
        fetch vresult3 into vrow3;
        exit when vresult%notfound;

        dbms_output.put_line(
            vrow."교육생 이름" || '-' ||
            vrow."주민번호 뒷자리"|| '-' ||
            vrow."개설 과정명" || '-' ||
            vrow."개설 과정기간" || '-' ||
            vrow."강의실" || '-' ||
            vrow."개설 과목명" || '-' ||
            vrow."개설 과목기간" || '-' ||
            vrow."교사명" || '-' ||
            vrow3.attendancescore || '-' ||     --출결
            vrow.writtentestscore || '-' ||        --필기
            vrow2.practicaltestscore);            --실기

    end loop;
end;


commit;


/*
8.
출결 관리 및 출결 조회

1. 특정 개설 과정을 선택하는 경우 모든 교육생의 출결을 조회할 수 있어야 한다.
2. 출결 현황을 기간별(년,월,일) 조회할 수 있어야 한다.
3. 특정(특정 과정, 특정 인원) 출결 현황을 조회할 수 있어야 한다.
4. 모든 출결 조회는 근태 상황을 구분할 수 있어야 한다.(정상, 지각, 조퇴, 외출, 병가, 기타)

*/


-- 특정 개설 과정 선택시 출결 현황
create or replace view vwChoiceOpenCourse
as
select
    toc.opencourseseq as "개설과정번호",
    tc.coursename as "과정명",
    tm.memberseq as "학생번호",
    tm.name as "학생명",
    ta.attendancedate as "수업날짜",
    ta.type as "출결현황",
    (case
        when tou.attendanceseq = ta.attendanceseq then 'Y'
        else 'N'
    end) as "외출여부"
from tblMember tm -- 회원
    inner join tblStudent tst -- 학생
        on tm.memberseq = tst.memberseq -- 회원번호 = 학생번호
            inner join tblSugang tsg -- 수강신청
                on tst.memberseq = tsg.memberseq -- 학생번호 = 수강학생번호
                    inner join tblAttendance ta -- 출결
                        on tsg.sugangseq = ta.sugangseq -- 수강번호 = 출결수강번호
                            inner join tblOpenCourse toc -- 개설과정
                                on tsg.opencourseseq = toc.opencourseseq -- 수강된개설과정 = 개설과정
                                    inner join tblCourse tc -- 과정
                                        on toc.courseseq = tc.courseseq -- 개설과정번호 = 과정번호
                                            left outer join tblOuting tou
                                                on ta.attendanceseq = tou.attendanceseq
    where toc.opencourseseq = 37; -- 개설과정


select * from vwChoiceOpenCourse;



-- 기간별 출결 현황 조회
select
    toc.opencourseseq as "개설과정번호",
    tc.coursename as "과정명",
    tm.memberseq as "학생번호",
    tm.name as "학생명",
    ta.attendancedate as "수업날짜",
    ta.type as "출결현황",
    (case
        when tou.attendanceseq = ta.attendanceseq then 'Y'
        else 'N'
    end) as "외출여부"
from tblMember tm -- 회원
    inner join tblStudent tst -- 학생
        on tm.memberseq = tst.memberseq -- 회원번호 = 학생번호
            inner join tblSugang tsg -- 수강신청
                on tst.memberseq = tsg.memberseq -- 학생번호 = 수강학생번호
                    inner join tblAttendance ta -- 출결
                        on tsg.sugangseq = ta.sugangseq -- 수강번호 = 출결수강번호
                            inner join tblOpenCourse toc -- 개설과정
                                on tsg.opencourseseq = toc.opencourseseq -- 수강된개설과정 = 개설과정
                                    inner join tblCourse tc -- 과정
                                        on toc.courseseq = tc.courseseq -- 개설과정번호 = 과정번호
                                            left outer join tblOuting tou
                                                on tou.attendanceseq = ta.attendanceseq
--    where to_char(attendancedate, 'yyyy') = '2021' -- 연별
    where to_char(attendancedate, 'yyyy-mm') = '2021-09' -- 월별
--    where to_char(attendancedate, 'dd') = '01' -- 일별
    ;



-- 특정 인원 선택시 출결 현황
select
    toc.opencourseseq as "개설과정번호",
    tc.coursename as "과정명",
    tm.memberseq as "학생번호",
    tm.name as "학생명",
    ta.attendancedate as "수업날짜",
    ta.type as "출결현황",
    (case
        when tou.attendanceseq = ta.attendanceseq then 'Y'
        else 'N'
    end) as "외출여부"
from tblMember tm -- 회원
    inner join tblStudent tst -- 학생
        on tm.memberseq = tst.memberseq
            inner join tblSugang tsg -- 수강신청
                on tst.memberseq = tsg.memberseq
                    inner join tblAttendance ta -- 출결
                        on tsg.sugangseq = ta.sugangseq
                            inner join tblOpenCourse toc -- 개설과정
                                on tsg.opencourseseq = toc.opencourseseq
                                    inner join tblCourse tc -- 과정
                                        on toc.courseseq = tc.courseseq
                                            left outer join tblOuting tou
                                                on tou.attendanceseq = ta.attendanceseq
    where tst.memberseq = 100
    ;


-- 특정 과정 선택시
select
    toc.opencourseseq as "개설과정번호",
    tc.coursename as "과정명",
    tm.memberseq as "학생번호",
    tm.name as "학생명",
    ta.attendancedate as "수업날짜",
    ta.type as "출결현황",
    (case
        when tou.attendanceseq = ta.attendanceseq then 'Y'
        else 'N'
    end) as "외출여부"
from tblMember tm -- 회원
    inner join tblStudent tst -- 학생
        on tm.memberseq = tst.memberseq -- 회원번호 = 학생번호
            inner join tblSugang tsg -- 수강신청
                on tst.memberseq = tsg.memberseq -- 학생번호 = 수강학생번호
                    inner join tblAttendance ta -- 출결
                        on tsg.sugangseq = ta.sugangseq -- 수강번호 = 출결수강번호
                            inner join tblOpenCourse toc -- 개설과정
                                on tsg.opencourseseq = toc.opencourseseq -- 수강된개설과정 = 개설과정
                                    inner join tblCourse tc -- 과정
                                        on toc.courseseq = tc.courseseq -- 개설과정번호 = 과정번호
                                            left outer join tblOuting tou
                                                on ta.attendanceseq = tou.attendanceseq
    where tc.courseseq = toc.courseseq
        and tc.courseseq = 1; -- 과정




--[관리자9]
--김재형
--기업 추가
insert into TBLFIRM (FIRMSEQ, REVENUE, CATEGORY, NAME, PAY) VALUES (31, 1500,'IT서비스','쌍용정보통신',4850);


--취업자 추가
--187번 취업
insert into TBLEMPLOYED (FIRMSEQ, BUSEO, JIKWI, IBSADATE, SUGANGSEQ) VALUES (31,'IT엔지니어','사원','2020-01-23',187)

--취업자 수정
update TBLEMPLOYED set JIKWI = '대리' where SUGANGSEQ =187;

