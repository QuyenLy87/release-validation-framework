/********************************************************************************
	component-centric-full-all-maps-referencedcomponentid-is-active-concept

	Assertion:
	All MAP REFSET FULL files have valid, active SNOMED CT concepts in the ReferencedComponentId

********************************************************************************/
   insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('EXTENDED MAP REFSET FULL: id=',a.id,' has inactive concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_extendedmaprefset_f a
        left join curr_concept_f b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;


    insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('COMPLEX MAP REFSET FULL: id=',a.id,' has inactive concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_complexmaprefset_f a
        left join curr_concept_f b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;


	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('SIMPLE MAP REFSET FULL: id=',a.id,' has inactive concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_simplemaprefset_f a
        left join curr_concept_f b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;

