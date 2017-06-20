/********************************************************************************
	component-centric-full-refset-descriptor-refsetid

	Assertion:
	RefsetId in REFSET DESCRIPTOR FULL is always set to '900000000000456007'

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset: id=',a.id,' in REFSET DESCRIPTOR FULL is not set to value 900000000000456007')
	from curr_refsetDescriptor_f a
	where a.refsetid <> '900000000000456007';
	commit;