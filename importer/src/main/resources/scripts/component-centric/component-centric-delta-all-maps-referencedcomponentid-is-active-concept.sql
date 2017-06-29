/********************************************************************************
	component-centric-delta-all-maps-referencedcomponentid-is-active-concept

	Assertion:
	All MAP REFSET DELTA files have valid, active SNOMED CT concepts in the ReferencedComponentId

********************************************************************************/
   insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('EXTENDED MAP REFSET DELTA: id=',a.id,' has inactive concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_extendedmaprefset_d a
        left join curr_concept_d b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('EXTENDED MAP REFSET DELTA: id=',a.id,' has invalid concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_extendedmaprefset_d a
        where a.referencedcomponentid not in (select id from curr_concept_d);
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('COMPLEX MAP REFSET DELTA: id=',a.id,' has inactive concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_complexmaprefset_d a
        left join curr_concept_d b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('COMPLEX MAP REFSET DELTA: id=',a.id,' has invalid concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_complexmaprefset_d a
        where a.referencedcomponentid not in (select id from curr_concept_d);
    commit;

	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('SIMPLE MAP REFSET DELTA: id=',a.id,' has inactive concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_simplemaprefset_d a
        left join curr_concept_d b
        on  a.referencedcomponentid = b.id
        where b.id is not null and a.active = 1 and b.active = 0;
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('SIMPLE MAP REFSET DELTA: id=',a.id,' has invalid concept in ReferencedComponentId field = ',a.referencedcomponentid)
        from curr_simplemaprefset_d a
        where a.referencedcomponentid not in (select id from curr_concept_d);
    commit;
