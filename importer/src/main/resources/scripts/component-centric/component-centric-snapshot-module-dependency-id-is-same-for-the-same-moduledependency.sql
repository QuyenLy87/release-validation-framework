/********************************************************************************
	component-centric-snapshot-module-dependency-id-is-same-for-the-same-moduledependency

	Assertion:
	For each record in Module Dependency Snapshot file, the UUID is same for the same record
	identified by the index of the three fields moduleid + refsetid + referencedcomponentid

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id,' in Module Dependency Snapshot file is not same id for refsetId = ',a.refsetid,
		 ' moduleId = ', a.moduleid, ' referencedComponentId = ', a.referencedcomponentid)
    from (
    select distinct t1.id,t1.moduleId,t1.refsetid,t1.referencedcomponentid
    from curr_moduleDependency_s t1
    join curr_moduleDependency_s t2
    on t1.moduleid = t2.moduleid
    and t1.refsetid = t2.refsetid
    and t1.referencedcomponentid = t2.referencedcomponentid
    where t1.id<>t2.id
    ) a;
	commit;