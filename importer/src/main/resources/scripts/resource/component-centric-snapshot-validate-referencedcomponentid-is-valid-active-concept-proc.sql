/********************************************************************************
	component-centric-snapshot-validate-referencedcomponentid-is-valid-active-concept-proc

	Defines a procedure to validate whether referencedComponentId is a valid, active concepts in all Refsets Snapshot

********************************************************************************/
drop procedure if exists validateValidActiveConceptInReferencedComponentIDSnapshot_proc;
create procedure validateValidActiveConceptInReferencedComponentIDSnapshot_proc(runId bigint, assertionId varchar(36),tablename varchar(255),expression varchar(4000))
begin
set @runSql1 = concat   ('
                        insert into qa_result (run_id, assertion_id,concept_id, details)
                        select ',
                        runId,',',
                        assertionId,',
                        result.conceptId,
						concat(''ConceptId='',result.conceptId, '' referenced in the column referencedcomponentid of ',expression,' is an inactive concept.'')
                        from
                        (select distinct t1.referencedcomponentid as conceptId from ',tablename,' as t1, concept_s as t2
                         where t1.referencedcomponentid=t2.id and t1.active=1  and t2.active =0
                        ) as result;
                        '
					    );

set @runSql2 = concat   ('
                         insert into qa_result (run_id, assertion_id,concept_id, details)
                         select ',
                         runId,',',
                         assertionId,',
                         result.conceptId,
                          concat(''ConceptId='',result.conceptId, '' referenced in the column referencedcomponentid of ',expression,' is an invalid concept.'')
                         from
                         (select distinct t1.referencedcomponentid as conceptId
                         from  ',tablename ,' as t1
                         where t1.referencedcomponentId not in (select id from concept_s)
                         )  as result;
                        '
					    );

prepare statement from @runSql1;
execute statement;

prepare statement from @runSql2;
execute statement;
end;