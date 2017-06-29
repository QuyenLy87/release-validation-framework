/********************************************************************************
	component-centric-delta-refset-descriptor-correct-number-of-values-for-attributeorder

	Assertion:
	AttributeOrder in REFSET DESCRIPTOR DELTA is set to correct value

********************************************************************************/
	insert into qa_result (runid, assertionuuid, concept_id, details)
	select
		<RUNID>,
		'<ASSERTIONUUID>',
		a.moduleid,
		concat('AttributeOrder of: id=',a.id,' in REFSET DESCRIPTOR DELTA is not set to correct value ')
    from (
    select t1.* from curr_refsetDescriptor_d t1 , curr_simplerefset_d t2
    where t1.referencedcomponentid = t2.referencedcomponentid
    and exists (select 1 from  curr_simplerefset_d x where x.referencedcomponentid=t1.referencedcomponentid
    and  t1.attributeorder <> 0)
    union
    select t1.*
    from curr_refsetDescriptor_d t1
    where t1.referencedcomponentid not in (select referencedcomponentid from curr_simplerefset_d )
    and not exists (select 1 from  curr_refsetDescriptor_d x where x.referencedcomponentid=t1.referencedcomponentid
    and  x.attributeorder <> 0)
    ) a;
	commit;