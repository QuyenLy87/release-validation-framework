/********************************************************************************
	release-type-delta-validation-identifier

	Assertion:
	The current Identifier delta file is an accurate derivative of the current full file

********************************************************************************/

   insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
    concat('Identifier: identifierSchemeId=',a.identifierschemeid, ' is in DELTA file, but not in FULL file.')
    from curr_identifier_d a
    left join curr_identifier_f b
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
        );
    commit;