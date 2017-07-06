/********************************************************************************
	release-type-snapshot-delta-validation-refset-descriptor

	Assertion:
	The current data in the Refset Descriptor snapshot file are the same as the data in
	the current delta file.
********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
    concat('Module Dependency: id=',a.id, ' is in delta file but not in snapshot file.')
    from curr_moduleDependency_d a
    left join curr_moduleDependency_s b
    on a.id = b.id
        and a.effectivetime = b.effectivetime
        and a.active = b.active
        and a.moduleid = b.moduleid
        and a.refsetid = b.refsetid
        and a.referencedcomponentid = b.referencedcomponentid
        and a.sourceeffectivetime = b.sourceeffectivetime
        and a.targeteffectivetime=b.targeteffectivetime
    where ( b.id is null
        or b.effectivetime is null
        or b.active is null
        or b.moduleid is null
        or b.refsetid is null
        or b.referencedcomponentid is null
        or b.sourceeffectivetime is null
        or b.targeteffectivetime is null
        ) ;
    commit;
