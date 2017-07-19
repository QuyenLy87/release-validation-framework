/********************************************************************************
	release-type-snapshot-simplemap-refset-addition-removal-CTV3-members

	Assertion:
	Verify that all additions/removals of members of CTV3 SimpleMap refset are valid:
	 - All additions should match exactly the number of new concepts
	 - Any in-activations should be related to inactivated concepts in the latest release

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.maptarget,
		concat('Simple Map Refset with: id = ',a.id, ' has new CTV3 member = ',a.maptarget,' added but does not map with any new concept .')
	from curr_simplemaprefset_s a
    left join prev_simplemaprefset_s b
    on a.id=b.id
        and a.moduleid=b.moduleid
        and a.refsetid=b.refsetid
        and a.referencedcomponentid=b.referencedcomponentid
        and a.maptarget=b.maptarget
    where (b.id is null
           or b.moduleid is null
           or b.refsetid is null
           or b.referencedcomponentid is null
           or b.maptarget is null)
    and a.active = 1
    and a.refsetid=900000000000497000
    and a.referencedcomponentid not in (select id from curr_concept_s);
    commit;

	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.maptarget,
		concat('Simple Map Refset with: id = ',a.id, ' has CTV3 member = ',a.maptarget,' is inactivated but still related to an active concept.')
    from curr_simplemaprefset_s a
    left join prev_simplemaprefset_s b
    on a.id=b.id
        and a.moduleid=b.moduleid
        and a.refsetid=b.refsetid
        and a.referencedcomponentid=b.referencedcomponentid
        and a.maptarget=b.maptarget
    where a.active=0
    and b.active=1
    and a.refsetid=900000000000497000
    and a.referencedcomponentid in (select id from curr_concept_s c where c.active=1);
    commit;