/********************************************************************************
    release-type-snapshot-identifier-successive-states

    Assertion:
    New inactive states follow active states in the Identifier snapshot.

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Identifier with SchemeId=',a.identifierschemeid, ' should not have a new inactive state as it was inactive previously.')
    from curr_identifier_s a , prev_identifier_s b
    where a.effectivetime != b.effectivetime
    and a.active = 0
    and a.identifierschemeid = b.identifierschemeid
    and a.active = b.active;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.referencedcomponentid,
        concat('Identifier with SchemeId=',a.identifierschemeid, ' is inactive but no active state found in the previous snapshot.')
    from curr_identifier_s a left join prev_identifier_s b
    on a.identifierschemeid = b.identifierschemeid
    where a.active = 0
    and b.identifierschemeid is null;