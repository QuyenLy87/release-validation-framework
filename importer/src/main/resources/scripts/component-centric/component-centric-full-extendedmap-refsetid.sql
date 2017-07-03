/********************************************************************************
	component-centric-full-extendedmap-refsetid

	Assertion:
	Extended Map Full file contains nothing except ICD-10 maps (International Edition only)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id,' and refsetId = ',a.refsetid,' in Extended Map Full file is not an ICD-10 map')
	from curr_extendedmaprefset_int_f a where a.refsetid not in (447562003);
	commit;