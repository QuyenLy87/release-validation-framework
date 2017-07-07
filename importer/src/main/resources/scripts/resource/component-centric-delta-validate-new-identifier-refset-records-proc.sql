/********************************************************************************
	component-centric-delta-validate-new-identifier-refset-records-proc

	Defines a procedure to validate there are no new SNOMED Identifier Refset records (900000000000498005)
	 in any file types in the Release package

********************************************************************************/
drop procedure if exists validateNewIdentifierRefsetRecordsDelta_procedure;
create procedure validateNewIdentifierRefsetRecordsDelta_procedure(runid bigint, assertionid varchar(36))
begin

    declare done int default 0;
	declare vtableName varchar(200);
    declare tmpcur cursor for select tablename from tmp;
	declare continue handler for not found set done = 1;
    drop temporary table if exists tmp ;
    create temporary table tmp (tablename varchar(200));

    insert into tmp values ('associationrefset_d'),
		('attributevaluerefset_d'),
		('complexmaprefset_d'),
		('expressionassociationrefset_d'),
		('extendedmaprefset_d'),
		('langrefset_d'),
		('mapcorrelationoriginrefset_d'),
		('moduledependency_d'),
		('mrcmattributedomainrefset_d'),
		('mrcmattributerangerefset_d'),
		('mrcmdomainrefset_d'),
		('mrcmmodulescoperefset_d'),
		('refsetdescriptor_d'),
		('simplerefset_d');

    open tmpcur;

	rloop: loop
		fetch tmpcur into vtableName;
		if done then
			leave rloop;
		end if;

		set @countstmt=concat('select count(*) into @numberOfRecords from ',vtableName,'  where referencedcomponentid=''900000000000498005'';');
		prepare statement from @countstmt;
		execute statement;

		if (@numberOfRecords <> 0) then
			set @insertstmt = concat('insert into qa_result (run_id, assertion_id,concept_id, details)
							select ',
							runid,',',
							assertionid,',
							result.conceptid,
							concat(''New record Id = '',result.id,'',conceptid = '',result.conceptid, '' referenced in the column referencedcomponentid of ',vtableName,' is existed invalidly.'')
							from
							    (select distinct id,t1.referencedcomponentid as conceptid
							    from  ',vtableName ,' as t1
							    where t1.referencedcomponentid = 900000000000498005  ) as result;');

		prepare statement from @insertstmt;
		execute statement;
        end if;

    end loop;
	close tmpcur;

end;
