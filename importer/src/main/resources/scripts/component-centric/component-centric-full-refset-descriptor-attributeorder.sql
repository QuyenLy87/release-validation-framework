/********************************************************************************
	component-centric-full-refset-descriptor-attributeorder

	Assertion:
	AttributeOrder in REFSET DESCRIPTOR FULL is always set to value > = 0

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('AttributeOrder of: id=',a.id,' in REFSET DESCRIPTOR FULL is not set to value >= 0')
	from curr_refsetDescriptor_f a
	where a.attributeorder < 0;
	commit;