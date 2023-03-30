#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.10
#pragma ModuleName = TS_BadHooks

#include "igortest"
#include "TestUtils"

// These are tests that checks if failed hooks have the correct output in the test results

static Function TEST_CASE_BEGIN_OVERRIDE(testCase)
	string testCase

	INFO("test if failed assertions in hooks work")
	CHECK(0)
End

// the start of this test case alone checks if a failed test hook does not have influence to the
// execution of other test cases.
static Function TestBeginHook_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/T/Z tc = Utils#LastTestCase(tcName = "TEST_CASE_BEGIN_OVERRIDE")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_FAIL, tcName = "TEST_CASE_BEGIN_OVERRIDE")

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
