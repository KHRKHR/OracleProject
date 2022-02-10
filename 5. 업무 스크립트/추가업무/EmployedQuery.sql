
set serverout on;

select * from tblemployed;
delete from tblemployed where sugangseq = 187;


--취직자 추가 프로시저
CREATE OR REPLACE PROCEDURE procemployed(
    psugangseq number,
    pfirmname varchar2,
    pbuseo varchar2,
    pjikwi varchar2,
    pibsadate date,
    ppay number
)
is 
begin
   insert into TBLEMPLOYED (SUGANGSEQ, FIRMNAME, BUSEO, JIKWI, IBSADATE, PAY) VALUES (psugangseq, pfirmname, pbuseo, pjikwi, pibsadate, ppay);
end procemployed;

--추가 실행문
begin
    procemployed(187,'AAA','IT엔지니어','사원','2020-01-23', 3600);
end;


--입사날짜별 취직자 출력
create or replace procedure procibsadate(
    pstartdate date,
    penddate date,
    presult out sys_refcursor
)
is
begin
    open presult 
        for select * from tblemployed where pstartdate <= ibsadate  and ibsadate <= penddate;
        
end procibsadate;


--날짜별 출력 프리시저
declare
    vstartdate date := '2019-03-01';
    venddate date := '2019-06-30';   
    vresult sys_refcursor;
    vrow tblemployed%rowtype;
begin
    procibsadate(vstartdate, venddate, vresult);
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line(
            vrow.sugangSeq ||'-'||
            vrow.firmName||'-'|| 
            vrow.buseo ||'-'|| 
            vrow.jikwi ||'-'|| 
            vrow.ibsadate ||'-'||
            vrow.pay);
    end loop;    
end;


--페이별 출력
create or replace procedure procpay(
    ppay number,
    presult out sys_refcursor
)
is
begin
    open presult 
        for select * from tblemployed where pay >= ppay;
        
end procpay;


declare
    vpay number := 3300;
    vresult sys_refcursor;
    vrow tblemployed%rowtype;
begin
    procpay(vpay, vresult);
    loop
        fetch vresult into vrow;
        exit when vresult%notfound;
        dbms_output.put_line(
            vrow.sugangSeq ||'-'||
            vrow.firmName||'-'|| 
            vrow.buseo ||'-'|| 
            vrow.jikwi ||'-'|| 
            vrow.ibsadate ||'-'||
            vrow.pay);
    end loop;    
end;


