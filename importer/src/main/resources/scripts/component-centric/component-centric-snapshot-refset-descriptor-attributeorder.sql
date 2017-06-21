/********************************************************************************
	component-centric-snapshot-refset-descriptor-attributeorder

	Assertion:
	AttributeOrder in REFSET DESCRIPTOR SNAPSHOT is always set to value > = 0

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('AttributeOrder of: id=',a.id,' in REFSET DESCRIPTOR SNAPSHOT is not set to value >= 0')
	from curr_refsetDescriptor_s a
	where a.attributeorder < 0;
	commit;