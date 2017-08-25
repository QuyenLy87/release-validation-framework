/********************************************************************************
	release-type-delta-previous-snapshot-validation-description-type

	Assertion:
	There must be actual changes made to previously published Description Type in order for them to appear in the current delta.

********************************************************************************/

    insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('Description Type: id = ',a.id, ' referencedComponentId = ',a.referencedcomponentid, ' is in the detla file, but no actual changes made since the previous release.')
	from curr_descriptionType_d a
	left join prev_descriptionType_s b
	on a.id = b.id
	and a.active = b.active
	and a.moduleid = b.moduleid
	and a.refsetid = b.refsetid
	and a.referencedcomponentid = b.referencedcomponentid
	and a.descriptionformat = b.descriptionformat
	and a.descriptionlength = b.descriptionlength
	where b.id is not null;
	commit;