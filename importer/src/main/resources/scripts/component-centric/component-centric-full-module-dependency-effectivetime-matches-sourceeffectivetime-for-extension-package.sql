/********************************************************************************
	component-centric-full-module-dependency-effectivetime-matches-sourceeffectivetime-for-extension-package

	Assertion:
	For each record in Module Dependency Full file, the effectiveTime always matches the sourceEffectiveTime
	(for Extension packages)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id, ' in Module Dependency Full file , effectiveTime = ',a.effectivetime,' does not match the sourceEffectiveTime = ',a.sourceeffectivetime)
	from curr_moduleDependency_f a, package_info b
	where a.effectivetime <> a.sourceeffectivetime
    and (
    b.releaseedition = 'SE'
    or b.releaseedition = 'DK'
    or b.releaseedition = 'GPFP'
    or b.releaseedition = 'ICNP'
    );
	commit;