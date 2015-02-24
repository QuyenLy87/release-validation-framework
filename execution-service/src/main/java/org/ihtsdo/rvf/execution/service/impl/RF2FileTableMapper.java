package org.ihtsdo.rvf.execution.service.impl;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

public class RF2FileTableMapper {

	private static final String TEXT_DEFINITION_FILE_HEADER = "sct2_TextDefinition_";
	private static final String STATED_RELATIONSHIP_FILE_HEADER = "sct2_StatedRelationship_";
	private static final String SIMPLE_FILE_HEADER = "der2_Refset_Simple";
	private static final String SIMPLE_MAP_FILE_HEADER = "der2_sRefset_SimpleMap";
	private static final String RELATIONSHIP_FILE_HEADER = "sct2_Relationship";
	private static final String LANGUAGE_FILE_HEADER = "der2_cRefset_Language";
	private static final String COMPLEX_MAP_FILE_HEADER = "der2_iissscRefset_ComplexMap";
	private static final String ATTRIBUTE_VALUE_FILE_HEADER = "der2_cRefset_AttributeValue";
	private static final String ASSOCIATION_REFERENCE_FILE_HEADER = "der2_cRefset_AssociationReference";
	private static final String DESCRIPTION_FILE_HEADER = "sct2_Description_";
	private static final String CONCEPT_FILE_HEADER = "sct2_Concept_";
	private static final Map<String,String> tableNameMap = new HashMap<>();
	private static final String DELTA = ".*Delta.*_INT_\\d{8}.txt";
	private static final String SNAPSHOT = ".*Snapshot.*_INT_\\d{8}.txt";
	private static final String FULL = ".*Full.*_INT_\\d{8}.txt";
	//list of file name regex expressions with RVF table names
	static {
		//Delta
		tableNameMap.put(CONCEPT_FILE_HEADER + DELTA, "concept_d");
		tableNameMap.put(DESCRIPTION_FILE_HEADER + DELTA, "description_d");
		tableNameMap.put(ASSOCIATION_REFERENCE_FILE_HEADER+ DELTA, "associationrefset_d");
		tableNameMap.put(ATTRIBUTE_VALUE_FILE_HEADER + DELTA, "attributevaluerefset_d");
		tableNameMap.put(COMPLEX_MAP_FILE_HEADER + DELTA, "complexmaprefset_d");
		tableNameMap.put(LANGUAGE_FILE_HEADER + DELTA, "langrefset_d");
		tableNameMap.put(RELATIONSHIP_FILE_HEADER + DELTA, "relationship_d");
		tableNameMap.put(SIMPLE_MAP_FILE_HEADER + DELTA, "simplemaprefset_d");
		tableNameMap.put(SIMPLE_FILE_HEADER + DELTA, "simplerefset_d");
		tableNameMap.put(STATED_RELATIONSHIP_FILE_HEADER + DELTA, "stated_relationship_d");
		tableNameMap.put(TEXT_DEFINITION_FILE_HEADER + DELTA, "textdefinition_d");
		
		//Full
		tableNameMap.put(CONCEPT_FILE_HEADER + FULL, "concept_f");
		tableNameMap.put(DESCRIPTION_FILE_HEADER + FULL, "description_f");
		tableNameMap.put(ASSOCIATION_REFERENCE_FILE_HEADER+ FULL, "associationrefset_f");
		tableNameMap.put(ATTRIBUTE_VALUE_FILE_HEADER + FULL, "attributevaluerefset_f");
		tableNameMap.put(COMPLEX_MAP_FILE_HEADER + FULL, "complexmaprefset_f");
		tableNameMap.put(LANGUAGE_FILE_HEADER + FULL, "langrefset_f");
		tableNameMap.put(RELATIONSHIP_FILE_HEADER + FULL, "relationship_f");
		tableNameMap.put(SIMPLE_MAP_FILE_HEADER + FULL, "simplemaprefset_f");
		tableNameMap.put(SIMPLE_FILE_HEADER + FULL, "simplerefset_f");
		tableNameMap.put(STATED_RELATIONSHIP_FILE_HEADER + FULL, "stated_relationship_f");
		tableNameMap.put(TEXT_DEFINITION_FILE_HEADER + FULL, "textdefinition_f");
		//Snapshot
		tableNameMap.put(CONCEPT_FILE_HEADER + SNAPSHOT, "concept_s");
		tableNameMap.put(DESCRIPTION_FILE_HEADER + SNAPSHOT, "description_s");
		tableNameMap.put(ASSOCIATION_REFERENCE_FILE_HEADER+ SNAPSHOT, "associationrefset_s");
		tableNameMap.put(ATTRIBUTE_VALUE_FILE_HEADER + SNAPSHOT, "attributevaluerefset_s");
		tableNameMap.put(COMPLEX_MAP_FILE_HEADER + SNAPSHOT, "complexmaprefset_s");
		tableNameMap.put(LANGUAGE_FILE_HEADER + SNAPSHOT, "langrefset_s");
		tableNameMap.put(RELATIONSHIP_FILE_HEADER + SNAPSHOT, "relationship_s");
		tableNameMap.put(SIMPLE_MAP_FILE_HEADER + SNAPSHOT, "simplemaprefset_s");
		tableNameMap.put(SIMPLE_FILE_HEADER + SNAPSHOT, "simplerefset_s");
		tableNameMap.put(STATED_RELATIONSHIP_FILE_HEADER + SNAPSHOT, "stated_relationship_s");
		tableNameMap.put(TEXT_DEFINITION_FILE_HEADER + SNAPSHOT, "textdefinition_s");
	}
	
	public static String getLegacyTableName(final String filename) {
		for(final String regex : tableNameMap.keySet()) {
			if (Pattern.compile(regex).matcher(filename).matches()) {
				return tableNameMap.get(regex);
			}
		}
		return null;
	}
	
	public static Collection<String> getAllTableNames() {
		return tableNameMap.values();
	}
}