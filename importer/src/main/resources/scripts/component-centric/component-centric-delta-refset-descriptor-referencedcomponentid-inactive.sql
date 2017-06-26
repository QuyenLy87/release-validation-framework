/********************************************************************************
	component-centric-delta-refset-descriptor-referencedcomponentid-inactive

	Assertion:
	REFSET DESCRIPTOR DELTA contains only inactive rows where the referenced refset is inactive

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('REFSET DESCRIPTOR DELTA: id=',a.id,' contains active rows where the referenced refset is inactive')
        from curr_refsetdescriptor_d a
        left join curr_concept_d b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 0 and b.active = 1;
    commit;