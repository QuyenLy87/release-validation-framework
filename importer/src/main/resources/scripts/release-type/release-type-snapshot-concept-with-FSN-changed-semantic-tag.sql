/********************************************************************************
    release-type-snapshot-concept-with-FSN-changed-semantic-tag.sql

    Assertion:
    Warning that there are no concepts with FSNs changed semantic tags

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
        <RUNID>,
        '<ASSERTIONUUID>',
        a.id,
        concat('CONCEPT: id=',a.id, ' has FSN changed semantic tag')
	from curr_concept_s a, prev_concept_s b, curr_description_s c, prev_description_s d
	where a.id = b.id
	and a.id = c.conceptid
	and b.id = d.conceptid
	and c.typeid = d.typeid
	and c.typeid= '900000000000003001' /* Fully Specified Name */
    and trim(substr(c.term,1,instr(c.term,'(')-1))=trim(substr(d.term,1,instr(d.term,'(')-1))
    and trim(substr(c.term,instr(c.term,'('))) <> trim(substr(d.term,instr(d.term,'('))) ;
    commit ;