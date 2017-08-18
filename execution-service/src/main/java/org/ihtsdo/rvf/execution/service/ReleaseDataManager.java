package org.ihtsdo.rvf.execution.service;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

import org.ihtsdo.otf.rest.exception.BusinessServiceException;
import org.ihtsdo.rvf.execution.service.util.RvfDynamicDataSource;

/**
 * Utility service that manages a repository of published SNOMED CT releases. Note that we have deliberately not
 * included a delete/update functionality in this service. This get functionality should never be exposed to the external world
 * without security, because it would allow anonymous users to download SNOMED CT data.
 */
public interface ReleaseDataManager {

    boolean uploadPublishedReleaseData(InputStream inputStream, String fileName, String product, String version) throws BusinessServiceException;

    boolean uploadPublishedReleaseData(File releasePackZip, String product, String version) throws BusinessServiceException;

    String loadSnomedData(String productVersion,List<String> rf2FilesLoaded, StringBuilder  previousVersionOutputFolder, File ... zipDataFile) throws BusinessServiceException;

    boolean isKnownRelease(String releaseVersion);

    Set<String> getAllKnownReleases();

    String getSchemaForRelease(String releaseVersion);

    void setSchemaForRelease(String releaseVersion, String schemaName);

	List<File> getZipFileForKnownRelease(String knownVersion);
	
	boolean combineKnownVersions(final String combinedVersionName, final String ... knownVersions);
	
	void dropVersion(String version);

	void copyTableData(String sourceVersion,String destinationVersion, String tableNamePattern, List<String> excludeTableNames) throws BusinessServiceException;
	void copyTableData(String sourceVersionA,String sourceVersionB,String destinationVersion, String tableNamePattern, List<String> excludeTableNames) throws BusinessServiceException;

	void updateSnapshotTableWithDataFromDelta(String prospectiveVersion);
	
	String loadSnomedDataIntoExistingDb(String productVersion,List<String> rf2FilesLoaded,File ... zipDataFile) throws BusinessServiceException;

	String createSchema(String versionName);

	void loadReleaseFilesToDB(final File rf2TextFilesDir, final RvfDynamicDataSource dataSource, List<String> rf2FilesLoaded, String schemaName) throws SQLException, FileNotFoundException;

	void createDBAndTables(final String schemaName, final Connection connection) throws SQLException, IOException;

	void dropDatabase(String schema, final Connection connection) throws SQLException;
}
