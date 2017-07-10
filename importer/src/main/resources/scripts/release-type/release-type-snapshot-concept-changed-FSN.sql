/********************************************************************************
    release-type-snapshot-concept-changed-FSN

    Assertion:
    Warning that there are no concepts with changed FSNs

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.id,
        concat('CONCEPT: id=',a.id, ' has changed FSN')
	from curr_concept_s a, prev_concept_s b, curr_description_s c, prev_description_s d
	where a.effectivetime != b.effectivetime
	and a.active = b.active
	and a.active = 1
	and a.id = b.id
	and a.id = c.conceptid
	and b.id = d.conceptid
	and c.typeid = d.typeid
	and c.typeid= '900000000000003001' /* Fully Specified Name */
    and c.term <> d.term;
    commit ;