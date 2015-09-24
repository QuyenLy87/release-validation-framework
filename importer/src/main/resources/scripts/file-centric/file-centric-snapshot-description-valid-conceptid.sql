
/******************************************************************************** 
	file-centric-snapshot-description-valid-conceptid

	Assertion:
	ConceptId value refers to valid concept identifier in DESCRIPTION snapshot.

********************************************************************************/
	insert into qa_result (runid, assertionuuid, assertiontext, details)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		'<ASSERTIONTEXT>',
		concat('DESCRIPTION: id=',a.id, ' refers to an invalid concept identifier in the DESCRIPTION snapshot.') 	
	from curr_description_s a
	left join curr_concept_s b
	on a.conceptid = b.id
	where b.id is null;
