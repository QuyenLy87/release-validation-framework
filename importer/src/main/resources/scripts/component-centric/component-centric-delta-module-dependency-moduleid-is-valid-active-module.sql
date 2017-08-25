

/********************************************************************************
	component-centric-delta-module-dependency-moduleid-is-valid-active-module

	Assertion:
	ModuleId is set to a valid, active module in Module Dependency Delta file

********************************************************************************/

    call validateModuleIdIsValidModuleInModuleDependencyDelta_proc(<RUNID>,'<ASSERTIONUUID>',
        'moduleDependency_d','moduleid ', ' is not valid descendant of 900000000000443000 |Module|');

	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Module with id = ',a.id,' in Module Dependency Delta file is inactive')
    from curr_moduleDependency_d a where a.active = 0;
	commit;