/********************************************************************************
    release-type-snapshot-description-type-successive-states

    Assertion:
    New inactive states follow active states in the Description Type snapshot.

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Description Type Id=',a.id, ' should not have a new inactive state as it was inactive previously.')
    from curr_descriptionType_s a , prev_descriptionType_s b
    where a.effectivetime != b.effectivetime
    and a.active = 0
    and a.id = b.id
    and a.active = b.active;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Description Type Id=',a.id, ' is inactive but no active state found in the previous snapshot.')
    from curr_descriptionType_s a left join prev_descriptionType_s b
    on a.id = b.id
    where a.active = 0
    and b.id is null;
