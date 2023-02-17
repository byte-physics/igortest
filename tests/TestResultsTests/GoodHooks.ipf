#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = TS_GoodHooks

#include "igortest"
#include "TestUtils"

// These are tests that checks if normal hooks have the correct output in the test results

static Function TEST_CASE_BEGIN_OVERRIDE(testCase)
	string testCase

	// assertions are optional but this tests if assertions work at all
	PASS()
End

static Function TestBeginHook_Verify()
	string expect, result
	variable childStart, childEnd, startTime, endTime

	WAVE/T/Z tc = Utils#LastTestCase(tcName = "TEST_CASE_BEGIN_OVERRIDE")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd = str2num(tc[0][%CHILD_END])
	INFO("Check if no children are defined")
	CHECK_EQUAL_VAR(childStart, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime = str2num(tc[0][%ENDTIME])
	INFO("Check if endtime is not before the starttime")
	CHECK_LE_VAR(startTime, endTime)

	INFO("Check if no errors are thrown")
	result = tc[0][%STDERR]
	CHECK_EMPTY_STR(result)

	INFO("Check if no assertion errors are set")
	expect = "0"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "1"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

static Function TEST_CASE_END_OVERRIDE(testCase)
	string testCase

	// assertions in user hooks are optional and this tests if no assertions at all succeed
End

static Function TestEndHook_Verify()
	string expect, result
	variable childStart, childEnd, startTime, endTime

	WAVE/T/Z tc = Utils#LastTestCase(tcName = "TEST_CASE_END_OVERRIDE")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd = str2num(tc[0][%CHILD_END])
	INFO("Check if no children are defined")
	CHECK_EQUAL_VAR(childStart, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime = str2num(tc[0][%ENDTIME])
	INFO("Check if endtime is not before the starttime")
	CHECK_LE_VAR(startTime, endTime)

	INFO("Check if no errors are thrown")
	result = tc[0][%STDERR]
	CHECK_EMPTY_STR(result)

	INFO("Check if no assertion errors are set")
	expect = "0"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "0"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End
