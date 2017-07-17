/********************************************************************************
	release-type-full-delta-validation-refset-descriptor

	Assertion:
	The current full Refset Descriptor file consists of the previously published full file and the changes for the current release

********************************************************************************/

	insert into qa_result (runid, assertionuuid, concept_id, details)
	select 
	<RUNID>,
	'<ASSERTIONUUID>',
	a.referencedcomponentid,
	concat('Refset Descriptor id =',a.id, ' referencedComponentId = ',a.referencedcomponentid, ' is in current full file, but not in prior full or current delta file.')
	from curr_refsetDescriptor_f a
	left join curr_refsetDescriptor_d b
		on a.id = b.id
		and a.effectivetime = b.effectivetime
		and a.active = b.active
    	and a.moduleid = b.moduleid
    	and a.refsetid = b.refsetid
   		and a.referencedcomponentid = b.referencedcomponentid
   		and a.attributedescription = b.attributedescription
	    and a.attributetype = b.attributetype
	    and a.attributeorder = b.attributeorder
   	left join prev_refsetDescriptor_f c
		on a.id = c.id
		and a.effectivetime = c.effectivetime
		and a.active = c.active
    	and a.moduleid = c.moduleid
    	and a.refsetid = c.refsetid
   		and a.referencedcomponentid = c.referencedcomponentid
   		and a.attributedescription = c.attributedescription
	    and a.attributetype = c.attributetype
	    and a.attributeorder = c.attributeorder
	where ( b.id is null
		or b.effectivetime is null
		or b.active is null
		or b.moduleid is null
 		or b.refsetid is null
  		or b.referencedcomponentid is null
  		or b.attributedescription is null
  		or b.attributetype is null
  		or b.attributeorder is null)
  	and ( c.id is null
		or c.effectivetime is null
		or c.active is null
		or c.moduleid is null
 		or c.refsetid is null
  		or c.referencedcomponentid is null
  		or c.attributedescription is null
  		or c.attributetype is null
  		or c.attributeorder is null);
    commit;