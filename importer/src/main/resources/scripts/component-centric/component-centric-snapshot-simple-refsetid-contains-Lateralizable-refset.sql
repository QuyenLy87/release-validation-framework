/********************************************************************************
	component-centric-snapshot-simple-refsetid-contains-Lateralizable-refset

	Assertion:
	Simple Refset Snapshot file only contains Lateralizable refset (International Edition only)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id,' and refsetId = ',a.refsetid,' in Simple Refset Snapshot file does not contain only Lateralizable refset')
	from curr_simplerefset_s a, curr_package_info b
	where a.refsetid <> 723264001
	and b.releaseedition like '%INT%';
	commit;