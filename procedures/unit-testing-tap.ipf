#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=UTF_Tap

// Licensed under 3-Clause BSD, see License.txt

static StrConstant TAP_LINEEND_STR     = "\n"

/// @brief returns 1 if all test cases are marked as SKIP and TAP is enabled, zero otherwise
///
/// @param testCaseList list of function names
/// @returns 1 if all test cases are marked as SKIP and TAP is enabled, zero otherwise
static Function TAP_AreAllFunctionsSkip()

	variable dimPos

	WAVE/T testRunData = UTF_Basics#GetTestRunData()
	dimPos = FindDimLabel(testRunData, UTF_COLUMN, "SKIP")
	Duplicate/FREE/R=[][dimPos, dimPos] testRunData, skipCol

	return DimSize(testRunData, UTF_ROW) == sum(skipCol)
End

/// @brief returns 1 if function is marked as TODO, zero otherwise
///
/// @param funcName name of function
/// @returns 1 if function is marked as TODO, zero otherwise
static Function TAP_IsFunctionTodo(funcName)
	string funcName

	variable err
	string str

	str = UTF_Utils#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
	if(!err)
		return strsearch(str, "TODO", 0, 2) == 0
	endif

	return 0
End

/// @brief returns 1 if function is marked as SKIP, zero otherwise
///
/// @param funcName name of function
/// @returns 1 if function is marked as SKIP, zero otherwise
static Function TAP_IsFunctionSkip(funcName)
	string funcName

	variable err
	string str

	str = UTF_Utils#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
	if(err == UTF_TAG_OK)
		return strsearch(str, "SKIP", 0, 2) == 0
	endif

	return 0
End

static Function/S TAP_GetValidDirective(str)
	string str

	str = "# " + ReplaceString("#", str, "_")

	return str
End

/// If a TAP Description starts with a digit (which is invalid), add a '_' at the front
static Function/S TAP_GetValidDescription(str)
	string str

	string notAllowedStart = "0123456789"
	variable i

	str = ReplaceString("#", str, "_")

	for(i = 0; i < strlen(notAllowedStart); i += 1)
		if(strsearch(str, notAllowedStart[i], 0) == 0)
			return ("_" + str)
		endif
	endfor
	return str
end

/// Converts generic diagnostic text to a valid TAP diagnostic text
static Function/S TAP_ValidDiagnostic(diag)
	string diag

	if(UTF_Utils#IsEmpty(diag))
		return diag
	endif
	// diagnostic message may start with 'ok' or 'not ok' in a line which are TAP keywords
	// so we add a "#" to each line
	diag = "# " + diag
	diag = ReplaceString("\r\n", diag, "\r")
	diag = ReplaceString("\r", diag, TAP_LINEEND_STR + "# ")
	diag = ReplaceString("\n", diag, TAP_LINEEND_STR + "# ")
	diag = diag[0, strlen(diag) - 3]
	return diag
End

/// @brief Converts a test case into TAP text
///
/// @param testCaseIndex     The index of the current test case inside the results wave
/// @param[in,out] caseCount The current number of printed test cases. This is used as all test
///                          cases need their own unique index and TAP has no concept of test
///                          suites. This function wont update this number.
static Function/S TAP_ToTestCaseString(testCaseIndex, caseCount)
	variable testCaseIndex
	variable caseCount

	string name, out, ok, diagnostics, description, directive, caseCountStr
	variable err

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	name = wvTestCase[testCaseIndex][%NAME]
	diagnostics = wvTestCase[testCaseIndex][%STDERR]
	directive = UTF_Utils#GetFunctionTagValue(name, UTF_FTAG_TAP_DIRECTIVE, err)
	if(err != UTF_TAG_OK)
		directive = ""
	endif
	description = UTF_Utils#GetFunctionTagValue(name, UTF_FTAG_TAP_DESCRIPTION, err)
	if(err != UTF_TAG_OK)
		description = ""
	endif

	directive = TAP_GetValidDirective(directive)
	description = TAP_GetValidDescription(description)

	strswitch(wvTestCase[testCaseIndex][%STATUS])
		case IUTF_STATUS_SKIP:
			ok = "ok"
			diagnostics = ""
			break
		case IUTF_STATUS_SUCCESS:
			ok = "ok"
			diagnostics = TAP_ValidDiagnostic(diagnostics)
			break
		case IUTF_STATUS_ERROR:
		case IUTF_STATUS_FAIL:
			ok = "not ok"
			diagnostics = TAP_ValidDiagnostic(diagnostics)
			break
		default:
			printf "Error: Unknown test status %s for test case %s (%d)\r", wvTestCase[testCaseIndex][%STATUS], name, testCaseIndex
			return ""
	endswitch

	sprintf caseCountStr, "%d", caseCount
	out = ok + " " + caseCountStr + " " + description + " " + directive + TAP_LINEEND_STR
	out += diagnostics

	return out
End

/// @brief Converts a test suite into TAP text
///
/// @param testSuiteIndex    The index of the current test suite inside the results wave
/// @param[in,out] caseCount The current number of printed test cases. This is used as all test
///                          cases need their own unique index and TAP has no concept of test
///                          suites. After this function call this parameter is updated to the new
///                          number of printed test cases.
static Function/S TAP_ToSuiteString(testSuiteIndex, caseCount)
	variable testSuiteIndex
	variable &caseCount

	variable childStart, childEnd, i
	string s = ""

	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	childStart = str2num(wvTestSuite[testSuiteIndex][%CHILD_START])
	childEnd = str2num(wvTestSuite[testSuiteIndex][%CHILD_END])

	for(i = childStart; i < childEnd; i += 1)
		s += TAP_ToTestCaseString(i, caseCount)
		caseCount += 1
	endfor

	return s
End

static Function TAP_Write()

	variable fnum, i, childStart, childEnd
	string filename, s
	variable caseCount = 1

	filename = "tap_" + GetBaseFilename() + ".log"
	PathInfo home
	filename = getUnusedFileName(S_path + filename)
	if(!strlen(filename))
		printf "Error: Unable to determine unused file name for TAP output in path %s !", S_path
		return NaN
	endif

	open/Z/P=home fnum as filename
	if(V_flag)
		PathInfo home
		printf "Error: Could not create TAP output file at %s\r", S_path + filename
		return NaN
	endif

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	childStart = str2num(wvTestRun[%CURRENT][%CHILD_START])
	childEnd = str2num(wvTestRun[%CURRENT][%CHILD_END])

	s = "TAP version 13" + TAP_LINEEND_STR

	if(!CmpStr(wvTestRun[%CURRENT][%NUM_TESTS], wvTestRun[%CURRENT][%NUM_SKIPPED]))
		s += "1..0 All test cases marked SKIP" + TAP_LINEEND_STR
	else
		s += "1.." + wvTestRun[%CURRENT][%NUM_TESTS] + TAP_LINEEND_STR
	endif

	for(i = childStart; i < childEnd; i += 1)
		s += TAP_ToSuiteString(i, caseCount)
	endfor

	if(shouldDoAbort())
		s += "Bail out!" + TAP_LINEEND_STR
	endif

	fBinWrite fnum, s
	close fnum
End
