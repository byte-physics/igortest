#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access
#pragma DefaultTab={3, 20, 4} // Set default tab width in Igor Pro 9 and later
#pragma version=1.10
#pragma ModuleName=TS_WaveTracking

#include "igortest"
#include "TestUtils"

#if IgorVersion() >= 9.0

// These are tests that check if WaveTracking is correctly done

static Function/WAVE GetWave()
	Make/FREE data
	return data
End

static Function TEST_CASE_END_OVERRIDE(testcase)
	string testcase

	if(!CmpStr(testcase, "TS_WaveTracking#NoLeak") || \
	   !CmpStr(testcase, "TS_WaveTracking#TestCaseAndHookLeak"))
		Leak()
	endif
End

static Function Leak()

	Duplicate/FREE GetWave(), data
	PASS()
End

static Function Leak_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase(tcName = "TS_WaveTracking#Leak")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR, tcName = "TS_WaveTracking#Leak")

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
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

	Utils#ExpectTestCaseStatus(IUTF_STATUS_SUCCESS, tcName = "TEST_CASE_END_OVERRIDE")
End

// This test case itself does not leak but its TEST_CASE_END hook
static Function NoLeak()

	PASS()
End

static Function NoLeak_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase(tcName = "TEST_CASE_END_OVERRIDE")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR, tcName = "TEST_CASE_END_OVERRIDE")

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
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

	Utils#ExpectTestCaseStatus(IUTF_STATUS_SUCCESS, tcName = "TS_WaveTracking#NoLeak")
End

static Function TestCaseAndHookLeak()

	Leak()
End

static Function TestCaseAndHookLeak_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase(tcName = "TS_WaveTracking#TestCaseAndHookLeak")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR, tcName = "TS_WaveTracking#TestCaseAndHookLeak")

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
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

	WAVE/Z/T tc = Utils#LastTestCase(tcName = "TEST_CASE_END_OVERRIDE")
	INFO("Bug: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR, tcName = "TEST_CASE_END_OVERRIDE")

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
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

#endif
