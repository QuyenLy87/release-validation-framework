/********************************************************************************
	release-type-snapshot-sourceeffectivetime-is-set-to-effectivetime-targeteffectivetime-is-set-to-effectivetime-of-dependent-INT

	Assertion:
	Verify that in the ModuleDependency files for all Extension packages (DK, SE, etc):
	- The sourceEffectiveTime for each record is set to the effectiveTime for the Extension Package release
	- The targetEffectiveTime is set to the effectiveTime for the dependent International Edition

********************************************************************************/

    insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Module Dependency Refset with: id = ',a.id, ' does not have sourceEffectiveTime matched with effectiveTime.')
	from curr_moduleDependency_s a, package_info b
	where a.sourceeffectivetime <> a.effectivetime
	and
		( b.releaseedition like '%DK%'
	    or b.releaseedition like '%SE%'
	    )
    ;
    commit;

   insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Module Dependency Refset with: id = ',a.id, ' does not have targetEffectiveTime matched with effectiveTime of the dependent International Edition.')
	from curr_moduleDependency_s a, dependant_moduleDependency_s b, package_info c
	where a.targeteffectivetime <> b.effectivetime
	and
	    ( c.releaseedition like '%DK%'
	    or c.releaseedition like '%SE%'
	    )
    ;
    commit;