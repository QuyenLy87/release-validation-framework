/********************************************************************************
	release-type-snapshot-delta-validation-identifier

	Assertion:
	The current data in the Identifier snapshot file are the same as the data in
	the current delta file.
********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Identifier: identifierSchemeId=',a.identifierschemeid, ' is in delta file but not in snapshot file.')
    from curr_identifier_d a
    left join curr_identifier_s b
    on a.identifierschemeid = b.identifierschemeid
        and a.effectivetime = b.effectivetime
        and a.active = b.active
        and a.moduleid = b.moduleid
        and a.referencedcomponentid = b.referencedcomponentid
        and a.alternateidentifier = b.alternateidentifier
    where ( b.identifierschemeid is null
        or b.effectivetime is null
        or b.active is null
        or b.moduleid is null
        or b.referencedcomponentid is null
        or b.alternateidentifier is null
        ) ;
    commit;
