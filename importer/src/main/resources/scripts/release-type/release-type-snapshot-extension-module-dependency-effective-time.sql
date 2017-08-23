/*
* Verify that in the ModuleDependency files for all Extension packages (DK, SE, etc), the sourceEffectiveTime for each record is set to the effectiveTime for the Extension Package release, and the targetEffectiveTime is set to the effectiveTime for the dependent International Edition.
*/
insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('MODULE ID=',a.moduleId, ', REFSET ID=', a.refsetId, ' has sourceEffectiveTime ', a.sourceEffectiveTime, ' does not match with ', p.releasetime)

	from curr_moduledependency_s a, curr_package_info p
	where a.sourceeffectivetime != p.releasetime
	union all
    select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('MODULE ID=',a.moduleId, ', REFSET ID=', a.refsetId, ' has targetEffectiveTime ', a.targetEffectiveTime, ' does not match with ', p.dependentreleasetime)
    from curr_moduledependency_s a, curr_package_info p
	where a.targeteffectivetime != p.dependentreleasetime;
