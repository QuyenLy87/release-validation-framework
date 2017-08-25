
/********************************************************************************
	release-type-delta-validation-description-type

	Assertion:
	The current Description Type delta file is an accurate derivative of the current full file

********************************************************************************/

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
    concat('Description Type: id=',a.id, ' is in DELTA file, but not in FULL file.')
    from curr_descriptionType_d a
    left join curr_descriptionType_f b
        on a.id = b.id
        and a.effectivetime = b.effectivetime
        and a.active = b.active
        and a.moduleid = b.moduleid
        and a.refsetid = b.refsetid
        and a.referencedcomponentid = b.referencedcomponentid
        and a.descriptionformat = b.descriptionformat
        and a.descriptionlength=b.descriptionlength
    where ( b.id is null
        or b.effectivetime is null
        or b.active is null
        or b.moduleid is null
        or b.refsetid is null
        or b.referencedcomponentid is null
        or b.descriptionformat is null
        or b.descriptionlength is null
        );
    commit;