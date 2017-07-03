/********************************************************************************
	component-centric-snapshot-module-dependency-targeteffectivetime-matches-sourceeffectivetime

	Assertion:
	For each record in Module Dependency Snapshot file, the targetEffectiveTime always matches the sourceEffectiveTime
	(International Edition only)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id, ' in Module Dependency Snapshot file , targetEffectiveTime = ',a.targeteffectivetime,' does not match the sourceEffectiveTime = ',a.sourceeffectivetime)
	from curr_moduleDependency_s a where a.targeteffectivetime <> a.sourceeffectivetime;
	commit;