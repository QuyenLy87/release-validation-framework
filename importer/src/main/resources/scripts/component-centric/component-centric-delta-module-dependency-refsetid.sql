/********************************************************************************
	component-centric-delta-module-dependency-refsetid

	Assertion:
	RefsetId in MODULE DEPENDENCY DELTA is always set to '900000000000534007'

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('RefsetId of: id=',a.id,' in MODULE DEPENDENCY DELTA is not set to value 900000000000534007')
	from curr_moduleDependency_d a
	where a.refsetid <> '900000000000534007';
	commit;
