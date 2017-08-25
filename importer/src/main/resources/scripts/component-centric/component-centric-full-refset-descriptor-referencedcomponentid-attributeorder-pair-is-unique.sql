/********************************************************************************
	component-centric-full-refset-descriptor-referencedcomponentid-attributeorder-pair-is-unique

	Assertion:
	referencedComponentId + attributeOrder pair is unique in REFSET DESCRIPTOR FULL

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset: id=',a.id,' with ReferencedComponentId = ',a.referencedcomponentid,' + AttributeOrder = ',a.attributeorder,'  is not unique pair in REFSET DESCRIPTOR FULL')
	from curr_refsetDescriptor_f a
    where (a.referencedcomponentid,a.attributeorder) in (
													select b.referencedcomponentid,b.attributeorder
													from curr_refsetDescriptor_f b
													group by b.referencedcomponentid,b.attributeorder
													having count(*) > 1
													);
	commit;