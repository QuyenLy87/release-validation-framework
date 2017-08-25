/********************************************************************************
	release-type-delta-previous-snapshot-validation-refset-descriptor

	Assertion:
	There must be actual changes made to previously published Refset Descriptor in order for them to appear in the current delta.

********************************************************************************/

    insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Refset Descriptor: id = ',a.id, ' referencedComponentId = ',a.referencedcomponentid, ' is in the detla file, but no actual changes made since the previous release.')
	from curr_refsetDescriptor_d a
	left join prev_refsetDescriptor_s b
	on a.id = b.id
	and a.active = b.active
	and a.moduleid = b.moduleid
	and a.refsetid = b.refsetid
	and a.referencedcomponentid = b.referencedcomponentid
	and a.attributedescription = b.attributedescription
	and a.attributetype = b.attributetype
	and a.attributeorder = b.attributeorder
	where b.id is not null;
	commit;
