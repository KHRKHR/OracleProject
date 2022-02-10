--Student_sqlproject.sql / 김혜림

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
1. 교육생 로그인 성공 > 교육생 계정 정보 조회
    - 교육생 개인의 정보
    - 교육생 수강한 과정명 
    - 교육생 과정기간(시작 년월일, 끝 년월일)
    - 교육생이 사용하는 강의실 
*/

-- 교육생 계정 정보 조회 > Table select   
select*from tblMember;
select*from tblStudent;
select*from tblSugang;
select*from tblOpenCourse;
select*from tblCourse;
select * from tblClassroom;
       
-- 교육생 계정 정보 조회 > SQL Query              
select
a.name as 이름, 
a.jumin as 주민등록번호, 
a.tel as 전화번호, 
a.email as 이메일, 
d.courseName as 과정명,
c.startdate || ' ~ ' ||c.enddate as "과정기간", 
e.classroomName as 강의실
        from tblMember a
            left outer join tblStudent e
                on a.memberseq = e.memberseq
                    LEFT outer join tblSugang b
                        on a.memberseq = b.memberseq
                            left outer join tblOpenCourse c
                                on b.opencourseseq = c.opencourseseq             
                                    LEFT outer join tblCourse d
                                        on d.courseSeq = c.courseSeq
                                            LEFT outer join tblClassroom e
                                                on c.classroomSeq = e.classroomSeq
--where a.memberseq >= 14; --교육생 전원 조회용(14번부터 교육생)
where a.memberseq = '15'; --특정 교육생 조회용
                                            
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
2. 교육생 로그인 성공 > 과목 성적 정보 조회(교육생)
    - 이름
    - 이메일
    - 과목명
    - 개설 과목기간
    - 교재명
    - 교사명
    - 과목별 배점 정보(출결, 필기, 실기 배점)
    - 과목별 시험날짜
    - 시험 문제 
*/

-- 과목 성적 정보 조회 > Table select
select*from tblMember;
select*from tblStudent;
select*from tblSugang;
select*from tblOpenCourse;
select*from tblOpenSubject;
select*from tblSubject;
select*from tblBookSubject;
select*from tblBook;
select*from tblPoint;
select*from tblWrittenTest;
select*from tblPracticalTest;

-- 과목 시험 정보 조회 > SQL Query
select 
a.name as 이름,
a.email as 이메일,
c.subjectName as "과목명",
b.startdate || ' ~ ' || b.enddate as "개설 과목기간",
e.bookName as 교재명,
aa.name as 교사명,
g.attendancePoint as 출결배점, 
g.writtenPoint as 필기배점, 
g.practicalPoint as 실기배점,
k.testDate as 필기시험일자,
l.testDate as 실기시험일자,
case
    when k.testQuestion = 1 then ' ○'
    when k.testQuestion = 0 then ' X'
end as 필기문제,
case
    when l.testQuestion = 1 then ' ○'
    when l.testQuestion = 0 then ' X'
end as 실기문제
        from tblMember a
            left outer join tblSugang
                 on a.memberseq = tblSugang.memberseq
                     left outer join tblStudent
                         on tblSugang.memberseq = tblStudent.memberseq
                            left outer join tblSugang
                                on tblStudent.memberseq = tblSugang.memberseq
                                    left outer join tblOpenCourse 
                                        on tblSugang.openCourseSeq = tblOpenCourse.openCourseSeq
                                            left outer join tblOpenSubject b
                                                on tblOpenCourse.openCourseSeq = b.openCourseSeq
                                                    left outer join tblSubject c
                                                        on b.subjectseq = c.subjectseq
                                                            left outer join tblmember aa
                                                                 on b.teacherseq = aa.memberseq
                                                                     left outer join tblBookSubject
                                                                         on c.subjectseq = tblBookSubject.subjectseq
                                                                             left outer join tblBook e
                                                                                  on tblBookSubject.bookseq = e.bookseq
         left outer join tblWrittenTest k
            on b.openSubjectSeq = k.openSubjectSeq
                left outer join tblPracticalTest l
                    on b.openSubjectSeq = l.openSubjectSeq
                        left outer join tblPoint g
                            on b.openSubjectSeq = g.openSubjectSeq
--where a.memberseq >= 14 order by a.memberseq, 4 asc; --교육생 전원 조회용(14번부터 교육생)
where a.memberseq = '15' order by 4 asc; --특정 교육생 조회용(과목기간순)

/*
3. 교육생 로그인 성공 > 교육생 성적 정보 조회
    - 이름
    - 이메일
    - 과목 번호
    - 과목명
    - 교사명
    - 교재명
    - 과목기간(시작 년월일, 끝 년월일)
    - 중도탈락 일자
    + 과목별 성적 정보(출결, 필기, 실기 점수)
*/

-- 교육생 성적 정보 조회 > Table select
select*from tblMember;
select*from tblStudent;
select*from tblSugang;
select*from tblOpenCourse;
select*from tblOpenSubject;
select*from tblSubject;
select*from tblBookSubject;
select*from tblBook;
select*from tblAttendanceScore;
select*from tblWrittenTestScore;
select*from tblPracticalTestScore;
select*from tblDrop;

-- 교육생 성적 정보 조회 > view
-- 교육생 정보 view
create view vwstudent
as
select 
a.name as "이름",
a.email as "이메일",
a.memberseq as "교육생번호",
tblsugang.sugangseq as "수강번호",
b.opensubjectSeq as "과목번호", 
c.subjectName as "과목명",
aa.name as "교사명",
e.bookName as "교재명",
b.startdate || ' ~ ' || b.enddate as "개설 과목기간",
Z.dropDate as "중도탈락 일자"
        from tblMember a
            left outer join tblSugang
                 on a.memberseq = tblSugang.memberseq
                     left outer join tblStudent
                         on tblSugang.memberseq = tblStudent.memberseq
                            left outer join tblSugang
                                on tblStudent.memberseq = tblSugang.memberseq
                                    left outer join tblOpenCourse 
                                        on tblSugang.openCourseSeq = tblOpenCourse.openCourseSeq
                                            left outer join tblOpenSubject b
                                                on tblOpenCourse.openCourseSeq = b.openCourseSeq
                                                    left outer join tblSubject c
                                                        on b.subjectseq = c.subjectseq
                                                            left outer join tblmember aa
                                                                 on b.teacherseq = aa.memberseq
    left outer join tblBookSubject
      on c.subjectseq = tblBookSubject.subjectseq                                                                   
        left outer join tblBook e
          on tblBookSubject.bookseq = e.bookseq                                                                        
            left outer join tblDrop z                                                                        
                on tblSugang.sugangSeq = z.sugangSeq                                                                                                                                                                                                                                                                                                                                                
order by tblsugang.sugangseq, b.opensubjectSeq;
    
SELECT * FROM vwstudent; 
--drop view vwStudent;

-- 점수 조회 view
create view vwscore
as
select 
    s.*,
    a.attendancescore as "출결점수",
    b.writtentestscore as "필기점수",
    c.practicaltestscore as "실기점수"
from vwstudent s
    left outer join tblattendancescore a
        on s."과목번호" = a.opensubjectseq and s."수강번호" = a.sugangseq
            left outer join tblwrittentest e 
                on s."과목번호" = e.opensubjectseq
                    left outer join tblwrittentestscore b
                        on s."수강번호" = b.sugangseq and e.testseq = b.writtentestseq
                            left outer join tblPracticalTest f
                                on s."과목번호" = f.opensubjectseq
                                    left outer join tblPracticalTestScore c
                                        on s."수강번호" = c.sugangseq and f.practicaltestseq = c.practicaltestseq
ORDER BY 3 asc, 4 ASC, 8 asc; 

SELECT * FROM vwscore;
--drop view vwscore;

-- 배점, 시험일자 정보 조회(점수 조회 vwscore + vwstudentpoint)  > View (필요시 추가용)
create view vwstudentpoint
as
select 
s.*,
g.attendancePoint as "출결배점", 
g.writtenPoint as "필기배점", 
g.practicalPoint as "실기배점",
k.testDate as "필기시험일자",
l.testDate as "실기시험일자",
k.testQuestion as "필기문제",
l.testQuestion as "실기문제"
from vwscore s
         left outer join tblWrittenTest k
            on s."과목번호" = k.opensubjectseq
                left outer join tblPracticalTest l
                    on s."과목번호" = l.opensubjectseq
                        left outer join tblPoint g
                            on s."과목번호" = g.openSubjectSeq;
                            
SELECT * FROM vwstudentpoint; 
--drop view vwstudentpoint;

-- 교육생번호 별 출력 프로시저
create or replace procedure procSIStudentSert(
    pstudentseq number,
    presult out sys_refcursor
)
is
begin
     open presult 
        for select * from vwscore
                where "교육생번호" =  pstudentseq;          
end;

declare
    vsubjectseq number := 14;
    vresult sys_refcursor;
    vrow vwscore%rowtype;
begin
    procSIStudentSert(vsubjectseq, vresult);
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line(
            vrow."이름" || '-' ||
            vrow."이메일"|| '-' ||
            vrow."과목명" || '-' ||
            vrow."교사명" || '-' ||
            vrow."교재명" || '-' ||
            vrow."개설 과목기간" || '-' ||
            vrow."중도탈락 일자" || '-' ||
            vrow."출결점수" || '-' ||
            vrow."필기점수" || '-' ||
            vrow."실기점수");
    end loop;    
end;

set serverout on;
set serverout off;
drop procedure procSIStudentSert;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------                

/*
4. 교육생 로그인 성공 > 교육생 출결 정보 조회
    - 매일 근태 관리를 기록한다. (출근1회, 퇴근1회)
    - 본인의 출결 현황을 기간별(전체, 월, 일)로  조회한다.
    - 타 교육생의 현황은 조회할 수 없다. (본인 출결만 가능)
    - 모든 출결 조회는 근태 상황을 구분한다. 
        (ex) 정상, 지각, 조퇴, 외출, 병가, 기타)
    - 각 과정의 시작일에는 OT일로 간주하여 출결 기록 X.
*/

-- 교육생 출결 정보 조회 > Table select
select * from tblAttendance;
select * from tblOuting;
select * from tblMember;
select * from tblHoliday;

-- 교육생 출결 정보 조회 > SQL Query
select
a.name as 이름, 
a.email as 이메일, 
e.courseName as 과정명,
b.attendanceDate as 일자,
b.startTime as 입실시간,
b.endTime as 퇴실시간,
b.type as 출결상태,
case
    when c.outringtime is null then ' '
    when c.outringtime is not null then c.outringtime
end as 외출시간,
case
    when c.returnTime is null then ' '
    when c.returnTime is not null then c.returnTime
end as 복귀시간
 from tblMember a
    left outer join tblStudent
        on a.memberseq = tblStudent.memberseq
            left outer join tblSugang
                on tblStudent.memberseq = tblSugang.memberseq
                    left outer join tblSugang
                        on tblStudent.memberseq = tblSugang.memberseq
                            left outer join tblAttendance b 
                                on tblSugang.sugangSeq = b.sugangSeq 
                                    left outer join tblOuting c
                                         on b.attendanceSeq = c.attendanceSeq
                                            left outer join tblOpenCourse
                                                on tblSugang.opencourseSeq = tblOpenCourse.opencourseSeq
                                                    left outer join tblCourse e
                                                         on tblOpenCourse.courseSeq = e.courseSeq
--where a.memberseq >= 14; --교육생 전원 조회용(14번부터 교육생)
where a.memberseq = '15' order by 4 asc; --특정 교육생 조회용

--where to_char(attendanceDate,'mm')=07 order by attendanceDate asc; --월별 조회용
--as "7월 출석일자" --select 구문추가용

--where a.name = '엄연연' order by attendancedate desc; --'엄연연' 교육생 출퇴근 인서트 확인용
--insert into tblAttendance values (seqAttendance.nextVal, '2021-12-11', 1, 1, '정상', '08:58', '18:23'); --'엄연연' 교육생 출퇴근 인서트
--rollback;
--commit;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
5. 교육생 로그인 성공 > 교육생 과목 평가 정보 조회
    - 교육생들은 수강신청 과정의 각 과목을 마친 후 평가한다.
    - 과목 평가는 10가지 항목으로 평가된다. 
    - 과목 평가는 한 항목 당 1~5점까지 기록한다.
*/

-- 교육생 과목 평가 정보 조회 > Table select
select * from tblEvaluation;
select * from tblItemEvaluation;
select * from tblMember;
select * from tblQuestion;

-- 교육생 과목 평가 정보 조회 > SQL Query
select
a.name as 이름,
a.email as 이메일,
b.openSubjectSeq as 과목번호, 
c.subjectName as 과목명,
aa.name as 교사명,
d.questionSeq || '. ' ||e.question as 평가항목,
d.itemEvaluationScore as 평가점수
    from tblMember a
        inner join tblStudent
            on a.memberseq = tblStudent.memberseq
                inner join tblSugang
                    on tblStudent.memberseq = tblSugang.memberseq
                             inner join tblEvaluation b
                                on tblSugang.sugangSeq = b.sugangSeq
                                     inner join tblOpensubject
                                         on b.openSubjectSeq = tblOpensubject.openSubjectSeq
                                             inner join tblSubject c
                                                on tblOpensubject.SubjectSeq = c.SubjectSeq
                                                    inner join tblmember aa
                                                       on tblOpensubject.teacherseq = aa.memberseq
                                                        inner join tblItemEvaluation d
                                                            on b.evaluationSeq = d.evaluationSeq
                                                                inner join tblQuestion e
                                                                    on d.questionSeq = e.questionSeq                                     
--where a.memberseq >= 14 order by 3 asc; --교육생 전원 조회용(14번부터 교육생)
where a.memberseq = '15' order by 3 asc, d.questionSeq asc; --특정 교육생 조회용

-- 교육생 과목 평가 정보 조회 > View
create or replace view vwEvaluation
as
select
a.name as "이름",
a.email as "이메일",
a.memberseq as "회원번호",
b.openSubjectSeq as "과목번호",
c.subjectName as "과목명",
aa.name as "교사명",
d.questionSeq || '. ' ||e.question as "평가항목",
d.itemEvaluationScore as "평가점수"
    from tblMember a
        inner join tblStudent
            on a.memberseq = tblStudent.memberseq
                inner join tblSugang
                    on tblStudent.memberseq = tblSugang.memberseq
                             inner join tblEvaluation b
                                on tblSugang.sugangSeq = b.sugangSeq
                                     inner join tblOpensubject
                                         on b.openSubjectSeq = tblOpensubject.openSubjectSeq
                                             inner join tblSubject c
                                                on tblOpensubject.SubjectSeq = c.SubjectSeq
                                                    inner join tblmember aa
                                                       on tblOpensubject.teacherseq = aa.memberseq
                                                        inner join tblItemEvaluation d
                                                            on b.evaluationSeq = d.evaluationSeq
                                                                inner join tblQuestion e
                                                                    on d.questionSeq = e.questionSeq;

select * from vwEvaluation; --교육생 전원 조회용(14번부터 교육생)
--select * from vwEvaluation where ”회원번호” = 15; --특정 교육생 조회용
--drop view vwEvaluation;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
6. 교육생 로그인 성공 > 교육생 교재 수령 여부 정보 조회
    - 교육생이 수강신청한 개설 과목에 따라 교재를 지급한다.
    - 교재 수령 했을 시 ‘1’ 표기.
    - 교재 수령 안했을 시 ‘0’ 표기.
    - 교육생 본인이 수강신청한 개설 과목에 따른 교재만 지급한다.
*/

-- 교육생 교재 수령 여부 정보 조회 > Table select
select * from tblBookState;
select * from tblMember;
select * from tblBook;

-- 교육생 교재 수령 여부 정보 조회 > SQL Query
select DISTINCT
a.name as 이름,
a.email as 이메일,
b.subjectName as 과목명,
e.bookName as 교재명,
e.publisher as 출판사명,
case
    when d.bookstate = 1 then ' ○'
    when d.bookstate = 0 then ' X'
end as 수령여부
    from tblMember a
        inner join tblStudent
            on a.memberseq = tblStudent.memberseq
                inner join tblSugang
                    on tblStudent.memberseq = tblSugang.memberseq
                             inner join tblOpencourse 
                                on tblopencourse.opencourseseq = tblsugang.opencourseseq
                                    inner join tblOpensubject c 
                                        on tblopencourse.opencourseseq = c.opencourseseq
                                            inner join tblsubject b
                                                on c.subjectseq = b.subjectseq
                                                    inner join tblBookState d
                                                        on c.opensubjectseq = d.opensubjectseq
                                                            inner join tblBookSubject
                                                                on b.subjectseq = tblBookSubject.subjectseq
                                                                     inner join tblBook e
                                                                         on tblBookSubject.bookseq = e.bookseq
--where a.memberseq >= 14 ORDER BY 1 asc, 4 asc; --교육생 전원 조회용(14번부터 교육생)
where a.memberseq = '15' ORDER BY 4 asc; --특정 교육생 조회용

-- 교육생 교재 수령 여부 정보 조회 > View
create or replace view vwbook
as
select DISTINCT
a.name as "이름",
a.email as "이메일",
a.memberseq as "회원번호",
b.subjectName as "과목명",
e.bookName as "교재명",
e.publisher as "출판사명",
case
    when d.bookstate = 1 then ' ○'
    when d.bookstate = 0 then ' X'
end as "수령여부"
    from tblMember a
        inner join tblStudent
            on a.memberseq = tblStudent.memberseq
                inner join tblSugang
                    on tblStudent.memberseq = tblSugang.memberseq
                             inner join tblOpencourse
                                on tblopencourse.opencourseseq = tblsugang.opencourseseq
                                    inner join tblOpensubject c
                                        on tblopencourse.opencourseseq = c.opencourseseq
                                            inner join tblsubject b
                                                on c.subjectseq = b.subjectseq
                                                    inner join tblBookState d
                                                        on c.opensubjectseq = d.opensubjectseq
                                                            inner join tblBookSubject
                                                                on b.subjectseq = tblBookSubject.subjectseq
                                                                     inner join tblBook e
                                                                         on tblBookSubject.bookseq = e.bookseq
                                                                            order by 3 asc;
                                                                         
select * from vwbook; --교육생 전원 조회용(14번부터 교육생)
--select * from vwbook where "회원번호" = 15; --특정 교육생 조회용
--drop view vwbook;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




