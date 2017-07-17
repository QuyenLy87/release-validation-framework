/********************************************************************************
	release-type-full-validation-description-type

	Assertion:
	The current Description Type full file contains all previously published data 
	unchanged.

	The current full file is the same as the prior version of the same full 
	file, except for the delta rows. Therefore, when the delta rows are excluded 
	from the current file, it should be identical to the prior version.

	This test identifies rows in prior, not in current, and in current, not in 
	prior.

********************************************************************************/

   insert into qa_result (runid, assertionuuid, concept_id, details)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
      	concat('Description Type id = ',a.id, ' referencedComponentId = ',a.referencedcomponentid, ' is in prior full file, but not in current full file.')
	from prev_descriptionType_f a
	left join curr_descriptionType_f b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
    	and a.moduleid = b.moduleid
    	and a.refsetid = b.refsetid
   		and a.referencedcomponentid = b.referencedcomponentid
        and a.descriptionformat = b.descriptionformat
        and a.descriptionlength = b.descriptionlength
    where ( b.id is null
		or b.effectivetime is null
		or b.active is null
		or b.moduleid is null
 		or b.refsetid is null
  		or b.referencedcomponentid is null
  		or b.descriptionformat is null
  		or b.descriptionlength is null);
    commit;