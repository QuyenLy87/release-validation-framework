package org.ihtsdo.rvf.controller;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletResponse;

import org.ihtsdo.rvf.entity.Assertion;
import org.ihtsdo.rvf.entity.AssertionGroup;
import org.ihtsdo.rvf.execution.service.AssertionExecutionService;
import org.ihtsdo.rvf.execution.service.impl.ExecutionConfig;
import org.ihtsdo.rvf.helper.AssertionHelper;
import org.ihtsdo.rvf.service.AssertionService;
import org.ihtsdo.rvf.service.EntityService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wordnik.swagger.annotations.Api;
import com.wordnik.swagger.annotations.ApiModelProperty;
import com.wordnik.swagger.annotations.ApiOperation;
import com.wordnik.swagger.annotations.ApiParam;

@Controller
@RequestMapping("/groups")
@Api(position = 3, value = "Assertions Groups")
public class AssertionGroupController {

	@Autowired
	private AssertionService assertionService;
	@Autowired
	private EntityService entityService;
	@Autowired
	private AssertionExecutionService assertionExecutionService;
	@Autowired
	private AssertionHelper assertionHelper;
	private final ObjectMapper objectMapper = new ObjectMapper();
	private final Logger logger = LoggerFactory
			.getLogger(AssertionGroupController.class);

	@RequestMapping(value = "", method = RequestMethod.GET)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Get all assertion groups", notes = "Retrieves all assertion groups defined in the system.")
	public List<AssertionGroup> getGroups() {
		List<AssertionGroup> result = assertionService.getAllAssertionGroups();
		if (result == null) {
			result = new ArrayList<>();
		}
		return result;
	}

	@RequestMapping(value = "{id}/assertions", method = RequestMethod.GET)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Get all assertions for a given assertion group", notes = "Retrieves all assertions for a given assertion group identified by the group id.")
	public List<Assertion> getAssertionsForGroup(@ApiParam(value = "Assertion group id") @PathVariable final Long id) {

		final AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);
		return assertionService.getAssertionsForGroup(group);
	}

	@RequestMapping(value = "{id}/assertions", method = RequestMethod.POST)
	@ResponseBody
	@ApiOperation(value = "Add assertions to a group", notes = "Adds assertions to the assertion group identified by the group id.")
	public AssertionGroup addAssertionsToGroup(@PathVariable final Long id,
			@RequestBody(required = false) final List<String> assertionsList,
			final HttpServletResponse response) {

		final AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);

		// Do we have anything to add?
		if (assertionsList == null || assertionsList.size() == 0) {
			response.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
		} else {
			final List<Assertion> assertions = getAssertions(assertionsList);
			for (final Assertion assertion : assertions) {
				assertionService.addAssertionToGroup(assertion, group);
			}
			response.setStatus(HttpServletResponse.SC_OK);
		}

		return group;
	}

	@RequestMapping(value = "{id}/addAllAssertions", method = RequestMethod.PUT)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Add all assertions available in the system to a group", notes = "Adds all assertions available in the system to a group."
			+ " This api may only be used when user desires to add all assertion found in the system to an assertion group"
			+ " otherwise use {id}/assertions api as post call.")
	public AssertionGroup addAllAssertions(@PathVariable final Long id) {
		final AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);
		final List<Assertion> assertionList = entityService.findAll(Assertion.class);
		final Set<Assertion> assertionSet = new HashSet<>(assertionList);
		group.setAssertions(assertionSet);
		return (AssertionGroup) entityService.update(group);
	}

	@RequestMapping(value = "{id}/assertions", method = RequestMethod.DELETE)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Delete assertions from a group", notes = "Removes supplied assertions from a given assertion group")
	public AssertionGroup removeAssertionsFromGroup(
			@PathVariable final Long id,
			@ApiParam(value = "Only assertion id is required") @RequestBody final List<Assertion> assertions) {
		AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);
		List<Assertion> toRemove = new ArrayList<>();
		for (Assertion assertion : assertions) {
			toRemove.add((Assertion) entityService.find(Assertion.class,
					assertion.getAssertionId()));
		}
		for (final Assertion assertion : toRemove) {
			group = assertionService.removeAssertionFromGroup(assertion, group);
		}
		return group;
	}

	@RequestMapping(value = "{id}/assertions", method = RequestMethod.PUT)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Add supplied assertions to an assertion group", notes = "Replaces existing assertions of an assertion group with supplied assertions")
	public AssertionGroup setAsAssertionsInGroup(@PathVariable final Long id,
			@RequestBody(required = false) final Set<Assertion> assertions) {

		final AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);
		// replace all existing assertions with current list
		group.setAssertions(assertions);

		return (AssertionGroup) entityService.update(group);
	}

	@RequestMapping(value = "{id}", method = RequestMethod.GET)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Get an assertion group", notes = "Retrieves an assertion group for a given id")
	public AssertionGroup getAssertionGroup(@PathVariable final Long id) {
		return (AssertionGroup) entityService.find(AssertionGroup.class, id);
	}

	@RequestMapping(value = "{id}", method = RequestMethod.DELETE)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Delete an assertion group", notes = "Deletes an assertion group from the system")
	public AssertionGroup deleteAssertionGroup(@ApiParam(value="Assertion group id") @PathVariable final Long id) {
		final AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);
		group.removeAllAssertionsFromGroup();
		entityService.delete(group);
		return group;
	}

	@RequestMapping(value = "", method = RequestMethod.POST)
	@ResponseBody
	@ResponseStatus(HttpStatus.CREATED)
	@ApiOperation(value = "Create an assertion group with specified name", notes = "Creates an assertion group with specified name")
	public AssertionGroup createAssertionGroupWithName(
			@RequestParam final String name) {
		final AssertionGroup group = new AssertionGroup();
		group.setName(name);
		return (AssertionGroup) entityService.create(group);
	}

	@RequestMapping(value = "{id}", method = RequestMethod.PUT)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Update an assertion group", notes = "Updates the group name for the assertion group identified by the group id.")
	public AssertionGroup updateAssertionGroup(@PathVariable final Long id,
			@ApiParam(value = "Assertion group name") @RequestParam final String name) {
		final AssertionGroup group = (AssertionGroup) entityService.find(AssertionGroup.class, id);
		group.setName(name);
		return (AssertionGroup) entityService.update(group);
	}

	@RequestMapping(value = "/{id}/run", method = RequestMethod.POST)
	@ResponseBody
	@ResponseStatus(HttpStatus.OK)
	@ApiOperation(value = "Execute all tests for a given assertion group", notes = "Executes all tests for the assertion group identified by the group id.")
	public Map<String, Object> executeAssertions(@ApiParam(value="Assertion group id")@PathVariable final Long id,
			@ApiParam(value="Unique number") @RequestParam final Long runId,
			@ApiParam(value="Prospective version") @RequestParam final String prospectiveReleaseVersion,
			@ApiParam(value="Previous release version") @RequestParam final String previousReleaseVersion) {

		final AssertionGroup group = (AssertionGroup) entityService.find(
				AssertionGroup.class, id);
		final ExecutionConfig config = new ExecutionConfig(runId);
		config.setPreviousVersion(previousReleaseVersion);
		config.setProspectiveVersion(prospectiveReleaseVersion);
		config.setFailureExportMax(-1);
		return assertionHelper.assertAssertions(
				assertionService.getAssertionsForGroup(group), config);
	}

	private List<Assertion> getAssertions(final List<String> items) {

		final List<Assertion> assertions = new ArrayList<>();
		for (final String item : items) {
			try {
				if (item.matches("\\d+")) {
					// treat as assertion id and retrieve associated assertion
					final Assertion assertion = assertionService.find(Long
							.valueOf(item));
					if (assertion != null) {
						assertions.add(assertion);
					}
				} else {
					assertions.add(objectMapper
							.readValue(item, Assertion.class));
				}
			} catch (final IOException e) {
				e.printStackTrace();
			}
		}

		return assertions;
	}
}
