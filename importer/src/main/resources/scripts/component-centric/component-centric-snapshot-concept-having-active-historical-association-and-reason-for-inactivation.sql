

/********************************************************************************
	component-centric-snapshot-concept-having-active-historical-association-and-reason-for-inactivation

	Assertion:
	Verify that there are no active concepts having active historical associations and reasons for inactivation
	Note:Some inactivation indicators may be applied to active descriptions.
	See https://confluence.ihtsdotools.org/display/DOCTSG/4.2.2+Component+Inactivation+Reference+Sets
	900000000000486000 |Limited component (foundation metadata concept)
	900000000000492006 |Pending move (foundation metadata concept)|

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		b.id,
		concat('Concept: id = ',b.id, ': historical association refset is active, but has reason for inactivation.')
	from curr_associationrefset_s a, curr_concept_s b, curr_attributevaluerefset_s c
	where a.referencedcomponentid = b.id
	and a.active = 1
	and b.active = 1
	and b.id = c.referencedcomponentid
	and c.refsetid='900000000000489007' /* Concept inactivation indicator attribute value  */
	and c.valueid not in ('900000000000486000','900000000000492006');
	commit;
