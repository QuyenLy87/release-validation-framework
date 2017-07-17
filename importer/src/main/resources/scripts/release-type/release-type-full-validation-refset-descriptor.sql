/********************************************************************************
	release-type-full-validation-refset-descriptor

	Assertion:
	The current Refset Descriptor full file contains all previously published data 
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
      	concat('Refset Descriptor id = ',a.id, ' referencedComponentId = ',a.referencedcomponentid, ' is in prior full file, but not in current full file.')
	from prev_refsetDescriptor_f a
	left join curr_refsetDescriptor_f b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
    	and a.moduleid = b.moduleid
    	and a.refsetid = b.refsetid
   		and a.referencedcomponentid = b.referencedcomponentid
   		and a.attributedescription = b.attributedescription
	    and a.attributetype = b.attributetype
	    and a.attributeorder = b.attributeorder
    where ( b.id is null
		or b.effectivetime is null
		or b.active is null
		or b.moduleid is null
 		or b.refsetid is null
  		or b.referencedcomponentid is null
  		or b.attributedescription is null
  		or b.attributetype is null
  		or b.attributeorder is null);
    commit;