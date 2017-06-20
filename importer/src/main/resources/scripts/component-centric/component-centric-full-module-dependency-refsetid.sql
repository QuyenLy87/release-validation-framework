/********************************************************************************
	component-centric-full-module-dependency-refsetid

	Assertion:
	RefsetId in MODULE DEPENDENCY FULL is always set to '900000000000534007'

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('Refset: id=',a.id,' in MODULE DEPENDENCY FULL is not set to value 900000000000534007')
	from curr_moduleDependency_f a
	where a.refsetid <> '900000000000534007';
	commit;