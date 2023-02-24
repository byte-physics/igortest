#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=IUTF_Tap


static StrConstant TAP_LINEEND_STR     = "\n"

/// @brief returns 1 if all test cases are marked as SKIP and TAP is enabled, zero otherwise
///
/// @param testCaseList list of function names
/// @returns 1 if all test cases are marked as SKIP and TAP is enabled, zero otherwise
static Function TAP_AreAllFunctionsSkip()

	variable dimPos

	WAVE/T testRunData = IUTF_Basics#GetTestRunData()
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

	str = IUTF_FunctionTags#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
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

	str = IUTF_FunctionTags#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
	if(err == UTF_TAG_OK)
		return strsearch(str, "SKIP", 0, 2) == 0
	endif

	return 0
End

static Function/S TAP_GetValidDirective(str)
	string str

	str = ReplaceString("#", str, "_")
	if(!IUTF_Utils#IsEmpty(str))
		str = " # " + str
	endif

	return str
End

/// If a TAP Description starts with a digit (which is invalid), add a '_' at the front
static Function/S TAP_GetValidDescription(str)
	string str

	str = ReplaceString("#", str, "_")
	if(!IUTF_Utils#IsEmpty(str))
		str = " - " + str
	endif

	return str
end

/// Converts generic diagnostic text to a valid TAP diagnostic text
static Function/S TAP_ValidDiagnostic(diag)
	string diag

	if(IUTF_Utils#IsEmpty(diag))
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

	string name, out, ok, diagnostics, description, directive, caseCountStr, msg, prefix
	variable err

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	name = wvTestCase[testCaseIndex][%NAME]
	diagnostics = wvTestCase[testCaseIndex][%STDERR]
	directive = IUTF_FunctionTags#GetFunctionTagValue(name, UTF_FTAG_TAP_DIRECTIVE, err)
	if(err != UTF_TAG_OK)
		directive = ""
	endif
	description = IUTF_FunctionTags#GetFunctionTagValue(name, UTF_FTAG_TAP_DESCRIPTION, err)
	if(err != UTF_TAG_OK)
		description = ""
	endif

	directive = TAP_GetValidDirective(directive)
	description = TAP_GetValidDescription(description)

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
	sprintf prefix, "%s (%s)", ReplaceString("#", name, ":"), wvTestSuite[%CURRENT][%PROCEDURENAME]

	strswitch(wvTestCase[testCaseIndex][%STATUS])
		case IUTF_STATUS_SKIP:
			ok = "ok"
			diagnostics = ""
			break
		case IUTF_STATUS_RETRY:
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
			sprintf msg, "Error: Unknown test status %s for test case %s (%d)", wvTestCase[testCaseIndex][%STATUS], name, testCaseIndex
			IUTF_Reporting#IUTF_PrintStatusMessage(msg)
			return ""
	endswitch

	sprintf caseCountStr, "%d", caseCount
	out = ok + " " + caseCountStr + " - " + prefix + description + directive + TAP_LINEEND_STR
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

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
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
	string filename, s, msg
	variable caseCount = 1

	filename = IUTF_Utils_Paths#AtHome("tap_" + GetBaseFilename() + ".log", unusedName = 1)

	open/Z fnum as filename
	if(V_flag)
		sprintf msg, "Error: Could not create TAP output file at %s", filename
		IUTF_Reporting#IUTF_PrintStatusMessage(msg)
		return NaN
	endif

	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
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
