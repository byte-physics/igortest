#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = TS_ReentryTests

#include "unit-testing"
#include "TestUtils"

// These are tests that check if UTF works correctly with re-entry tests

// a simple background task that directly exists after its first run
static Function ReEntryTask(s)
	STRUCT WMBackgroundStruct &s

	PASS()

	return 1 // exit
End

static Function CheckBackgroundTask()
	PASS()
	CtrlNamedBackground testtask, proc=TS_ReentryTests#ReEntryTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "TS_ReentryTests#CheckBackgroundTask_REENTRY")
End

static Function CheckBackgroundTask_REENTRY()

	PASS()
End

static Function CheckBackgroundTask_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/T/Z tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_SUCCESS)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd = str2num(tc[0][%CHILD_END])
	INFO("Check if no assertion was thrown")
	CHECK_EQUAL_VAR(0, childEnd - childStart)

	stdErr = tc[0][%STDERR]
	INFO("Check if stderr is empty")
	CHECK_EMPTY_STR(stdErr)

	INFO("Check if no assertion errors are set")
	expect = "0"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "3"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End
