<p align="center">  
<h1 align="middle">:book:  오라클 DB 프로젝트 - SY 교육 관리 시스템  :book:</h1>
<p align="center">
<img src="https://user-images.githubusercontent.com/97592294/153464931-6c029cfa-b7d2-494c-a771-2e5898fcb9fd.png" width="800" />
</p>


</p>
<br>
<p align="middle">저의 두번째 팀 프로젝트,</p>
<p align="center">학생과 선생님 관리 및 교육에 대한 전반적인 관리 시스템</p>
<h3 align="center"><b>SY 교육 관리 시스템</b>입니다! </h3>

<br><br><br><br><br><br>

<h2 align="middle"> 🙋‍♀️ 쌍용은행을 만든 사람들 🙋‍♂️</h2>
<p align="center">
  
| [혜림]  |  [기현]  |   [재경]      |  [찬우]  | [세라]   | [재형]   |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | 
| <img src="https://user-images.githubusercontent.com/43840561/129164013-2a88c2e7-1a93-4cc7-bbd8-c5818f5152c7.png"/> | <img src="https://user-images.githubusercontent.com/44080404/133540314-639cc580-1aa5-4bf4-8d54-b435bfe5e5f8.png" /> | <img src="https://user-images.githubusercontent.com/44080404/133540309-ae1e774e-4404-4801-bb5c-0037eab41818.PNG" /> | <img src="https://user-images.githubusercontent.com/44080404/133540317-20da5664-aa3d-4afb-809b-a7d4780a5a17.png" /> |  <img src="https://user-images.githubusercontent.com/44080404/133540321-7f8f4215-3e01-4f21-88e3-90d608377aab.png" /> | <img src="https://user-images.githubusercontent.com/44080404/133540503-22c158d4-1042-4e7c-9ee5-79c694bf5841.png" /> |

</p>

<br><br><br><br><br><br>

<p align="center">
<h2 align="middle"> 프로젝트 개요 및 환경 👨‍💻 </h2>
<br>
<h3>1. 프로젝트 개요</h3>
· 교육생, 계정관리⠂성적조회⠂출결조회⠂추가업무<br>
· 교사, 강의 스케줄 출력⠂배점 입력⠂시험정보 입력⠂성적 입출력⠂출결 조회<br>
· 관리자, 교육생 관리⠂시험관리 및 성적 조회⠂개설 과정 관리⠂개설 과목 관리<br>
· 관리자, 신청자 등록⠂기초 정보 관리⠂교사 계정 관리⠂출결 관리<br>

<h3>2. 프로젝트 환경</h3>
· Windows 7, 10<br>
· Oracle SQL Developer<br>
· DataGrip<br>
<br><br><br><br><br><br>

<h2 align="middle"> 데이터 설계 🎡 </h2>
<br>
<h3>· ERD 구조</h3>
<img src="https://user-images.githubusercontent.com/97592294/153466569-2867a0be-a676-49a4-8c33-4ef1335555dd.png">
<br><br><br><br><br><br>

<h2 align="middle"> 나의 담당 업무 🎯 </h2>
<br>
<h3>· 교육생 계정 관리</h3><br>
<img src="https://user-images.githubusercontent.com/97592294/153469382-8475b6b4-31db-4108-9693-31600f937d85.png" width="800" />
<h4>1. 교육생의 계정 정보 조회를 구현했습니다.</h4>
<h4>2. 회원 정보들과 여러 테이블을 innerjoin 하여 구현하였습니다.</h4>
<pre>
<code>
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
</code>
</pre>
<br>
<h3>· 교육생 성적 조회</h3><br>
<img src="https://user-images.githubusercontent.com/97592294/153469897-04802543-e919-4825-83e5-478e11da0401.png" width="800" />
<h4>1. 교육생의 성적 정보 조회를 구현하였습니다.</h4>
<h4>2. 뷰를 생성하였으며 교육생이 수강한 과목에 따라 성적을 확인 할 수 있습니다.</h4>
<h4>3. 추가로 교육생 번호 별 프로시저를 생성하였습니다.</h4>
<pre>
<code>
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
</code>
</pre>
<br>
<h3>· 교육생 출결 조회</h3><br>
<img src="https://user-images.githubusercontent.com/97592294/153470883-09f2f416-e3b3-4824-b84f-d61fe61fb35b.png" width="800" />
<h4>1. 교육생들의 출결을 일별로 확인 할 수 있습니다.</h4>
<h4>2. innerjoin을 사용하여 구현하였으며 case를 사용하여 조건을 추가하였습니다.</h4>
<pre>
<code>
	case
    when c.outringtime is null then ' '
    when c.outringtime is not null then c.outringtime
end as 외출시간,
case
    when c.returnTime is null then ' '
    when c.returnTime is not null then c.returnTime
end as 복귀시간
</code>
</pre>
<br>
<h3>· 교육생 추가 업무</h3><br>
<img src="https://user-images.githubusercontent.com/97592294/153471184-e2c9d615-3611-4a5d-8f34-803feebcbb1d.png" width="800" />
<h4>1. 교육생들의 과목 평가 내용을 조회 할 수 있습니다.</h4>
<h4>2. 교육생들의 과목 평가 항목에 따른 평가 점수를 확인 할 수 있습니다.</h4>
<pre>
<code>
inner join tblStudent
            on a.memberseq = tblStudent.memberseq
                inner join tblSugang
                    on tblStudent.memberseq = tblSugang.memberseq
                             inner join tblEvaluation b
</code>
</pre>
<br>

<br><br><br><br><br><br>

<h2 align="middle"> ⚙️ 기술 스택 ⚙️ </h2>
<br>
<div align="middle">
<img src="https://img.shields.io/badge/Java-3178C6?style=flat-square&logo=Java&logoColor=white"/>
<img src="https://img.shields.io/badge/Eclipse IDE-000000?style=flat-square&logo=Next.Eclipse IDE&logoColor=white"/><br/>
<img src="https://img.shields.io/badge/Oracle-caa6fe?style=flat-square&logo=Oracle&logoColor=white"/>
<img src="https://img.shields.io/badge/MySQL-FF6C37?style=flat-square&logo=MySQL&logoColor=white"/>
</div>

<br><br><br><br><br><br>
