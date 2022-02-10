--신청자를 회원으로 등록하기

drop sequence SEQMEMBER;
create sequence seqMember start with 250;



create or replace procedure procaddmember (
    pname varchar2,
    pjumin varchar2,
    ptel varchar2,
    pemail varchar2,
    presult out number
)
is
begin
    insert into tblmember (memberseq, name, jumin, tel, email) values
    (seqmember.nextval,pname,pjumin,ptel,pemail);
    presult:=1;
    exception when others then presult:=0;
end;


--신청자 정보 출력
create or replace view vwapplicant as
select ta.applicantseq,ta.name,ta.jumin,ta.tel,ta.email,tas.interviewscore,tas.documentscore from tblapplicant ta left outer join tblapplicantscore tas on ta.applicantseq = tas.applicantseq;

select * from vwapplicant where applicantseq>201 order by applicantseq ;

--점수 등록
update TBLAPPLICANTSCORE set INTERVIEWSCORE =86,DOCUMENTSCORE=82 where APPLICANTSCORESEQ between 189 and 250;


declare
    cursor vcursor is select * from vwapplicant;
    vrow vwapplicant%rowtype;
    vresult number;
begin
    open vcursor;
    loop
        fetch vcursor into vrow;
        exit when vcursor%notfound;
        if (vrow.applicantseq > 201 and vrow.interviewscore >= 80 and vrow.documentscore >=80) then
            procaddmember(vrow.name, vrow.jumin, vrow.tel, vrow.email, vresult);
             if vresult =1 then
                dbms_output.put_line('성공');
            else
                dbms_output.put_line('실패');
            end if;
        end if;
    end loop;
    close vcursor;
end;

select * from tblMember where MEMBERSEQ>202;

rollback;


