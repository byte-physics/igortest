#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = TS_MD_Tests

#include "igortest"
#include "TestUtils"

// These are tests that check if IUTF works correctly with multi data tests

// IUTF_TD_GENERATOR CheckMultiData_GEN
static Function CheckMultiData([arg])
	variable arg

	CHECK_LE_VAR(1, arg)
	CHECK_NEQ_VAR(2, arg)
	CHECK_LE_VAR(arg, 4)
End

static Function/WAVE CheckMultiData_GEN()
	Make/FREE data = { 1, 2, 3, 4 }
	return data
End

static Function CheckMultiData_Verify()
	string expect, result, stdErr
	variable i, childStart, childEnd

	WAVE/T/Z tc = Utils#LastTestCases()
	INFO("BUG: test case not found")
	REQUIRE(WaveExists(tc))

	INFO("BUG: 4 test instances are expected")
	REQUIRE_EQUAL_VAR(4, DimSize(tc, UTF_ROW))

	for(i = 0; i < 4; i += 1)
		if(i == 1)
			Utils#ExpectTestCaseStatus(IUTF_STATUS_FAIL, offset = i - 3)

			childStart = str2num(tc[i][%CHILD_START])
			childEnd = str2num(tc[i][%CHILD_END])
			INFO("Check if one assertion was thrown (offset: %d)", n0 = i)
			CHECK_EQUAL_VAR(1, childEnd - childStart)

			stdErr = tc[i][%STDERR]
			INFO("Check if stderr not empty (offset: %d)", n0 = i)
			CHECK_NON_EMPTY_STR(stdErr)

			INFO("Check if one assertion errors are set (offset: %d)", n0 = i)
			expect = "1"
			result = tc[i][%NUM_ASSERT_ERROR]
			CHECK_EQUAL_STR(expect, result)

			INFO("Check if the assertion counter is correct (offset: %d)", n0 = i)
			expect = "3"
			result = tc[i][%NUM_ASSERT]
			CHECK_EQUAL_STR(expect, result)
		else
			Utils#ExpectTestCaseStatus(IUTF_STATUS_SUCCESS, offset = i - 3)

			childStart = str2num(tc[i][%CHILD_START])
			childEnd = str2num(tc[i][%CHILD_END])
			INFO("Check if no assertion was thrown (offset: %d)", n0 = i)
			CHECK_EQUAL_VAR(0, childEnd - childStart)

			stdErr = tc[i][%STDERR]
			INFO("Check if stderr is empty (offset: %d)", n0 = i)
			CHECK_EMPTY_STR(stdErr)

			INFO("Check if no assertion errors are set (offset: %d)", n0 = i)
			expect = "0"
			result = tc[i][%NUM_ASSERT_ERROR]
			CHECK_EQUAL_STR(expect, result)

			INFO("Check if the assertion counter is correct (offset: %d)", n0 = i)
			expect = "3"
			result = tc[i][%NUM_ASSERT]
			CHECK_EQUAL_STR(expect, result)
		endif
	endfor
End
