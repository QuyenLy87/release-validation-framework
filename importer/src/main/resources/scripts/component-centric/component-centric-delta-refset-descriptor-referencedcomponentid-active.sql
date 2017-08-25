/********************************************************************************
	component-centric-delta-refset-descriptor-referencedcomponentid-active

	Assertion:
	REFSET DESCRIPTOR DELTA contains only active rows where the referenced refset is active

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('REFSET DESCRIPTOR DELTA: id=',a.id,' contains inactive rows where the referenced refset is active')
        from curr_refsetdescriptor_d a
        left join curr_concept_d b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;