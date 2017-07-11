/********************************************************************************
	component-centric-full-simple-refsetid-contains-Lateralizable-refset

	Assertion:
	Simple Refset Full file only contains Lateralizable refset (International Edition only)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id,' and refsetId = ',a.refsetid,' in Simple Refset Full file does not contain only Lateralizable refset')
	from curr_simplerefset_f a, package_info b
	where a.refsetid <> 723264001
	and b.releaseedition = 'INT';
	commit;