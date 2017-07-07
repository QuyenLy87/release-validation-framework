/********************************************************************************
	component-centric-delta-validate-new-identifier-refset-records

	Verify that there are no new SNOMED Identifier Refset records (900000000000498005)
	in any file types in the Release package

********************************************************************************/

call validateNewIdentifierRefsetRecordsDelta_procedure (<RUNID>,'<ASSERTIONUUID>');