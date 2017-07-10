

/********************************************************************************
    release-type-snapshot-concept-changed-from-primitive-to-fully-defined

    Assertion:
    Warning that there are no concepts that changed from primitive to fully defined

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.id,
        concat('CONCEPT: id=',a.id, ' has changed from primitive to fully defined.')
	from curr_concept_s a, prev_concept_s b
	where a.effectivetime != b.effectivetime
	and a.id = b.id
	and b.active = 1
	and a.active = 1
	and a.definitionstatusid = '900000000000073002' /* Sufficiently defined concept - Defined*/
	and b.definitionstatusid = '900000000000074008' /* Necessary but not sufficient concept - Primitive*/;
    commit;
