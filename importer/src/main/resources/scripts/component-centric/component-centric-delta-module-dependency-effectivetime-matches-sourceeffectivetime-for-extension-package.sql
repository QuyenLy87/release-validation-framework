/********************************************************************************
	component-centric-delta-module-dependency-effectivetime-matches-sourceeffectivetime-for-extension-package

	Assertion:
	For each record in Module Dependency Delta file, the effectiveTime always matches the sourceEffectiveTime
	(for Extension packages)

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset with id = ',a.id, ' in Module Dependency Delta file , effectiveTime = ',a.effectivetime,' does not match the sourceEffectiveTime = ',a.sourceeffectivetime)
	from curr_moduleDependency_d a, package_info b
	where a.effectivetime <> a.sourceeffectivetime
	and
	    ( b.releaseedition like '%DK%'
	    or b.releaseedition like '%SE%'
	    );
	commit;