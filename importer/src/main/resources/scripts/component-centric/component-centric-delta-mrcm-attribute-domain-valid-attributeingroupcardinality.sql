
/******************************************************************************** 
	component-centric-delta-mrcm-attribute-domain-valid-attributeingroupcardinality

	Assertion:
	AttributeInGroupCardinality value is in ('0..0', '0..1', '0..*') in MRCM ATTRIBUTE DOMAIN delta file

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		a.referencedcomponentid,
		concat('MRCM ATTRIBUTE DOMAIN REFSET: id=',a.id,' AttributeInGroupCardinality value is not in ("0..0", "0..1", "0..*") in MRCM ATTRIBUTE DOMAIN delta file') 	
	from curr_mrcmattributedomainrefset_d a
	where a.attributeingroupcardinality NOT IN ('0..0','0..1','0..*');
	commit;
