

/********************************************************************************
	component-centric-snapshot-concept-having-active-historical-association-or-reason-for-inactivation

	Assertion:
	Verify that there are no active concepts having active historical associations or reasons for inactivation

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Concept: id = ',b.id, ': historical association refset is active, but has reason for inactivation.')
	from curr_associationrefset_s a, curr_concept_s b, curr_attributevaluerefset_s c
	where a.referencedcomponentid = b.id
	and b.active = 1
	and b.id = c.referencedcomponentid
	and a.active = 1
	or c.refsetid='900000000000489007'; /* Concept inactivation indicator attribute value  */
	commit;
