/********************************************************************************
	release-type-snapshot-delta-validation-module-dependency

	Assertion:
	The current data in the Module Dependency snapshot file are the same as the data in
	the current delta file.
********************************************************************************/

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Refset Descriptor: id=',a.id, ' is in delta file but not in snapshot file.')
    from curr_refsetDescriptor_d a
    left join curr_refsetDescriptor_s b
    on a.id = b.id
        and a.effectivetime = b.effectivetime
        and a.active = b.active
        and a.moduleid = b.moduleid
        and a.refsetid = b.refsetid
        and a.referencedcomponentid = b.referencedcomponentid
        and a.attributedescription = b.attributedescription
        and a.attributetype=b.attributetype
        and a.attributeorder=b.attributeorder
    where ( b.id is null
        or b.effectivetime is null
        or b.active is null
        or b.moduleid is null
        or b.refsetid is null
        or b.referencedcomponentid is null
        or b.attributedescription is null
        or b.attributetype is null
        or b.attributeorder is null) ;
    commit;
