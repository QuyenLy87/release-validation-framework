/********************************************************************************
	component-centric-full-refset-descriptor-referencedcomponentid-unique-attributeorder-is-zero

	Assertion:
	For each referencedComponentId there is one record where attributeOrder = 0 in REFSET DESCRIPTOR FULL

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset: id=',a.id,' ReferencedComponentId = ',a.referencedcomponentid,' has more than one record where attributeOrder = 0 in REFSET DESCRIPTOR FULL')
	from curr_refsetDescriptor_f a, (
                                    select  b.referencedcomponentid ,count(*) total
                                    from curr_refsetDescriptor_f b
                                    where b.attributeorder=0
                                    group by b.referencedcomponentid
                                    having count(*) > 1
                                    ) c
    where a.referencedcomponentid=c.referencedcomponentid
    and  a.attributeorder=0;
	commit;