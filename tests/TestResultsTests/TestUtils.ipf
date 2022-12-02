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

