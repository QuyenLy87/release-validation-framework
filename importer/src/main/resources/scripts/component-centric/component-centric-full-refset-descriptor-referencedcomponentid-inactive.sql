/********************************************************************************
	component-centric-full-refset-descriptor-referencedcomponentid-inactive

	Assertion:
	REFSET DESCRIPTOR FULL contains only inactive rows where the referenced refset is inactive

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('REFSET DESCRIPTOR FULL: id=',a.id,' contains active rows where the referenced refset is inactive')
        from curr_refsetdescriptor_f a
        left join curr_concept_f b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 0 and b.active = 1;
    commit;