
/******************************************************************************** 
	cs-parser-description-new-missing-rf2

	Assertion:
	Find new Description Ids found is in CS_ but missing in RF2.

********************************************************************************/
	
	drop view if exists v_allid;
	drop view if exists v_newid;
	drop view if exists v_maxidtime;
	drop view if exists v_newdescription;
	drop table if exists newmaxattribute_tmp;
	drop table if exists newinactive_tmp;
	drop table if exists missingrf2new_tmp;
	drop table if exists textdefintion_tmp;
	drop view if exists v_allconceptid;
	drop view if exists v_newconceptid;
	drop view if exists v_maxconceptidtime;
	drop view if exists v_newconcept;
	drop table if exists newmaxconceptattribute_tmp;
	drop table if exists newinactiveconcept_tmp;
	drop view if exists v_allconceptid;
	drop view if exists v_newconceptid;
	drop view if exists v_maxidconcepttime;
	drop view if exists v_newconcept;
	drop table if exists newmaxconceptattribute_tmp;
	drop table if exists newinactiveconcept_tmp;
	drop table if exists missingrf2new_tmp;

	/* Prep */
	-- All distinct Descriptions Ids in CS
	create view v_allid as
	select distinct(a.id) from cs_description a;


	-- SCTIDs that new to current release
	create view v_newid as
	select a.* from v_allid a
	left join prev_description_s b on a.id = b.id
	where b.id is null;

	-- Map all ids to latest committime
	create view v_maxidtime as
	select id, max(committime) as committime from cs_description 
	group by id; 

	-- All attributes of Descriptions that are new in current release 
	create view v_newdescription as 
	select a.* from cs_description a, v_newid b 
	where a.id = b.id;  

	-- Latest timestamp of Descriptions thast are new in current release
	create table newmaxattribute_tmp as 
	select a.* from v_newdescription a, v_maxidtime b
	where a.id = b.id
	and a.committime = b.committime;




	

	/* Analysis */
	-- New Descriptions that were created in current release but were then inactivated
	create table newinactive_tmp as 
	select * from newmaxattribute_tmp where active = 0;

	-- List of New Text Definitions in CS Files
	create table textdefintion_tmp as 
	select * from newmaxattribute_tmp 
	where typeid = '900000000000550004';

	-- New Descriptions that exist in the CS File but are missing in RF2
	create table missingrf2new_tmp as 
	select a.* from newmaxattribute_tmp a 
	left join curr_description_d b on a.id = b.id 
	where b.id is null; 



	delete from missingrf2new_tmp
	where id in (
		select id from newinactive_tmp
	);
	
	
	delete from missingrf2new_tmp
	where id in (
		select id from textdefintion_tmp
	);
	

	/* Remove descriptions of new but inactivated concepts */
	-- All distinct Ids in CS
	create view v_allconceptid as
	select distinct(a.id) from cs_concept a;


	-- SCTIDs that new to current release
	create view v_newconceptid as
	select a.* from v_allconceptid a
	left join prev_concept_s b on a.id = b.id
	where b.id is null;

	-- Map all ids to latest committime
	create view v_maxidconcepttime as
	select id, max(committime) as committime from cs_concept 
	group by id; 

	-- All attributes of concepts that are new in current release 
	create view v_newconcept as 
	select a.* from cs_concept a, v_newconceptid b 
	where a.id = b.id;  

	-- Latest timestamp of concepts thast are new in current release
	create table newmaxconceptattribute_tmp as 
	select a.* from v_newconcept a, v_maxidconcepttime b
	where a.id = b.id
	and a.committime = b.committime;

	-- Concepts that were created in current release but were then inactivated
	create table newinactiveconcept_tmp as 
	select * from newmaxconceptattribute_tmp where active = 0;


	delete from missingrf2new_tmp
	where conceptid in (
		select id from newinactiveconcept_tmp
	);
	





	insert into qa_result (runid, assertionuuid, assertiontext, details)
	select 
		<RUNID>,
		'<ASSERTIONUUID>',
		'<ASSERTIONTEXT>',
		concat('Description: id=',id, ': Description that is new in current release is referenced in change set file but not in RF2.') 
	from missingrf2new_tmp;
	
	
	
