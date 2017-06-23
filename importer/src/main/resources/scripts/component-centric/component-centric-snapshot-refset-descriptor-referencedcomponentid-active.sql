/********************************************************************************
	component-centric-snapshot-refset-descriptor-referencedcomponentid-active

	Assertion:
	REFSET DESCRIPTOR SNAPSHOT contains only active rows where the referenced refset is active

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('REFSET DESCRIPTOR SNAPSHOT: id=',a.id,' contains inactive rows where the referenced refset is active')
        from curr_refsetdescriptor_s a
        left join curr_concept_s b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;