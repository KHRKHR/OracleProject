--교사

--------------------------------교사1 :  로그인-----------------------------------------

--로그인 시 email - 주민번호뒷자리
select email, SUBSTR(jumin, 8) from tblMember where email = 'YCC9vlbG@naver.com';


-----------------------------교사2 : 강의스케쥴 출력------------------------------------

--스케쥴 상세정보 뷰
create view vwschedule
as
select
   os.opensubjectseq, 
   s.subjectname, 
   os.startdate as osstartdate, 
   os.enddate as osenddate,
   case
        when sysdate < os.startdate then '강의예정'
        when os.startdate <= sysdate and sysdate <= os.enddate then '강의중'
        when os.enddate < sysdate then '강의종료' 
    end as state,
   c.coursename, 
   oc.startdate as ocstartdate, 
   oc.enddate as ocenddate, 
   cr.classroomname,
   cr.personnel,
   (select count(*) from tblsugang where openCourseSeq = oc.openCourseSeq) as sugangMember,
   b.bookname,
   os.teacherseq
from tblopensubject os
    left outer join tblopencourse oc
        on os.openCourSeseq = oc.openCourseSeq
            left outer join tblcourse c
                on oc.courseseq = c.courseseq
                    left outer join tblsubject s
                        on os.subjectSeq = s.subjectSeq
                            left outer join tblbooksubject bs
                                on s.subjectseq = bs.subjectseq
                                    left outer join tblbook b
                                        on bs.bookseq = b.bookseq
                                            left outer join tblclassRoom cr
                                                on oc.classroomseq = cr.classroomseq;


--교사별 스케쥴 상세 정보
create or replace procedure procschedule(
    pteacher varchar2,
    presult out sys_refcursor
)
is
   
begin
     open presult 
        for select * from vwschedule where teacherSeq = pteacher;

end procschedule;

drop procedure procschedule;




--스케쥴 상세 정보 출력(ex 회원번호 10번 교사의 강의 스케쥴)
declare
    vteacher varchar2(15) := 10;
    vresult sys_refcursor;
    vrow vwschedule%rowtype;
begin
    procschedule(vteacher, vresult);

    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line(
            vrow.opensubjectseq ||'-'|| 
            vrow.subjectname ||'-'|| 
            vrow.osstartdate ||'-'|| 
            vrow.osenddate ||'-'||
            vrow.state ||'-'|| 
            vrow.coursename ||'-'|| 
            vrow.ocstartdate ||'-'|| 
            vrow.ocenddate ||'-'|| 
            vrow.classroomname ||'-'|| 
            vrow.personnel ||'-'|| 
            vrow.SUGANGMEMBER ||'-'||
            vrow.bookname);
    end loop;    
end;


------------------------------교사3 : 배점/시험정보 입출력-------------------------------


-- 과목목록출력
-- 과목번호, 과정명, 과정기간, 강의실,
-- 과목명, 과목기간, 교재명, 출결, 필기, 실기 배점 출력

create or REPLACE view vwpoint
as
select 
    os.opensubjectseq 과목번호, 
    c.coursename as 과정이름, 
    oc.startdate as "과정기간(시작)", 
    oc.enddate as "과정기간(끝)", 
    cr.classroomname as 강의실,
    s.subjectname 과목명, 
    os.startdate "과목기간(시작)", 
    os.enddate as "과목기간(끝)", 
    b.bookname as 교재명,
    p.attendancepoint as 출결배점,
    p.writtenpoint as 필기배점,
    p.practicalpoint as 실기배점
from tblopensubject os
    left outer join tblopencourse oc
        on os.openCourSeseq = oc.openCourseSeq
            left outer join tblcourse c
                on oc.courseseq = c.courseseq
                    left outer join tblsubject s
                        on os.subjectSeq = s.subjectSeq
                            left outer join tblbooksubject bs
                                on s.subjectseq = bs.subjectseq
                                    left outer join tblbook b
                                        on bs.bookseq = b.bookseq
                                            left outer join tblclassRoom cr
                                                on oc.classroomseq = cr.classroomseq      
                                                    left outer join tblPoint p
                                                        on p.opensubjectseq = os.opencourseseq;


--배점 추가/변경 프로시저
create or replace procedure procPoint(
    pOpenSubjectSeq number,
    pAPoint number,
    pWPoint number,
    pPPoint number
)
is
    vcnt number;
    checks number;
begin
    select max(pointSeq)+1 into vcnt from tblPoint;
    select NVL(max(opensubjectseqSeq), 0) into checks from tblPoint where opensubjectseq = pOpenSubjectSeq;
    dbms_output.put_line(checks);
       
    if checks = 0 then
        insert into tblPoint values(vcnt,pOpenSubjectSeq,pAPoint,pWPoint,pPPoint);
        dbms_output.put_line('추가한다');
    else
        update tblPoint set attendancePoint = pAPoint, writtenPoint = pWPoint, practicalPoint = pPPoint where openSubjectSeq = pOpenSubjectSeq;
        dbms_output.put_line('변경한다');
    end if;
    
end procPoint;

--배점 추가/변경 실행문

declare
    vOpenSubjectSeq number := 51;
    vAPoint number := 20;
    vWPoint number := 40;
    vPPoint number := 40;
begin
    procPoint(vOpenSubjectSeq, vAPoint, vWPoint, vPPoint); 
end;

rollback;

select * from tblPoint;



--시험정보 등록.

--필기시험정보 추가/변경 
create or replace procedure procWTest(
    pSubSeq number,
    pTestDate date,
    pQuestion number
)
is
    vcnt number;
    checks number;
begin
    select max(testSeq)+1 into vcnt from tblWrittenTest;
    select NVL(max(testSeq), 0) into checks from tblWrittenTest where openSubjectSeq = pSubSeq;
    dbms_output.put_line(checks);
       
    if checks = 0 then
        insert into tblWrittenTest values(vcnt,pSubSeq,pTestDate,pQuestion);
        dbms_output.put_line('추가한다');
    else
        update tblWrittenTest set testDate = pTestDate, testQuestion = pQuestion where openSubjectSeq = pSubSeq;
        dbms_output.put_line('변경한다');
    end if;
    
end procWTest;


--실기시험정보 추가/변경
create or replace procedure procPTest(
    pSubSeq number,
    pTestDate date,
    pQuestion number
)
is
    vcnt number;
    checks number;
begin
    select max(practicaltestSeq)+1 into vcnt from tblPracticalTest;
    select NVL(max(practicaltestSeq), 0) into checks from tblPracticalTest where openSubjectSeq = pSubSeq;
    dbms_output.put_line(checks);
       
    if checks = 0 then
        insert into tblPracticalTest values(vcnt,pSubSeq,pTestDate,pQuestion);
        dbms_output.put_line('추가한다');
    else
        update tblPracticalTest set testDate = pTestDate, testQuestion = pQuestion where openSubjectSeq = pSubSeq;
        dbms_output.put_line('변경한다');
    end if;
    
end procPTest;




--필기/실기 시험정보 수정 실행문
declare
    vSubSeq number := 1;
    vTestDate date := null;
    vQuestion number := 0;
begin
    procWTest(vSubSeq,vTestDate,vQuestion);
end;

rollback;

declare
    vSubSeq number := 20;
    vTestDate date := '2021-01-20';
    vQuestion number := 0;
begin
    procPTest(vSubSeq,vTestDate,vQuestion);
end;




--실기 필기 동시 등록
declare
    vSubSeq number := 20;
    vTestDate date := null;
    vTestDate2 date := null;
    vQuestion number := 1;
    vQuestion2 number := 1;
begin
    procWTest(vSubSeq,vTestDate,vQuestion);
    procPTest(vSubSeq,vTestDate2,vQuestion2);
end;

select * from tblWrittenTest;


-----------------------------------교사4 : 성적 입출력-----------------------------------

/*
테스트케이스
    과목번호 : 1
    수강번호 : 1
    이름      : 엄연연
    교사번호 : 10
    필기점수 : 81
    실기점수 : 81
    출석점수 : 100
*/



--요구사항 1 : 교사가 마친 과목 목록을 출력
--------------------------------------------------------------------------------
create or replace view vwScoreSubject
as 
select
os.teacherseq as "교사번호",
os.opensubjectseq as "개설과목번호",
co.coursename as "과정명",
o.startdate as "과정시작",
o.enddate as "과정종료",
cr.classroomname as "강의실",
sub.subjectname as "과목명",
os.startdate as "과목시작",
os.enddate as "과목종료",
bo.bookname as "교재명",
po.attendancepoint as "출결배점",
po.writtenpoint as "필기배점",
po.practicalpoint as "실기배점",
(select count(writtentestscore) from tblwrittentestscore where os.opensubjectseq = opensubjectseq) as "count"
 from tblopencourse o
    left outer join tblopensubject os
        on o.opencourseseq = os.opencourseseq
            left outer join tblsugang su
                on os.opencourseseq = su.opencourseseq 
                    left outer join TBLWRITTENTEST wt
                        on os.opensubjectseq = wt.opensubjectseq
                            left outer join tblpoint po
                                on os.opensubjectseq = po.opensubjectseq
                                    left outer join tbldrop dr
                                        on o.opencourseseq = dr.opencourseseq
                                            left outer join tblClassroom cr
                                                on o.classroomseq = cr.classroomseq
                                                    left outer join tblcourse co
                                                        on co.courseseq = o.courseseq
                                                            left outer join tblsubject sub
                                                                on sub.subjectseq = os.subjectseq
                                                                    left outer join tblbooksubject bs
                                                                        on bs.subjectseq = sub.subjectseq
                                                                            left outer join tblbook bo
                                                                                on bo.bookseq = bs.bookseq
                                                                                    left outer join tblmember me
                                                                                        on me.memberseq = su.memberseq
                                                                                            left outer join tblcompletedate com
                                                                                                on com.sugangseq = su.sugangseq
                                                                                order by su.memberseq;
        


--교사번호 10의 과목목록 출력
select distinct * from vwScoreSubject where "교사번호" = 10 order by "개설과목번호";



--요구사항 2: 과목번호 선택 시 교육성 정보를 출력  (중도탈락된 경우, 그 이후 치뤄진 시험의 성적은 null로 처리)
--------------------------------------------------------------------------------
create or replace view vwScoreMember
as  
select
wt.opensubjectseq as "과목번호",
os.teacherseq as "교사번호",
tsu.SUGANGSEQ as "수강번호",
me.name as "이름",
me.tel as "전화번호",
case 
    when dr.dropdate is null then com.completedate || ' (수료)'
    else  ' (중도탈락) ' || dr.dropdate
end as "수료/탈락날짜",
case 
    when dr.dropdate < wt.testdate then null
    else tws.writtentestscore
end as "필기점수",
case 
    when dr.dropdate < pt.testdate then null
    else tps.practicaltestscore
end as "실기점수",
case 
    when dr.dropdate is not null then null
    else tas.attendancescore
end as "출석점수"
from TBLSUGANG tsu 
    inner join TBLWRITTENTESTSCORE tws 
        on tsu.SUGANGSEQ = tws.SUGANGSEQ
            inner join TBLPRACTICALTESTSCORE tps 
                on tsu.SUGANGSEQ = tps.SUGANGSEQ
                    inner join TBLATTENDANCESCORE tas 
                        on tsu.SUGANGSEQ = tas.SUGANGSEQ 
                            inner join tblmember me
                                on tsu.memberseq = me.memberseq
                                    left outer join tbldrop dr
                                        on dr.sugangseq = tsu.sugangseq
                                            left outer join tblcompletedate com
                                                on com.sugangseq = tsu.sugangseq
                                                    left outer join tblwrittentest wt
                                                        on tws.writtentestseq = wt.testseq
                                                            left outer join tblpracticaltest pt
                                                                on pt.practicaltestseq = tps.practicaltestseq
                                                                    left outer join TBLOPENSUBJECT os
                                                                        on pt.OPENSUBJECTSEQ = os.OPENSUBJECTSEQ
                                    where PRACTICALSCORESEQ=WRITTENSCORESEQ and PRACTICALSCORESEQ=ATTENDANCESCORESEQ
                                and tsu.opencourseseq = 37
                    order by tsu.SUGANGSEQ;            
    


-- 과목번호 1에 대한 수강생들의 성적정보 출력  (교사번호 10이 확인 중이라고 가정)
------------------------------------------------------
select distinct * from vwscoremember 
    where "과목번호" = 1
        order by "수강번호";
        
        
--요구사항4 : 성적 미등록 학생 출력 (과목번호, 수강번호, 학생명, 필기/실기/출결 점수 등록/미등록 여부)
select distinct * from vwscoremember
    where "교사번호" = 10
    and ("필기점수" is null or "실기점수" is null or "출석점수" is null)
        order by "수강번호";






--요구사항4 : 특정과목 및 교육생 선택하여 출결/필기/실기 시험점수 입력

create or replace procedure procReviseScore(
    psugangseq number,              --수강번호
    popensubjectseq number,         --개설과목번호
    pwrittentestscore number ,      --필기점수
    ppracticaltestscore number ,    --실기점수
    pattendancescore number         --출결점수
)
is 
begin
     
    update tblwrittentestscore set writtentestscore = pwrittentestscore
        where writtentestseq = (select testseq from tblwrittentest where opensubjectseq = popensubjectseq)
        and sugangseq = psugangseq;
        
    update TBLPRACTICALTESTSCORE set PRACTICALTESTSCORE = ppracticaltestscore
        where PRACTICALTESTSEQ = (select PRACTICALTESTSEQ from TBLPRACTICALTEST where opensubjectseq = popensubjectseq)
        and sugangseq = psugangseq;
        
    update TBLATTENDANCESCORE set ATTENDANCESCORE = pattendancescore
        where OPENSUBJECTSEQ = popensubjectseq
        and sugangseq = psugangseq;
end procReviseScore;        





-- 과목번호 1번을 수강한 수강번호 1번 학생의 필기/실기/출결 점수를 null로 수정 (미등록 상황을 가정하기 위함)
begin
    procrevisescore(1,1,null,null,null);
end;


-- 과목번호 1번을 수강한 수강번호 1번 학생의 필기/실기/출결 점수를 70,80,100으로 수정
begin
    procrevisescore(1,1,70,80,100);
end;


-- 수정되었는지 확인
select distinct * from vwscoremember 
    where "과목번호" = 1 and "수강번호" = 1;


-----------------------------------교사5 : 출결조회-----------------------------------


create or replace view vwattendance
as
select
os.TEACHERSEQ as "교사번호",
a.OPENSUBJECTSEQ as "과목번호",
SUBJECTNAME as "과목명",
a.SUGANGSEQ as "수강번호",
ATTENDANCEDATE as "날짜",
type as "근태유형",
STARTTIME as "출근시간",
ENDTIME as "퇴근시간",
case
    when outingseq is null then 'X'
    else 'O, ' || outringtime || ' ~ ' || returntime
end as "외출여부 및 시간",
oc.OPENCOURSESEQ as "과정번호",
oc.STARTDATE as "과정시작",
oc.ENDDATE as "과정종료"
--count(*)
from TBLATTENDANCE a
    left outer join TBLSUGANG su on a.SUGANGSEQ = su.SUGANGSEQ
        left outer join TBLSTUDENT stu on su.MEMBERSEQ = stu.MEMBERSEQ
            left outer join TBLMEMBER me on stu.MEMBERSEQ = me.MEMBERSEQ
                left outer join TBLOPENSUBJECT os on a.OPENSUBJECTSEQ = os.OPENSUBJECTSEQ
                    left outer join TBLSUBJECT sub on os.SUBJECTSEQ = sub.SUBJECTSEQ
                        left outer join TBLOPENCOURSE oc on os.OPENCOURSESEQ = oc.OPENCOURSESEQ
                            left outer join TBLCOURSE co on oc.COURSESEQ = co.COURSESEQ
                                left outer join TBLCLASSROOM cl on oc.CLASSROOMSEQ = cl.CLASSROOMSEQ
                                    left outer join TBLOUTING ou on a.ATTENDANCESEQ = ou.ATTENDANCESEQ
    order by a.SUGANGSEQ, a.ATTENDANCEDATE;



create or replace view vwNullDate
as
select
regdate,
case
    when to_char(v.regdate, 'd') in ('1', '7') and h.name is not null then '토, 일'
    when to_char(v.regdate, 'd') in ('1', '7') and h.name is null then '토, 일'
    else '공휴일'
end as type
from
((select
    to_date('2021-07-02','yyyy-mm-dd') + level -1 as regdate
    from dual
        connect by level <= (to_date('2021-12-27', 'yyyy-mm-dd') - to_date('2021-07-02','yyyy-mm-dd')+1)
            minus select distinct(ATTENDANCEDATE) from TBLATTENDANCE) v
                left outer join TBLHOLIDAY h on v.regdate = h.HOLIDAY)
                     order by v.regdate;



create table tblNullDate(
        regdate date primary key,
        type varchar2(60) not null
);



declare
    vregdate tblNullDate.regdate%type;
    vtype tblNullDate.type%type;
    cursor vcursor is select regdate, type from vwNullDate;
begin
    open vcursor;
        loop
            fetch vcursor into vregdate,vtype;
            exit when vcursor%notfound; --boolean
            insert into tblNullDate values (vregdate,vtype);
        end loop;
    close vcursor;
end;




declare
    vSugangMin number;
    vSugangMax number;
    vopenSubjectSeqMin number;
    vopenSubjectSeqMax number;
    vnull number;
    vSubjectStart date;
    vSubjectEnd date;
    vDate tblNullDate.regdate%type;
    vType tblNullDate.type%type;
    cursor vcursor is select regdate, type from tblNullDate;

begin
    select min(SUGANGSEQ) into vSugangMin from tblattendance;
    select max(SUGANGSEQ) into vSugangMax from tblattendance;
    select min(OPENSUBJECTSEQ) into vopenSubjectSeqMin from TBLOPENSUBJECT;
    select max(OPENSUBJECTSEQ) into vopenSubjectSeqMax from TBLOPENSUBJECT;
    for suSeq in vSugangMin..vSugangMax loop
        for subSeq in vopenSubjectSeqMin..vopenSubjectSeqMax loop
            select count(distinct(OPENSUBJECTSEQ)) into vnull from tblattendance where SUGANGSEQ = suSeq and OPENSUBJECTSEQ = subSeq;
            if vnull > 0 then
                select STARTDATE into vSubjectStart from TBLOPENSUBJECT where OPENSUBJECTSEQ = subSeq;
                select ENDDATE into vSubjectEnd from TBLOPENSUBJECT where OPENSUBJECTSEQ = subSeq;
                open vcursor;
                    loop
                        fetch vcursor into vDate, vType;
                        exit when vcursor%notfound;
                        if (vDate >= vSubjectStart and vDate <= vSubjectEnd) then
                             insert into tblAttendance values (seqAttendance.nextVal,vDate,subSeq, suSeq, vType , '0', '0');
                        end if;
                    end loop;
                close vcursor;
            end if;
        end loop;
    end loop;
end;





-- 요구사항 : 교사가 자신이 강의한 과목들에 대해서 전체 또는 특정 인원의 출결을 확인할 수 있어야 한다.
    -- 한 교사가 가르치는 과목이 여러개일 수 있다고 전제
    -- 조회할 날짜 구간을 설정 가능해야 함
    -- 4가지 경우 각각에 대해 조회 가능해야 함
        -- 전체 과목, 전체 학생
        -- 전체 과목, 특정 학생
        -- 특정 과목, 전체 학생
        -- 특정 과목, 특정 학생
        
        
        
select
*
from vwattendance
        where "교사번호" = 10                                   -- 전체 과목, 전체 학생
        and "날짜" between to_date('2021-07-02', 'yyyy-mm-dd') and to_date('2021-07-05', 'yyyy-mm-dd') --특정 기간
--         and "과목번호" = 1                                     -- 특정 과목, 전체 학생
--         and "수강번호" = 14                                   -- 전체 과목, 특정 학생
--         and "과목번호" = 1 and "수강번호" = 14          --특정 과목, 특정 학생
            order by "수강번호", "날짜";








