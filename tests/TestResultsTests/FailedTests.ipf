#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = TS_FailedTests

#include "unit-testing"
#include "TestUtils"

// These are tests that check ifI IUTF works correctly with failed tests

static Function StatusFail()
	CHECK(0)
End

static Function StatusFail_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/T/Z tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_FAIL)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd = str2num(tc[0][%CHILD_END])
	INFO("Check if exactly one assertion was thrown")
	CHECK_EQUAL_VAR(1, childEnd - childStart)

	stdErr = tc[0][%STDERR]
	INFO("Check if stderr is not empty")
	CHECK_NON_EMPTY_STR(stdErr)

	INFO("Check if one assertion errors is set")
	expect = "1"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "1"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

static Function MultipleAssertions()
	INFO("First assertion")
	CHECK(0)

	INFO("succeeded assertion")
	PASS()

	INFO("third assertion")
	CHECK(0)
End

static Function MultipleAssertions_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/T/Z tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_FAIL)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd = str2num(tc[0][%CHILD_END])
	INFO("Check if exactly two assertions are thrown")
	CHECK_EQUAL_VAR(2, childEnd - childStart)

	WAVE/T assert = Utils#GetTestAssertions(childStart, childEnd)

	childStart = str2num(assert[0][%CHILD_START])
	childEnd = str2num(assert[0][%CHILD_END])
	INFO("Check if assertion 0 got 1 information")
	CHECK_EQUAL_VAR(1, childEnd - childStart)
	WAVE/T infos = Utils#GetTestInfos(childStart, childEnd)
	expect = "First assertion"
	result = infos[0][%MESSAGE]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(assert[1][%CHILD_START])
	childEnd = str2num(assert[1][%CHILD_END])
	INFO("Check if assertion 1 got 1 information")
	CHECK_EQUAL_VAR(1, childEnd - childStart)
	WAVE/T infos = Utils#GetTestInfos(childStart, childEnd)
	expect = "third assertion"
	result = infos[0][%MESSAGE]
	CHECK_EQUAL_STR(expect, result)

	stdErr = tc[0][%STDERR]
	INFO("Check if stderr is not empty")
	CHECK_NON_EMPTY_STR(stdErr)

	INFO("Check if two assertion errors are set")
	expect = "2"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "3"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

// UTF_EXPECTED_FAILURE
static Function EmptyExpected()
	PASS()
End

static Function EmptyExpected_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/T/Z tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_FAIL)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd = str2num(tc[0][%CHILD_END])
	INFO("Check if exactly one assertion was thrown")
	CHECK_EQUAL_VAR(1, childEnd - childStart)

	stdErr = tc[0][%STDERR]
	INFO("Check if stderr is not empty")
	CHECK_NON_EMPTY_STR(stdErr)

	INFO("Check if one assertion errors is set")
	expect = "1"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "1" // the failed check after the test case doesn't count as assertion
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End
