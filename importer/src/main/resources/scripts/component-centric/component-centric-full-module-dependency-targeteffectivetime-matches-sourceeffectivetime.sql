/********************************************************************************
	component-centric-full-module-dependency-targeteffectivetime-matches-sourceeffectivetime

	Assertion:
	For each record in Module Dependency Full file, the targetEffectiveTime always matches the sourceEffectiveTime
	(International Edition or all Derivative Packages)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id, ' in Module Dependency Full file , targetEffectiveTime = ',a.targeteffectivetime,' does not match the sourceEffectiveTime = ',a.sourceeffectivetime)
	from curr_moduleDependency_f a
	where a.targeteffectivetime <> a.sourceeffectivetime;
	commit;