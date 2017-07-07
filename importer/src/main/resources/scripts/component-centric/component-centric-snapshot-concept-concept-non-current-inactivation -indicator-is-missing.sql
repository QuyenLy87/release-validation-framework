

/********************************************************************************
	component-centric-snapshot-concept-concept-non-current-inactivation -indicator-is-missing

	Assertion:
	"Concept non-current" inactivation indicator is missing when a concept is inactivated

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.id,
		concat('CONCEPT: id=',a.id, ' is inactivated but inactivation indicator is missing.')
	from curr_concept_s a, curr_description_s b, package_info c
    where a.id = b.conceptid
    and a.effectivetime = c.releasetime
    and a.active = 0
    and b.active = 1
    and not exists (select 1 from curr_attributevaluerefset_s r
                             where r.referencedcomponentid = b.id
                             and r.active = 1
                             and r.valueid = 900000000000495008
                    );
    commit ;
