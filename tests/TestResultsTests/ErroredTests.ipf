#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access
#pragma DefaultTab={3, 20, 4} // Set default tab width in Igor Pro 9 and later
#pragma version=1.10
#pragma ModuleName=TS_ErroredTests

#include "igortest"
#include "TestUtils"

// These are tests that check if IUTF works correctly with errored tests

static Function PendingRTE()
	// Increase assertion counter
	PASS()
	// Create pending RTE
	WAVE/Z   wv   = $""
	variable test = wv[0]
End

static Function PendingRTE_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR)

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

static Function InfoWithPendingRTE()
	// increase assertion counter
	PASS()
	// create a pending RTE
	WAVE/Z   wv   = $""
	variable test = wv[0]
	// INFO refuses to format while an RTE is pending -- Igor's sprintf
	// misbehaves in that state -- and reports the refusal as a failed
	// assertion. See the "RTEs and aborts" section of examples.rst.
	INFO("info after a pending RTE")
End

static Function InfoWithPendingRTE_Verify()
	string expect, result
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
	INFO("Check if the failed INFO and the uncaught RTE were recorded")
	CHECK_EQUAL_VAR(2, childEnd - childStart)

	WAVE/T assert = Utils#GetTestAssertions(childStart, childEnd)
	INFO("Check if the first failure is the INFO and names the pending RTE")
	CHECK(strsearch(assert[0][%MESSAGE], "Pending RTE detected", 0) >= 0)
	INFO("Check if the second failure is the uncaught RTE")
	CHECK(strsearch(assert[1][%MESSAGE], "Uncaught runtime error 330", 0) >= 0)

	INFO("Check if INFO left the assertion counter alone")
	expect = "1"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the failed INFO was counted as an assertion error")
	expect = "2"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)
End

static Function TestStackOverflow()
	// increase assertion counter
	PASS()
	// provoke stack overflow
	CHECK(OverflowHelper_IGNORE(0))
End

static Function OverflowHelper_IGNORE(a)
	variable a

	variable b = OverflowHelper_IGNORE(a + 1)

	return b
End

static Function TestStackOverflow_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR)

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

static Function TestAbort()
	// increase assertion counter
	PASS()
	// trigger abort
	abort
	// this code should never executed
	PASS()
End

static Function TestAbort_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR)

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

static Function TestAbortOnValue()
	// increase assertion counter
	PASS()
	// trigger abort
	AbortOnValue 1, 42
	// this code should never executed
	PASS()
End

static Function TestAbortOnValue_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR)

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

static Function TestAbortOnRTE()
	// increase assertion counter
	PASS()
	// trigger abort
	WAVE/Z wv = $""
	wv[0] = 1
	AbortOnRTE
	// this code should never executed
	PASS()
End

static Function TestAbortOnRTE_Verify()
	string expect, result, stdErr
	variable childStart, childEnd

	WAVE/Z/T tc = Utils#LastTestCase()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	Utils#ExpectTestCaseStatus(IUTF_STATUS_ERROR)

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
