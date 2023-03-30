#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.10
#pragma ModuleName = TS_RetryTests

#include "igortest"
#include "TestUtils"

static Function TEST_SUITE_BEGIN_OVERRIDE(name)
	string name

	variable/G root:retryCounter = 0
End

static Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name
End

static Function TEST_CASE_END_OVERRIDE(name)
	string name
End

static Function ExecFlaky_IGNORE()
	NVAR counter = root:retryCounter
	counter += 1
	CHECK_GE_VAR(counter, 5)
	if(counter >= 5)
		counter = 0
	endif
End

// IUTF_RETRY_FAILED
static Function UnreliableStatus()
	ExecFlaky_IGNORE()
End

static Function CheckUserHooks()
	variable i, startIndex, endIndex, retries
	string expect, result

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
	startIndex = str2num(wvTestSuite[%CURRENT][%CHILD_START])
	endIndex = str2num(wvTestSuite[%CURRENT][%CHILD_END])

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	for(i = startIndex + 1; i < endIndex - 1; i += 1)
		if(CmpStr("TS_RetryTests#UnreliableStatus", wvTestCase[i][%NAME]))
			continue
		endif

		INFO("Expect user begin hook %d at index %d", n0 = retries, n1 = i)
		expect = "TEST_CASE_BEGIN_OVERRIDE"
		result = wvTestCase[i - 1][%NAME]
		CHECK_EQUAL_STR(expect, result)

		INFO("Expect user end hook %d at index %d", n0 = retries, n1 = i)
		expect = "TEST_CASE_END_OVERRIDE"
		result = wvTestCase[i + 1][%NAME]
		CHECK_EQUAL_STR(expect, result)

		retries += 1
	endfor

	INFO("Check if the test case was retried the correct number of times")
	CHECK_EQUAL_VAR(5, retries)
End

static Function SetupRequireFlaky()
	variable/G root:retryCounter = 0
	PASS()
End

// IUTF_RETRY_FAILED
static Function UnreliableStatusReq()
	NVAR counter = root:retryCounter
	counter += 1
	REQUIRE_GE_VAR(counter, 5)
End

static Function SetupMultiFlaky()
	variable/G root:retryCounter = 0
	PASS()
End

static Function/WAVE GetDG()
	Make/FREE wv = { 1, 2, 3 }
	return wv
End

// IUTF_RETRY_FAILED
// IUTF_TD_GENERATOR GetDG
static Function UnreliableStatusMD([n])
	variable n

	INFO("MD: %d", n0 = n)
	ExecFlaky_IGNORE()
End

static Function CheckUserHooksMD()
	variable i, startIndex, endIndex, retries0, retries1, retries2, istc
	string expect, result

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
	startIndex = str2num(wvTestSuite[%CURRENT][%CHILD_START])
	endIndex = str2num(wvTestSuite[%CURRENT][%CHILD_END])

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	for(i = startIndex + 1; i < endIndex - 1; i += 1)
		istc = 0
		strswitch(wvTestCase[i][%NAME])
			case "TS_RetryTests#UnreliableStatusMD:0":
				retries0 += 1
				istc = 1
				break
			case "TS_RetryTests#UnreliableStatusMD:1":
				retries1 += 1
				istc = 1
				break
			case "TS_RetryTests#UnreliableStatusMD:2":
				retries2 += 1
				istc = 1
				break
		endswitch

		if(!istc)
			continue
		endif

		INFO("Expect user begin hook (%d,%d,%d) at index %d", n0 = retries0, n1 = retries1, n2 = retries1, n3 = i)
		expect = "TEST_CASE_BEGIN_OVERRIDE"
		result = wvTestCase[i - 1][%NAME]
		CHECK_EQUAL_STR(expect, result)

		INFO("Expect user end hook (%d,%d,%d) at index %d", n0 = retries0, n1 = retries1, n2 = retries1, n3 = i)
		expect = "TEST_CASE_END_OVERRIDE"
		result = wvTestCase[i + 1][%NAME]
		CHECK_EQUAL_STR(expect, result)
	endfor

	INFO("Check if the test case 0 was retried the correct number of times")
	CHECK_EQUAL_VAR(5, retries0)
	INFO("Check if the test case 1 was retried the correct number of times")
	CHECK_EQUAL_VAR(5, retries1)
	INFO("Check if the test case 2 was retried the correct number of times")
	CHECK_EQUAL_VAR(5, retries2)
End

// IUTF_RETRY_FAILED
// IUTF_TD_GENERATOR v0:GetDG
// IUTF_TD_GENERATOR v1:GetDG
static Function UnreliableStatusMMD([m])
	STRUCT IUTF_mData& m

	INFO("MMD: %d,%d", n0 = m.v0, n1 = m.v1)
	ExecFlaky_IGNORE()
End

static Function CheckUserHooksMMD()
	variable i, startIndex, endIndex, retries
	string expect, result

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
	startIndex = str2num(wvTestSuite[%CURRENT][%CHILD_START])
	endIndex = str2num(wvTestSuite[%CURRENT][%CHILD_END])

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	for(i = startIndex + 1; i < endIndex - 1; i += 1)

		if(CmpStr("TS_RetryTests#UnreliableStatusMMD", StringFromList(0, wvTestCase[i][%NAME], ":")))
			continue
		endif

		INFO("Expect user begin hook %d at index %d", n0 = retries, n1 = i)
		expect = "TEST_CASE_BEGIN_OVERRIDE"
		result = wvTestCase[i - 1][%NAME]
		CHECK_EQUAL_STR(expect, result)

		INFO("Expect user end hook %d at index %d", n0 = retries, n1 = i)
		expect = "TEST_CASE_END_OVERRIDE"
		result = wvTestCase[i + 1][%NAME]
		CHECK_EQUAL_STR(expect, result)

		retries += 1
	endfor

	INFO("Check if the test case was retried the correct number of times")
	CHECK_EQUAL_VAR(5 * 3 * 3, retries)
End
