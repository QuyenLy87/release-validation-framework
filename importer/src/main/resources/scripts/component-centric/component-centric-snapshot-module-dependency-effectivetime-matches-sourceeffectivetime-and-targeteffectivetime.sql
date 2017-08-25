/********************************************************************************
	component-centric-snapshot-module-dependency-effectivetime-matches-sourceeffectivetime-and-targeteffectivetime

	Assertion:
	For each record in Module Dependency Snapshot file, the effectiveTime always matches the sourceEffectiveTime and targetEffectiveTime
	(International Edition or all Derivative Packages)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id, ' in Module Dependency Snapshot file , effectiveTime = ',a.effectivetime,' does not match the sourceEffectiveTime and targetEffectiveTime = ',a.sourceeffectivetime)
	from curr_moduleDependency_s a
	where a.effectivetime <> a.sourceeffectivetime
    and a.sourceeffectivetime = a.targeteffectivetime;
	commit;