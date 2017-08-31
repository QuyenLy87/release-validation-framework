/********************************************************************************
	release-type-snapshot-module-dependency-new-record-with-new-effectivetime-assigned-in-targeteffectivetime

	Assertion:
	Verify that in the Module Dependency files there are new record(s) for each of the pre-existing active records
    (identified by the index of the three fields moduleId+refsetId+referencedComponentId)
	with the new effectiveTime (for the Release that is currently being run)
	assigned to them in the targetEffectiveTime field

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Module Dependency id = ',a.referencedcomponentid, ' has new record for pre-existing active records but new effectiveTime is not updated')
	from curr_moduleDependency_s a, prev_moduleDependency_s b, curr_package_info c
    where a.id = b.id
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
    and a.active = 1
    and a.effectivetime = a.targeteffectivetime
    and a.effectivetime != c.releasetime;
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
    	<RUNID>,
    	'<ASSERTIONUUID>',
    	a.referencedcomponentid,
    	concat('Module Dependency id = ',a.referencedcomponentid, ' new record for pre-existing active records but new effectiveTime is not assigned to targetEffectiveTime')
    from curr_moduleDependency_s a, prev_moduleDependency_s b, curr_package_info c
    where a.id = b.id
    and a.moduleid = b.moduleid
    and a.refsetid = b.refsetid
    and a.referencedcomponentid = b.referencedcomponentid
    and a.active = 1
    and a.effectivetime != a.targeteffectivetime
    and a.effectivetime = c.releasetime;
    commit;