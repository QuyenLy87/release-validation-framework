/********************************************************************************
	release-type-delta-validation-refset-descriptor

	Assertion:
	The current Refset Descriptor delta file is an accurate derivative of the current full file

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
    concat('Refset Descriptor: id=',a.id, ' is in DELTA file, but not in FULL file.')
    from curr_refsetDescriptor_d a
    left join curr_refsetDescriptor_f b
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
        or b.attributeorder is null);
    commit;