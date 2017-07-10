/********************************************************************************
    release-type-snapshot-concept-reactivated-since-last-release

    Assertion:
    Warning that there are no concepts have been re-activated since the last release

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.id,
        concat('CONCEPT: id=',a.id, ' should not have a new active state as it was active previously.')
	from curr_concept_s a, prev_concept_s b
	where a.effectivetime != b.effectivetime
	and a.id = b.id
	and a.active = b.active
	and a.active = 1;
    commit ;