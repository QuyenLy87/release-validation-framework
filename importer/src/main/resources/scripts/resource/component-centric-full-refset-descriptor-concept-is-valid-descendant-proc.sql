
/********************************************************************************
	component-centric-full-refset-descriptor-concept-is-valid-descendant-proc.sql

	Defines a procedure to validate whether a concept is a descendant of specified concepts in RefsetDescriptor Delta

        created date: 23 Jun 2017
		user created : NheLy
        Description: Verify that RefsetDescriptor files (delta,full,snapshot)
        a. contain only rows with referencedComponentId = < 900000000000455006 |Reference set (foundation metadata concept)|
        b. contain only rows with attributeDescription = < 900000000000457003 |Reference set attribute (foundation metadata concept)|
        c. contain only rows with attributeType = < 900000000000459000 |Attribute type (foundation metadata concept)|

        column name: referencedComponentId or attributeDescription or attributeType
        table name: refsetdescriptor_d,refsetdescriptor_f,refsetdescriptor_s
        rootconceptid : 900000000000455006 ,900000000000457003 , 900000000000459000

        step 1: find descendants of rootconceptid
        step 2: find values of column name of table name  that not in list of descendants of rootconceptid

********************************************************************************/
drop procedure if exists validateValidDescendantsInRefsetDescriptorFull_procedure;
create procedure validateValidDescendantsInRefsetDescriptorFull_procedure(runid bigint, assertionid varchar(36),tablename varchar(255),  columnname varchar(255), rootconceptid varchar(1024), expression varchar(4000))
begin
	declare currentdepth integer default 0;
	declare numberOfChildren integer;

	drop table if exists tbl_hierachy_tree_f;

	create table tbl_hierachy_tree_f(sourceid bigint(20) not null,
									destinationid bigint(20) not null,
									depth integer);

	insert into tbl_hierachy_tree_f(sourceid, destinationid, depth)
						select sourceid, destinationid,currentdepth
                        from stated_relationship_f s
						where s.active = 1 and s.typeid = 116680003 and s.destinationid in (rootconceptid);

	set numberOfChildren = (select count(distinct sourceid) from tbl_hierachy_tree_f where depth = currentdepth);

	while numberOfChildren > 0 do
		insert into tbl_hierachy_tree_f(sourceid, destinationid, depth)
		select sourceid, destinationid, (currentdepth + 1) from stated_relationship_f s
		where s.active = 1 and s.typeid = 116680003 and s.destinationid in (select distinct sourceid from tbl_hierachy_tree_f where depth = currentdepth);

		set currentdepth = currentdepth + 1;
		set numberOfChildren = (select count(distinct sourceid) from tbl_hierachy_tree_f where depth = currentdepth);
	end while;


    drop table if exists tmp_f;
	create table tmp_f( conceptid bigint(20));
	set @runSql = concat("insert into tmp_f( conceptid) select ", columnname, " from ", tablename, ";");
	prepare statement from @runSql;
	execute statement;

	insert into qa_result (run_id, assertion_id,concept_id, details)
	select distinct
	runid,
	assertionid,
	res.conceptid,
	concat('Refset Descriptor Full: ',columnname,' = ',res.conceptid ,' is not valid descendant of expression ', expression)
	from  (select conceptid  from tmp_f where conceptid not in (select sourceid from tbl_hierachy_tree_f)) as res;

	drop table if exists tbl_hierachy_tree_f;
    drop table if exists tmp_f;

end;