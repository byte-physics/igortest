#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Basics

// Licensed under 3-Clause BSD, see License.txt

///@cond HIDDEN_SYMBOL

static Constant FFNAME_OK        = 0x00
static Constant FFNAME_NOT_FOUND = 0x01
static Constant FFNAME_NO_MODULE = 0x02
static Constant TC_MATCH_OK      = 0x00
static Constant TC_REGEX_INVALID = 0x04
static Constant TC_NOT_FOUND     = 0x08
static Constant TC_LIST_EMPTY    = 0x10
static Constant GREPLIST_ERROR   = 0x20

static Constant IGOR_MAX_DIMENSIONS = 4

/// @name Constants for ExecuteHooks
/// @anchor HookTypes
/// @{
static Constant TEST_BEGIN_CONST       = 0x01
static Constant TEST_END_CONST         = 0x02
static Constant TEST_SUITE_BEGIN_CONST = 0x04
static Constant TEST_SUITE_END_CONST   = 0x08
static Constant TEST_CASE_BEGIN_CONST  = 0x10
static Constant TEST_CASE_END_CONST    = 0x20
/// @}

/// @name Constants for WaveTypes
/// @anchor WaveTypes
/// @{
Constant IUTF_WAVETYPE0_CMPL = 0x01
Constant IUTF_WAVETYPE0_FP32 = 0x02
Constant IUTF_WAVETYPE0_FP64 = 0x04
Constant IUTF_WAVETYPE0_INT8 = 0x08
Constant IUTF_WAVETYPE0_INT16 = 0x10
Constant IUTF_WAVETYPE0_INT32 = 0x20
Constant IUTF_WAVETYPE0_INT64 = 0x80
Constant IUTF_WAVETYPE0_USGN = 0x40

Constant IUTF_WAVETYPE1_NULL = 0x00
Constant IUTF_WAVETYPE1_NUM = 0x01
Constant IUTF_WAVETYPE1_TEXT = 0x02
Constant IUTF_WAVETYPE1_DFR = 0x03
Constant IUTF_WAVETYPE1_WREF = 0x04

Constant IUTF_WAVETYPE2_NULL = 0x00
Constant IUTF_WAVETYPE2_GLOBAL = 0x01
Constant IUTF_WAVETYPE2_FREE = 0x02
/// @}

/// @name Constants for Debugger mode
/// @anchor DebugConstants
/// @{
Constant IUTF_DEBUG_DISABLE = 0x00
Constant IUTF_DEBUG_ENABLE = 0x01
Constant IUTF_DEBUG_ON_ERROR = 0x02
Constant IUTF_DEBUG_NVAR_SVAR_WAVE = 0x04
Constant IUTF_DEBUG_FAILED_ASSERTION = 0x08
/// @}

static StrConstant FIXED_LOG_FILENAME = "IUTF_Test"

StrConstant IUTF_TRACE_REENTRY_KEYWORD = " *** REENTRY ***"

static Constant TEST_CASE_TYPE = 0x01
static Constant USER_HOOK_TYPE = 0x02

static StrConstant NO_SOURCE_PROCEDURE = "No source procedure"

static StrConstant BACKGROUNDMONTASK   = "UTFBackgroundMonitor"
static StrConstant BACKGROUNDMONFUNC   = "UTFBackgroundMonitor"
static StrConstant BACKGROUNDINFOSTR   = ":UNUSED_FOR_REENTRY:"

static StrConstant DGEN_VAR_TEMPLATE = "v"
static StrConstant DGEN_STR_TEMPLATE = "s"
static StrConstant DGEN_DFR_TEMPLATE = "dfr"
static StrConstant DGEN_WAVE_TEMPLATE = "w"
static StrConstant DGEN_CMPLX_TEMPLATE = "c"
static StrConstant DGEN_INT64_TEMPLATE = "i"
static Constant DGEN_NUM_VARS = 5

static Constant TC_MODE_NORMAL = 0
static Constant TC_MODE_MD = 1
static Constant TC_MODE_MMD = 2

static StrConstant TC_SUFFIX_SEP = ":"
#if IgorVersion() >= 7.00
// right arrow
StrConstant TC_ASSERTION_MLINE_INDICATOR = "\342\236\224"
// right filled triangle
StrConstant TC_ASSERTION_LIST_INDICATOR = "\342\226\266"
// info icon
StrConstant TC_ASSERTION_INFO_INDICATOR = "\xE2\x93\x98"
#else
StrConstant TC_ASSERTION_MLINE_INDICATOR = "->"
StrConstant TC_ASSERTION_LIST_INDICATOR = "-"
StrConstant TC_ASSERTION_INFO_INDICATOR = "(i)"
#endif

static Constant WAVE_TRACKING_INACTIVE_MODE = 0
static Constant WAVE_TRACKING_COUNT_MODE = 1
static Constant WAVE_TRACKING_TRACKER_MODE = 2

/// @brief Returns a global wave that stores data about this testrun
static Function/WAVE GetTestRunData()

	string name = "TestRunData"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/T/N=(0, 6) dfr:$name/WAVE=wv

	SetDimLabel UTF_COLUMN, 0, PROCWIN, wv
	SetDimLabel UTF_COLUMN, 1, TESTCASE, wv
	SetDimLabel UTF_COLUMN, 2, FULLFUNCNAME, wv
	SetDimLabel UTF_COLUMN, 3, DGENLIST, wv
	SetDimLabel UTF_COLUMN, 4, SKIP, wv
	SetDimLabel UTF_COLUMN, 5, EXPECTFAIL, wv

	return wv
End

/// @brief Returns a global wave that stores the multi-multi-data testcase (MMD TC) state waves
///        The getter function for the MMD TC state waves is GetMMDFuncState()
static Function/WAVE GetMMDataState()

	string name = "MMDataState"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=0 dfr:$name/WAVE=wv

	return wv
End

/// @brief Returns a global wave that stores the results of the DataGenerators of this testrun
static Function/WAVE GetDataGeneratorWaves()

	string name = "DataGeneratorWaves"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=0 dfr:$name/WAVE=wv

	return wv
End

/// @brief Returns a global wave that stores the Function Tag Waves of this testrun
static Function/WAVE GetFunctionTagWaves()

	string name = "FunctionTagWaves"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=0 dfr:$name/WAVE=wv

	return wv
End

/// @brief Helper function for try/catch with AbortOnRTE
///
/// Not clearing the RTE before calling `AbortOnRTE` will always trigger the RTE no
/// matter what you do in that line.
///
/// Usage:
/// @code
///
///    try
///       ClearRTError()
///       myFunc(); AbortOnRTE
///    catch
///      err = GetRTError(1)
///    endtry
///
/// @endcode
static Function ClearRTError()

	variable err = GetRTError(1)
End

/// @brief Convert the mode parameter for `EqualWaves` to a string
Function/S EqualWavesModeToString(mode)
	variable mode

	switch(mode)
		case WAVE_DATA:
			return "WAVE_DATA"
		case WAVE_DATA_TYPE:
			return "WAVE_DATA_TYPE"
		case WAVE_SCALING:
			return "WAVE_SCALING"
		case DATA_UNITS:
			return "DATA_UNITS"
		case DIMENSION_UNITS:
			return "DIMENSION_UNITS"
		case DIMENSION_LABELS:
			return "DIMENSION_LABELS"
		case WAVE_NOTE:
			return "WAVE_NOTE"
		case WAVE_LOCK_STATE:
			return "WAVE_LOCK_STATE"
		case DATA_FULL_SCALE:
			return "DATA_FULL_SCALE"
		case DIMENSION_SIZES:
			return "DIMENSION_SIZES"
		default:
			return "unknown mode"
	endswitch
End

/// @brief Check wether the function reference points to
/// the prototype function or to an assigned function
///
/// Due to Igor Pro limitations you need to pass the function
/// info from `FuncRefInfo` and not the function reference itself.
///
/// @return 0 if pointing to prototype function, 1 otherwise
Function UTF_FuncRefIsAssigned(funcInfo)
	string funcInfo

	return NumberByKey("ISPROTO", funcInfo) == 0
End

/// @brief Return a free text wave with the dimension labels of the
///        given dimension of the wave
static Function/WAVE GetDimLabels(wv, dim)
	WAVE/Z wv
	variable dim

	variable size

	if(!WaveExists(wv))
		return $""
	endif

	size = DimSize(wv, dim)

	if(size == 0)
		return $""
	endif

	Make/FREE/T/N=(size) labels = GetDimLabel(wv, dim, p)

	return labels
End

/// @brief Create a diagnostic message of the differing dimension labels
///
/// @param[in] wv1  Possible non-existing wave
/// @param[in] wv2  Possible non-existing wave
/// @param[out] str Diagnostic message indicating the deviations, empty string on success
///
/// @return 1 with no differences, 0 with differences
Function GenerateDimLabelDifference(wv1, wv2, msg)
	WAVE/Z wv1, wv2
	string &msg

	variable i, j, numEntries
	string str1, str2, tmpStr1, tmpStr2
	variable ret

	msg = ""

	for(i = 0; i < IGOR_MAX_DIMENSIONS; i += 1)

		WAVE/T/Z label1 = GetDimLabels(wv1, i)
		WAVE/T/Z label2 = GetDimLabels(wv2, i)

		if(!WaveExists(label1) && !WaveExists(label2))
			break
		endif

		if(!WaveExists(label1))
			sprintf msg, "Empty dimension vs non-empty dimension"
			return 0
		elseif(!WaveExists(label2))
			sprintf msg, "Non-empty dimension vs empty dimension"
			return 0
		else
			 // both exist but differ
			str1 = GetDimLabel(wv1, i, -1)
			str2 = GetDimLabel(wv2, i, -1)

			if(cmpstr(str1, str2))
				tmpStr1 = UTF_Utils#PrepareStringForOut(str1)
				tmpStr2 = UTF_Utils#PrepareStringForOut(str2)
				sprintf msg, "Dimension labels for the entire dimension %d differ: %s vs %s", i, tmpStr1, tmpStr2
				return 0
			endif

			if(EqualWaves(label1, label2, WAVE_DATA))
				continue
			endif

			if(DimSize(label1, i) != DimSize(label2, i))
				sprintf msg, "The sizes for dimension %d don't match: %d vs %d", i, DimSize(label1, i), DimSize(label2, i)
				return 0
			endif

			numEntries = DimSize(label1, i)
			for(j = 0; j < numEntries; j += 1)
				if(!cmpstr(label1[j], label2[j]))
					continue
				endif
				str1 = label1[j]
				str2 = label2[j]
				tmpStr1 = UTF_Utils#PrepareStringForOut(str1)
				tmpStr2 = UTF_Utils#PrepareStringForOut(str2)
				sprintf msg, "Differing dimension label in dimension %d at index %d: %s vs %s", i, j, tmpStr1, tmpStr2
				return 0
			endfor
		endif
	endfor

	return 1
End

Function/S GetVersion()
	string version
	sprintf version, "%.2f", PKG_VERSION

	return version
End

/// Returns the package folder
Function/DF GetPackageFolder()
	if(!DataFolderExists(PKG_FOLDER))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:UnitTesting
	endif

	DFREF dfr = $PKG_FOLDER
	return dfr
End

/// Returns 0 if the file exists, !0 otherwise
static Function FileNotExists(fname)
	string fname

	GetFileFolderInfo/Q/Z fname
	return V_Flag
End

/// returns a non existing file name an empty string
Function/S getUnusedFileName(fname)
	string fname

	variable count
	string fn, fnext, fnn

	if (FileNotExists(fname))
		return fname
	endif
	fname = ParseFilePath(5, fname, "\\", 0, 0)
	fnext = "." + ParseFilePath(4, fname, "\\", 0, 0)
	fnn = RemoveEnding(fname, fnext)

	count = -1
	do
		count += 1
		sprintf fn, "%s_%03d%s", fnn, count, fnext
	while(!FileNotExists(fn) && count < 999)
	if(!FileNotExists(fn))
		return ""
	endif
	return fn
End

/// Creates a global with the allowed variable names for mmd data tests and returns the value
static Function/S GetMMDAllVariablesList()

	variable i, j, numTemplates
	string varName, varList

	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr mmdAllVariablesList

	if(SVAR_EXISTS(mmdAllVariablesList))
		return mmdAllVariablesList
	endif

	varList = ""

	WAVE/T templates = GetMMDVarTemplates()
	numTemplates = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTemplates; i += 1)
		for(j = 0; j < DGEN_NUM_VARS; j += 1)
			varName = templates[i] + num2istr(j)
			varList = AddListItem(varName, varList)
		endfor
	endfor

	string/G dfr:mmdAllVariablesList = varList

	return varList
End

/// Returns 1 if debug output is enabled and zero otherwise
Function EnabledDebug()
	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr verbose

	if(NVAR_EXISTS(verbose) && verbose == 1)
		return 1
	endif

	return 0
End

/// Output debug string in assertions
/// @param str            debug string
/// @param booleanValue   assertion state
static Function DebugOutput(str, booleanValue)
	string &str
	variable booleanValue

	str = str + ": is " + SelectString(booleanValue, "false", "true") + "."
	if(EnabledDebug())
		UTF_Reporting#ReportError(str, incrErrorCounter = 0)
	endif
End

/// Set the status and output debug information
/// @param str            debug string
/// @param booleanValue   assertion state
Function SetTestStatusAndDebug(str, booleanValue)
	string str
	variable booleanValue

	DebugOutput(str, booleanValue)
	SetTestStatus(str)
End

/// Evaluate the result of an assertion that was used in a testcase. For evaluating internal errors use
/// ReportError* functions.
/// @param result          Set to 0 to signal an error. Any value different to 0 will be considered as success.
/// @param str             The message to report.
/// @param flags           A combination flags that are used by ReportResults() to determine what to do if result
///                        is in an error state.
/// @param cleanupInfo [optional, default enabled] If set different to zero it will cleanup
///               any assertion info message at the end of this function.
///               Cleanup is enforced if flags contains the ABORT_FUNCTION flag.
Function EvaluateResults(result, str, flags, [cleanupInfo])
	variable result, flags
	string str
	variable cleanupInfo

	cleanupInfo = ParamIsDefault(cleanupInfo) ? 1 : !!cleanupInfo

	DebugFailedAssertion(result)
	UTF_Reporting#ReportResults(result, str, flags, cleanupInfo = cleanupInfo)
End

/// Opens the Debugger if the assertion failed and the debugMode option is set
static Function DebugFailedAssertion(result)
	variable result

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_assertion

	if(igor_debug_assertion && !result)
		Debugger
	endif
End

/// Returns the current state of the Igor Debugger as ORed bitmask of IUTF_DEBUG_* constants
static Function GetCurrentDebuggerState()

	DebuggerOptions
	return (!!V_enable) * IUTF_DEBUG_ENABLE | (!!V_debugOnError) * IUTF_DEBUG_ON_ERROR | (!!V_NVAR_SVAR_WAVE_Checking) * IUTF_DEBUG_NVAR_SVAR_WAVE
End

/// Set the Igor Debugger, returns the previous state
/// @param state		3 bits to set
///						0x01: debugger enable
///						0x02: debug on error
///						0x04: debug on NVAR SVAR WAVE reference error
static Function SetIgorDebugger(state)
	variable state

	variable prevState, enable, debugOnError, nvarSvarWave

	prevState = GetCurrentDebuggerState()

	enable = !!(state & IUTF_DEBUG_ENABLE)
	debugOnError = !!(state & IUTF_DEBUG_ON_ERROR)
	nvarSvarWave = !!(state & IUTF_DEBUG_NVAR_SVAR_WAVE)

	DebuggerOptions enable=enable, debugOnError=debugOnError, NVAR_SVAR_WAVE_Checking=nvarSvarWave

	return prevState
End

/// Enable the Igor Pro Debugger in a certain state, return its previous state
static Function EnableIgorDebugger(debugMode)
	variable debugMode

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_assertion

	igor_debug_assertion = !!(debugMode & IUTF_DEBUG_FAILED_ASSERTION)

	return SetIgorDebugger(debugMode | IUTF_DEBUG_ENABLE)
End

/// Disable the Igor Pro Debugger, return its previous state
static Function DisableIgorDebugger()

	return SetIgorDebugger(IUTF_DEBUG_DISABLE)
End

/// Restore the Igor Pro Debugger to its prior state
static Function RestoreIgorDebugger(debuggerState)
	variable debuggerState

	SetIgorDebugger(debuggerState)
End

/// Create the variables igor_debug_state and igor_debug_assertion
/// in PKG_FOLDER and initialize it to zero
static Function InitIgorDebugVariables()
	DFREF dfr = GetPackageFolder()
	Variable/G dfr:igor_debug_state = 0
	Variable/G dfr:igor_debug_assertion = 0
End

/// Creates the variable status in PKG_FOLDER
static Function InitTestStatus()
	DFREF dfr = GetPackageFolder()
	string/G dfr:status = "test status initialized"
End

/// Set the status variable for debug output
/// and failed assertions. Creates the variable
/// if not present.
/// @param setValue   test status as string with trailing \r
static Function SetTestStatus(setValue)
	string setValue

	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr status

	if(!SVAR_EXISTS(status))
		InitTestStatus()
		SVAR/SDFR=dfr status
	endif

	status = setValue
End

/// Creates the variable global_error_count in PKG_FOLDER
/// and initializes it to zero
static Function initGlobalError()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:global_error_count = 0
End

/// Creates the variable run_count in PKG_FOLDER
/// and initializes it to zero
static Function initRunCount()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:run_count = 0
End

/// Increments the run_count in PKG_FOLDER and creates it if necessary
static Function incrRunCount()
	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr run_count

	if(!NVAR_Exists(run_count))
		initRunCount()
		NVAR/SDFR=dfr run_count
	endif

	run_count +=1
End

/// Creates the variable error_count in PKG_FOLDER
/// and initializes it to zero
static Function initError()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:error_count = 0
End

/// Increments the error_count in PKG_FOLDER and creates it if necessary
Function incrError()
	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr error_count

	if(!NVAR_Exists(error_count))
		initError()
		NVAR/SDFR=dfr error_count
	endif

	AddMessageToBuffer()

	error_count +=1
End

/// Creates the variable assert_count in PKG_FOLDER
/// and initializes it to zero
static Function initAssertCount()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:assert_count = 0
End

/// Creates the failure message buffer wave
static Function initMessageBuffer()
	DFREF dfr = GetPackageFolder()
	Make/O/T/N=(0, 2) dfr:messageBuffer
	WAVE/T messageBuffer = dfr:messageBuffer
	SetDimLabel UTF_COLUMN, 0, MESSAGE, messageBuffer
	SetDimLabel UTF_COLUMN, 1, TYPE, messageBuffer
End

/// Adds current Message to buffer
static Function AddMessageToBuffer()

	variable size

	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	WAVE/T/SDFR=dfr/Z messageBuffer

	if(!WaveExists(messageBuffer))
		initMessageBuffer()
		WAVE/T/SDFR=dfr messageBuffer
	endif

	size = DimSize(messageBuffer, UTF_ROW)
	Redimension/N=(size + 1, -1) messageBuffer
	messageBuffer[size][%MESSAGE] = message
	messageBuffer[size][%TYPE] = type
End

/// Increments the assert_count in PKG_FOLDER and creates it if necessary
Function incrAssert()
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr/Z assert_count

	if(!NVAR_Exists(assert_count))
		initAssertCount()
		NVAR/SDFR=dfr assert_count
		assert_count = 0
	endif

	assert_count +=1

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestCase[%CURRENT][%NUM_ASSERT]) + 1)
End

/// Returns 1 if the abortFlag is set and zero otherwise
Function shouldDoAbort()
	NVAR/Z/SDFR=GetPackageFolder() abortFlag
	if(NVAR_Exists(abortFlag) && abortFlag == 1)
		return 1
	else
		return 0
	endif
End

/// Sets the abort flag
static Function setAbortFlag()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 1
End

static Function CleanupInfoMsg()
	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr AssertionInfo

	if(SVAR_Exists(AssertionInfo))
		AssertionInfo = ""
	endif
End

/// Resets the abort flag
static Function InitAbortFlag()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 0
End

/// @brief returns 1 if the current testcase is marked as expected failure, zero otherwise
///
/// @returns 1 if the current testcase is marked as expected failure, zero otherwise
Function IsExpectedFailure()
	NVAR/Z/SDFR=GetPackageFolder() expected_failure_flag

	if(NVAR_Exists(expected_failure_flag) && expected_failure_flag == 1)
		return 1
	else
		return 0
	endif
End

/// Sets the expected_failure_flag global
static Function SetExpectedFailure(val)
	variable val

	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr expected_failure_flag

	if(!NVAR_Exists(expected_failure_flag))
		Variable/G dfr:expected_failure_flag
		NVAR/SDFR=dfr expected_failure_flag
	endif

	expected_failure_flag = val
End

/// Return true if running in `ProcGlobal`, false otherwise
static Function IsProcGlobal()

	return !cmpstr("ProcGlobal", GetIndependentModuleName())
End

/// @brief Saves the current assertion counter in global saveAssertCount
static Function SaveAssertionCounter()

	DFREF dfr = GetPackageFolder()

	NVAR/SDFR=dfr/Z assert_count
	if(!NVAR_Exists(assert_count))
		initAssertCount()
		NVAR/SDFR=dfr assert_count
	endif

	NVAR/SDFR=dfr/Z saveAssertCount
	if(!NVAR_Exists(saveAssertCount))
		variable/G dfr:saveAssertCount = assert_count
	else
		saveAssertCount = assert_count
	endif
End

/// @brief Retrieves the saved assertion counter from global saveAssertCount
static Function GetSavedAssertionCounter()

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr/Z saveAssertCount

	if(!NVAR_Exists(saveAssertCount))
		return NaN
	endif

	return saveAssertCount
End

/// Prints an informative message about the test's success or failure
// 0 failed, 1 succeeded
static Function/S getInfo(result, expectedFailure)
	variable result, expectedFailure

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr assert_count
	string caller, func, procedure, callStack, contents, moduleName
	string text, cleanText, line, callerTestCase, tmpStr, partialStack
	variable numCallers, i, assertLine
	variable callerIndex = NaN
	variable testCaseIndex

	callStack = GetRTStackInfo(3)
	numCallers = ItemsInList(callStack)
	moduleName = ""

	// traverse the callstack from bottom up,
	// the first function not in one of the unit testing procedures is
	// the one we want to report. Except if helper functions are involved.
	for(i = numCallers - 1; i >= 0; i -= 1)
		caller    = StringFromList(i, callStack)
		procedure = StringFromList(1, caller, ",")

		if(StringMatch(procedure, "unit-testing*"))
			if(UTF_Utils#IsNaN(callerIndex))
				continue
			endif
			testCaseIndex = i + 1
			break
		else
			if(UTF_Utils#IsNaN(callerIndex))
				callerIndex = i
			endif
		endif
	endfor

	if(UTF_Utils#IsNaN(callerIndex))
		if(assert_count - GetSavedAssertionCounter() == 0)
			// We have no external caller, assuming the internal call was the check in AfterTestCase()
			return "The test case did not make any assertions!"
		else
			// We have no external caller, but a test case assertion - should never happen
			return "Assertion failed in unknown location"
		endif
	endif

	callerTestCase = StringFromList(testCaseIndex, callStack)

	caller     = StringFromList(callerIndex, callStack)
	func       = StringFromList(0, caller, ",")
	procedure  = StringFromList(1, caller, ",")
	line       = StringFromList(2, caller, ",")
	assertLine = str2num(StringFromList(2, caller, ","))

	if(callerIndex != testcaseIndex)
		func = StringFromList(0, callerTestCase, ",") + TC_ASSERTION_MLINE_INDICATOR + func
		line = StringFromList(2, callerTestCase, ",") + TC_ASSERTION_MLINE_INDICATOR + line
	endif

	if(!expectedFailure)
		partialStack = ""
		for(i = testcaseIndex; i <= callerIndex; i += 1)
			partialStack = AddListItem(StringFromList(i, callStack), partialStack, ";", Inf)
		endfor
		WAVE/T wvAssertion = UTF_Reporting#GetTestAssertionWave()
		wvAssertion[%CURRENT][%STACKTRACE] = partialStack
	endif

	if(!IsProcGlobal())
		moduleName = " [" + GetIndependentModuleName() + "]"
	endif

	contents = ProcedureText("", -1, procedure)
	text = StringFromList(assertLine, contents, "\r")

	cleanText = trimstring(text)

	tmpStr = UTF_Utils#PrepareStringForOut(cleanText)
	sprintf text, "Assertion \"%s\" %s in %s%s (%s, line %s)", tmpStr, SelectString(result, "failed", "succeeded"), func, moduleName, procedure, line
	return text
End

/// Groups all hooks which are executed at test case/suite begin/end
static Structure TestHooks
	string testBegin
	string testEnd
	string testSuiteBegin
	string testSuiteEnd
	string testCaseBegin
	string testCaseEnd
EndStructure

/// Sets the hooks to the builtin defaults
static Function setDefaultHooks(hooks)
	Struct TestHooks &hooks

	hooks.testBegin      = "TEST_BEGIN"
	hooks.testEnd        = "TEST_END"
	hooks.testSuiteBegin = "TEST_SUITE_BEGIN"
	hooks.testSuiteEnd   = "TEST_SUITE_END"
	hooks.testCaseBegin  = "TEST_CASE_BEGIN"
	hooks.testCaseEnd    = "TEST_CASE_END"
End

/// Check that all hook functions, default and override,
/// have the expected signature and abort if not.
static Function abortWithInvalidHooks(hooks)
	Struct TestHooks& hooks

	variable i, numEntries
	string msg

	Make/T/N=6/FREE wvInfo

	wvInfo[0] = FunctionInfo(hooks.testBegin)
	wvInfo[1] = FunctionInfo(hooks.testEnd)
	wvInfo[2] = FunctionInfo(hooks.testSuiteBegin)
	wvInfo[3] = FunctionInfo(hooks.testSuiteEnd)
	wvInfo[4] = FunctionInfo(hooks.testCaseBegin)
	wvInfo[5] = FunctionInfo(hooks.testCaseEnd)

	numEntries = DimSize(wvInfo, 0)
	for(i = 0; i < numEntries; i += 1)
		if(NumberByKey("N_PARAMS", wvInfo[i]) != 1 || NumberByKey("N_OPT_PARAMS", wvInfo[i]) != 0 || NumberByKey("PARAM_0_TYPE", wvInfo[i]) != 0x2000)
			sprintf msg, "The override test hook \"%s\" must accept exactly one string parameter.", StringByKey("NAME", wvInfo[i])
			UTF_Reporting#ReportErrorAndAbort(msg)
		endif

		if(NumberByKey("RETURNTYPE", wvInfo[i]) != 0x4)
			sprintf msg, "The override test hook \"%s\" must return a numeric variable.", StringByKey("NAME", wvInfo[i])
			UTF_Reporting#ReportErrorAndAbort(msg)
		endif
	endfor
End

/// Looks for global override hooks in the same indpendent module as the framework itself
/// is running in.
static Function getGlobalHooks(hooks)
	Struct TestHooks& hooks

	string userHooks = FunctionList("*_OVERRIDE", ";", "KIND:2,WIN:[" + GetIndependentModuleName() + "]")

	variable i
	for(i = 0; i < ItemsInList(userHooks); i += 1)
		string userHook = StringFromList(i, userHooks)
		strswitch(userHook)
			case "TEST_BEGIN_OVERRIDE":
				hooks.testBegin = userHook
				break
			case "TEST_END_OVERRIDE":
				hooks.testEnd = userHook
				break
			case "TEST_SUITE_BEGIN_OVERRIDE":
				hooks.testSuiteBegin = userHook
				break
			case "TEST_SUITE_END_OVERRIDE":
				hooks.testSuiteEnd = userHook
				break
			case "TEST_CASE_BEGIN_OVERRIDE":
				hooks.testCaseBegin = userHook
				break
			case "TEST_CASE_END_OVERRIDE":
				hooks.testCaseEnd = userHook
				break
			default:
				// ignore unknown functions
				break
		endswitch
	endfor

	abortWithInvalidHooks(hooks)
End

/// Looks for local override hooks in a specific procedure file
static Function getLocalHooks(hooks, procName)
	string procName
	Struct TestHooks& hooks

	variable err
	string userHooks = FunctionList("*_OVERRIDE", ";", "KIND:18,WIN:" + procName)

	variable i
	for(i = 0; i < ItemsInList(userHooks); i += 1)
		string userHook = StringFromList(i, userHooks)

		string fullFunctionName = getFullFunctionName(err, userHook, procName)
		strswitch(userHook)
			case "TEST_SUITE_BEGIN_OVERRIDE":
				hooks.testSuiteBegin = fullFunctionName
				break
			case "TEST_SUITE_END_OVERRIDE":
				hooks.testSuiteEnd = fullFunctionName
				break
			case "TEST_CASE_BEGIN_OVERRIDE":
				hooks.testCaseBegin = fullFunctionName
				break
			case "TEST_CASE_END_OVERRIDE":
				hooks.testCaseEnd = fullFunctionName
				break
			default:
				// ignore unknown functions
				break
		endswitch
	endfor

	abortWithInvalidHooks(hooks)
End

/// Returns the functionName of the specified DataGenerator. The priority is first local then ProcGlobal.
/// If funcName is specified with Module then in all procedures is looked. No ProcGlobal function is returned in that case.
static Function/S GetDataGeneratorFunctionName(err, funcName, procName)
	variable &err
	string funcName, procName

	string infoStr, modName, pName, errMsg

	err = 0
	if(ItemsInList(funcName, "#") > 2)
		sprintf errMsg, "Data Generator Function %s is specified with Independent Module, this is not supported.", funcName
		err = 1
		return errMsg
	endif
	// if funcName is specified without Module then FunctionInfo looks in procedure procName only.
	// if funcName is specified with Module then FunctionInfo looks in all procedures of current compile unit, independent of procName
	infoStr = FunctionInfo(funcName, procName)
	if(!UTF_Utils#IsEmpty(infoStr))
		modName = StringByKey("MODULE", infoStr)
		pName = StringByKey("NAME", infoStr)
		if(!CmpStr(StringByKey("SPECIAL", infoStr), "static") && UTF_Utils#IsEmpty(modName))
			sprintf errMsg, "Data Generator Function %s is declared static but the procedure file %s is missing a \"#pragma ModuleName=myName\" declaration.", pName, procName
			err = 1
			return errMsg
		endif
		if(UTF_Utils#IsEmpty(modName))
			return pName
		endif
		return modName + "#" + pName
	else
		// look in ProcGlobal of current compile unit
		infoStr = FunctionInfo(funcName)
		if(!UTF_Utils#IsEmpty(infoStr))
			pName = StringByKey("NAME", infoStr)
			return pName
		endif
	endif
	infoStr = GetIndependentModuleName()
	if(!CmpStr(infoStr, "ProcGlobal"))
		sprintf errMsg, "Data Generator Function %s not found in %s or ProcGlobal.", funcName, procName
	else
		sprintf errMsg, "In Independent Module %s, data Generator Function %s not found in %s or globally in IM.", infoStr, funcName, procName
	endif
	err = 1

	return errMsg
End

/// Returns the full name of a function including its module
/// @param &err returns 0 for no error, 1 if function not found, 2 is static function in proc without ModuleName
static Function/S getFullFunctionName(err, funcName, procName)
	variable &err
	string funcName, procName

	err = FFNAME_OK
	string errMsg, module, infoStr, funcNameReturn

	infoStr = FunctionInfo(funcName, procName)

	if(UTF_Utils#IsEmpty(infoStr))
		sprintf errMsg, "Function %s in procedure file %s is unknown", funcName, procName
		err = FFNAME_NOT_FOUND
		return errMsg
	endif

	funcNameReturn = StringByKey("NAME", infoStr)

	if(!cmpstr(StringByKey("SPECIAL", infoStr), "static"))
		module = StringByKey("MODULE", infoStr)

		// we can only use static functions if they live in a module
		if(UTF_Utils#IsEmpty(module))
			sprintf errMsg, "The procedure file %s is missing a \"#pragma ModuleName=myName\" declaration.", procName
			err = FFNAME_NO_MODULE
			return errMsg
		endif

		funcNameReturn = module + "#" + funcNameReturn
	endif

	// even if we are running in an independent module we don't need its name prepended as we
	// 1.) run in the same IM anyway
	// 2.) FuncRef does not accept that

	return funcNameReturn
End

/// Prototype for test cases
Function TEST_CASE_PROTO()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototypes for multi data test cases
Function TEST_CASE_PROTO_MD_VAR([var])
	variable var

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_STR([str])
	string str

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WV([wv])
	WAVE wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WVTEXT([wv])
	WAVE/T wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WVDFREF([wv])
	WAVE/DF wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WVWAVEREF([wv])
	WAVE/WAVE wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_DFR([dfr])
	DFREF dfr

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_CMPL([cmpl])
	variable/C cmpl

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

#if (IgorVersion() >= 7.0)

Function TEST_CASE_PROTO_MD_INT([int])
	int64 int

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

#else

Function TEST_CASE_PROTO_MD_INT([int])
	variable int

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

#endif

/// Prototype for multi data test cases data generator
Function/WAVE TEST_CASE_PROTO_DGEN()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototype for run functions in autorun mode
Function AUTORUN_MODE_PROTO()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototype for hook functions
Function USER_HOOK_PROTO(str)
	string str

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototype for multi multi data test case functions
Function TEST_CASE_PROTO_MD([md])
	STRUCT IUTF_mData &md

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_Reporting#ReportErrorAndAbort(msg)
End

///@endcond // HIDDEN_SYMBOL

///@addtogroup Helpers
///@{

/// Turns debug output on
Function EnableDebugOutput()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:verbose = 1
End

/// Turns debug output off
Function DisableDebugOutput()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:verbose = 0
End

///@}

///@cond HIDDEN_SYMBOL

/// Evaluates an RTE and puts a composite error message into message/type
static Function EvaluateRTE(err, errmessage, abortCode, funcName, funcType, procWin)
	variable err
	string errmessage
	variable abortCode, funcType
	string funcName
	string procWin

	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	SVAR/SDFR=dfr/Z AssertionInfo
	string str, funcTypeString

	if(!err && !abortCode)
		return NaN
	endif

	switch(funcType)
		case TEST_CASE_TYPE:
			funcTypeString = "test case"
			break
		case USER_HOOK_TYPE:
			funcTypeString = "user hook"
			break
		default:
			UTF_Reporting#ReportErrorAndAbort("Unknown func type in EvaluateRTE")
			break
	endswitch

	type = ""
	message = ""
	if(err)
		sprintf str, "Uncaught runtime error %d:\"%s\" in %s \"%s\" (%s)", err, errmessage, funcTypeString, funcName, procWin
		UTF_Reporting#AddFailedSummaryInfo(str)
		UTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
		message = str
		type = "RUNTIME ERROR"
	endif
	if(abortCode != -4)
		if(!strlen(type))
			type = "ABORT"
		endif
		str = ""
		switch(abortCode)
			case -1:
				sprintf str, "User aborted Test Run manually in %s \"%s\" (%s)", funcTypeString, funcName, procWin
				UTF_Reporting#AddFailedSummaryInfo(str)
				UTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
				break
			case -2:
				sprintf str, "Stack Overflow in %s \"%s\" (%s)", funcTypeString, funcName, procWin
				UTF_Reporting#AddFailedSummaryInfo(str)
				UTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
				break
			case -3:
				sprintf str, "Encountered \"Abort\" in %s \"%s\" (%s)", funcTypeString, funcName, procWin
				UTF_Reporting#AddFailedSummaryInfo(str)
				UTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
				break
			default:
				break
		endswitch
		message += str
		if(abortCode > 0)
			sprintf str, "Encountered \"AbortOnValue\" Code %d in %s \"%s\" (%s)", abortCode, funcTypeString, funcName, procWin
			UTF_Reporting#AddFailedSummaryInfo(str)
			UTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
			message += str
		endif
	endif

	UTF_Reporting#ReportError(message)
	if(SVAR_Exists(AssertionInfo) && strlen(AssertionInfo))
		UTF_Reporting#ReportError(AssertionInfo, incrErrorCounter = 0)
	endif

	CheckAbortCondition(abortCode)
End

/// Check if the User manually pressed Abort and set Abort flag
///
/// @param abortCode V_AbortCode output from try...catch
static Function CheckAbortCondition(abortCode)
	variable abortCode

	if(abortCode == -1)
		setAbortFlag()
	endif
End

/// Internal Setup for Testrun
/// @param name   name of the test suite group
static Function TestBegin(name, debugMode)
	string name
	variable debugMode

	string msg
	WAVE/T wvFailed = UTF_Reporting#GetFailedProcWave()
	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%STARTTIME] = UTF_Reporting#GetTimeString()

	initGlobalError()
	initRunCount()
	InitAbortFlag()
	initTestStatus()

	InitIgorDebugVariables()
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_state
	if(!debugMode)
		igor_debug_state = DisableIgorDebugger()
	endif
	if(debugMode & (IUTF_DEBUG_ENABLE | IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE | IUTF_DEBUG_FAILED_ASSERTION))
		igor_debug_state = EnableIgorDebugger(debugMode)
	endif

	string/G dfr:message = ""
	string/G dfr:type = "0"
	string/G dfr:systemErr = ""
	UTF_Utils_Vector#SetLength(wvFailed, 0)

	ClearBaseFilename()

	sprintf msg, "Start of test \"%s\"", name
	UTF_Reporting#UTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Testrun
/// @param name   name of the test suite group
static Function TestEnd(name, debugMode)
	string name
	variable debugMode

	string msg
	variable i, index
	WAVE/T wvFailed = UTF_Reporting#GetFailedProcWave()

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr global_error_count

	if(global_error_count == 0)
		sprintf msg, "Test finished with no errors"
	else
		sprintf msg, "Test finished with %d errors", global_error_count
	endif

	UTF_Reporting#UTF_PrintStatusMessage(msg)

	index = UTF_Utils_Vector#GetLength(wvFailed)
	for(i = 0; i < index; i += 1)
		msg = "  " + TC_ASSERTION_LIST_INDICATOR + " " + wvFailed[i]
		UTF_Reporting#UTF_PrintStatusMessage(msg)
	endfor

	sprintf msg, "End of test \"%s\"", name
	UTF_Reporting#UTF_PrintStatusMessage(msg)

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%ENDTIME] = UTF_Reporting#GetTimeString()

	NVAR/SDFR=dfr igor_debug_state
	RestoreIgorDebugger(igor_debug_state)
End

/// Internal Setup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteBegin(testSuite)
	string testSuite

	string msg
	variable id

	WAVE/T wvSuite = UTF_Reporting#GetTestSuiteWave()
	id = UTF_Utils_Vector#AddRow(wvSuite)

	wvSuite[id][%PROCEDURENAME] = testSuite
	wvSuite[id][%STARTTIME] = UTF_Reporting#GetTimeString()
	wvSuite[id][%NUM_ERROR] = "0"
	wvSuite[id][%NUM_SKIPPED] = "0"
	wvSuite[id][%NUM_TESTS] = "0"
	wvSuite[id][%NUM_ASSERT] = "0"
	wvSuite[id][%NUM_ASSERT_ERROR] = "0"

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	UTF_Reporting#UpdateChildRange(wvSuite, wvTestCase, init = 1)

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	UTF_Reporting#UpdateChildRange(wvTestRun, wvSuite)

	initError()
	incrRunCount()

	sprintf msg, "Entering test suite \"%s\"", testSuite
	UTF_Reporting#UTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteEnd(testSuite)
	string testSuite

	string msg

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr error_count

	if(error_count == 0)
		sprintf msg, "Finished with no errors"
	else
		sprintf msg, "Failed with %d errors", error_count
	endif

	UTF_Reporting#UTF_PrintStatusMessage(msg)

	NVAR/SDFR=dfr global_error_count
	global_error_count += error_count

	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	wvTestSuite[%CURRENT][%ENDTIME] = UTF_Reporting#GetTimeString()

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ASSERT]) + str2num(wvTestSuite[%CURRENT][%NUM_ASSERT]))
	wvTestRun[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ASSERT_ERROR]) + str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]))
	wvTestRun[%CURRENT][%NUM_ERROR] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ERROR]) + str2num(wvTestSuite[%CURRENT][%NUM_ERROR]))
	wvTestRun[%CURRENT][%NUM_SKIPPED] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_SKIPPED]) + str2num(wvTestSuite[%CURRENT][%NUM_SKIPPED]))

	sprintf msg, "Leaving test suite \"%s\"", testSuite
	UTF_Reporting#UTF_PrintStatusMessage(msg)
End

/// Internal Setup for Test Case
/// @param testCase name of the test case
static Function TestCaseBegin(testCase, skip)
	string testCase
	variable skip

	string msg
	variable testId

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	testId = UTF_Utils_Vector#AddRow(wvTestCase)

	wvTestCase[testId][%NAME] = testCase
	wvTestCase[testId][%STARTTIME] = UTF_Reporting#GetTimeString()
	wvTestCase[testId][%NUM_ASSERT] = "0"
	wvTestCase[testId][%NUM_ASSERT_ERROR] = "0"

	WAVE/T wvAssertion = UTF_Reporting#GetTestAssertionWave()
	UTF_Reporting#UpdateChildRange(wvTestCase, wvAssertion, init = 1)

	WAVE/T wvSuite = UTF_Reporting#GetTestSuiteWave()
	UTF_Reporting#UpdateChildRange(wvSuite, wvTestCase)
	wvSuite[%CURRENT][%NUM_TESTS] = num2istr(str2num(wvSuite[%CURRENT][%NUM_TESTS]) + 1)

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%NUM_TESTS] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_TESTS]) + 1)

	if(skip)
		wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_SKIP
		wvTestCase[%CURRENT][%ENDTIME] = "0"
		wvTestCase[%CURRENT][%STARTTIME] = "0"
		return NaN
	else
		Notebook HistoryCarbonCopy, getData = 1
		wvTestCase[%CURRENT][%STDOUT] = S_Value
	endif

	initAssertCount()
	initMessageBuffer()

	// create a new unique folder as working folder
	DFREF dfr = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	SetDataFolder root:
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/O/S $workFolder

	string/G dfr:systemErr = ""

	sprintf msg, "Entering test case \"%s\"", testCase
	UTF_Reporting#UTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Test Case
/// @param testCase name of the test case
static Function TestCaseEnd(testCase)
	string testCase

	string msg

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%ENDTIME] = UTF_Reporting#GetTimeString()

	sprintf msg, "Leaving test case \"%s\"", testCase
	UTF_Reporting#UTF_PrintStatusMessage(msg)

	Notebook HistoryCarbonCopy, getData = 1
	wvTestCase[%CURRENT][%STDOUT] = S_Value[strlen(wvTestCase[%CURRENT][%STDOUT]), Inf]

	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	wvTestSuite[%CURRENT][%STDOUT] += wvTestCase[%CURRENT][%STDOUT]
	wvTestSuite[%CURRENT][%STDERR] += wvTestCase[%CURRENT][%STDERR]
	wvTestSuite[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT]) + str2num(wvTestCase[%CURRENT][%NUM_ASSERT]))
	wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]) + str2num(wvTestCase[%CURRENT][%NUM_ASSERT_ERROR]))
End

/// Checks functions signature of each multi data test case candidate
/// returns 1 if ok, 0 otherwise
/// when 1 is returned the wave type variable contain the format
static Function GetFunctionSignatureTCMD(testCase, wType0, wType1, wrefSubType)
	string testCase
	variable &wType0
	variable &wType1
	variable &wrefSubType

	wType0 = NaN
	wType1 = NaN
	wrefSubType = NaN
	// Check function signature
	FUNCREF TEST_CASE_PROTO_MD_VAR fTCMDVAR = $testCase
	FUNCREF TEST_CASE_PROTO_MD_STR fTCMDSTR = $testCase
	FUNCREF TEST_CASE_PROTO_MD_DFR fTCMDDFR = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WV fTCMDWV = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WVTEXT fTCMDWVTEXT = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WVDFREF fTCMDWVDFREF = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WVWAVEREF fTCMDWVWAVEREF = $testCase
	FUNCREF TEST_CASE_PROTO_MD_CMPL fTCMDCMPL = $testCase
	FUNCREF TEST_CASE_PROTO_MD_INT fTCMDINT = $testCase
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDVAR)))
		wType0 = 0xff %^ IUTF_WAVETYPE0_CMPL %^ IUTF_WAVETYPE0_INT64
		wType1 = IUTF_WAVETYPE1_NUM
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDSTR)))
		wType1 = IUTF_WAVETYPE1_TEXT
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDDFR)))
		wType1 = IUTF_WAVETYPE1_DFR
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWV)))
		wType1 = IUTF_WAVETYPE1_WREF
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWVTEXT)))
		wType1 = IUTF_WAVETYPE1_WREF
		wrefSubType = IUTF_WAVETYPE1_TEXT
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWVDFREF)))
		wType1 = IUTF_WAVETYPE1_WREF
		wrefSubType = IUTF_WAVETYPE1_DFR
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWVWAVEREF)))
		wType1 = IUTF_WAVETYPE1_WREF
		wrefSubType = IUTF_WAVETYPE1_WREF
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDCMPL)))
		wType0 = IUTF_WAVETYPE0_CMPL
		wType1 = IUTF_WAVETYPE1_NUM
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDINT)))
		wType0 = IUTF_WAVETYPE0_INT64
		wType1 = IUTF_WAVETYPE1_NUM
	else
		return 0
	endif

	return 1
End

static Function/S GetDataGenFullFunctionName(procWin, fullTestCase)
	string fullTestCase
	string procWin

	variable err
	string dgen, msg

	dgen = UTF_Utils#GetFunctionTagValue(fullTestCase, UTF_FTAG_TD_GENERATOR, err)
	if(err)
		sprintf msg, "Could not find data generator specification for multi data test case %s. %s", fullTestCase, dgen
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif

	dgen = GetDataGeneratorFunctionName(err, dgen, procWin)
	if(err)
		sprintf msg, "Could not get full function name of data generator: %s", dgen
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif

	return dgen
End

/// Checks functions signature of a test case candidate
/// and its attributed data generator function
/// Returns 1 on error, 0 on success
static Function CheckFunctionSignatureTC(procWin, fullFuncName, dgenList, markSkip)
	string procWin
	string fullFuncName
	string &dgenList
	variable &markSkip

	variable err, wType1, wType0, wRefSubType
	string dgen, msg
	string funcInfo

	dgenList = ""
	markSkip = 0

	// Require only optional parameter
	funcInfo = FunctionInfo(fullFuncName)
	if (NumberByKey("N_PARAMS", funcInfo) != NumberByKey("N_OPT_PARAMS", funcInfo))
		return 1
	endif

	// Simple Test Cases
	FUNCREF TEST_CASE_PROTO fTC = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTC)))
		return 0
	endif
	// MMD Test Case
	FUNCREF TEST_CASE_PROTO_MD fTCmmd = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCmmd)))
		dgenList = CheckFunctionSignatureMDgen(procWin, fullFuncName, markSkip)
		return 0
	endif

	// Multi Data Test Cases
	if(!GetFunctionSignatureTCMD(fullFuncName, wType0, wType1, wRefSubType))
		return 1
	endif

	dgen = GetDataGenFullFunctionName(procWin, fullFuncName)
	WAVE wGenerator = CheckDGenOutput(procWin, fullFuncName, dgen, wType0, wType1, wRefSubType)

	dgenList = AddListItem(dgen, dgenList, ";", Inf)
	AddDataGeneratorWave(dgen, wGenerator)
	markSkip = CheckDataGenZeroSize(wGenerator, fullFuncName, dgen)

	return 0
End

static Function AddDataGeneratorWave(dgen, dgenWave)
	string dgen
	WAVE dgenWave

	variable dgenSize

	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	if(FindDimLabel(dgenWaves, UTF_ROW, dgen) == -2)
		dgenSize = DimSize(dgenWaves, UTF_ROW)
		Redimension/N=(dgenSize + 1) dgenWaves
		dgenWaves[dgenSize] = dgenWave
		SetDimLabel UTF_ROW, dgenSize, $dgen, dgenWaves
	endif
End

static Function/WAVE GetMMDVarTemplates()

	Make/FREE/T templates = {DGEN_VAR_TEMPLATE, DGEN_STR_TEMPLATE, DGEN_DFR_TEMPLATE, DGEN_WAVE_TEMPLATE, DGEN_CMPLX_TEMPLATE, DGEN_INT64_TEMPLATE}
	return templates
End

static Function/S CheckFunctionSignatureMDgen(procWin, fullFuncName, markSkip)
	string procWin, fullFuncName
	variable &markSkip

	variable i, j, numTypes
	string msg
	string dgenList = ""

	WAVE/T templates = GetMMDVarTemplates()
	Make/FREE/D wType0 = {0xff %^ IUTF_WAVETYPE0_CMPL %^ IUTF_WAVETYPE0_INT64, NaN, NaN, NaN, IUTF_WAVETYPE0_CMPL, IUTF_WAVETYPE0_INT64}
	Make/FREE/D wType1 = {IUTF_WAVETYPE1_NUM, IUTF_WAVETYPE1_TEXT, IUTF_WAVETYPE1_DFR, IUTF_WAVETYPE1_WREF, IUTF_WAVETYPE1_NUM, IUTF_WAVETYPE1_NUM}

	numTypes = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTypes; i += 1)
		for(j = 0; j < DGEN_NUM_VARS; j += 1)
			markSkip = markSkip | CheckMDgenOutput(procWin, fullFuncName, templates[i], j, wType0[i], wType1[i], dgenList)
		endfor
	endfor

	if(UTF_Utils#IsEmpty(dgenList))
		sprintf msg, "No data generator functions specified for test case %s in test suite %s.", fullFuncName, procWin
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif

	return dgenList
End

/// Check Multi-Multi Data Generator output
/// return 1 if one data generator has a zero sized wave, 0 otherwise
static Function CheckMDgenOutput(procWin, fullFuncName, varTemplate, index, wType0, wType1, dgenList)
	string procWin, fullFuncName, varTemplate
	variable index, wType0, wType1
	string &dgenList

	string varName, tagName, dgen, msg
	variable err

	varName = varTemplate + num2istr(index)
	tagName = UTF_FTAG_TD_GENERATOR + " " + varName
	dgen = UTF_Utils#GetFunctionTagValue(fullFuncName, tagName, err)
	if(err == UTF_TAG_NOT_FOUND)
		return NaN
	endif
	dgen = GetDataGeneratorFunctionName(err, dgen, procWin)
	if(err)
		sprintf msg, "Could not get full function name of data generator: %s", dgen
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif

	EvaluateDgenTagResult(err, fullFuncName, varName)

	WAVE wGenerator = CheckDGenOutput(procWin, fullFuncName, dgen, wType0, wType1, NaN)
	AddDataGeneratorWave(dgen, wGenerator)
	dgenList = AddListItem(dgen, dgenList, ";", Inf)

	AddMMDTestCaseData(fullFuncName, dgen, varName, DimSize(wGenerator, UTF_ROW))

	return CheckDataGenZeroSize(wGenerator, fullFuncName, dgen)
End

static Function CheckDataGenZeroSize(wGenerator, fullFuncName, dgen)
	WAVE wGenerator
	string fullFuncName, dgen

	string msg

	if(!DimSize(wGenerator, UTF_ROW))
		sprintf msg, "Note: In test case %s data generator function (%s) returns a zero sized wave. Test case marked SKIP.", fullFuncName, dgen
		UTF_Reporting#ReportError(msg, incrErrorCounter = 0)
		return 1
	endif

	return 0
End

static Function/WAVE GetMMDFuncState()

	Make/FREE/T/N=(0, 3) mdFunState
	SetDimLabel UTF_COLUMN, 0, DATAGEN, mdFunState
	SetDimLabel UTF_COLUMN, 1, GENSIZE, mdFunState
	SetDimLabel UTF_COLUMN, 2, INDEX, mdFunState

	return mdFunState
End

static Function AddMMDTestCaseData(fullFuncName, dgen, varName, genSize)
	string fullFuncName, dgen, varName
	variable genSize

	variable funPos, size
	variable varPos, vSize

	WAVE/WAVE mdState = GetMMDataState()
	funPos = FindDimLabel(mdState, UTF_ROW, fullFuncName)
	if(funPos == -2)
		size = DimSize(mdState, UTF_ROW)
		Redimension/N=(size + 1) mdState
		SetDimLabel UTF_ROW, size, $fullFuncName, mdState
		funPos = size
		WAVE/T mdFunState = GetMMDFuncState()
		varPos = -2
	else
		WAVE/T mdFunState = mdState[funPos]
		varPos = FindDimLabel(mdFunState, UTF_ROW, varName)
	endif

	if(varPos == -2)
		vSize = DimSize(mdFunState, UTF_ROW)
		Redimension/N=(vSize + 1, -1) mdFunState
		SetDimLabel UTF_ROW, vSize, $varName, mdFunState
		varPos = vSize
	endif
	mdFunState[varPos][%DATAGEN] = dgen
	mdFunState[varPos][%GENSIZE] = num2istr(genSize)
	mdFunState[varPos][%INDEX] = num2istr(0)
	mdState[funPos] = mdFunState
End

static Function EvaluateDgenTagResult(err, fullFuncName, varName)
	variable err
	string fullFuncName, varName

	string msg

	if(err == UTF_TAG_EMPTY)
		sprintf msg, "No data generator function specified for function %s data generator variable %s.", fullFuncName, varName
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif
	if(err != UTF_TAG_OK)
		sprintf msg, "Problem determining data generator function specified for function %s data generator variable %s.", fullFuncName, varName
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif
End

static Function/WAVE GetGeneratorWave(dgen, fullFuncName)
	string dgen, fullFuncName

	variable dimPos
	string msg

	WAVE/WAVE wDgen = GetDataGeneratorWaves()
	dimPos = FindDimlabel(wDgen, UTF_ROW, dgen)
	if(dimPos == -2)
		FUNCREF TEST_CASE_PROTO_DGEN fDgen = $dgen
		if(!UTF_FuncRefIsAssigned(FuncRefInfo(fDgen)))
			sprintf msg, "Data Generator function %s has wrong format. It is referenced by test case %s.", dgen, fullFuncName
			UTF_Reporting#ReportErrorAndAbort(msg)
		endif
		WAVE/Z wGenerator = fDgen()
	else
		WAVE wGenerator = wDgen[dimPos]
	endif

	return wGenerator
End

static Function/WAVE CheckDGenOutput(procWin, fullFuncName, dgen, wType0, wType1, wRefSubType)
	string procWin, fullFuncName, dgen
	variable wType0, wType1, wRefSubType

	string msg

	WAVE/Z wGenerator = GetGeneratorWave(dgen, fullFuncName)
	if(!WaveExists(wGenerator))
		sprintf msg, "Data Generator function %s returns a null wave. It is referenced by test case %s.", dgen, fullFuncName
		UTF_Reporting#ReportErrorAndAbort(msg)
	elseif(DimSize(wGenerator, UTF_COLUMN) > 0)
		sprintf msg, "Data Generator function %s returns not a 1D wave. It is referenced by test case %s.", dgen, fullFuncName
		UTF_Reporting#ReportErrorAndAbort(msg)
	elseif(!((wType1 == IUTF_WAVETYPE1_NUM && WaveType(wGenerator, 1) == wType1 && WaveType(wGenerator) & wType0) || (wType1 != IUTF_WAVETYPE1_NUM && WaveType(wGenerator, 1) == wType1)))
		sprintf msg, "Data Generator %s functions returned wave format does not fit to expected test case parameter. It is referenced by test case %s.", dgen, fullFuncName
		UTF_Reporting#ReportErrorAndAbort(msg)
	elseif(!UTF_Utils#IsNaN(wRefSubType) && wType1 == IUTF_WAVETYPE1_WREF && !UTF_Utils#HasConstantWaveTypes(wGenerator, wRefSubType))
		sprintf msg, "Test case %s expects specific wave type1 %u from the Data Generator %s. The wave type from the data generator does not fit to expected wave type.", fullFuncName, wRefSubType, dgen
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif

	return wGenerator
End

/// Returns List of Test Functions in Procedure Window procWin
static Function/S GetTestCaseList(procWin)
	string procWin

	string testCaseList = FunctionList("!*_IGNORE", ";", "KIND:18,NPARAMS:0,VALTYPE:1,WIN:" + procWin)
	string testCaseMDList = FunctionList("!*_IGNORE", ";", "KIND:18,NPARAMS:1,VALTYPE:1,WIN:" + procWin)

	testCaseList = GrepList(testCaseList, PROCNAME_NOT_REENTRY)
	testCaseMDList = GrepList(testCaseMDList, PROCNAME_NOT_REENTRY)

	if(!UTF_Utils#IsEmpty(testCaseMDList))
		testCaseList = testCaseList + testCaseMDList
	endif

	return SortTestCaseList(procWin, testCaseList)
End

/// Returns the list of testcases sorted by line number
static Function/S SortTestCaseList(procWin, testCaseList)
	string procWin, testCaseList

	if(UTF_Utils#IsEmpty(testCaseList))
		return ""
	endif

	Wave/T testCaseWave = ListToTextWave(testCaseList, ";")

	Make/FREE/N=(ItemsInList(testCaseList)) lineNumberWave
	lineNumberWave[] = str2num(StringByKey("PROCLINE", FunctionInfo(testCaseWave[p], procWin)))

	Sort lineNumberWave, testCaseWave

	return UTF_Utils#TextWaveToList(testCaseWave, ";")
End

#if (IgorVersion() >= 7.0)
    // ListToTextWave is available
#else
/// @brief Convert a string list to a text wave
///
/// @param[in] list string list
/// @param[in] sep separator string
/// @returns wave reference to free wave
static Function/WAVE ListToTextWave(list, sep)
    string list, sep

    Make/T/FREE/N=(ItemsInList(list, sep)) result = StringFromList(p, list, sep)

    return result
End
#endif

/// @brief get test cases matching a certain pattern and fill TesRunSetup wave
///
/// This function searches for test cases in a given list of test suites. The
/// search can be performed either using a regular expression or on a defined
/// list of test cases. All Matches are checked.
/// The function returns an error
/// * If a given test case is not found
/// * If no test case was found
/// * if fullFunctionName returned an error
///
/// @param[in]  procWinList List of test suites, separated by ";"
/// @param[in]  matchStr    * List of test cases, separated by ";" (enableRegExp = 0)
///                         * *one* regular expression without ";" (enableRegExp = 1)
/// @param[in]  enableRegExp (0,1) defining the type of search for matchStr
/// @param[out] errMsg error message in case of error
///
/// @returns Numeric Error Code
static Function CreateTestRunSetup(procWinList, matchStr, enableRegExp, errMsg, enableTAP)
	string procWinList
	string matchStr
	variable enableRegExp
	string &errMsg
	variable enableTAP

	string procWin
	string funcName
	string funcList
	string fullFuncName, dgenList
	string testCase, testCaseMatch
	variable numTC, numpWL, numFL, numMatches, markSkip
	variable i,j,k, tdIndex
	variable err = TC_MATCH_OK

	if(enableRegExp && !(strsearch(matchStr, ";", 0) < 0))
		errMsg = "semicolon is not allowed in given regex pattern: " + matchStr
		return TC_REGEX_INVALID
	endif

	if(enableRegExp)
		sprintf matchStr, "^(?i)%s$", matchStr
	endif

	WAVE/T testRunData = GetTestRunData()

	numTC = ItemsInList(matchStr)
	numpWL = ItemsInList(procWinList)
	for(i = 0; i < numTC; i += 1)
		testCase = StringFromList(i, matchStr)
		testCaseMatch = ""
		numMatches = 0
		for(j = 0; j < numpWL; j += 1)
			procWin = StringFromList(j, procWinList)
			funcList = getTestCaseList(procWin)

			if(enableRegExp)
				try
					ClearRTError()
					testCaseMatch = GrepList(funcList, matchStr, 0, ";"); AbortOnRTE
				catch
					testCaseMatch = ""
					err = GetRTError(1)
					switch(err)
						case 1233:
							errMsg = "Regular expression error: " + matchStr
							err = TC_REGEX_INVALID
							break
						default:
							errMsg = GetErrMessage(err)
							err = GREPLIST_ERROR
					endswitch
					sprintf errMsg, "Error executing GrepList: %s", errMsg
					return err
				endtry
			else
				if(WhichListItem(testCase, funcList, ";", 0, 0) < 0)
					continue
				endif
				testCaseMatch = testCase
			endif

			numFL = ItemsInList(testCaseMatch)
			numMatches += numFL
			for(k = 0; k < numFL; k += 1)
				funcName = StringFromList(k, testCaseMatch)
				fullFuncName = getFullFunctionName(err, funcName, procWin)
				if(err)
					sprintf errMsg, "Could not get full function name: %s", fullFuncName
					return err
				endif

				AddFunctionTagWave(fullFuncName)

				if(CheckFunctionSignatureTC(procWin, fullFuncName, dgenList, markSkip))
					continue
				endif

				UTF_Utils_Vector#EnsureCapacity(testRunData, tdIndex)
				testRunData[tdIndex][%PROCWIN] = procWin
				testRunData[tdIndex][%TESTCASE] = fullFuncName
				testRunData[tdIndex][%FULLFUNCNAME] = fullFuncName
				testRunData[tdIndex][%DGENLIST] = dgenList
				markSkip = markSkip | UTF_Utils#HasFunctionTag(fullFuncName, UTF_FTAG_SKIP)
				testRunData[tdIndex][%SKIP] = SelectString(enableTAP, num2istr(markSkip), num2istr(UTF_TAP#TAP_IsFunctionSkip(fullFuncName) | markSkip))
				testRunData[tdIndex][%EXPECTFAIL] = num2istr(UTF_Utils#HasFunctionTag(fullFuncName, UTF_FTAG_EXPECTED_FAILURE))
				tdIndex += 1
			endfor
		endfor

		if(!numMatches)
			sprintf errMsg, "Could not find test case \"%s\" in procedure list \"%s\".", testCase, procWinList
			return TC_NOT_FOUND
		endif
	endfor
	Redimension/N=(tdIndex, -1, -1, -1) testRunData

	if(!tdIndex)
		errMsg = "No test cases found."
		return TC_LIST_EMPTY
	endif

	return TC_MATCH_OK
End

static Function AddFunctionTagWave(fullFuncName)
	string fullFuncName

	variable size

	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	WAVE/T tags = UTF_Utils#GetFunctionTagWave(fullFuncName)
	if(DimSize(tags, UTF_ROW))
		size = DimSize(ftagWaves, UTF_ROW)
		Redimension/N=(size + 1) ftagWaves
		ftagWaves[size] = tags
		SetDimLabel UTF_ROW, size, $fullFuncName, ftagWaves
	endif
End

/// Function determines the total number of test cases
/// Normal test cases are counted with 1
/// MD test cases are counted by multiplying all data generator wave sizes
/// When the optional string procWin is given then the number of test cases for that
/// procedure window (test suite) is returned.
/// Returns the total number of all test cases to be called
static Function GetTestCaseCount([procWin])
	string procWin

	variable i, j, size, dgenSize
	variable tcCount, dgenCount
	string dgenList, dgen

	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	WAVE/T testRunData = GetTestRunData()
	size = DimSize(testRunData, UTF_ROW)
	for(i = 0; i < size; i += 1)
		if(!ParamIsDefault(procWin) && CmpStr(procWin, testRunData[i][%PROCWIN]))
			continue
		endif

		dgenCount = 1
		dgenList = testRunData[i][%DGENLIST]
		dgenSize = ItemsInList(dgenList)
		for(j = 0; j < dgenSize; j += 1)
			dgen = StringFromList(j, dgenList)
			WAVE wv = dgenWaves[%$dgen]
			dgenCount *= DimSize(wv, UTF_ROW)
		endfor
		tcCount += dgenCount
	endfor

	return tcCount
End

// Return the status of an `SetIgorOption` setting
static Function QueryIgorOption(option)
	string option

	variable state

	Execute/Q "SetIgorOption " + option + "=?"
	NVAR V_Flag

	state = V_Flag
	KillVariables/Z V_Flag

	return state
End

/// Add an IM specification to every procedure name if running in an IM
static Function/S AdaptProcWinList(procWinList, enableRegExp)
	string procWinList
	variable enableRegExp

	variable i, numEntries
	string str
	string list = ""

	if(IsProcGlobal())
		return procWinList
	endif

	numEntries = ItemsInList(procWinList)
	for(i = 0; i < numEntries; i += 1)
		if(enableRegExp)
			str = StringFromList(i, procWinList) + "[[:space:]]\[" + GetIndependentModuleName() + "\]"
		else
			str = StringFromList(i, procWinList) + " [" + GetIndependentModuleName() + "]"
		endif
		list = AddListItem(str, list, ";", INF)
	endfor

	return list
End

/// get all available procedures as a ";" separated list
static Function/S GetProcedureList()

	string msg

	if(!IsProcGlobal())
		if(!QueryIgorOption("IndependentModuleDev"))
			sprintf msg, "Error: The unit-testing framework lives in the IM \"%s\" but \"SetIgorOption IndependentModuleDev=1\" is not set.", GetIndependentModuleName()
			UTF_Reporting#ReportError(msg)
			return ""
		endif
		return WinList("* [" + GetIndependentModuleName() + "]", ";", "WIN:128,INDEPENDENTMODULE:1")
	endif
	return WinList("*", ";", "WIN:128")
End

/// verify that the selected procedures are available.
///
/// @param procWinList   a list of procedures to check
/// @param enableRegExp  treat list items as regular expressions
/// @returns parsed list of procedures
static Function/S FindProcedures(procWinListIn, enableRegExp)
	string procWinListIn
	variable enableRegExp

	string procWin
	string procWinMatch
	string allProcWindows
	string errMsg, msg
	variable numItemsPW
	variable numMatches
	variable err
	variable i, j
	string procWinListOut = ""

	numItemsPW = ItemsInList(procWinListIn)
	if(numItemsPW <= 0)
		return ""
	endif

	allProcWindows = GetProcedureList()
	numItemsPW = ItemsInList(procWinListIn)
	for(i = 0; i < numItemsPW; i += 1)
		procWin = StringFromList(i, procWinListIn)
		if(enableRegExp)
			procWin = "^(?i)" + procWin + "$"
			try
				ClearRTError()
				procWinMatch = GrepList(allProcWindows, procWin, 0, ";"); AbortOnRTE
			catch
				procWinMatch = ""
				err = GetRTError(1)
				switch(err)
					case 1233:
						errMsg = "Regular expression error"
						break
					default:
						errMsg = GetErrMessage(err)
				endswitch
				sprintf msg, "Error executing GrepList: %s", errMsg
				UTF_Reporting#ReportError(msg)
			endtry
		else
			procWinMatch = StringFromList(WhichListItem(procWin, allProcWindows, ";", 0, 0), allProcWindows)
		endif

		numMatches = ItemsInList(procWinMatch)
		if(numMatches <= 0)
			sprintf msg, "Error: A procedure window matching the pattern \"%s\" could not be found.", procWin
			UTF_Reporting#ReportError(msg)
			return ""
		endif

		for(j = 0; j < numMatches; j += 1)
			procWin = StringFromList(j, procWinMatch)
			if(FindListItem(procWin, procWinListOut, ";", 0, 0) == -1)
				procWinListOut = AddListItem(procWin, procWinListOut, ";", INF)
			else
				sprintf msg, "Error: The procedure window named \"%s\" is a duplicate entry in the input list of procedures.", procWin
				UTF_Reporting#ReportError(msg)
				return ""
			endif
		endfor
	endfor

	return procWinListOut
End

/// @brief Called after the test case begin user hook and before the test case function
static Function BeforeTestCase(name)
	string name

#if IgorVersion() >= 9.0
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr/Z waveTrackingMode

	if(NVAR_Exists(waveTrackingMode))
		WaveTracking/LOCL stop
		WaveTracking/FREE stop
		if(!UTF_Utils#HasFunctionTag(name, UTF_FTAG_NO_WAVE_TRACKING))
			if((waveTrackingMode & UTF_WAVE_TRACKING_FREE) == UTF_WAVE_TRACKING_FREE)
				WaveTracking/FREE counter
			endif
			if((waveTrackingMode & UTF_WAVE_TRACKING_LOCAL) == UTF_WAVE_TRACKING_LOCAL)
				WaveTracking/LOCL counter
			endif
		endif
	endif
#endif

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_RUNNING

	SaveAssertionCounter()
End

/// @brief Called after the test case and after the test case end user hook
static Function AfterTestCaseUserHook(name, keepDataFolder)
	string name
	variable keepDataFolder

	string msg

	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr lastFolder
	SVAR/Z/SDFR=dfr workFolder

	if(SVAR_Exists(lastFolder) && DataFolderExists(lastFolder))
		SetDataFolder $lastFolder
	endif
	if (!keepDataFolder)
		if(SVAR_Exists(workFolder) && DataFolderExists(workFolder))
			KillDataFolder/Z $workFolder
		endif
	endif

#if IgorVersion() >= 9.0
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr waveTrackingMode

	if(NVAR_Exists(waveTrackingMode))
		if((waveTrackingMode & UTF_WAVE_TRACKING_LOCAL) == UTF_WAVE_TRACKING_LOCAL)
			WaveTracking/LOCL count
			if(V_Flag == WAVE_TRACKING_COUNT_MODE)
				if(V_numWaves)
					sprintf msg, "Local wave leak detected (leaked waves: %d) in \"%s\"", V_numWaves, name
					UTF_Reporting#TestCaseFail(msg)
				endif
				WaveTracking/LOCL stop
			elseif(V_Flag != WAVE_TRACKING_INACTIVE_MODE)
				// do nothing for WAVE_TRACKING_INACTIVE_MODE.
				// Most likely the user has used a tag to opt out this test case for wave tracking.
				sprintf msg, "Test case \"%s\" modified WaveTracking mode to %d. UTF can not track at the same time.", name, V_Flag
				UTF_Reporting#TestCaseFail(msg)
			endif
		endif

		if((waveTrackingMode & UTF_WAVE_TRACKING_FREE) == UTF_WAVE_TRACKING_FREE)
			WaveTracking/FREE count
			if(V_Flag == WAVE_TRACKING_COUNT_MODE)
				if(V_numWaves)
					sprintf msg, "Free wave leak detected (leaked waves: %d) in \"%s\"", V_numWaves, name
					UTF_Reporting#TestCaseFail(msg)
				endif
				WaveTracking/FREE stop
			elseif(V_Flag != WAVE_TRACKING_INACTIVE_MODE)
				// do nothing for WAVE_TRACKING_INACTIVE_MODE.
				// Most likely the user has used a tag to opt out this test case for wave tracking.
				sprintf msg, "Test case \"%s\" modified WaveTracking mode to %d. UTF can not track at the same time.", name, V_Flag
				UTF_Reporting#TestCaseFail(msg)
			endif
		endif
	endif
#endif

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	if(!CmpStr(wvTestCase[%CURRENT][%STATUS], IUTF_STATUS_UNKNOWN))
		sprintf msg, "Bug: Test case \"%s\" has an unknown state after it was running.", name
		UTF_Reporting#TestCaseFail(msg)
	endif
	strswitch(wvTestCase[%CURRENT][%STATUS])
		case IUTF_STATUS_RUNNING:
			wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_SUCCESS
			break
		case IUTF_STATUS_ERROR:
		case IUTF_STATUS_FAIL:
			WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
			wvTestSuite[%CURRENT][%NUM_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ERROR]) + 1)
			break
		case IUTF_STATUS_SKIP:
			WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
			wvTestSuite[%CURRENT][%NUM_SKIPPED] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_SKIPPED]) + 1)
			break
		default:
			sprintf msg, "test status \"%s\" is not supported for test case \"%s\".", wvTestCase[%CURRENT][%STATUS], name
			UTF_Reporting#ReportError(msg)
			break
	endswitch

End

/// @brief Called after the test case and before the test case end user hook
static Function AfterTestCase(name, skip)
	string name
	variable skip

	string msg

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr assert_count

	CleanupInfoMsg()

	if(assert_count == GetSavedAssertionCounter() && !skip)
		sprintf msg, "Test case \"%s\" doesn't contain at least one assertion", name
		UTF_Reporting#TestCaseFail(msg)
	endif
End

/// @brief Execute the builtin and user hooks
///
/// @param hookType One of @ref HookTypes
/// @param hooks    hooks structure
/// @param enableTAP set this to a value other than 0 to enable TAP output
/// @param enableJU set this to a value other than 0 to enable JUnit output
/// @param name     name of the test run/suite/case
/// @param procWin  name of the procedure window
/// @param tcIndex  current index of TestRunData
/// @param param    parameter for the builtin hooks
///
/// Catches runtime errors in the user hooks as well.
/// Takes care of correct bracketing of user and builtin functions as well. For
/// `begin` functions the order is builtin/user and for `end` functions user/builtin.
static Function ExecuteHooks(hookType, hooks, enableTAP, enableJU, name, procWin, tcIndex, [param])
	variable hookType
	Struct TestHooks& hooks
	variable enableTAP, enableJU
	string name, procWin
	variable tcIndex
	variable param

	variable err, skip
	string errorMessage, hookName

	WAVE/T testRunData = UTF_Basics#GetTestRunData()
	skip = str2num(testRunData[tcIndex][%SKIP])

	try
		ClearRTError()
		switch(hookType)
			case TEST_BEGIN_CONST:
				AbortOnValue ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testBegin

				TestBegin(name, param)
				userHook(name); AbortOnRTE
				break
			case TEST_SUITE_BEGIN_CONST:
				AbortOnValue !ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testSuiteBegin

				TestSuiteBegin(name)
				userHook(name); AbortOnRTE
				break
			case TEST_CASE_BEGIN_CONST:
				AbortOnValue !ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseBegin

				TestCaseBegin(name, skip)
				if(!skip)
					userHook(name); AbortOnRTE
					BeforeTestCase(name)
				endif
				break
			case TEST_CASE_END_CONST:
				AbortOnValue ParamIsDefault(param), 1

				AfterTestCase(name, skip)
				FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseEnd

				userHook(name); AbortOnRTE
				AfterTestCaseUserHook(name, param)
				break
			case TEST_SUITE_END_CONST:
				AbortOnValue !ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testSuiteEnd

				userHook(name); AbortOnRTE
				break
			case TEST_END_CONST:
				AbortOnValue ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testEnd

				userHook(name); AbortOnRTE
				break
			default:
				UTF_Reporting#ReportErrorAndAbort("Unknown hookType")
				break
		endswitch
	catch
		errorMessage = GetRTErrMessage()
		err = GetRTError(1)
		name = StringByKey("Name", FuncRefInfo(userHook))
		EvaluateRTE(err, errorMessage, V_AbortCode, name, USER_HOOK_TYPE, procWin)

		setAbortFlag()
	endtry

	switch(hookType)
		case TEST_CASE_END_CONST:
			if(!skip)
				TestCaseEnd(name)
			endif
			break
		case TEST_SUITE_END_CONST:
			TestSuiteEnd(name)
			break
		case TEST_END_CONST:
			TestEnd(name, param)
			if(enableJU)
				UTF_JUnit#JU_WriteOutput()
			endif
			if(enableTAP)
				UTF_TAP#TAP_Write()
			endif
			break
		default:
			// do nothing
			break
	endswitch
End

/// @brief Background monitor of the Unit Testing Framework
Function UTFBackgroundMonitor(s)
	STRUCT WMBackgroundStruct &s

	variable i, numTasks, result, stopState
	string task

	DFREF df = GetPackageFolder()
	SVAR/Z tList = df:BCKG_TaskList
	SVAR/Z rFunc = df:BCKG_ReentryFunc
	NVAR/Z timeout = df:BCKG_EndTime
	NVAR/Z mode = df:BCKG_Mode
	NVAR/Z failOnTimeout = df:BCKG_failOnTimeout

	if(!SVAR_Exists(tList) || !SVAR_Exists(rFunc) || !NVAR_Exists(mode) || !NVAR_Exists(timeout) || !NVAR_Exists(failOnTimeout))
		UTF_Reporting#ReportErrorAndAbort("UTFBackgroundMonitor can not find monitoring data in package DF, aborting monitoring.", setFlagOnly = 1)
		ClearReentrytoUTF()
		QuitOnAutoRunFull()
		return 2
	endif

	if(mode == BACKGROUNDMONMODE_OR)
		result = 0
	elseif(mode == BACKGROUNDMONMODE_AND)
		result = 1
	else
		UTF_Reporting#ReportErrorAndAbort("Unknown mode set for background monitor", setFlagOnly = 1)
		ClearReentrytoUTF()
		QuitOnAutoRunFull()
		return 2
	endif

	if(timeout && datetime > timeout)
		UTF_Reporting#ReportError("UTF background monitor has reached the timeout for reentry", incrErrorCounter = failOnTimeout)

		RunTest(BACKGROUNDINFOSTR)
		return 0
	endif

	numTasks = ItemsInList(tList)
	for(i = 0; i < numTasks; i += 1)
		task = StringFromList(i, tList)
		CtrlNamedBackground $task, status
		stopState = !NumberByKey("RUN", S_Info)
		if(mode == BACKGROUNDMONMODE_OR)
			result = result | stopState
		elseif(mode == BACKGROUNDMONMODE_AND)
			result = result & stopState
		endif
	endfor

	if(result)
		RunTest(BACKGROUNDINFOSTR)
	endif

	return 0
End

/// @brief Clear the glboal reentry flag, removes any saved RunTest state and stops the UTF monitoring task
static Function ClearReentrytoUTF()

	ResetBckgRegistered()
	KillDataFolder/Z $PKG_FOLDER_SAVE
	CtrlNamedBackground $BACKGROUNDMONTASK, stop
End

/// @brief Stores the state of TestHook structure to DF dfr with key as template
static Function StoreHooks(dfr, s, key)
	DFREF dfr
	STRUCT TestHooks &s
	string key

	key = "S" + key
	string/G dfr:$(key + "testBegin") = s.testBegin
	string/G dfr:$(key + "testEnd") = s.testEnd
	string/G dfr:$(key + "testSuiteBegin") = s.testSuiteBegin
	string/G dfr:$(key + "testSuiteEnd") = s.testSuiteEnd
	string/G dfr:$(key + "testCaseBegin") = s.testCaseBegin
	string/G dfr:$(key + "testCaseEnd") = s.testCaseEnd
End

/// @brief Restores the state of TestHook structure from DF dfr with key as template
static Function RestoreHooks(dfr, s, key)
	DFREF dfr
	STRUCT TestHooks &s
	string key

	key = "S" + key
	SVAR testBegin = dfr:$(key + "testBegin")
	SVAR testEnd = dfr:$(key + "testEnd")
	SVAR testSuiteBegin = dfr:$(key + "testSuiteBegin")
	SVAR testSuiteEnd = dfr:$(key + "testSuiteEnd")
	SVAR testCaseBegin = dfr:$(key + "testCaseBegin")
	SVAR testCaseEnd = dfr:$(key + "testCaseEnd")
	s.testBegin = testBegin
	s.testEnd = testEnd
	s.testSuiteBegin = testSuiteBegin
	s.testSuiteEnd = testSuiteEnd
	s.testCaseBegin = testCaseBegin
	s.testCaseEnd = testCaseEnd
End

/// @brief Saves the variable state of RunTest from a strRunTest structure to a dfr
static Function SaveState(dfr, s)
	DFREF dfr
	STRUCT strRunTest &s

	// save all local vars
	string/G dfr:SprocWinList = s.procWinList
	string/G dfr:Sname = s.name
	string/G dfr:StestCase = s.testCase
	variable/G dfr:SenableJU = s.enableJU
	variable/G dfr:SenableTAP = s.enableTAP
	variable/G dfr:SenableRegExp = s.enableRegExp
	variable/G dfr:SkeepDataFolder = s.keepDataFolder
	variable/G dfr:SenableRegExpTC = s.enableRegExpTC
	variable/G dfr:SenableRegExpTS = s.enableRegExpTS
	variable/G dfr:SdgenIndex = s.dgenIndex
	variable/G dfr:SdgenSize = s.dgenSize
	variable/G dfr:SmdMode = s.mdMode
	variable/G dfr:StracingEnabled = s.tracingEnabled
	variable/G dfr:ShtmlCreation = s.htmlCreation
	string/G dfr:StcSuffix = s.tcSuffix

	variable/G dfr:Si = s.i
	variable/G dfr:Serr = s.err
	StoreHooks(dfr, s.hooks, "TH")
	StoreHooks(dfr, s.procHooks, "PH")
End

/// @brief Restores the variable state of RunTest from dfr to a strRunTest structure
static Function RestoreState(dfr, s)
	DFREF dfr
	STRUCT strRunTest &s

	SVAR str = dfr:SprocWinList
	s.procWinList = str
	SVAR str = dfr:Sname
	s.name = str
	SVAR str = dfr:StestCase
	s.testCase = str
	NVAR var = dfr:SenableJU
	s.enableJU = var
	NVAR var = dfr:SenableTAP
	s.enableTAP = var
	NVAR var = dfr:SenableRegExp
	s.enableRegExp = var
	NVAR var = dfr:SkeepDataFolder
	s.keepDataFolder = var
	NVAR var = dfr:SenableRegExpTC
	s.enableRegExpTC = var
	NVAR var = dfr:SenableRegExpTS
	s.enableRegExpTS = var

	NVAR var = dfr:SdgenIndex
	s.dgenIndex = var
	NVAR var = dfr:SdgenSize
	s.dgenSize = var
	NVAR var = dfr:SmdMode
	s.mdMode = var
	NVAR var = dfr:StracingEnabled
	s.tracingEnabled = var
	NVAR var = dfr:ShtmlCreation
	s.htmlCreation = var
	SVAR str = dfr:StcSuffix
	s.tcSuffix = str

	NVAR var = dfr:Si
	s.i = var
	NVAR var = dfr:Serr
	s.err = var

	RestoreHooks(dfr, s.hooks, "TH")
	RestoreHooks(dfr, s.procHooks, "PH")
End

/// @brief initialize all strings in TestHook structure to be non <null>
static Function InitHooks(s)
	STRUCT TestHooks &s

	s.testBegin = ""
	s.testEnd = ""
	s.testSuiteBegin = ""
	s.testSuiteEnd = ""
	s.testCaseBegin = ""
	s.testCaseEnd = ""
End

static Function IsBckgRegistered()
	DFREF dfr = GetPackageFolder()
	NVAR/Z bckgRegistered = dfr:BCKG_Registered
	return NVAR_Exists(bckgRegistered) && bckgRegistered == 1
End

static Function ResetBckgRegistered()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:BCKG_Registered = 0
End

static Function CallTestCase(s, reentry)
	STRUCT strRunTest &s
	variable reentry

	STRUCT IUTF_mData mData

	variable wType0, wType1, wRefSubType, err, tcIndex
	string func, msg, dgenFuncName, origTCName

	WAVE/T testRunData = GetTestRunData()
	tcIndex = s.i

	if(reentry)
		DFREF dfr = GetPackageFolder()
		SVAR reentryFuncName = dfr:BCKG_ReentryFunc
		func = reentryFuncName
		sprintf msg, "Entering reentry \"%s\"", func
		UTF_Reporting#UTF_PrintStatusMessage(msg)
	else
		func = testRunData[tcIndex][%FULLFUNCNAME]
	endif

	if(s.mdMode  == TC_MODE_MD)

		WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
		dgenFuncName = StringFromList(0, testRunData[tcIndex][%DGENLIST])
		WAVE wGenerator = dgenWaves[%$dgenFuncName]
		wType0 = WaveType(wGenerator)
		wType1 = WaveType(wGenerator, 1)
		if(wType1 == IUTF_WAVETYPE1_NUM)
			if(wType0 & IUTF_WAVETYPE0_CMPL)

				FUNCREF TEST_CASE_PROTO_MD_CMPL fTCMD_CMPL = $func
				if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_CMPL)))
					sprintf msg, "Reentry function %s does not meet required format for Complex argument.", func
					UTF_Reporting#ReportErrorAndAbort(msg)
				endif
				fTCMD_CMPL(cmpl=wGenerator[s.dgenIndex]); AbortOnRTE

			elseif(wType0 & IUTF_WAVETYPE0_INT64)

				FUNCREF TEST_CASE_PROTO_MD_INT fTCMD_INT = $func
				if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_INT)))
					sprintf msg, "Reentry function %s does not meet required format for INT64 argument.", func
					UTF_Reporting#ReportErrorAndAbort(msg)
				endif
				fTCMD_INT(int=wGenerator[s.dgenIndex]); AbortOnRTE

			else

				FUNCREF TEST_CASE_PROTO_MD_VAR fTCMD_VAR = $func
				if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_VAR)))
					sprintf msg, "Reentry function %s does not meet required format for numeric argument.", func
					UTF_Reporting#ReportErrorAndAbort(msg)
				endif
				fTCMD_VAR(var=wGenerator[s.dgenIndex]); AbortOnRTE

			endif
		elseif(wType1 == IUTF_WAVETYPE1_TEXT)

			WAVE/T wGeneratorStr = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_STR fTCMD_STR = $func
			if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_STR)))
				sprintf msg, "Reentry function %s does not meet required format for string argument.", func
				UTF_Reporting#ReportErrorAndAbort(msg)
			endif
			fTCMD_STR(str=wGeneratorStr[s.dgenIndex]); AbortOnRTE

		elseif(wType1 == IUTF_WAVETYPE1_DFR)

			WAVE/DF wGeneratorDF = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_DFR fTCMD_DFR = $func
			if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_DFR)))
				sprintf msg, "Reentry function %s does not meet required format for data folder reference argument.", func
				UTF_Reporting#ReportErrorAndAbort(msg)
			endif
			fTCMD_DFR(dfr=wGeneratorDF[s.dgenIndex]); AbortOnRTE

		elseif(wType1 == IUTF_WAVETYPE1_WREF)

			WAVE/WAVE wGeneratorWV = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_WV fTCMD_WV = $func
			if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WV)))
				fTCMD_WV(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
			else
				wRefSubType = WaveType(wGeneratorWV[s.dgenIndex], 1)
				if(wRefSubType == IUTF_WAVETYPE1_TEXT)
					FUNCREF TEST_CASE_PROTO_MD_WVTEXT fTCMD_WVTEXT = $func
					if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVTEXT)))
						fTCMD_WVTEXT(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				elseif(wRefSubType == IUTF_WAVETYPE1_DFR)
					FUNCREF TEST_CASE_PROTO_MD_WVDFREF fTCMD_WVDFREF = $func
					if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVDFREF)))
						fTCMD_WVDFREF(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				elseif(wRefSubType == IUTF_WAVETYPE1_WREF)
					FUNCREF TEST_CASE_PROTO_MD_WVWAVEREF fTCMD_WVWAVEREF = $func
					if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVWAVEREF)))
						fTCMD_WVWAVEREF(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				else
					sprintf msg, "Got wave reference wave from Data Generator %s with waves of unsupported type for reentry of test case %s.", dgenFuncName, func
					UTF_Reporting#ReportErrorAndAbort(msg)
				endif
				if(err)
					sprintf msg, "Reentry function %s does not meet required format for wave reference argument from data generator %s.", func, dgenFuncName
					UTF_Reporting#ReportErrorAndAbort(msg)
				endif
			endif

		endif
	elseif(s.mdMode  == TC_MODE_MMD)
		origTCName = testRunData[tcIndex][%FULLFUNCNAME]
		SetupMMDStruct(mData, origTCName)
		FUNCREF TEST_CASE_PROTO_MD fTCMD = $func
		if(!UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD)))
			sprintf msg, "Reentry function %s does not meet required format for multi-multi-data test case.", func
			UTF_Reporting#ReportErrorAndAbort(msg)
		else
			fTCMD(md=mData); AbortOnRTE
		endif
	elseif(s.mdMode  == TC_MODE_NORMAL)
		FUNCREF TEST_CASE_PROTO TestCaseFunc = $func
		TestCaseFunc(); AbortOnRTE
	else
		sprintf msg, "Unknown test case mode for function %s.", func
		UTF_Reporting#ReportErrorAndAbort(msg)
	endif
End

/// Return 1 if the counting finished, 0 otherwise
static Function IncreaseMMDIndices(fullFuncName)
	string fullFuncName

	variable i, numVars, index, genSize

	WAVE/WAVE mdState = GetMMDataState()
	WAVE/T mdFunState = mdState[%$fullFuncName]
	numVars = DimSize(mdFunState, UTF_ROW)
	for(i = 0; i < numVars; i += 1)
		index = str2num(mdFunState[i][%INDEX])
		genSize = str2num(mdFunState[i][%GENSIZE])
		index += 1
		if(index < genSize)
			mdFunState[i][%INDEX] = num2istr(index)
			return 0
		else
			mdFunState[i][%INDEX] = num2istr(0)
		endif
	endfor

	return 1
End

static Function SetupMMDStruct(mData, fullFuncName)
	STRUCT IUTF_mData &mData
	string fullFuncName

	variable i, j, numTypes
	variable funPos, varPos, index, val
	variable/C cplx
	string msg, varName, dgen, str
#if (IgorVersion() >= 7.0)
	int64 i64
#endif

	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	WAVE/WAVE mdState = GetMMDataState()
	WAVE/T templates = GetMMDVarTemplates()

	WAVE/T mdFunState = mdState[%$fullFuncName]

	numTypes = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTypes; i += 1)
		for(j = 0; j < DGEN_NUM_VARS; j += 1)
			varName = templates[i] + num2istr(j)
			varPos = FindDimLabel(mdFunState, UTF_ROW, varName)
			if(varPos == -2)
				continue
			endif
			dgen = mdFunState[varPos][%DATAGEN]
			index = str2num(mdFunState[varPos][%INDEX])

			strSwitch(templates[i])
				case DGEN_VAR_TEMPLATE:
					WAVE wGenerator = dgenWaves[%$dgen]
					val = wGenerator[index]

					switch(j)
						case 0:
							mData.v0 = val
							break
						case 1:
							mData.v1 = val
							break
						case 2:
							mData.v2 = val
							break
						case 3:
							mData.v3 = val
							break
						case 4:
							mData.v4 = val
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_STR_TEMPLATE:
					WAVE/T wGeneratorT = dgenWaves[%$dgen]
					str = wGeneratorT[index]

					switch(j)
						case 0:
							mData.s0 = str
							break
						case 1:
							mData.s1 = str
							break
						case 2:
							mData.s2 = str
							break
						case 3:
							mData.s3 = str
							break
						case 4:
							mData.s4 = str
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_DFR_TEMPLATE:
					WAVE/DF wGeneratorDFR = dgenWaves[%$dgen]
					DFREF dfr = wGeneratorDFR[index]

					switch(j)
						case 0:
							mData.dfr0 = dfr
							break
						case 1:
							mData.dfr1 = dfr
							break
						case 2:
							mData.dfr2 = dfr
							break
						case 3:
							mData.dfr3 = dfr
							break
						case 4:
							mData.dfr4 = dfr
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_WAVE_TEMPLATE:
					WAVE/WAVE wGeneratorWV = dgenWaves[%$dgen]
					WAVE wv = wGeneratorWV[index]

					switch(j)
						case 0:
							WAVE mData.w0 = wv
							break
						case 1:
							WAVE mData.w1 = wv
							break
						case 2:
							WAVE mData.w2 = wv
							break
						case 3:
							WAVE mData.w3 = wv
							break
						case 4:
							WAVE mData.w4 = wv
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_CMPLX_TEMPLATE:
					WAVE/C wGeneratorC = dgenWaves[%$dgen]
					cplx = wGeneratorC[index]

					switch(j)
						case 0:
							mData.c0 = cplx
							break
						case 1:
							mData.c1 = cplx
							break
						case 2:
							mData.c2 = cplx
							break
						case 3:
							mData.c3 = cplx
							break
						case 4:
							mData.c4 = cplx
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
#if (IgorVersion() >= 7.0)
				case DGEN_INT64_TEMPLATE:
					WAVE wGeneratorI = dgenWaves[%$dgen]
					i64 = wGeneratorI[index]

					switch(j)
						case 0:
							mData.i0 = i64
							break
						case 1:
							mData.i1 = i64
							break
						case 2:
							mData.i2 = i64
							break
						case 3:
							mData.i3 = i64
							break
						case 4:
							mData.i4 = i64
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
#endif
				default:
					UTF_Reporting#ReportErrorAndAbort("Encountered invalid type for mmd tc")
					break
			endswitch
		endfor
	endfor
End

/// @brief Structure for multi data function using multiple data generators
#if (IgorVersion() >= 7.0)
Structure IUTF_mData
	variable v0
	variable v1
	variable v2
	variable v3
	variable v4
	string s0
	string s1
	string s2
	string s3
	string s4
	DFREF dfr0
	DFREF dfr1
	DFREF dfr2
	DFREF dfr3
	DFREF dfr4
	WAVE/WAVE w0
	WAVE/WAVE w1
	WAVE/WAVE w2
	WAVE/WAVE w3
	WAVE/WAVE w4
	variable/C c0
	variable/C c1
	variable/C c2
	variable/C c3
	variable/C c4
	int64 i0
	int64 i1
	int64 i2
	int64 i3
	int64 i4
EndStructure
#else
Structure IUTF_mData
	variable v0
	variable v1
	variable v2
	variable v3
	variable v4
	string s0
	string s1
	string s2
	string s3
	string s4
	DFREF dfr0
	DFREF dfr1
	DFREF dfr2
	DFREF dfr3
	DFREF dfr4
	WAVE/WAVE w0
	WAVE/WAVE w1
	WAVE/WAVE w2
	WAVE/WAVE w3
	WAVE/WAVE w4
	variable/C c0
	variable/C c1
	variable/C c2
	variable/C c3
	variable/C c4
EndStructure
#endif

/// @brief initialize all strings in strRunTest structure to be non <null>
static Function InitStrRunTest(s)
	STRUCT strRunTest &s

	s.procWinList = ""
	s.name = ""
	s.testCase = ""

	s.tcSuffix = ""

	InitHooks(s.hooks)
	InitHooks(s.procHooks)
End

/// @brief this structure stores all local variables used in RunTest. It is used to store the complete function state.
static Structure strRunTest
	string procWinList
	string name
	string testCase
	variable enableJU
	variable enableTAP
	variable enableRegExp
	variable debugMode
	variable keepDataFolder
	variable enableRegExpTC
	variable enableRegExpTS
	variable dgenIndex
	variable dgenSize
	variable mdMode
	variable tracingEnabled
	variable htmlCreation
	string tcSuffix
	STRUCT TestHooks hooks
	STRUCT TestHooks procHooks
	variable i
	variable err
EndStructure

///@endcond // HIDDEN_SYMBOL

/// @brief Registers a background monitor for a list of other background tasks
///
/// @verbatim embed:rst:leading-slashes
///     .. code-block:: igor
///        :caption: usage example
///
///        RegisterUTFMonitor("TestCaseTask1;TestCaseTask2", BACKGROUNDMONMODE_OR, \
///                           "testcase_REENTRY", timeout = 60)
///
///     This command will register the UTF background monitor task to monitor
///     the state of `TestCaseTask1` and `TestCaseTask2`. As mode is set to
///     `BACKGROUNDMONMODE_OR`, when `TestCaseTask1` OR `TestCaseTask2` has
///     finished the function `testcase_REENTRY()` is called to  continue the
///     current test case. The reentry function is also called if after 60 seconds
///     both tasks are still running.
///
/// @endverbatim
///
/// @param   taskList      A list of background task names that should be monitored by the unit testing framework
///                        @n The list should be given semicolon (";") separated.
///
/// @param   mode          Mode sets how multiple tasks are evaluated. If set to
///                        `BACKGROUNDMONMODE_AND` all tasks of the list must finish (AND).
///                        If set to `BACKGROUNDMONMODE_OR` one task of the list must finish (OR).
///
/// @param   reentryFunc   Name of the function that the unit testing framework calls when the monitored background tasks finished.
///                        The function name must end with _REENTRY and it must be of the form `$fun_REENTRY()` (same format as test cases).
///                        The reentry function *continues* the current test case therefore no hooks are called.
///
/// @param   timeout       (optional) default 0. Timeout in seconds that the background monitor waits for the test case task(s).
///                        A timeout of 0 equals no timeout. If the timeout is reached the registered reentry function is called.
/// @param   failOnTimeout (optional) default to false. If the test case should be failed on reaching the timeout.
Function RegisterUTFMonitor(taskList, mode, reentryFunc, [timeout, failOnTimeout])
	string taskList
	variable mode
	string reentryFunc
	variable timeout, failOnTimeout

	string procWinList, rFunc
	variable tmpVar
	DFREF dfr = GetPackageFolder()

	if(ParamIsDefault(timeout))
		timeout = 0
	endif
	timeout = timeout <= 0 ? 0 : datetime + timeout

	failOnTimeout = ParamIsDefault(failOnTimeout) ? 0 : !!failOnTimeout

	if(UTF_Utils#IsEmpty(tasklist))
		UTF_Reporting#ReportErrorAndAbort("Tasklist is empty.")
	endif

	if(!(mode == BACKGROUNDMONMODE_OR || mode == BACKGROUNDMONMODE_AND))
		UTF_Reporting#ReportErrorAndAbort("Unknown mode set")
	endif

	if(FindListItem(BACKGROUNDMONTASK, taskList) != -1)
		UTF_Reporting#ReportErrorAndAbort("Igor Unit Testing framework will not monitor its own monitoring task (" + BACKGROUNDMONTASK + ").")
	endif

	// check valid reentry function
	if(GrepString(reentryFunc, PROCNAME_NOT_REENTRY))
		UTF_Reporting#ReportErrorAndAbort("Name of Reentry function must end with _REENTRY")
	endif
	FUNCREF TEST_CASE_PROTO rFuncRef = $reentryFunc
	FUNCREF TEST_CASE_PROTO_MD rFuncRefMMD = $reentryFunc
	if(!UTF_FuncRefIsAssigned(FuncRefInfo(rFuncRef)) && !UTF_FuncRefIsAssigned(FuncRefInfo(rFuncRefMMD)) && !GetFunctionSignatureTCMD(reentryFunc, tmpVar, tmpVar, tmpVar))
		UTF_Reporting#ReportErrorAndAbort("Specified reentry procedure has wrong format. The format must be function_REENTRY() or for multi data function_REENTRY([type]).")
	endif

	string/G dfr:BCKG_TaskList = taskList
	string/G dfr:BCKG_ReentryFunc = reentryFunc
	variable/G dfr:BCKG_Mode = mode

	variable/G dfr:BCKG_EndTime = timeout
	variable/G dfr:BCKG_Registered = 1
	variable/G dfr:BCKG_FailOnTimeout = failOnTimeout

	CtrlNamedBackground $BACKGROUNDMONTASK, proc=UTFBackgroundMonitor, period=10, start
End

static Function ClearTestSetupWaves()

	WAVE/T testRunData = GetTestRunData()
	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	WAVE/WAVE mdState = GetMMDataState()

	KillWaves testRunData, dgenWaves, ftagWaves, mdState
End

static Function/S GetMMDTCSuffix(tdIndex)
	variable tdIndex

	variable i, numVars, index
	string fullFuncName, dgen, lbl
	string tcSuffix = ""

	WAVE/T testRunData = GetTestRunData()
	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	WAVE/WAVE mdState = GetMMDataState()

	fullFuncName = testRunData[tdIndex][%FULLFUNCNAME]
	WAVE/T mdFunState = mdState[%$fullFuncName]

	numVars = DimSize(mdFunState, UTF_ROW)
	for(i = 0; i < numVars; i += 1)
		dgen = mdFunState[i][%DATAGEN]
		index = str2num(mdFunState[i][%INDEX])
		WAVE wGenerator = dgenWaves[%$dgen]
		lbl = GetDimLabel(wGenerator, UTF_ROW, index)
		if(!UTF_Utils#IsEmpty(lbl))
			tcSuffix += TC_SUFFIX_SEP + lbl
		else
			tcSuffix += TC_SUFFIX_SEP + num2istr(index)
		endif
	endfor

	return tcSuffix
End

/// @brief Main function to execute test suites with the unit testing framework.
///
/// @verbatim embed:rst:leading-slashes
///     .. code-block:: igor
///        :caption: usage example
///
///        RunTest("proc0;proc1", name="myTest")
///
///     This command will run the test suites `proc0` and `proc1` in a test named `myTest`.
/// @endverbatim
///
/// @param   procWinList    A list of procedure files that should be treated as test suites.
///                         @n The list should be given semicolon (";") separated.
///                         @n The procedure name must not include Independent Module specifications.
///                         @n This parameter can be given as a regular expression with enableRegExp set to 1.
///
/// @param   name           (optional) default "Unnamed" @n
///                         descriptive name for the executed test suites. This can be
///                         used to group multiple test suites into a single test run.
///
/// @param   testCase       (optional) default ".*" (all test cases in the list of test suites) @n
///                         function names, resembling test cases, which should be
///                         executed in the given list of test suites (procWinList).
///                         @n The list should be given semicolon (";") separated.
///                         @n This parameter can be treated as a regular expression with enableRegExp set to 1.
///
/// @param   enableJU       (optional) default disabled, enabled when set to 1: @n
///                         A JUNIT compatible XML file is written at the end of the Test Run.
///                         It allows the combination of this framework with continuous integration
///                         servers like Atlassian Bamboo/GitLab/etc.
///                         Can not be combined with enableTAP.
///                         The experiment is required to be saved somewhere on the disk. (it is okay to have unsaved changes.)
///
/// @param   enableTAP      (optional) default disabled, enabled when set to 1: @n
///                         A TAP compatible file is written at the end of the test run.
///                         @verbatim embed:rst:leading-slashes
///                             `Test Anything Protocol (TAP) <https://testanything.org>`__
///                             `standard 13 <https://testanything.org/tap-version-13-specification.html>`__
///                         @endverbatim
///                         Can not be combined with enableJU.
///                         The experiment is required to be saved somewhere on the disk. (it is okay to have unsaved changes.)
///
/// @param   enableRegExp   (optional) default disabled, enabled when set to 1: @n
///                         The input for test suites (procWinList) and test cases (testCase) is
///                         treated as a regular expression.
///                         @verbatim embed:rst:leading-slashes
///                             .. code-block:: igor
///                                :caption: Example
///
///                                RunTest("example[1-3]-plain\\.ipf", enableRegExp=1)
///
///                             This command will run all test cases in the following test suites:
///
///                             * :ref:`example1-plain.ipf<example1>`
///                             * :ref:`example2-plain.ipf<example2>`
///                             * :ref:`example3-plain.ipf<example3>`
///                         @endverbatim
///
/// @param   allowDebug     (optional) default disabled, enabled when set to 1: @n
///                         The Igor debugger will be left in its current state when running the
///                         tests. Is ignored when debugMode is also enabled.
///
/// @param	debugMode      (optional) default disabled, enabled when set to 1-15: @n
///                         The Igor debugger will be turned on in the state: @n
///								  1st bit = 1 (IUTF_DEBUG_ENABLE): Enable Debugger (only breakpoints) @n
///                         2nd bit = 1 (IUTF_DEBUG_ON_ERROR): Debug on Error @n
///								  3rd bit = 1 (IUTF_DEBUG_NVAR_SVAR_WAVE): Check NVAR SVAR WAVE @n
///                         4th bit = 1 (IUTF_DEBUG_FAILED_ASSERTION): Debug on failed assertion
///                         @verbatim embed:rst:leading-slashes
///                             .. code-block:: igor
///                                :caption: Example
///
///                                RunTest(..., debugMode = IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_FAILED_ASSERTION)
///
///                             This will enable the debugger with Debug On Error and debugging on failed assertion.
///                         @endverbatim
///
/// @param   keepDataFolder (optional) default disabled, enabled when set to 1: @n
///                         The temporary data folder wherein each test case is executed is not
///                         removed at the end of the test case. This allows to review the
///                         produced data.
///
/// @param   traceWinList   (optional) default ""
///                         A list of windows where execution gets traced. The unit testing framework saves a RTF document
///                         for each traced procedure file. When REGEXP was set in traceOptions then traceWinList is also interpreted
///                         as a regular expression.
///                         The experiment is required to be saved somewhere on the disk. (it is okay to have unsaved changes.)
///
/// @param   traceOptions   (optional) default ""
///                         A key:value pair list of additional tracing options. Currently supported is:
///                         INSTRUMENTONLY:boolean When set, run instrumentation only and return. No tests are executed.
///                         HTMLCREATION:boolean When set to zero, no htm result files are created at the end of the run
///                         REGEXP:boolean When set, traceWinList is interpreted as regular expression
///
/// @param   fixLogName     (optional) default 0 disabled, enabled when set to 1: @n
///                         If enabled the output files that will be generated after an autorun will have predictable names like
///                         "IUTF_Test.log". If disabled the file names will always contain the name of the procedure file and a
///                         timestamp.
///
/// @param   waveTrackingMode (optional) default disabled, enabled when set to a value different than 0: @n
///                         Monitors the number of free waves before and after a test case run. If for some reasons the number is not
///                         the same as before this considered as an error. If you want to opt-out a single test case you have to tag
///                         it with UTF_NO_WAVE_TRACKING.
///                         This uses the flags UTF_WAVE_TRACKING_FREE, UTF_WAVE_TRACKING_LOCAL and UTF_WAVE_TRACKING_ALL.
///                         This feature is only available since Igor Pro 9.
///
/// @return                 total number of errors
Function RunTest(procWinList, [name, testCase, enableJU, enableTAP, enableRegExp, allowDebug, debugMode, keepDataFolder, traceWinList, traceOptions, fixLogName, waveTrackingMode])
	string procWinList, name, testCase
	variable enableJU, enableTAP, enableRegExp
	variable allowDebug, debugMode, keepDataFolder
	string traceWinList, traceOptions
	variable fixLogName
	variable waveTrackingMode

	// All variables that are needed to keep the local function state are wrapped in s
	// new var/str must be added to strRunTest and added in SaveState/RestoreState functions
	STRUCT strRunTest s
	InitStrRunTest(s)

	DFREF dfr = GetPackageFolder()

	// init global vars
	string/G dfr:message = ""
	string/G dfr:type = "0"
	string/G dfr:systemErr = ""

	// do not save these for reentry
	//
	variable reentry
	// these use a very local scope where used
	// loop counter and loop end derived vars
	variable i, j, tcFuncCount, startNextTS, skip, tcCount, reqSave
	string procWin, fullFuncName, previousProcWin, dgenFuncName
	// used as temporal locals
	variable var, err
	string msg, errMsg

	fixLogName = ParamIsDefault(fixLogName) ? 0 : !!fixLogName
	waveTrackingMode = ParamIsDefault(waveTrackingMode) ? UTF_WAVE_TRACKING_NONE : waveTrackingMode

	reentry = IsBckgRegistered()
	ResetBckgRegistered()
	if(reentry)

		// check also if a saved state is existing
		if(!DataFolderExists(PKG_FOLDER_SAVE))
			UTF_Reporting#ReportErrorAndAbort("No saved test state found, aborting. (Did you RegisterUTFMonitor in an End Hook?)")
		endif
	  // check if the reentry call originates from our own background monitor
		if(CmpStr(GetRTStackInfo(2), BACKGROUNDMONFUNC))
			ClearReentrytoUTF()
			UTF_Reporting#ReportErrorAndAbort("RunTest was called by user after background monitoring was registered. This is not supported.")
		endif

	else
		// no early return/abort above this point
		DFREF dfr = GetPackageFolder()
		string/G dfr:baseFilenameOverwrite = SelectString(fixLogName, "", FIXED_LOG_FILENAME)
		ClearTestSetupWaves()
		UTF_Reporting#ClearTestResultWaves()
		ClearBaseFilename()
		CreateHistoryLog()

		allowDebug = ParamIsDefault(allowDebug) ? 0 : !!allowDebug

		// transfer parameters to s. variables
		s.enableRegExp = enableRegExp
		s.enableRegExpTC = ParamIsDefault(enableRegExp) ? 0 : !!enableRegExp
		s.enableRegExpTS = s.enableRegExpTC
		s.enableJU = ParamIsDefault(enableJU) ? 0 : !!enableJU
		s.enableTAP = ParamIsDefault(enableTAP) ? 0 : !!enableTAP
		s.debugMode = ParamIsDefault(debugMode) ? 0 : debugMode
		s.keepDataFolder = ParamIsDefault(keepDataFolder) ? 0 : !!keepDataFolder

		s.tracingEnabled = !ParamIsDefault(traceWinList) && !UTF_Utils#IsEmpty(traceWinList)

		if(s.enableTAP && s.enableJU)
			UTF_Reporting#ReportError("Error: enableTAP and enableJU can not be both true.")
			return NaN
		endif

		if(s.enableJU || s.enableTAP || s.tracingEnabled)
			PathInfo home
			if(!V_flag)
				UTF_Reporting#ReportError("Error: Please Save experiment first.")
				return NaN
			endif
		endif

		var = IUTF_DEBUG_ENABLE | IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE | IUTF_DEBUG_FAILED_ASSERTION
		if(s.debugMode > var || s.debugMode < 0 || !UTF_Utils#IsInteger(s.debugMode))
			sprintf msg, "debugMode can only be an integer between 0 and %d. The input %g is wrong, aborting!.\r", var, s.debugMode
			msg = msg + "Use the constants IUTF_DEBUG_ENABLE, IUTF_DEBUG_ON_ERROR,\r"
			msg = msg + "IUTF_DEBUG_NVAR_SVAR_WAVE and IUTF_DEBUG_FAILED_ASSERTION for debugMode.\r\r"
			msg = msg + "Example: debugMode = IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE"
			UTF_Reporting#ReportErrorAndAbort(msg)
		endif

		if(s.debugMode > 0 && allowDebug > 0)
			print "Note: debugMode parameter is set, allowDebug parameter is ignored."
		endif
		if(s.debugMode == 0 && allowDebug > 0)
			s.debugMode = GetCurrentDebuggerState()
		endif

#if IgorVersion() < 9.00
		if(waveTrackingMode)
			UTF_Reporting#ReportErrorAndAbort("Error: wave tracking is only allowed to be used in Igor Pro 9 or higher.")
		else
			variable/G dfr:waveTrackingMode = UTF_WAVE_TRACKING_NONE
		endif
#else
		if((waveTrackingMode & UTF_WAVE_TRACKING_ALL) != waveTrackingMode)
			sprintf msg, "Error: Invalid wave tracking mode %d", waveTrackingMode
			UTF_Reporting#ReportErrorAndAbort(msg)
		endif
		variable/G dfr:waveTrackingMode = waveTrackingMode
#endif

		traceOptions = SelectString(ParamIsDefault(traceOptions), traceOptions, "")

		if(ParamIsDefault(name))
			s.name = "Unnamed"
		else
			s.name = name
		endif

		if(ParamIsDefault(testCase))
			s.testCase = ".*"
			s.enableRegExpTC = 1
		else
			s.testCase = testCase
		endif
		s.procWinList = procWinList

		if(s.tracingEnabled)
#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
			if(!CmpStr(traceWinList, IUTF_TRACE_REENTRY_KEYWORD))
				DFREF dfSave = $PKG_FOLDER_SAVE
				RestoreState(dfSave, s)
				ClearReentrytoUTF()
			else
				ClearReentrytoUTF()

				var = NumberByKey(UTF_KEY_HTMLCREATION, traceOptions)
				s.htmlCreation = UTF_Utils#IsNaN(var) ? 1 : var

				NewDataFolder $PKG_FOLDER_SAVE
				DFREF dfSave = $PKG_FOLDER_SAVE
				SaveState(dfSave, s)
				TUFXOP_Init/N="IUTF_Testrun"
				TUFXOP_Clear/Q/Z/N="IUTF_Error"
				UTF_Tracing#SetupTracing(traceWinList, traceOptions)
				return NaN
			endif
#else
			UTF_Reporting#ReportErrorAndAbort("Tracing requires Igor Pro 9 Build 38812 (or later) and the Thread Utilities XOP.")
#endif
		else
#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
			TUFXOP_Init/N="IUTF_Testrun"
#endif
		endif

		// below here use only s. variables to keep local state in struct

		s.procWinList = AdaptProcWinList(s.procWinList, s.enableRegExpTS)
		s.procWinList = FindProcedures(s.procWinList, s.enableRegExpTS)

		if(ItemsInList(s.procWinList) <= 0)
			UTF_Reporting#ReportError("Error: The list of procedure windows is empty or invalid.")
			return NaN
		endif

		err = CreateTestRunSetup(s.procWinList, s.testCase, s.enableRegExpTC, errMsg, s.enableTAP)
		tcCount = GetTestCaseCount()

		if(err != TC_MATCH_OK)
			if(err == TC_LIST_EMPTY)
				errMsg = s.procWinList
				errMsg = UTF_Utils#PrepareStringForOut(errMsg)
				sprintf msg, "Error: A test case matching the pattern \"%s\" could not be found in test suite(s) \"%s\".", s.testcase, errMsg
				UTF_Reporting#ReportError(msg)
				return NaN
			endif

			errMsg = UTF_Utils#PrepareStringForOut(errMsg)
			sprintf msg, "Error %d in CreateTestRunSetup: %s", err, errMsg
			UTF_Reporting#ReportError(msg)
			return NaN
		endif

		// 1.) set the hooks to the default implementations
		setDefaultHooks(s.hooks)
		// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
		getGlobalHooks(s.hooks)

		// Reinitializes
		ExecuteHooks(TEST_BEGIN_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param=s.debugMode)

		// TAP Handling, find out if all should be skipped and number of all test cases
		if(s.enableTAP)
			if(UTF_TAP#TAP_AreAllFunctionsSkip())
				ExecuteHooks(TEST_END_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param=s.debugMode)
				return 0
			endif
		endif

	endif

	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	NVAR/SDFR=dfr global_error_count

	// The Test Run itself is split into Test Suites for each Procedure File
	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	WAVE/T testRunData = GetTestRunData()
	tcFuncCount = DimSize(testRunData, UTF_ROW)
	for(i = 0; i < tcFuncCount; i += 1)
		s.i = i

		procWin = testRunData[i][%PROCWIN]
		fullFuncName = testRunData[i][%FULLFUNCNAME]
		if(s.i > 0)
			previousProcWin = testRunData[s.i - 1][%PROCWIN]
		else
			previousProcWin = ""
		endif
		startNextTS = !!CmpStr(previousProcWin, procWin)

		if(!reentry)

			if(startNextTS)
				if(i > 0)
					s.procHooks = s.hooks
					// 3.) get local user hooks which reside in the same Module as the requested procedure
					getLocalHooks(s.procHooks, previousProcWin)
					ExecuteHooks(TEST_SUITE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, previousProcWin, previousProcWin, s.i - 1)
				endif

				if(shouldDoAbort())
					break
				endif
			endif

			s.procHooks = s.hooks
			// 3.) dito
			getLocalHooks(s.procHooks, procWin)

			if(startNextTS)
				ExecuteHooks(TEST_SUITE_BEGIN_CONST, s.procHooks, s.enableTAP, s.enableJU, procWin, procWin, s.i)
			endif

			SetExpectedFailure(str2num(testRunData[s.i][%EXPECTFAIL]))
			skip = str2num(testRunData[s.i][%SKIP])
			s.dgenIndex = 0
			s.tcSuffix = ""
			FUNCREF TEST_CASE_PROTO TestCaseFunc = $fullFuncName
			FUNCREF TEST_CASE_PROTO_MD TestCaseFuncMMD = $fullFuncName
			if(UTF_FuncRefIsAssigned(FuncRefInfo(TestCaseFunc)))
				s.mdMode = TC_MODE_NORMAL
			elseif(UTF_FuncRefIsAssigned(FuncRefInfo(TestCaseFuncMMD)))
				s.mdMode = TC_MODE_MMD
			else
				s.mdMode = TC_MODE_MD
				dgenFuncName = StringFromList(0, testRunData[s.i][%DGENLIST])
				WAVE wGenerator = dgenWaves[%$dgenFuncName]
				s.dgenSize = DimSize(wGenerator, UTF_ROW)
			endif

		endif

		do

			if(!reentry)

				if(s.mdMode == TC_MODE_MD)
					dgenFuncName = StringFromList(0, testRunData[s.i][%DGENLIST])
					WAVE wGenerator = dgenWaves[%$dgenFuncName]
					s.tcSuffix = ":" + GetDimLabel(wGenerator, UTF_ROW, s.dgenIndex)
					if(strlen(s.tcSuffix) == 1)
						s.tcSuffix = TC_SUFFIX_SEP + num2istr(s.dgenIndex)
					endif
				elseif(s.mdMode == TC_MODE_MMD)
					s.tcSuffix = GetMMDTCSuffix(i)
				endif

				ExecuteHooks(TEST_CASE_BEGIN_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i)
			else

				DFREF dfSave = $PKG_FOLDER_SAVE
				RestoreState(dfSave, s)
				// restore state done
				DFREF dfSave = $""
				ClearReentrytoUTF()
				// restore all loop counters and end loop locals
				i = s.i
				procWin = testRunData[s.i][%PROCWIN]
				fullFuncName = testRunData[s.i][%FULLFUNCNAME]
				skip = str2num(testRunData[s.i][%SKIP])

			endif

			if(!skip)

				if(GetRTError(0))
					message = GetRTErrMessage()
					err = GetRTError(1)
					sprintf msg, "Internal runtime error in UTF %d:\"%s\" before executing test case \"%s\".", err, message, fullFuncName
					UTF_Reporting#ReportErrorAndAbort(msg, setFlagOnly = 1)
				endif

				try
					CallTestCase(s, reentry)
				catch
					message = GetRTErrMessage()
					s.err = GetRTError(1)
					// clear the abort code from setAbortFlag()
					V_AbortCode = shouldDoAbort() ? 0 : V_AbortCode
					EvaluateRTE(s.err, message, V_AbortCode, fullFuncName, TEST_CASE_TYPE, procWin)

					if(shouldDoAbort() && !(s.enableTAP && UTF_TAP#TAP_IsFunctionTodo(fullFuncName)))
						// abort condition is on hold while in catch/endtry, so all cleanup must happen here
						ExecuteHooks(TEST_CASE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i, param = s.keepDataFolder)

						ExecuteHooks(TEST_SUITE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, procWin, procWin, s.i)

						ExecuteHooks(TEST_END_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param = s.debugMode)

						ClearReentrytoUTF()
						QuitOnAutoRunFull()
						return global_error_count
					endif
				endtry

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
				// check if Z_ has stored some errors
				if(s.tracingEnabled)
					TUFXOP_GetStorage/Z/Q/N="IUTF_Error" wvAllStorage
					if(!V_flag)
						variable numThreads = NumberByKey("Index", note(wvAllStorage))
						for(j = 0; j < numThreads; ++j)
							Wave/WAVE wvStorage = wvAllStorage[j]
							Wave/T data = wvStorage[0]
							UTF_Reporting#ReportError(data[0])
						endfor
					endif
				endif
#endif

			endif

			reentry = 0

			if(IsBckgRegistered())
				// save state
				NewDataFolder $PKG_FOLDER_SAVE
				DFREF dfSave = $PKG_FOLDER_SAVE
				SaveState(dfSave, s)

				return RUNTEST_RET_BCKG
			endif

			ExecuteHooks(TEST_CASE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i, param = s.keepDataFolder)

			if(shouldDoAbort())
				break
			endif

			if(s.mdMode == TC_MODE_MD)
				s.dgenIndex += 1
			elseif(s.mdMode == TC_MODE_MMD)
				s.dgenIndex = IncreaseMMDIndices(fullFuncName)
			endif

		while((s.mdMode == TC_MODE_MD && s.dgenIndex < s.dgenSize) || (s.mdMode == TC_MODE_MMD && !s.dgenIndex))

		if(shouldDoAbort())
			break
		endif

	endfor

	ExecuteHooks(TEST_SUITE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, procWin, procWin, s.i)
	ExecuteHooks(TEST_END_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param = s.debugMode)

	ClearReentrytoUTF()

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
	if(s.htmlCreation)
		UTF_Tracing#AnalyzeTracingResult()
	endif
#endif

	QuitOnAutoRunFull()

	return global_error_count
End
