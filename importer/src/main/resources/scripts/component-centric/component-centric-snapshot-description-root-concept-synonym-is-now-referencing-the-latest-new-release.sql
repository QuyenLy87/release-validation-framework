/********************************************************************************
	component-centric-snapshot-description-root-concept-synonym-is-now-referencing-the-latest-new-release

	Assertion:
	Verify that the root concept synonym is now referencing the latest new release

********************************************************************************/
    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
    		<RUNID>,
            '<ASSERTIONUUID>',
            result.id,
            result.expression
            from
            (select a.id,
                     concat('Concept id = ',a.id,', root concept synonym is not referencing the latest new release') expression
                     from curr_description_s a, curr_package_info b
                     where a.conceptid= '138875005'
                     and a.typeid = '900000000000013009'
                     and a.active = 1
                     and a.effectiveTime <>  b.releasetime
                     and a.term like concat('%SNOMED Clinical Terms version: %',b.releasetime,'%')) as result;
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
    select
    	<RUNID>,
    	'<ASSERTIONUUID>',
        result.id,
        result.expression
        from
        (select a.id,
                  concat('Concept id = ',a.id,', root concept synonym is now referencing the latest new release but is in inactivate state') expression
                  from curr_description_s a, curr_package_info b
                  where a.conceptid= '138875005'
                  and a.typeid = '900000000000013009'
                  and a.active = 0
                  and a.effectivetime = b.releasetime
                  and a.term like concat('%SNOMED Clinical Terms version: %',b.releasetime,'%')) as result;
    commit;

    insert into qa_result (runid, assertionuuid, concept_id, details)
        select
        	<RUNID>,
        	'<ASSERTIONUUID>',
            result.id,
            result.expression
            from
            (select a.id,
                      concat('Concept id = ',a.id,', root concept synonym is not valid') expression
                      from curr_description_s a, curr_package_info b
                      where a.conceptid= '138875005'
                      and a.typeid = '900000000000013009'
                      and a.active = 1
                      and a.effectivetime = b.releasetime
                      and a.term not like concat('%SNOMED Clinical Terms version: %',b.releasetime,'%')) as result;
    commit;










