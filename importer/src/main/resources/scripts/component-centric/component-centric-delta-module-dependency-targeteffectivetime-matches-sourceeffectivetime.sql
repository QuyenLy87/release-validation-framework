/********************************************************************************
	component-centric-delta-module-dependency-targeteffectivetime-matches-sourceeffectivetime

	Assertion:
	For each record in Module Dependency Delta file, the targetEffectiveTime always matches the sourceEffectiveTime
	(International Edition or all Derivative Packages)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id, ' in Module Dependency Delta file , targetEffectiveTime = ',a.targeteffectivetime,' does not match the sourceEffectiveTime = ',a.sourceeffectivetime)
	from curr_moduleDependency_d a, package_info b
	where a.targeteffectivetime <> a.sourceeffectivetime
	and (
    b.releaseedition = 'INT'
    or b.releaseedition = 'SE'
    or b.releaseedition = 'DK'
    or b.releaseedition = 'GPFP'
    or b.releaseedition = 'ICNP'
    );
	commit;