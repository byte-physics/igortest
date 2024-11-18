#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access
#pragma DefaultTab={3, 20, 4} // Set default tab width in Igor Pro 9 and later
#pragma version=1.10
#pragma ModuleName=TS_EasyTests

#include "igortest"
#include "TestUtils"

// These are simple tests that do not rely on modifying the test results

static Function StatusSuccess()
	PASS()
	PASS()
End

static Function StatusSuccess_Verify()
	string expect, result
	variable childStart, childEnd, startTime, endTime

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
	INFO("Check if no children are defined")
	CHECK_EQUAL_VAR(childStart, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime   = str2num(tc[0][%ENDTIME])
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
	expect = "2"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

// IUTF_SKIP
static Function StatusSkip()
	FAIL()
End

static Function StatusSkip_Verify()
	string expect, result
	variable childStart, childEnd, startTime, endTime

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("Check if status is skip")
	expect = IUTF_STATUS_SKIP
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
	INFO("Check if no children are defined")
	CHECK_EQUAL_VAR(childStart, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime   = str2num(tc[0][%ENDTIME])
	INFO("Check if start time is 0")
	CHECK_EQUAL_VAR(0, startTime)
	INFO("Check if end time is 0")
	CHECK_EQUAL_VAR(0, endTime)

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

// IUTF_EXPECTED_FAILURE
static Function ExpectedFailures()
	CHECK(0)
End

static Function ExpectedFailures_Verify()
	string expect, result
	variable childStart, childEnd, startTime, endTime

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
	INFO("Check if some children are defined")
	CHECK_EQUAL_VAR(childStart + 1, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime   = str2num(tc[0][%ENDTIME])
	INFO("Check if endtime is not before the starttime")
	CHECK_LE_VAR(startTime, endTime)

	INFO("Check if some errors are thrown")
	result = tc[0][%STDERR]
	CHECK_NON_EMPTY_STR(result)

	INFO("Check if no assertion errors are set")
	expect = "0"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "1"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

static Function InfoInErrorOutput()
	INFO("find this info")
	WARN(0)
End

static Function InfoInErrorOutput_Verify()
	string expect, result
	variable childStart, childEnd, startTime, endTime

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the information is included in the error output")
	expect = "find this info"
	result = tc[0][%STDERR]
	CHECK(strsearch(result, expect, 0) > -1)
End

// The following 4 tests rely on consecutive execution in the order of appearance
static Function TC_SkipTC()

	SKIP_TESTCASE()
End

static Function TC_SkipTC_Check()

	WAVE/T wvSuite = IUTF_Reporting#GetTestSuiteWave()
	CHECK_EQUAL_STR(wvSuite[%CURRENT][%NUM_SKIPPED], "1")
End

static Function TC_SkipTCFail()

	CHECK(0)
	SKIP_TESTCASE_EXPECT_FAILS()
End

static Function TC_SkipTCFail_Check()

	WAVE/T wvSuite = IUTF_Reporting#GetTestSuiteWave()
	CHECK_EQUAL_STR(wvSuite[%CURRENT][%NUM_SKIPPED], "2")
End
