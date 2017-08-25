package org.ihtsdo.rvf.execution.service.impl;

import com.google.common.collect.Sets;
import net.rcarz.jiraclient.JiraException;
import org.apache.commons.codec.DecoderException;
import org.apache.commons.dbcp.BasicDataSource;
import org.apache.commons.io.FileUtils;
import org.ihtsdo.drools.RuleExecutor;
import org.ihtsdo.drools.response.InvalidContent;
import org.ihtsdo.drools.validator.rf2.SnomedDroolsComponentFactory;
import org.ihtsdo.drools.validator.rf2.SnomedDroolsComponentRepository;
import org.ihtsdo.drools.validator.rf2.domain.DroolsConcept;
import org.ihtsdo.drools.validator.rf2.service.DroolsConceptService;
import org.ihtsdo.drools.validator.rf2.service.DroolsDescriptionService;
import org.ihtsdo.drools.validator.rf2.service.DroolsRelationshipService;
import org.ihtsdo.otf.rest.exception.BusinessServiceException;
import org.ihtsdo.otf.snomedboot.ReleaseImportException;
import org.ihtsdo.otf.snomedboot.ReleaseImporter;
import org.ihtsdo.otf.snomedboot.factory.LoadingProfile;
import org.ihtsdo.otf.sqs.service.exception.ServiceException;
import org.ihtsdo.rvf.entity.*;
import org.ihtsdo.rvf.execution.service.AssertionExecutionService;
import org.ihtsdo.rvf.execution.service.ReleaseDataManager;
import org.ihtsdo.rvf.execution.service.impl.ValidationReportService.State;
import org.ihtsdo.rvf.jira.JiraService;
import org.ihtsdo.rvf.service.AssertionService;
import org.ihtsdo.rvf.util.ZipFileUtils;
import org.ihtsdo.rvf.validation.ColumnPatternTester;
import org.ihtsdo.rvf.validation.StructuralTestRunner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.snomed.quality.validator.mrcm.ValidationRun;
import org.snomed.quality.validator.mrcm.ValidationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Service;
import org.springframework.util.Assert;

import javax.annotation.Resource;
import java.io.*;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.*;
import java.util.concurrent.*;

@Service
@Scope("prototype")
public class ValidationRunner {
	
	private static final String RELEASE_TYPE_VALIDATION = "release-type-validation";

	private static final String MMRCM_TYPE_VALIDATION = "mrcm-validation";

	private static final String VALIDATION_CONFIG = "validationConfig";

	public static final String FAILURE_MESSAGE = "failureMessage";

	private final Logger logger = LoggerFactory.getLogger(ValidationRunner.class);
	
	@Autowired
	private StructuralTestRunner structuralTestRunner;
	
	@Autowired
	private ReleaseDataManager releaseDataManager;
	
	@Autowired
	private AssertionService assertionService;
	
	@Autowired
	private AssertionExecutionService assertionExecutionService;
	
	private int batchSize = 0;

	private ExecutorService executorService = Executors.newCachedThreadPool();
	@Autowired
	private ValidationReportService reportService;
	
	@Autowired
	ValidationVersionLoader releaseVersionLoader;

	private String droolRulesModuleName;

	@Autowired
	private JiraService jiraService;

	@Resource(name = "snomedDataSource")
	private BasicDataSource snomedDataSource;

	@Value("${rvf.snomed.jdbc.username}")
	private String username;

	@Value("${rvf.snomed.jdbc.password}")
	private String password;

	public ValidationRunner( int batchSize) {
		this.batchSize = batchSize;
	}
	
	public void run(ValidationRunConfig validationConfig) {
		final Map<String , Object> responseMap = new LinkedHashMap<>();
		try {
			responseMap.put(VALIDATION_CONFIG, validationConfig);
			runValidation(responseMap, validationConfig);
		} catch (final Throwable t) {
			final StringWriter errors = new StringWriter();
			t.printStackTrace(new PrintWriter(errors));
			final String failureMsg = "System Failure: " + t.getMessage() + " : " + errors.toString();
			responseMap.put(FAILURE_MESSAGE, failureMsg);
			logger.error("Exception thrown, writing as result",t);
			try {
				reportService.writeResults(responseMap, State.FAILED, validationConfig.getStorageLocation());
			} catch (final Exception e) {
				//Can't even record the error to disk!  Lets hope Telemetry is working
				logger.error("Failed to record failure (which was: " + failureMsg + ") due to " + e.getMessage());
			}
		} finally {
			FileUtils.deleteQuietly(validationConfig.getLocalProspectiveFile());
			FileUtils.deleteQuietly(validationConfig.getLocalManifestFile());
		}
	}
	
	
	private void runValidation(final Map<String , Object> responseMap, ValidationRunConfig validationConfig) throws Exception {
		final Calendar startTime = Calendar.getInstance();
		//download prospective version
		releaseVersionLoader.downloadProspectiveVersion(validationConfig);
		logger.info(String.format("Started execution with runId [%1s] : ", validationConfig.getRunId()));
		// load the filename
		final String structureTestStartMsg = "Start structure testing for release file:" + validationConfig.getTestFileName();
		logger.info(structureTestStartMsg);
		String reportStorage = validationConfig.getStorageLocation();
		reportService.writeProgress(structureTestStartMsg, reportStorage);
		reportService.writeState(State.RUNNING, reportStorage);
	
		if (validationConfig.getLocalProspectiveFile() == null) {
			reportService.writeResults(responseMap, State.FAILED, reportStorage);
			String errorMsg ="Prospective file can't be null" + validationConfig.getLocalProspectiveFile();
			logger.error(errorMsg);
			responseMap.put(FAILURE_MESSAGE, errorMsg);
			throw new BusinessServiceException(errorMsg);
		}


		boolean isFailed = structuralTestRunner.verifyZipFileStructure(responseMap, validationConfig.getLocalProspectiveFile(), validationConfig.getRunId(),
				validationConfig.getLocalManifestFile(), validationConfig.isWriteSucceses(), validationConfig.getUrl(), validationConfig.getStorageLocation());
		reportService.putFileIntoS3(reportStorage, new File(structuralTestRunner.getStructureTestReportFullPath()));
		if (isFailed) {
			reportService.writeResults(responseMap, State.FAILED, reportStorage);
			return;
		} 

		//load previous published version
		ExecutionConfig executionConfig = releaseVersionLoader.createExecutionConfig(validationConfig);
		//check dependency version is loaded
		if (executionConfig.isExtensionValidation()) {
			if (!releaseVersionLoader.isKnownVersion(executionConfig.getExtensionDependencyVersion(), responseMap)) {
				reportService.writeResults(responseMap, State.FAILED, reportStorage);
				return;
			}
		}
		if (executionConfig.isReleaseValidation() && !executionConfig.isFirstTimeRelease()) {
			boolean isLoaded = releaseVersionLoader.loadPreviousVersion(executionConfig, validationConfig, responseMap);
			if (!isLoaded) {
				reportService.writeResults(responseMap, State.FAILED, reportStorage);
				return;
			}
		}
		//check version are loaded
		//load prospective version
		boolean isSuccessful = releaseVersionLoader.loadProspectiveVersion(executionConfig, responseMap, validationConfig);
		if (!isSuccessful) {
			reportService.writeResults(responseMap, State.FAILED, reportStorage);
			return;
		}

		storeLatestVersion(validationConfig.getLocalProspectiveFile().getName());
		
		// for extension release validation we need to test the release-type validations first using previous extension against current extension
		// first then loading the international snapshot for the file-centric and component-centric validations.

		ValidationReport report = new ValidationReport();
		report.setExecutionId(validationConfig.getRunId());

		if (executionConfig.isReleaseValidation() && executionConfig.isExtensionValidation()) {
			logger.info("Run extension release validation with runId:" +  executionConfig.getExecutionId());
			runExtensionReleaseValidation(report, responseMap, validationConfig,reportStorage, executionConfig);
		} else {
			runAssertionTests(report, executionConfig, reportStorage);
		}

		//Run Drool Validator
		runDroolValidator(report, validationConfig, executionConfig);

		//Run MRCM Validator
		runMRCMAssertionTests(report, validationConfig, executionConfig);

		addJiraLinkToReport(executionConfig, report);
		ValidationReport structuralReport = (ValidationReport) responseMap.get(TestType.ARCHIVE_STRUCTURAL.toString() + "TestResult");
		if(structuralReport != null){
			addJiraLinkToReport(executionConfig, structuralReport);
		}

		responseMap.put("TestResult", report);
		final Calendar endTime = Calendar.getInstance();
		final long timeTaken = (endTime.getTimeInMillis() - startTime.getTimeInMillis()) / 60000;
		logger.info(String.format("Finished execution with runId : [%1s] in [%2s] minutes ", validationConfig.getRunId(), timeTaken));
		responseMap.put("startTime", startTime.getTime());
		responseMap.put("endTime", endTime.getTime());
		reportService.writeResults(responseMap, State.COMPLETE, reportStorage);
		releaseDataManager.dropVersion(executionConfig.getProspectiveVersion());
	}

	private void addJiraLinkToReport(ExecutionConfig executionConfig, ValidationReport report) {
		if(executionConfig.isJiraIssueCreationFlag()) {
			// Add Jira ticket for each fail assertions
			try {
				String relaseYear = executionConfig.getReleaseDate().substring(0,4);
				String relaseMonth = executionConfig.getReleaseDate().substring(4,6);
				String dateMonth = executionConfig.getReleaseDate().substring(6,8);
				jiraService.addJiraTickets(executionConfig.getProductName(),relaseYear + "-" + relaseMonth + "-"  +dateMonth,executionConfig.getReportingStage(), report.getAssertionsFailed());
			} catch (JiraException e) {
				logger.error("Error while creating Jira Ticket for failed assertions. Message : " + e.getMessage());
			}
		}
	}

	private void runDroolValidator(ValidationReport validationReport, ValidationRunConfig validationConfig, ExecutionConfig executionConfig) {
		long timeStart = System.currentTimeMillis();
		String directoryOfRuleSetsPath = droolRulesModuleName;

		HashSet<String> ruleSetNamesToRun = Sets.newHashSet(validationConfig.getGroupsList().iterator().next());
		List<InvalidContent> invalidContents = null;
		try {
			invalidContents = validateRF2(new FileInputStream(validationConfig.getLocalProspectiveFile()), directoryOfRuleSetsPath, ruleSetNamesToRun);
		} catch (Exception e){
			logger.error("Error: " + e);
		}
		HashMap<String, List<InvalidContent>> invalidContentMap = new HashMap<>();
		for(InvalidContent invalidContent : invalidContents){
			if(!invalidContentMap.containsKey(invalidContent.getMessage())){
				List<InvalidContent> invalidContentArrayList = new ArrayList<>();
				invalidContentArrayList.add(invalidContent);
				invalidContentMap.put(invalidContent.getMessage(), invalidContentArrayList);
			}else {
				invalidContentMap.get(invalidContent.getMessage()).add(invalidContent);
			}
		}
		invalidContents.clear();
		Iterator it = invalidContentMap.entrySet().iterator();
		List<TestRunItem> failedAssertions = new ArrayList<>();
		while (it.hasNext()){
			Map.Entry pair = (Map.Entry)it.next();
			TestRunItem failedAssertion = new TestRunItem();
			failedAssertion.setTestType(TestType.DROOL_RULES);
			failedAssertion.setTestCategory("");
			failedAssertion.setAssertionUuid(null);
			failedAssertion.setAssertionText((String) pair.getKey());
			failedAssertion.setExtractResultInMillis(0L);
			List<InvalidContent> invalidContentList = (List<InvalidContent>) pair.getValue();
			failedAssertion.setFailureCount((long) invalidContentList.size());
			List<FailureDetail> failureDetails = new ArrayList<>();
			for (InvalidContent invalidContent : invalidContentList){
				failureDetails.add(new FailureDetail(invalidContent.getConceptId(), invalidContent.getMessage(), null));
			}
			failedAssertion.setFirstNInstances(failureDetails.subList(0, failureDetails.size() > 10 ? 10 : failedAssertions.size()));
			failedAssertions.add(failedAssertion);
			it.remove(); // avoids a ConcurrentModificationException
		}
		validationReport.addTimeTaken((System.currentTimeMillis() - timeStart) / 1000);
		validationReport.addFailedAssertions(failedAssertions);

	}

	private List<InvalidContent> validateRF2(InputStream fileInputStream, String directoryOfRuleSetsPath, HashSet<String> ruleSetNamesToRun) throws Exception {
		long start = (new Date()).getTime();
		Assert.isTrue((new File(directoryOfRuleSetsPath)).isDirectory(), "The rules directory is not accessible.");
		Assert.isTrue(ruleSetNamesToRun != null && !ruleSetNamesToRun.isEmpty(), "The name of at least one rule set must be specified.");
		ReleaseImporter importer = new ReleaseImporter();
		SnomedDroolsComponentRepository repository = new SnomedDroolsComponentRepository();
		this.logger.info("Loading components from RF2");
		LoadingProfile loadingProfile = LoadingProfile.complete;

		importer.loadSnapshotReleaseFiles(fileInputStream, loadingProfile,  new SnomedDroolsComponentFactory(repository));
		this.logger.info("Components loaded");
		DroolsConceptService conceptService = new DroolsConceptService(repository);
		DroolsDescriptionService descriptionService = new DroolsDescriptionService(repository);
		DroolsRelationshipService relationshipService = new DroolsRelationshipService(repository);
		RuleExecutor ruleExecutor = new RuleExecutor(directoryOfRuleSetsPath);

		Collection<DroolsConcept> concepts = repository.getConcepts();
		this.logger.info("Running tests");
		List<InvalidContent> invalidContents = ruleExecutor.execute(ruleSetNamesToRun, concepts, conceptService, descriptionService, relationshipService, true, false);
		this.logger.info("Tests complete. Total run time {} seconds", Long.valueOf(((new Date()).getTime() - start) / 1000L));
		this.logger.info("invalidContent count {}", Integer.valueOf(invalidContents.size()));
		return invalidContents;
	}
	private File extractZipFile(ValidationRunConfig validationConfig, Long executionId) throws BusinessServiceException {
		File outputFolder;
		try{
			outputFolder = new File(FileUtils.getTempDirectoryPath(), "rvf_loader_data_" + executionId);
			logger.info("MRCM output folder location = " + outputFolder.getAbsolutePath());
			if (outputFolder.exists()) {
				logger.info("MRCM output folder already exists and will be deleted before recreating.");
				outputFolder.delete();
			}
			outputFolder.mkdir();
			ZipFileUtils.extractFilesFromZipToOneFolder(validationConfig.getLocalProspectiveFile(), outputFolder.getAbsolutePath());
		} catch (final IOException ex){
			final String errorMsg = String.format("Error while loading file %s.", validationConfig.getLocalProspectiveFile());
			logger.error(errorMsg, ex);
			throw new BusinessServiceException(errorMsg, ex);
		}
		return outputFolder;
	}
	private void runMRCMAssertionTests(final ValidationReport report, ValidationRunConfig validationConfig, ExecutionConfig executionConfig) throws IOException, ReleaseImportException, ServiceException {
		final long timeStart = System.currentTimeMillis();
		ValidationService validationService = new ValidationService();
		ValidationRun validationRun = new ValidationRun();
		File outputFolder = null;
		try {
			outputFolder = extractZipFile(validationConfig, executionConfig.getExecutionId());
			if(outputFolder != null){
				validationService.loadMRCM(outputFolder, validationRun);
				validationService.validateRelease(outputFolder, validationRun);
				FileUtils.deleteQuietly(outputFolder);
			}

		} catch (BusinessServiceException ex) {
			logger.error("Error:" + ex);
		}

		TestRunItem testRunItem;
		final List<TestRunItem> passedAssertions = new ArrayList<>();
		for(org.snomed.quality.validator.mrcm.Assertion assertion : validationRun.getCompletedAssertions()){
			testRunItem = new TestRunItem();
			testRunItem.setTestCategory(MMRCM_TYPE_VALIDATION);
			testRunItem.setTestType(TestType.MRCM);
			testRunItem.setAssertionUuid(assertion.getUuid());
			testRunItem.setAssertionText(assertion.getAssertionText());
			testRunItem.setFailureCount(0L);
			testRunItem.setExtractResultInMillis(0L);
			passedAssertions.add(testRunItem);
		}

		final List<TestRunItem> skippedAssertions = new ArrayList<>();
		for(org.snomed.quality.validator.mrcm.Assertion assertion : validationRun.getSkippedAssertions()){
			testRunItem = new TestRunItem();
			testRunItem.setTestCategory(MMRCM_TYPE_VALIDATION);
			testRunItem.setTestType(TestType.MRCM);
			testRunItem.setAssertionUuid(assertion.getUuid());
			testRunItem.setAssertionText(assertion.getAssertionText());
			testRunItem.setFailureCount(0L);
			testRunItem.setExtractResultInMillis(0L);
			skippedAssertions.add(testRunItem);
		}

		final List<TestRunItem> failedAssertions = new ArrayList<>();
		for(org.snomed.quality.validator.mrcm.Assertion assertion : validationRun.getFailedAssertions()){
			testRunItem = new TestRunItem();
			testRunItem.setTestCategory(MMRCM_TYPE_VALIDATION);
			testRunItem.setTestType(TestType.MRCM);
			testRunItem.setAssertionUuid(assertion.getUuid());
			testRunItem.setAssertionText(assertion.getAssertionText());
			testRunItem.setExtractResultInMillis(0L);
			int failureCount = assertion.getConceptIdsWithInvalidAttributeValue().size();
			testRunItem.setFailureCount(Long.valueOf(failureCount));
			List<FailureDetail> failedDetails = new ArrayList(failureCount);
			for (Long conceptId : assertion.getConceptIdsWithInvalidAttributeValue()){
				failedDetails.add(new FailureDetail(String.valueOf(conceptId), assertion.getAssertionText(), null));
			}
			testRunItem.setFirstNInstances(failedDetails.subList(0, failedDetails.size() > 10 ? 10 : failedDetails.size()));
			failedAssertions.add(testRunItem);
		}

		report.addTimeTaken((System.currentTimeMillis() - timeStart) / 1000);
		report.addSkippedAssertions(skippedAssertions);
		report.addFailedAssertions(failedAssertions);
		report.addPassedAssertions(passedAssertions);
	}

	private void runExtensionReleaseValidation(final ValidationReport report, final Map<String, Object> responseMap, ValidationRunConfig validationConfig, String reportStorage,
											   ExecutionConfig executionConfig) throws IOException,
			NoSuchAlgorithmException, DecoderException, BusinessServiceException, SQLException {
		final long timeStart = System.currentTimeMillis();
		//run release-type validations
		List<Assertion> assertions = getAssertions(executionConfig.getGroupNames());
		logger.debug("Total assertions found:" + assertions.size());
		List<Assertion> releaseTypeAssertions = new ArrayList<>();
		for (Assertion assertion : assertions) {
			if (assertion.getKeywords().contains(RELEASE_TYPE_VALIDATION)) {
				releaseTypeAssertions.add(assertion);
			}
		}
		logger.debug("Running release-type validations:" + releaseTypeAssertions.size());
		List<TestRunItem> testItems = runAssertionTests(executionConfig, releaseTypeAssertions,reportStorage,false);
		String prospectiveExtensionVersion = executionConfig.getProspectiveVersion();
		//loading international snapshot
		releaseVersionLoader.combineCurrenExtensionWithDependencySnapshot(executionConfig, responseMap, validationConfig);
		releaseDataManager.dropVersion(prospectiveExtensionVersion);
		//run remaining component-centric and file-centric validaitons
		assertions.removeAll(releaseTypeAssertions);
		testItems.addAll(runAssertionTests(executionConfig, assertions, reportStorage, true));
		constructTestReport(report, timeStart, testItems);
	}

	private List<Assertion> getAssertions(List<String> groupNames) {
		final List<AssertionGroup> groups = assertionService.getAssertionGroupsByNames(groupNames);
		final Set<Assertion> assertions = new HashSet<>();
		for (final AssertionGroup group : groups) {
			assertions.addAll(assertionService.getAssertionsForGroup(group));
		}
		return new ArrayList<Assertion>(assertions);
	}

	private List<TestRunItem> runAssertionTests(ExecutionConfig executionConfig,List<Assertion> assertions, String reportStorage, boolean runResourceAssertions) {
		List<TestRunItem> result = new ArrayList<>();
		if (runResourceAssertions) {
			final List<Assertion> resourceAssertions = assertionService.getResourceAssertions();
			logger.info("Found total resource assertions need to be run before test: " + resourceAssertions.size());
			reportService.writeProgress("Start executing assertions...", reportStorage);
			result.addAll(executeAssertions(executionConfig, resourceAssertions, reportStorage));
		}
		reportService.writeProgress("Start executing assertions...", reportStorage);
		logger.info("Total assertions to run: " + assertions.size());
		if (batchSize == 0) {
			result.addAll(executeAssertions(executionConfig, assertions, reportStorage));
		} else {
			result.addAll(executeAssertionsConcurrently(executionConfig,assertions, batchSize, reportStorage));
		}
		return result;
	}

	private void runAssertionTests(final ValidationReport report, final ExecutionConfig executionConfig, String reportStorage) throws IOException {
		final long timeStart = System.currentTimeMillis();
		final List<AssertionGroup> groups = assertionService.getAssertionGroupsByNames(executionConfig.getGroupNames());
		//execute common resources for assertions before executing group in the future we should run tests concurrently
		final List<Assertion> resourceAssertions = assertionService.getResourceAssertions();
		logger.info("Found total resource assertions need to be run before test: " + resourceAssertions.size());
		reportService.writeProgress("Start executing assertions...", reportStorage);
		 final List<TestRunItem> items = executeAssertions(executionConfig, resourceAssertions, reportStorage);
		final Set<Assertion> assertions = new HashSet<>();
		for (final AssertionGroup group : groups) {
			for (final Assertion assertion : assertionService.getAssertionsForGroup(group)) {
				assertions.add(assertion);
			}
		}
		logger.info("Total assertions to run: " + assertions.size());
		if (batchSize == 0) {
			items.addAll(executeAssertions(executionConfig, assertions, reportStorage));
		} else {
			items.addAll(executeAssertionsConcurrently(executionConfig,assertions, batchSize, reportStorage));
		}
		constructTestReport(report, timeStart, items);
		
	}

	private void constructTestReport(final ValidationReport report, final long timeStart, final List<TestRunItem> items) {
		final long timeEnd = System.currentTimeMillis();
		report.addTimeTaken((timeEnd - timeStart) / 1000);
		//failed tests
		final List<TestRunItem> failedItems = new ArrayList<>();
		final List<TestRunItem> warningItems = new ArrayList<>();
		for (final TestRunItem item : items) {
			if (item.getFailureCount() != 0 && !SeverityLevel.WARN.toString().equalsIgnoreCase(item.getSeverity())) {
				failedItems.add(item);
			}
			if(SeverityLevel.WARN.toString().equalsIgnoreCase(item.getSeverity())){
				warningItems.add(item);
			}
			item.setTestType(TestType.SQL);
		}

		report.addFailedAssertions(failedItems);
		report.addWarningAssertions(warningItems);

		items.removeAll(failedItems);
		items.removeAll(warningItems);
		report.addPassedAssertions(items);

	}

	private List<TestRunItem> executeAssertionsConcurrently(final ExecutionConfig executionConfig, final Collection<Assertion> assertions, int batchSize, String reportStorage) {
		
		final List<Future<Collection<TestRunItem>>> tasks = new ArrayList<>();
		final List<TestRunItem> results = new ArrayList<>();
		int counter = 1;
		List<Assertion> batch = null;
		for (final Assertion assertion: assertions) {
			if (batch == null) {
				batch = new ArrayList();
			}
			batch.add(assertion);
			if (counter % batchSize == 0 || counter == assertions.size()) {
				final List<Assertion> work = batch;
				logger.info(String.format("Started executing assertion [%1s] of [%2s]", counter, assertions.size()));
				final Future<Collection<TestRunItem>> future = executorService.submit(new Callable<Collection<TestRunItem>>() {
					@Override
					public Collection<TestRunItem> call() throws Exception {
						return assertionExecutionService.executeAssertions(work, executionConfig);
					}
				});
				logger.info(String.format("Finished executing assertion [%1s] of [%2s]", counter, assertions.size()));
				//reporting every 10 assertions
				reportService.writeProgress(String.format("[%1s] of [%2s] assertions are started.", counter, assertions.size()), reportStorage);
				tasks.add(future);
				batch = null;
			}
			counter++;
		}
		
		// Wait for all concurrent tasks to finish
		for (final Future<Collection<TestRunItem>> task : tasks) {
			try {
				results.addAll(task.get());
			} catch (ExecutionException | InterruptedException e) {
				logger.error("Thread interrupted while waiting for future result for run item:" + task , e);
			}
		}
		return results;
	}

	private List<TestRunItem> executeAssertions(final ExecutionConfig executionConfig, final Collection<Assertion> assertions, String reportStorage) {
		
		final List<TestRunItem> results = new ArrayList<>();
		int counter = 1;
		for (final Assertion assertion: assertions) {
			logger.info(String.format("Started executing assertion [%1s] of [%2s] with uuid : [%3s]", counter, assertions.size(), assertion.getUuid()));
			results.addAll(assertionExecutionService.executeAssertion(assertion, executionConfig));
			logger.info(String.format("Finished executing assertion [%1s] of [%2s] with uuid : [%3s]", counter, assertions.size(), assertion.getUuid()));
			counter++;
			if (counter % 10 == 0) {
				//reporting every 10 assertions
				reportService.writeProgress(String.format("[%1s] of [%2s] assertions are completed.", counter, assertions.size()), reportStorage);
			}
		}
		reportService.writeProgress(String.format("[%1s] of [%2s] assertions are completed.", counter, assertions.size()), reportStorage);
		return results;
	}

	private void storeLatestVersion(String fileName){
		try {
			Connection connection = snomedDataSource.getConnection();
			connection.setAutoCommit(true);
			String[] fileNameStrArray = fileName.split("_");
			String lastestVersion = fileNameStrArray[fileNameStrArray.length - 1];
			String releaseEdition = fileNameStrArray[fileNameStrArray.length - 3]  + "_" + fileNameStrArray[fileNameStrArray.length - 2];
			lastestVersion = lastestVersion.substring(0, lastestVersion.indexOf("."));
			if(lastestVersion.length() > 8){
				lastestVersion = lastestVersion.substring(0, 8);
			}
			if(lastestVersion.matches(ColumnPatternTester.DATE_PATTERN.pattern())){
				//clean and create database
				String createDbStr = "insert into package_info values ('"+ releaseEdition + "', '" + lastestVersion + "'); ";
				try(Statement statement = connection.createStatement()) {
					statement.execute(createDbStr);
				}
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	public void setDroolRulesModuleName(String droolRulesModuleName) {
		this.droolRulesModuleName = droolRulesModuleName;
	}
}
