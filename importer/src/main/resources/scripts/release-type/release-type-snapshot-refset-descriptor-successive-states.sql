/********************************************************************************
   release-type-snapshot-refset-descriptor-successive-states

   Assertion:
   New inactive states follow active states in the Refset Descriptor snapshot.

********************************************************************************/
   insert into qa_result (runid, assertionuuid, concept_id, details)
   select
         <RUNID>,
         '<ASSERTIONUUID>',
          a.referencedcomponentid,
          concat('Refset Descriptor Id=',a.id, ' should not have a new inactive state as it was inactive previously.')
   from curr_refsetDescriptor_s a , prev_refsetDescriptor_s b
   where a.effectivetime != b.effectivetime
   and a.active = 0
   and a.id = b.id
   and a.active = b.active;

   insert into qa_result (runid, assertionuuid, concept_id, details)
   select
      <RUNID>,
      '<ASSERTIONUUID>',
      a.referencedcomponentid,
      concat('Refset Descriptor Id=',a.id, ' is inactive but no active state found in the previous snapshot.')
   from curr_refsetDescriptor_s a left join prev_refsetDescriptor_s b
   on a.id = b.id
   where a.active = 0
   and b.id is null;
