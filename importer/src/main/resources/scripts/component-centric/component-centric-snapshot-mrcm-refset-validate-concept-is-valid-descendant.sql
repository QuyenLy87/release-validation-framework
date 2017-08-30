-- Common checks
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributedomainrefset_s','moduleId ','mrcmAttributeDomainRefset',
'900000000000443000', '< 900000000000443000 |Module|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributerangerefset_s','moduleId ','mrcmAttributeRangeRefset',
'900000000000443000', '< 900000000000443000 |Module|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmdomainrefset_s','moduleId ','mrcmDomainRefset',
'900000000000443000', '< 900000000000443000 |Module|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmmodulescoperefset_s','moduleId ','mrcmmodulescoperefset_s',
'900000000000443000', '< 900000000000443000 |Module|');
-- MRCM Domain Refset checks
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmdomainrefset_s','refsetId ','mrcmDomainRefset',
'723589008', '< 723589008 |MRCM domain reference set|');
-- MRCM Attribute Domain Refset checks
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributedomainrefset_s','refsetId ','mrcmAttributeDomainRefset',
'723604009', '< 723604009 |MRCM attribute domain reference set|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributedomainrefset_s','referencedComponentId','mrcmAttributeDomainRefset',
'410662002', '< 410662002 |Concept model attribute|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributedomainrefset_s','ruleStrengthId','mrcmAttributeDomainRefset',
'723573005', '< 723573005 |Concept model rule strength|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributedomainrefset_s','contentTypeId','mrcmAttributeDomainRefset',
'723574004', '< 723574004 |Content type|');
-- MRCM Attribute Range Refset checks
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributerangerefset_s','refsetId','mrcmAttributeRangeRefset',
'723592007', '< 723592007 |MRCM attribute range reference set|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmattributerangerefset_s','referencedComponentId','mrcmAttributeRangeRefset',
'410662002', '< 410662002 |Concept model attribute|');
-- MRCM Attribute Module Scope Refset checks
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmmodulescoperefset_s','referencedComponentId','mrcmModuleScopeRefset',
'900000000000443000', '< 900000000000443000 |Module|');
call validateConceptIdIsValidDescendantsInMRCMRefsetSnap_proc(<RUNID>,'<ASSERTIONUUID>',
'mrcmmodulescoperefset_s','mrcmRuleRefsetId','mrcmModuleScopeRefset',
'723589008,723604009,723592007', '( < 723589008 |MRCM domain reference set| OR < 723604009 |MRCM attribute domain reference set| OR < 723592007 |MRCM attribute range reference set|)');

