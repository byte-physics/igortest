#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = Utils

#include "unit-testing"

static Function/WAVE GetGridRows(wv, y1, y2)
	WAVE/T wv
	variable y1, y2

	variable i
	string label
	variable columns = DimSize(wv, UTF_COLUMN)

	if(y1 > y2)
		return GetGridRows(wv, y2, y1)
	endif

	MAKE/FREE/N=(y2 - y1, columns)/T result = wv[p + y1][q]

	for(i = 0; i < columns; i += 1)
		label = GetDimLabel(wv, UTF_COLUMN, i)
		SetDimLabel UTF_COLUMN, i, $label, result
	endfor

	return result
End

static Function/WAVE GetGridRow(wv, y)
	WAVE/T wv
	variable y

	WAVE/T result = GetGridRows(wv, y, y + 1)

	return result
End

/// @brief Searches for the index of the last test case that was run. This will only check for test
/// cases in the same test suite. This function will also check if the current test case was run
/// multiple times and always return the test case before the current one.
/// If no previous test case exists it will return -1.
static Function LastTestCaseIndex()
	variable index, start, i

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	index = FindDimLabel(wvTestCase, UTF_ROW, "CURRENT")

	if(index <= 0)
		return -1
	endif

	// check the limits of the current test suite
	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	start = str2num(wvTestSuite[%CURRENT][%CHILD_START])

	// search for the previous test case with a different name. A test case can rerun under certain
	// circumstances so the same test case name can appear more than once.
	for(i = index - 1; i >= start; i -= 1)
		if(CmpStr(wvTestCase[index][%NAME], wvTestCase[i][%NAME]))
			return i
		endif
	endfor

	return -1
End

/// @brief Searches for the last test case that was run. This will only check for test
/// cases in the same test suite. This function will also check if the current test case was run
/// multiple times and always return the test case before the current one.
/// If no previous test case exists it will return null.
static Function/WAVE LastTestCase()
	variable index = LastTestCaseIndex()

	if(index < 0)
		return $""
	endif

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	WAVE/T result = GetGridRow(wvTestCase, index)

	return result
End

/// @brief Searches for the last test case that was run. This will only check for test
/// cases in the same test suite. This function will also check if the current test case was run
/// multiple times and always return the test case before the current one.
/// If no previous test case exists it will return null. If the previous test case was run
/// multiple times it will return all of them.
static Function/WAVE LastTestCases()
	string name, name2
	variable start

	variable index = LastTestCaseIndex()

	if(index < 0)
		return $""
	endif

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()

	if(index > 0)
		name = StringFromList(0, wvTestCase[index][%NAME], ":")
		for(start = index - 1; start >= 0; start -= 1)
			name2 = StringFromList(0, wvTestCase[start][%NAME], ":")
			if(CmpStr(name, name2))
				start += 1
				break
			endif
		endfor
		start = max(0, start)
	else
		start = index
	endif

	WAVE/T result = GetGridRows(wvTestCase, start, index + 1)

	return result
End

/// @brief Checks if the status of the last test case is the expected one. If the expected test
/// status is IUTF_STATUS_ERROR or IUTF_STATUS_FAIL this will change the status to
/// IUTF_STATUS_SUCCESS and revert any error counter.
/// This changes the global state! Try to receive a copy with LastTestCase() first!
static Function ExpectTestCaseStatus(status, [offset])
	string status
	variable offset

	string expect, result
	variable isFailed, numAssertError
	variable tcIndex = LastTestCaseIndex()

	offset = ParamIsDefault(offset) ? 0 : offset

	tcIndex += offset

	INFO("BUG: a last test was expected (offset: %d, index: %d)", n1 = offset, n2 = tcIndex)
	REQUIRE_LE_VAR(0, tcIndex)

	WAVE/T wvTest = UTF_Reporting#GetTestCaseWave()
	INFO("TC index: %d, offset: %d", n0 = tcIndex, n1 = offset)
	expect = status
	result = wvTest[tcIndex][%STATUS]
	CHECK_EQUAL_STR(expect, result)

#ifndef UTF_KEEP_TC_STATUS

	if(CmpStr(status, IUTF_STATUS_ERROR) && CmpStr(status, IUTF_STATUS_FAIL))
		return NaN
	endif

	isFailed = !CmpStr(status, wvTest[tcIndex][%STATUS])
	numAssertError = str2num(wvTest[tcIndex][%NUM_ASSERT_ERROR])

	wvTest[tcIndex][%STATUS] = IUTF_STATUS_SUCCESS
	wvTest[tcIndex][%NUM_ASSERT_ERROR] = "0"
	wvTest[tcIndex][%STDOUT] = ""
	wvTest[tcIndex][%STDERR] = ""
	wvTest[tcIndex][%CHILD_END] = wvTest[tcIndex][%CHILD_START] // trim any assertions

	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	if(isFailed)
		wvTestSuite[%CURRENT][%NUM_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ERROR]) - 1)
	endif
	wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]) - numAssertError)

#endif
End

static Function/WAVE GetTestAssertions(childStart, childEnd)
	variable childStart, childEnd

	CHECK_LE_VAR(childStart, childEnd)

	WAVE/T wvAssertion = UTF_Reporting#GetTestAssertionWave()
	WAVE/T result = GetGridRows(wvAssertion, childStart, childEnd)

	return result
End

static Function/WAVE GetTestInfos(childStart, childEnd)
	variable childStart, childEnd

	CHECK_LE_VAR(childStart, childEnd)

	WAVE/T wvInfo = UTF_Reporting#GetTestInfoWave()
	WAVE/T result = GetGridRows(wvInfo, childStart, childEnd)

	return result
End