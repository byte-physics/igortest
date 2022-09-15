#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.08
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

StrConstant IUTF_TRACE_REENTRY_KEYWORD = " *** REENTRY ***"

static Constant TEST_CASE_TYPE = 0x01
static Constant USER_HOOK_TYPE = 0x02

static StrConstant NO_SOURCE_PROCEDURE = "No source procedure"

static StrConstant BACKGROUNDMONTASK   = "UTFBackgroundMonitor"
static StrConstant BACKGROUNDMONFUNC   = "UTFBackgroundMonitor"
static StrConstant BACKGROUNDINFOSTR   = ":UNUSED_FOR_REENTRY:"
static Constant IP8_PRINTF_STR_MAX_LENGTH = 2400
static Constant WAVECHUNK_SIZE = 1024

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
	SetDimLabel UTF_COLUMN, 4, TAP_SKIP, wv
	SetDimLabel UTF_COLUMN, 5, EXPECTFAIL, wv

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

/// @brief Simple function to automatically increase the wave size by a chunk in the rows dimension
///        The actual (filled) wave size is not tracked, the caller has to do that.
///        Returns 1 if the wave was resized, 0 if it was not resized
static Function EnsureLargeEnoughWaveSimple(wv, indexShouldExist)

	WAVE wv
	variable indexShouldExist

	variable size = DimSize(wv, UTF_ROW)

	if(indexShouldExist < size)
		return 0
	endif

	Redimension/N=(size + WAVECHUNK_SIZE, -1, -1, -1) wv

	return 1
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

	dfref dfr = $PKG_FOLDER
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

/// Returns 1 if debug output is enabled and zero otherwise
Function EnabledDebug()
	dfref dfr = GetPackageFolder()
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
		UTF_PrintStatusMessage(str)
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

Function EvaluateResults(result, str, flags)
	variable result, flags
	string str
	
	DebugFailedAssertion(result)
	ReportResults(result, str, flags)
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
	dfref dfr = GetPackageFolder()
	variable/G dfr:global_error_count = 0
End

/// Creates the variable run_count in PKG_FOLDER
/// and initializes it to zero
static Function initRunCount()
	dfref dfr = GetPackageFolder()
	variable/G dfr:run_count = 0
End

/// Increments the run_count in PKG_FOLDER and creates it if necessary
static Function incrRunCount()
	dfref dfr = GetPackageFolder()
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
	dfref dfr = GetPackageFolder()
	variable/G dfr:error_count = 0
End

/// Increments the error_count in PKG_FOLDER and creates it if necessary
Function incrError()
	dfref dfr = GetPackageFolder()
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
	dfref dfr = GetPackageFolder()
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
	WAVE/T/SDFR=dfr messageBuffer

	size = DimSize(messageBuffer, UTF_ROW)
	Redimension/N=(size + 1, -1) messageBuffer
	messageBuffer[size][%MESSAGE] = message
	messageBuffer[size][%TYPE] = type
End

/// Increments the assert_count in PKG_FOLDER and creates it if necessary
Function incrAssert()
	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr/Z assert_count

	if(!NVAR_Exists(assert_count))
		initAssertCount()
		NVAR/SDFR=dfr assert_count
		assert_count = 0
	endif

	assert_count +=1
End

/// Adds a string to the system error log, it is reset at each test case begin
static Function UTF_ToSystemErrorStream(message)
	string message

	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr systemErr

	systemErr += message + "\r"
End

/// Prints an informative message that the test failed
/// @param prefix string to be added at the beginning
Function PrintFailInfo([prefix])
	String prefix

	string str

	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr status
	SVAR/SDFR=dfr type

	prefix = SelectString(ParamIsDefault(prefix), prefix, "")

	str = getInfo(0)
	message = prefix + status + " " + str

	UTF_PrintStatusMessage(message)
	type = "FAIL"
	UTF_ToSystemErrorStream(message)

	if(TAP_IsOutputEnabled())
		SVAR/SDFR=dfr tap_diagnostic
		tap_diagnostic = tap_diagnostic + message
	endif
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
	dfref dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 1
End

/// @brief Wrapper function result reporting
///
/// @param result Return value of a check function from `unit-testing-assertion-checks.ipf`
/// @param str    Message string
/// @param flags  Wrapper function `flags` argument
static Function ReportResults(result, str, flags)
	variable result, flags
	string str

	SetTestStatusAndDebug(str, result)

	if(!result)
		if(IsExpectedFailure())
			if(flags & OUTPUT_MESSAGE)
				printFailInfo(prefix = "Expected Failure: ")
			endif
		else
			if(flags & OUTPUT_MESSAGE)
				printFailInfo()
			endif
			if(flags & INCREASE_ERROR)
				incrError()
			endif
			if(flags & ABORT_FUNCTION)
				abortNow()
			endif
		endif
	endif
End

Function abortNow()
	setAbortFlag()
	Abort
End

/// Resets the abort flag
static Function InitAbortFlag()
	dfref dfr = GetPackageFolder()
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

/// Sets the expected_failure_flag according to if a test case is defined as expected failure
static Function InitExpectedFailure(testCase)
	string testCase

	variable err
	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr expected_failure_flag

	if(!NVAR_Exists(expected_failure_flag))
		Variable/G dfr:expected_failure_flag
		NVAR/SDFR=dfr expected_failure_flag
	endif

	expected_failure_flag = UTF_Utils#HasFunctionTag(testCase, UTF_FTAG_EXPECTED_FAILURE)
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
static Function/S getInfo(result)
	variable result
	
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr assert_count
	string caller, procedure, callStack, contents
	string text, cleanText, line, callerTestCase, tmpStr
	variable numCallers, i
	variable callerIndex = NaN
	variable testCaseIndex

	callStack = GetRTStackInfo(3)
	numCallers = ItemsInList(callStack)

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

	caller    = StringFromList(callerIndex, callStack)
	procedure = StringFromList(1, caller, ",")
	line      = StringFromList(2, caller, ",")

	if(callerIndex != testcaseIndex)
		line += " (" +  StringFromList(2, callerTestCase , ",") + ")"
	endif

	if(!IsProcGlobal())
		procedure += " [" + GetIndependentModuleName() + "]"
	endif

	contents = ProcedureText("", -1, procedure)
	text = StringFromList(str2num(line), contents, "\r")

	cleanText = trimstring(text)

	tmpStr = UTF_Utils#PrepareStringForOut(cleanText)
	sprintf text, "Assertion \"%s\" %s in line %s, procedure \"%s\"", tmpStr,  SelectString(result, "failed", "succeeded"), line, procedure
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

	Make/T/N=6/FREE info

	info[0] = FunctionInfo(hooks.testBegin)
	info[1] = FunctionInfo(hooks.testEnd)
	info[2] = FunctionInfo(hooks.testSuiteBegin)
	info[3] = FunctionInfo(hooks.testSuiteEnd)
	info[4] = FunctionInfo(hooks.testCaseBegin)
	info[5] = FunctionInfo(hooks.testCaseEnd)

	numEntries = DimSize(info, 0)
	for(i = 0; i < numEntries; i += 1)
		if(NumberByKey("N_PARAMS", info[i]) != 1 || NumberByKey("N_OPT_PARAMS", info[i]) != 0 || NumberByKey("PARAM_0_TYPE", info[i]) != 0x2000)
			sprintf msg, "The override test hook \"%s\" must accept exactly one string parameter.\r", StringByKey("NAME", info[i])
			Abort msg
		endif

		if(NumberByKey("RETURNTYPE", info[i]) != 0x4)
			sprintf msg, "The override test hook \"%s\" must return a numeric variable.\r", StringByKey("NAME", info[i])
			Abort msg
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
	UTF_PrintStatusMessage(msg)
	abortNow()
End

/// Prototypes for multi data test cases
Function TEST_CASE_PROTO_MD_VAR([var])
	variable var

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_STR([str])
	string str

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_WV([wv])
	WAVE wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_WVTEXT([wv])
	WAVE/T wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_WVDFREF([wv])
	WAVE/DF wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_WVWAVEREF([wv])
	WAVE/WAVE wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_DFR([dfr])
	DFREF dfr

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

Function TEST_CASE_PROTO_MD_CMPL([cmpl])
	variable/C cmpl

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

#if (IgorVersion() >= 7.0)

Function TEST_CASE_PROTO_MD_INT([int])
	int64 int

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

#else

Function TEST_CASE_PROTO_MD_INT([int])
	variable int

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

#endif

/// Prototype for multi data test cases data generator
Function/WAVE TEST_CASE_PROTO_DGEN()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

/// Prototype for run functions in autorun mode
Function AUTORUN_MODE_PROTO()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

/// Prototype for hook functions
Function USER_HOOK_PROTO(str)
	string str

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	UTF_PrintStatusMessage(msg)
	abortNow()
End

///@endcond // HIDDEN_SYMBOL

///@addtogroup Helpers
///@{

/// Turns debug output on
Function EnableDebugOutput()
	dfref dfr = GetPackageFolder()
	variable/G dfr:verbose = 1
End

/// Turns debug output off
Function DisableDebugOutput()
	dfref dfr = GetPackageFolder()
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

	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
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
			Abort "Unknown type"
			break
	endswitch

	type = ""
	message = ""
	if(err)
		sprintf str, "Uncaught runtime error %d:\"%s\" in %s \"%s\", procedure file \"%s\"", err, errmessage, funcTypeString, funcName, procWin
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
				sprintf str, "User aborted Test Run manually in %s \"%s\", procedure file \"%s\"", funcTypeString, funcName, procWin
				break
			case -2:
				sprintf str, "Stack Overflow in %s \"%s\", procedure file \"%s\"", funcTypeString, funcName, procWin
				break
			case -3:
				sprintf str, "Encountered \"Abort\" in %s \"%s\", procedure file \"%s\"", funcTypeString, funcName, procWin
				break
			default:
				break
		endswitch
		message += str
		if(abortCode > 0)
			sprintf str, "Encountered \"AbortOnvalue\" Code %d in %s \"%s\", procedure file \"%s\"", abortCode, funcTypeString, funcName, procWin
			message += str
		endif
	endif

	UTF_PrintStatusMessage(message)
	UTF_ToSystemErrorStream(message)
	incrError()

	CheckAbortCondition(abortCode)
	if(TAP_IsOutputEnabled())
		SVAR/SDFR=dfr tap_diagnostic
		tap_diagnostic += message + "\r"
	endif
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

	ClearBaseFilename()

	sprintf msg, "Start of test \"%s\"", name
	UTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Testrun
/// @param name   name of the test suite group
static Function TestEnd(name, debugMode)
	string name
	variable debugMode

	string msg

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr global_error_count

	if(global_error_count == 0)
		sprintf msg, "Test finished with no errors"
	else
		sprintf msg, "Test finished with %d errors", global_error_count
	endif

	UTF_PrintStatusMessage(msg)

	sprintf msg, "End of test \"%s\"", name
	UTF_PrintStatusMessage(msg)

	NVAR/SDFR=dfr igor_debug_state
	RestoreIgorDebugger(igor_debug_state)
End

/// Internal Setup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteBegin(testSuite)
	string testSuite

	string msg

	initError()
	incrRunCount()

	sprintf msg, "Entering test suite \"%s\"", testSuite
	UTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteEnd(testSuite)
	string testSuite

	string msg

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr error_count

	if(error_count == 0)
		sprintf msg, "Finished with no errors"
	else
		sprintf msg, "Failed with %d errors", error_count
	endif

	UTF_PrintStatusMessage(msg)

	NVAR/SDFR=dfr global_error_count
	global_error_count += error_count

	sprintf msg, "Leaving test suite \"%s\"", testSuite
	UTF_PrintStatusMessage(msg)
End

/// Internal Setup for Test Case
/// @param testCase name of the test case
static Function TestCaseBegin(testCase)
	string testCase

	string msg

	initAssertCount()
	initMessageBuffer()
	InitExpectedFailure(StringFromList(0, testCase, ":"))

	// create a new unique folder as working folder
	dfref dfr = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	SetDataFolder root:
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/O/S $workFolder

	string/G dfr:systemErr = ""

	sprintf msg, "Entering test case \"%s\"", testCase
	UTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Test Case
/// @param testCase name of the test case
static Function TestCaseEnd(testCase, keepDataFolder)
	string testCase
	variable keepDataFolder

	string msg

	dfref dfr = GetPackageFolder()
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

	sprintf msg, "Leaving test case \"%s\"", testCase
	UTF_PrintStatusMessage(msg)
End

/// @brief Print the given message to the Igor history area and to stdout (IP8 only)
///
/// Always use this function if you want to inform the user about something.
///
/// @param msg message to be outputted, without trailing end-of-line
static Function UTF_PrintStatusMessage(msg)
	string msg

	string tmpStr

	if(strlen(msg) == 0)
		return NaN
	endif

#if (IgorVersion() >= 9.0)
	printf "%s\r", msg
#elif  (IgorVersion() >= 8.0)
	print/LEN=2500 msg
#elif  (IgorVersion() >= 7.0)
	print/LEN=1000 msg
#elif  (IgorVersion() >= 6.0)
	print/LEN=400 msg
#endif

#if	(IgorVersion() >= 9.0)
	fprintf -1, "%s\r\n", msg
#elif (IgorVersion() >= 8.0)
	tmpStr = UTF_Utils#PrepareStringForOut(msg, maxLen = IP8_PRINTF_STR_MAX_LENGTH - 2)
	fprintf -1, "%s\r\n", tmpStr
#endif
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
		UTF_PrintStatusMessage(msg)
		Abort msg
	endif

	dgen = GetDataGeneratorFunctionName(err, dgen, procWin)
	if(err)
		sprintf msg, "Could not get full function name of data generator: %s", dgen
		UTF_PrintStatusMessage(msg)
		Abort msg
	endif

	return dgen
End

/// Checks functions signature of a test case candidate
/// and its attributed data generator function
/// Returns 1 on error, 0 on success
static Function CheckFunctionSignatureTC(procWin, fullFuncName, dgenList)
	string procWin
	string fullFuncName
	string &dgenList

	variable err, wType1, wType0, wRefSubType, dgenSize
	string dgen, msg

	dgenList = ""

	// Simple Test Cases
	FUNCREF TEST_CASE_PROTO fTC = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTC)))
		return 0
	endif
	// Multi Data Test Cases
	if(!GetFunctionSignatureTCMD(fullFuncName, wType0, wType1, wRefSubType))
		return 1
	endif

	dgen = GetDataGenFullFunctionName(procWin, fullFuncName)

	FUNCREF TEST_CASE_PROTO_DGEN fDgen = $dgen
	if(!UTF_FuncRefIsAssigned(FuncRefInfo(fDgen)))
		sprintf msg, "Data Generator function %s has wrong format. It is referenced by test case %s.", dgen, fullFuncName
		UTF_PrintStatusMessage(msg)
		Abort msg
	endif
	WAVE/Z wGenerator = fDgen()
	if(!WaveExists(wGenerator))
		sprintf msg, "Data Generator function %s returns a null wave. It is referenced by test case %s.", dgen, fullFuncName
		UTF_PrintStatusMessage(msg)
		Abort msg
	elseif(DimSize(wGenerator, 1) > 0)
		sprintf msg, "Data Generator function %s returns not a 1D wave. It is referenced by test case %s.", dgen, fullFuncName
		UTF_PrintStatusMessage(msg)
		Abort msg
	elseif(!((wType1 == IUTF_WAVETYPE1_NUM && WaveType(wGenerator, 1) == wType1 && WaveType(wGenerator) & wType0) || (wType1 != IUTF_WAVETYPE1_NUM && WaveType(wGenerator, 1) == wType1)))
		sprintf msg, "Data Generator %s functions returned wave format does not fit to expected test case parameter. It is referenced by test case %s.", dgen, fullFuncName
		UTF_PrintStatusMessage(msg)
		Abort msg
	elseif(!DimSize(wGenerator, 0))
		sprintf msg, "Data Generator function %s returns a wave with zero points. It is referenced by test case %s.", dgen, fullFuncName
		UTF_PrintStatusMessage(msg)
		return 1
	elseif(!UTF_Utils#IsNaN(wRefSubType) && wType1 == IUTF_WAVETYPE1_WREF && !UTF_Utils#HasConstantWaveTypes(wGenerator, wRefSubType))
		sprintf msg, "Test case %s expects specific wave type1 %u from the Data Generator %s. The wave type from the data generator does not fit to expected wave type.", fullFuncName, wRefSubType, dgen
		UTF_PrintStatusMessage(msg)
		Abort msg
	endif

	dgenList = AddListItem(dgen, dgenList, ";", Inf)

	WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
	if(FindDimLabel(dgenWaves, UTF_ROW, dgen) == -2)
		dgenSize = DimSize(dgenWaves, UTF_ROW)
		Redimension/N=(dgenSize + 1) dgenWaves
		dgenWaves[dgenSize] = wGenerator
		SetDimLabel UTF_ROW, dgenSize, $dgen, dgenWaves
	endif

	return 0
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
static Function CreateTestRunSetup(procWinList, matchStr, enableRegExp, errMsg)
	string procWinList
	string matchStr
	variable enableRegExp
	string &errMsg

	string procWin
	string funcName
	string funcList
	string fullFuncName, dgenList
	string testCase, testCaseMatch
	variable numTC, numpWL, numFL, numMatches
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

				if(CheckFunctionSignatureTC(procWin, fullFuncName, dgenList))
					continue
				endif

				EnsureLargeEnoughWaveSimple(testRunData, tdIndex)
				testRunData[tdIndex][%PROCWIN] = procWin
				testRunData[tdIndex][%TESTCASE] = fullFuncName
				testRunData[tdIndex][%FULLFUNCNAME] = fullFuncName
				testRunData[tdIndex][%DGENLIST] = dgenList
				testRunData[tdIndex][%TAP_SKIP] = SelectString(TAP_IsOutputEnabled(), num2istr(0), num2istr(TAP_IsFunctionSkip(fullFuncName)))
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
			UTF_PrintStatusMessage(msg)
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
				UTF_PrintStatusMessage(msg)
			endtry
		else
			procWinMatch = StringFromList(WhichListItem(procWin, allProcWindows, ";", 0, 0), allProcWindows)
		endif

		numMatches = ItemsInList(procWinMatch)
		if(numMatches <= 0)
			sprintf msg, "Error: A procedure window matching the pattern \"%s\" could not be found.", procWin
			UTF_PrintStatusMessage(msg)
			return ""
		endif

		for(j = 0; j < numMatches; j += 1)
			procWin = StringFromList(j, procWinMatch)
			if(FindListItem(procWin, procWinListOut, ";", 0, 0) == -1)
				procWinListOut = AddListItem(procWin, procWinListOut, ";", INF)
			else
				sprintf msg, "Error: The procedure window named \"%s\" is a duplicate entry in the input list of procedures.", procWin
				UTF_PrintStatusMessage(msg)
				return ""
			endif
		endfor
	endfor

	return procWinListOut
End

/// @brief Called after the test case begin user hook and before the test case function
static Function BeforeTestCase(name)
	string name

	SaveAssertionCounter()
End

/// @brief Called after the test case and before the test case end user hook
static Function AfterTestCase(name)
	string name

	string msg

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr assert_count

	sprintf msg, "Test case \"%s\" contained at least one assertion", name
	ReportResults(assert_count != GetSavedAssertionCounter(), msg, OUTPUT_MESSAGE | INCREASE_ERROR)
End

/// @brief Execute the builtin and user hooks
///
/// @param hookType One of @ref HookTypes
/// @param hooks    hooks structure
/// @param juProps  state structure for JUnit output
/// @param name     name of the test run/suite/case
/// @param procWin  name of the procedure window
/// @param param    parameter for the builtin hooks
///
/// Catches runtime errors in the user hooks as well.
/// Takes care of correct bracketing of user and builtin functions as well. For
/// `begin` functions the order is builtin/user and for `end` functions user/builtin.
static Function ExecuteHooks(hookType, hooks, juProps, name, procWin, [param])
	variable hookType
	Struct TestHooks& hooks
	Struct JU_Props& juProps
	string name, procWin
	variable param

	variable err
	string errorMessage, hookName

	try
		ClearRTError()
		switch(hookType)
			case TEST_BEGIN_CONST:
				AbortOnValue ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testBegin

				JU_TestBegin(juProps)
				TestBegin(name, param)
				userHook(name); AbortOnRTE
				break
			case TEST_SUITE_BEGIN_CONST:
				AbortOnValue !ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testSuiteBegin

				JU_TestSuiteBegin(juProps, name, procWin)
				TestSuiteBegin(name)
				userHook(name); AbortOnRTE
				break
			case TEST_CASE_BEGIN_CONST:
				AbortOnValue !ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseBegin

				TAP_TestCaseBegin(name)
				JU_TestCaseBegin(juProps, name, procWin)
				TestCaseBegin(name)
				userHook(name); AbortOnRTE
				BeforeTestCase(name)
				break
			case TEST_CASE_END_CONST:
				AbortOnValue ParamIsDefault(param), 1

				AfterTestCase(name)
				FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseEnd

				userHook(name); AbortOnRTE
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
				Abort "Unknown hookType"
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
			TestCaseEnd(name, param)
			JU_TestCaseEnd(juProps, name, procWin)
			TAP_TestCaseEnd()
			break
		case TEST_SUITE_END_CONST:
			TestSuiteEnd(name)
			JU_TestSuiteEnd(juProps)
			break
		case TEST_END_CONST:
			TestEnd(name, param)
			JU_WriteOutput(juProps)
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
		print "Fatal: UTFBackgroundMonitor can not find monitoring data in package DF, aborting monitoring."
		ClearReentrytoUTF()
		QuitOnAutoRunFull()
		return 2
	endif

	if(mode == BACKGROUNDMONMODE_OR)
		result = 0
	elseif(mode == BACKGROUNDMONMODE_AND)
		result = 1
	else
		print "Fatal: Unknown mode set for background monitor"
		ClearReentrytoUTF()
		QuitOnAutoRunFull()
		return 2
	endif

	if(timeout && datetime > timeout)
		print "UTF background monitor has reached the timeout for reentry"

		if(failOnTimeout)
			incrError()
		endif

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
	variable/G dfr:StcCount = s.tcCount

	string/G dfr:SprocWin = s.procWin
	string/G dfr:StestCaseList = s.testCaseList
	string/G dfr:SallTestCasesList = s.allTestCasesList
	string/G dfr:SfullFuncName = s.fullFuncName
	variable/G dfr:Stap_skipCase = s.tap_skipCase
	variable/G dfr:Stap_caseCount = s.tap_caseCount
	variable/G dfr:SenableRegExpTC = s.enableRegExpTC
	variable/G dfr:SenableRegExpTS = s.enableRegExpTS
	variable/G dfr:SdgenIndex = s.dgenIndex
	variable/G dfr:SdgenSize = s.dgenSize
	variable/G dfr:SmdMode = s.mdMode
	variable/G dfr:StracingEnabled = s.tracingEnabled
	variable/G dfr:ShtmlCreation = s.htmlCreation
	string/G dfr:StcSuffix = s.tcSuffix
	string/G dfr:SdgenFuncName = s.dgenFuncName

	variable/G dfr:Si = s.i
	variable/G dfr:Sj = s.j
	variable/G dfr:Serr = s.err
	StoreHooks(dfr, s.hooks, "TH")
	StoreHooks(dfr, s.procHooks, "PH")

	variable/G dfr:SJUPenableJU = s.juProps.enableJU

	string/G dfr:SJUPSPpropNameList = s.juProps.juTSProp.propNameList
	string/G dfr:SJUPSPpropValueList = s.juProps.juTSProp.propValueList

	string/G dfr:SJUPTCname = s.juProps.juTC.name
	string/G dfr:SJUPTCclassName = s.juProps.juTC.className
	variable/G dfr:SJUPTCtimeTaken = s.juProps.juTC.timeTaken
	variable/G dfr:SJUPTCassertions = s.juProps.juTC.assertions
	string/G dfr:SJUPTCstatus = s.juProps.juTC.status
	string/G dfr:SJUPTCmessage = s.juProps.juTC.message
	string/G dfr:SJUPTCtype = s.juProps.juTC.type
	string/G dfr:SJUPTCsystemErr = s.juProps.juTC.systemErr
	string/G dfr:SJUPTCsystemOut = s.juProps.juTC.systemOut
	variable/G dfr:SJUPTCtimeStart = s.juProps.juTC.timeStart
	variable/G dfr:SJUPTCerror_count = s.juProps.juTC.error_count
	string/G dfr:SJUPTChistory = s.juProps.juTC.history
	variable/G dfr:SJUPTCtestResult = s.juProps.juTC.testResult

	string/G dfr:SJUPTSpackage = s.juProps.juTS.package
	variable/G dfr:SJUPTSid = s.juProps.juTS.id
	string/G dfr:SJUPTSname = s.juProps.juTS.name
	string/G dfr:SJUPTStimestamp = s.juProps.juTS.timestamp
	string/G dfr:SJUPTShostname = s.juProps.juTS.hostname
	variable/G dfr:SJUPTStests = s.juProps.juTS.tests
	variable/G dfr:SJUPTSfailures = s.juProps.juTS.failures
	variable/G dfr:SJUPTSerrors = s.juProps.juTS.errors
	variable/G dfr:SJUPTSskipped = s.juProps.juTS.skipped
	variable/G dfr:SJUPTStimeTaken = s.juProps.juTS.timeTaken
	string/G dfr:SJUPTSsystemErr = s.juProps.juTS.systemErr
	string/G dfr:SJUPTSsystemOut = s.juProps.juTS.systemOut
	variable/G dfr:SJUPTStimeStart = s.juProps.juTS.timeStart

	variable/G dfr:SJUPtestCaseCount = s.juProps.testCaseCount
	variable/G dfr:SJUPtestSuiteNumber = s.juProps.testSuiteNumber
	string/G dfr:SJUPtestSuiteOut = s.juProps.testSuiteOut
	string/G dfr:SJUPtestCaseListOut = s.juProps.testCaseListOut
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
	NVAR var = dfr:StcCount
	s.tcCount = var
	SVAR str = dfr:SprocWin
	s.procWin = str
	SVAR str = dfr:StestCaseList
	s.testCaseList = str
	SVAR str = dfr:SallTestCasesList
	s.allTestCasesList = str
	SVAR str = dfr:SfullFuncName
	s.fullFuncName = str
	NVAR var = dfr:Stap_skipCase
	s.tap_skipCase = var
	NVAR var = dfr:Stap_caseCount
	s.tap_caseCount = var
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
	SVAR str = dfr:SdgenFuncName
	s.dgenFuncName = str

	NVAR var = dfr:Si
	s.i = var
	NVAR var = dfr:Sj
	s.j = var
	NVAR var = dfr:Serr
	s.err = var

	RestoreHooks(dfr, s.hooks, "TH")
	RestoreHooks(dfr, s.procHooks, "PH")

	NVAR var = dfr:SJUPenableJU
	s.juProps.enableJU = var

	SVAR str = dfr:SJUPSPpropNameList
	s.juProps.juTSProp.propNameList = str
	SVAR str = dfr:SJUPSPpropValueList
	s.juProps.juTSProp.propValueList = str

	SVAR str = dfr:SJUPTCname
	s.juProps.juTC.name = str
	SVAR str = dfr:SJUPTCclassName
	s.juProps.juTC.className = str
	NVAR var = dfr:SJUPTCtimeTaken
	s.juProps.juTC.timeTaken = var
	NVAR var = dfr:SJUPTCassertions
	s.juProps.juTC.assertions = var
	SVAR str = dfr:SJUPTCstatus
	s.juProps.juTC.status = str
	SVAR str = dfr:SJUPTCmessage
	s.juProps.juTC.message = str
	SVAR str = dfr:SJUPTCtype
	s.juProps.juTC.type = str
	SVAR str = dfr:SJUPTCsystemErr
	s.juProps.juTC.systemErr = str
	SVAR str = dfr:SJUPTCsystemOut
	s.juProps.juTC.systemOut = str
	NVAR var = dfr:SJUPTCtimeStart
	s.juProps.juTC.timeStart = var
	NVAR var = dfr:SJUPTCerror_count
	s.juProps.juTC.error_count = var
	SVAR str = dfr:SJUPTChistory
	s.juProps.juTC.history = str
	NVAR var = dfr:SJUPTCtestResult
	s.juProps.juTC.testResult = var

	SVAR str = dfr:SJUPTSpackage
	s.juProps.juTS.package = str
	NVAR var = dfr:SJUPTSid
	s.juProps.juTS.id = var
	SVAR str = dfr:SJUPTSname
	s.juProps.juTS.name = str
	SVAR str = dfr:SJUPTStimestamp
	s.juProps.juTS.timestamp = str
	SVAR str = dfr:SJUPTShostname
	s.juProps.juTS.hostname = str
	NVAR var = dfr:SJUPTStests
	s.juProps.juTS.tests = var
	NVAR var = dfr:SJUPTSfailures
	s.juProps.juTS.failures = var
	NVAR var = dfr:SJUPTSerrors
	s.juProps.juTS.errors = var
	NVAR var = dfr:SJUPTSskipped
	s.juProps.juTS.skipped = var
	NVAR var = dfr:SJUPTStimeTaken
	s.juProps.juTS.timeTaken = var
	SVAR str = dfr:SJUPTSsystemErr
	s.juProps.juTS.systemErr = str
	SVAR str = dfr:SJUPTSsystemOut
	s.juProps.juTS.systemOut = str
	NVAR var = dfr:SJUPTStimeStart
	s.juProps.juTS.timeStart = var

	NVAR var = dfr:SJUPtestCaseCount
	s.juProps.testCaseCount = var
	NVAR var = dfr:SJUPtestSuiteNumber
	s.juProps.testSuiteNumber = var
	SVAR str = dfr:SJUPtestSuiteOut
	s.juProps.testSuiteOut = str
	SVAR str = dfr:SJUPtestCaseListOut
	s.juProps.testCaseListOut = str
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

static Function CallTestCase(tcIndex, reentry, mdMode, dgenIndex)
	variable tcIndex
	variable reentry
	variable mdMode
	variable dgenIndex

	variable wType0, wType1, wRefSubType, err
	string func, msg, dgenFuncName

	WAVE/T testRunData = GetTestRunData()

	if(reentry)
		DFREF dfr = GetPackageFolder()
		SVAR reentryFuncName = dfr:BCKG_ReentryFunc
		func = reentryFuncName
		sprintf msg, "Entering reentry \"%s\"", func
		UTF_PrintStatusMessage(msg)
	else
		func = testRunData[tcIndex][%FULLFUNCNAME]
	endif

	FUNCREF TEST_CASE_PROTO TestCaseFunc = $func
	if((mdMode && !reentry) || (mdMode && reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(TestCaseFunc))))

		WAVE/WAVE dgenWaves = GetDataGeneratorWaves()
		dgenFuncName = StringFromList(0, testRunData[tcIndex][%DGENLIST])
		WAVE wGenerator = dgenWaves[%$dgenFuncName]
		wType0 = WaveType(wGenerator)
		wType1 = WaveType(wGenerator, 1)
		if(wType1 == IUTF_WAVETYPE1_NUM)
			if(wType0 & IUTF_WAVETYPE0_CMPL)

				FUNCREF TEST_CASE_PROTO_MD_CMPL fTCMD_CMPL = $func
				if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_CMPL)))
					sprintf msg, "Fatal: Reentry function %s does not meet required format for Complex argument.", func
					UTF_PrintStatusMessage(msg)
					incrError()
					abortNow()
				endif
				fTCMD_CMPL(cmpl=wGenerator[dgenIndex]); AbortOnRTE

			elseif(wType0 & IUTF_WAVETYPE0_INT64)

				FUNCREF TEST_CASE_PROTO_MD_INT fTCMD_INT = $func
				if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_INT)))
					sprintf msg, "Fatal: Reentry function %s does not meet required format for INT64 argument.", func
					UTF_PrintStatusMessage(msg)
					incrError()
					abortNow()
				endif
				fTCMD_INT(int=wGenerator[dgenIndex]); AbortOnRTE

			else

				FUNCREF TEST_CASE_PROTO_MD_VAR fTCMD_VAR = $func
				if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_VAR)))
					sprintf msg, "Fatal: Reentry function %s does not meet required format for numeric argument.", func
					UTF_PrintStatusMessage(msg)
					incrError()
					abortNow()
				endif
				fTCMD_VAR(var=wGenerator[dgenIndex]); AbortOnRTE

			endif
		elseif(wType1 == IUTF_WAVETYPE1_TEXT)

			WAVE/T wGeneratorStr = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_STR fTCMD_STR = $func
			if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_STR)))
				sprintf msg, "Fatal: Reentry function %s does not meet required format for string argument.", func
				UTF_PrintStatusMessage(msg)
				incrError()
				abortNow()
			endif
			fTCMD_STR(str=wGeneratorStr[dgenIndex]); AbortOnRTE

		elseif(wType1 == IUTF_WAVETYPE1_DFR)

			WAVE/DF wGeneratorDF = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_DFR fTCMD_DFR = $func
			if(reentry && !UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_DFR)))
				sprintf msg, "Fatal: Reentry function %s does not meet required format for data folder reference argument.", func
				UTF_PrintStatusMessage(msg)
				incrError()
				abortNow()
			endif
			fTCMD_DFR(dfr=wGeneratorDF[dgenIndex]); AbortOnRTE

		elseif(wType1 == IUTF_WAVETYPE1_WREF)

			WAVE/WAVE wGeneratorWV = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_WV fTCMD_WV = $func
			if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WV)))
				fTCMD_WV(wv=wGeneratorWV[dgenIndex]); AbortOnRTE
			else
				wRefSubType = WaveType(wGeneratorWV[dgenIndex], 1)
				if(wRefSubType == IUTF_WAVETYPE1_TEXT)
					FUNCREF TEST_CASE_PROTO_MD_WVTEXT fTCMD_WVTEXT = $func
					if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVTEXT)))
						fTCMD_WVTEXT(wv=wGeneratorWV[dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				elseif(wRefSubType == IUTF_WAVETYPE1_DFR)
					FUNCREF TEST_CASE_PROTO_MD_WVDFREF fTCMD_WVDFREF = $func
					if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVDFREF)))
						fTCMD_WVDFREF(wv=wGeneratorWV[dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				elseif(wRefSubType == IUTF_WAVETYPE1_WREF)
					FUNCREF TEST_CASE_PROTO_MD_WVWAVEREF fTCMD_WVWAVEREF = $func
					if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVWAVEREF)))
						fTCMD_WVWAVEREF(wv=wGeneratorWV[dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				else
					sprintf msg, "Fatal: Got wave reference wave from Data Generator %s with waves of unsupported type for reentry of test case %s.", dgenFuncName, func
					UTF_PrintStatusMessage(msg)
					incrError()
					abortNow()
				endif
				if(err)
					sprintf msg, "Fatal: Reentry function %s does not meet required format for wave reference argument from data generator %s.", func, dgenFuncName
					UTF_PrintStatusMessage(msg)
					incrError()
					abortNow()
				endif
			endif

		endif
	else
		TestCaseFunc(); AbortOnRTE
	endif

End

/// @brief initialize all strings in strRunTest structure to be non <null>
static Function InitStrRunTest(s)
	STRUCT strRunTest &s

	s.procWinList = ""
	s.name = ""
	s.testCase = ""

	s.procWin = ""
	s.testCaseList = ""
	s.allTestCasesList = ""
	s.fullFuncName = ""
	s.tcSuffix = ""
	s.dgenFuncName = ""
	s.tcCount = 0

	InitJUProp(s.juProps)
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
	variable tcCount

	string procWin
	string testCaseList
	string allTestCasesList
	string fullFuncName
	variable tap_skipCase
	variable tap_caseCount
	variable enableRegExpTC
	variable enableRegExpTS
	variable dgenIndex
	variable dgenSize
	variable mdMode
	variable tracingEnabled
	variable htmlCreation
	string tcSuffix
	string dgenFuncName
	STRUCT JU_Props juProps
	STRUCT TestHooks hooks
	STRUCT TestHooks procHooks
	variable i
	variable j
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
		print "Tasklist is empty."
		incrError()
		Abort
	endif

	if(!(mode == BACKGROUNDMONMODE_OR || mode == BACKGROUNDMONMODE_AND))
		print "Unknown mode set"
		incrError()
		Abort
	endif

	if(FindListItem(BACKGROUNDMONTASK, taskList) != -1)
		print "Igor Unit Testing framework will not monitor its own monitoring task (" + BACKGROUNDMONTASK + ")."
		incrError()
		Abort
	endif

	// check valid reentry function
	if(GrepString(reentryFunc, PROCNAME_NOT_REENTRY))
		print "Name of Reentry function must end with _REENTRY"
		incrError()
		Abort
	endif
	FUNCREF TEST_CASE_PROTO rFuncRef = $reentryFunc
	if(!UTF_FuncRefIsAssigned(FuncRefInfo(rFuncRef)))
		if(!GetFunctionSignatureTCMD(reentryFunc, tmpVar, tmpVar, tmpVar))
			print "Specified reentry procedure has wrong format. The format must be function_REENTRY() or for multi data function_REENTRY([type])."
			incrError()
			Abort
		endif
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
	KillWaves testRunData, dgenWaves, ftagWaves
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
///
/// @param   enableTAP      (optional) default disabled, enabled when set to 1: @n
///                         A TAP compatible file is written at the end of the test run.
///                         @verbatim embed:rst:leading-slashes
///                             `Test Anything Protocol (TAP) <https://testanything.org>`__
///                             `standard 13 <https://testanything.org/tap-version-13-specification.html>`__
///                         @endverbatim
///                         Can not be combined with enableJU.
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
///
/// @param   traceOptions   (optional) default ""
///                         A key:value pair list of additional tracing options. Currently supported is:
///                         INSTRUMENTONLY:boolean When set, run instrumentation only and return. No tests are executed.
///                         HTMLCREATION:boolean When set to zero, no htm result files are created at the end of the run
///                         REGEXP:boolean When set, traceWinList is interpreted as regular expression
///
/// @return                 total number of errors
Function RunTest(procWinList, [name, testCase, enableJU, enableTAP, enableRegExp, allowDebug, debugMode, keepDataFolder, traceWinList, traceOptions])
	string procWinList, name, testCase
	variable enableJU, enableTAP, enableRegExp
	variable allowDebug, debugMode, keepDataFolder
	string traceWinList, traceOptions

	// All variables that are needed to keep the local function state are wrapped in s
	// new var/str must be added to strRunTest and added in SaveState/RestoreState functions
	STRUCT strRunTest s
	InitStrRunTest(s)

	DFREF dfr = GetPackageFolder()

	// do not save these for reentry
	//
	variable reentry
	// these use a very local scope where used
	// loop counter and loop end derived vars
	variable i, tcFuncCount, startNextTS, tap_skipCase
	string procWin, fullFuncName, previousProcWin, dgenFuncName
	// used as temporal locals
	variable var, err
	string msg, errMsg

	reentry = IsBckgRegistered()
	ResetBckgRegistered()
	if(reentry)

		// check also if a saved state is existing
		if(!DataFolderExists(PKG_FOLDER_SAVE))
			print "No saved test state found, aborting. (Did you RegisterUTFMonitor in an End Hook?)"
			Abort
		endif
	  // check if the reentry call originates from our own background monitor
		if(CmpStr(GetRTStackInfo(2), BACKGROUNDMONFUNC))
			ClearReentrytoUTF()
			print "RunTest was called by user after background monitoring was registered. This is not supported."
			Abort
		endif

	else

		PathInfo home
		if(!V_flag)
			sprintf msg, "Error: Please Save experiment first."
			UTF_PrintStatusMessage(msg)
			return NaN
		endif

		allowDebug = ParamIsDefault(allowDebug) ? 0 : !!allowDebug

		// transfer parameters to s. variables
		s.enableRegExp = enableRegExp
		s.enableRegExpTC = ParamIsDefault(enableRegExp) ? 0 : !!enableRegExp
		s.enableRegExpTS = s.enableRegExpTC
		s.juProps.enableJU = ParamIsDefault(enableJU) ? 0 : !!enableJU
		s.enableTAP = ParamIsDefault(enableTAP) ? 0 : !!enableTAP
		s.debugMode = ParamIsDefault(debugMode) ? 0 : debugMode
		s.keepDataFolder = ParamIsDefault(keepDataFolder) ? 0 : !!keepDataFolder

		s.tracingEnabled = !ParamIsDefault(traceWinList) && !UTF_Utils#IsEmpty(traceWinList)

		if(s.enableTAP && s.juProps.enableJU)
			sprintf msg, "Error: enableTAP and enableJU can not be both true."
			UTF_PrintStatusMessage(msg)
			return NaN
		endif

		var = IUTF_DEBUG_ENABLE | IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE | IUTF_DEBUG_FAILED_ASSERTION
		if(s.debugMode > var || s.debugMode < 0 || !UTF_Utils#IsInteger(s.debugMode))
			printf "debugMode can only be an integer between 0 and %d. The input %g is wrong, aborting!.\r", var, s.debugMode
			printf "Use the constants IUTF_DEBUG_ENABLE, IUTF_DEBUG_ON_ERROR,\r"
			printf "IUTF_DEBUG_NVAR_SVAR_WAVE and IUTF_DEBUG_FAILED_ASSERTION for debugMode.\r\r"
			printf "Example: debugMode = IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE\r"
			Abort
		endif

		if(s.debugMode > 0 && allowDebug > 0)
			print "Note: debugMode parameter is set, allowDebug parameter is ignored."
		endif
		if(s.debugMode == 0 && allowDebug > 0)
			s.debugMode = GetCurrentDebuggerState()
		endif

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
				UTF_Tracing#SetupTracing(traceWinList, traceOptions)
				return NaN
			endif
#else
			printf "Tracing requires Igor Pro 9 Build 38812 (or later) and the Thread Utilities XOP.\r"
			Abort
#endif
		else
#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
			TUFXOP_Init/N="IUTF_Testrun"
#endif
		endif

		ClearTestSetupWaves()

		// below here use only s. variables to keep local state in struct
		ClearBaseFilename()
		CreateHistoryLog()

		s.procWinList = AdaptProcWinList(s.procWinList, s.enableRegExpTS)
		s.procWinList = FindProcedures(s.procWinList, s.enableRegExpTS)

		if(ItemsInList(s.procWinList) <= 0)
			sprintf msg, "Error: The list of procedure windows is empty or invalid."
			UTF_PrintStatusMessage(msg)
			return NaN
		endif

		err = CreateTestRunSetup(s.procWinList, s.testCase, s.enableRegExpTC, errMsg)
		s.tcCount = GetTestCaseCount()

		if(err != TC_MATCH_OK)
			if(err == TC_LIST_EMPTY)
				errMsg = s.procWinList
				errMsg = UTF_Utils#PrepareStringForOut(errMsg)
				sprintf msg, "Error: A test case matching the pattern \"%s\" could not be found in test suite(s) \"%s\".", s.testcase, errMsg
				UTF_PrintStatusMessage(msg)
				return NaN
			endif

			errMsg = UTF_Utils#PrepareStringForOut(errMsg)
			sprintf msg, "Error %d in CreateTestRunSetup: %s", err, errMsg
			UTF_PrintStatusMessage(msg)
			return NaN
		endif

		// 1.) set the hooks to the default implementations
		setDefaultHooks(s.hooks)
		// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
		getGlobalHooks(s.hooks)

		// Reinitializes
		ExecuteHooks(TEST_BEGIN_CONST, s.hooks, s.juProps, s.name, NO_SOURCE_PROCEDURE, param=s.debugMode)

		// TAP Handling, find out if all should be skipped and number of all test cases
		if(s.enableTAP)
			TAP_EnableOutput()
			TAP_CreateFile()

			if(TAP_AreAllFunctionsSkip())
				TAP_WriteOutputIfReq("1..0 All test cases marked SKIP")
				ExecuteHooks(TEST_END_CONST, s.hooks, s.juProps, s.name, NO_SOURCE_PROCEDURE, param=s.debugMode)
				Abort
			else
				TAP_WriteOutputIfReq("1.." + num2str(s.tcCount))
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
					ExecuteHooks(TEST_SUITE_END_CONST, s.procHooks, s.juProps, previousProcWin, previousProcWin)
				endif

				if(shouldDoAbort())
					break
				endif
			endif

			s.procHooks = s.hooks
			// 3.) dito
			getLocalHooks(s.procHooks, procWin)

			if(startNextTS)
				s.juProps.testCaseCount = GetTestCaseCount(procWin=procWin)
				ExecuteHooks(TEST_SUITE_BEGIN_CONST, s.procHooks, s.juProps, procWin, procWin)
				s.juProps.testSuiteNumber += 1
			endif

			// get Description and Directive of current Function for TAP
			tap_skipCase = str2num(testRunData[i][%TAP_SKIP])
			s.dgenIndex = 0
			s.tcSuffix = ""
		endif

		do

			if(!reentry)

				FUNCREF TEST_CASE_PROTO TestCaseFunc = $fullFuncName
				if(UTF_FuncRefIsAssigned(FuncRefInfo(TestCaseFunc)))
					s.mdMode = 0
				else
					s.mdMode = 1
					dgenFuncName = StringFromList(0, testRunData[i][%DGENLIST])
					WAVE wGenerator = dgenWaves[%$dgenFuncName]
					s.dgenSize = DimSize(wGenerator, UTF_ROW)
					s.tcSuffix = ":" + GetDimLabel(wGenerator, UTF_ROW, s.dgenIndex)
					if(strlen(s.tcSuffix) == 1)
						s.tcSuffix = ":" + num2istr(s.dgenIndex)
					endif
				endif
				if(!tap_skipCase)
					ExecuteHooks(TEST_CASE_BEGIN_CONST, s.procHooks, s.juProps, fullFuncName + s.tcSuffix, procWin)
				endif
			else

				DFREF dfSave = $PKG_FOLDER_SAVE
				RestoreState(dfSave, s)
				// restore state done
				DFREF dfSave = $""
				ClearReentrytoUTF()
				// restore all loop counters and end loop locals
				i = s.i
				procWin = testRunData[i][%PROCWIN]
				fullFuncName = testRunData[i][%FULLFUNCNAME]
				tap_skipCase = str2num(testRunData[i][%TAP_SKIP])

			endif

			if(!tap_skipCase)

				try
					ClearRTError()
					CallTestCase(i, reentry, s.mdMode, s.dgenIndex)
				catch
					message = GetRTErrMessage()
					s.err = GetRTError(1)
					// clear the abort code from abortNow()
					V_AbortCode = shouldDoAbort() ? 0 : V_AbortCode
					EvaluateRTE(s.err, message, V_AbortCode, fullFuncName, TEST_CASE_TYPE, procWin)

					if(shouldDoAbort() && !(TAP_IsOutputEnabled() && TAP_IsFunctionTodo_Fast()))
						// abort condition is on hold while in catch/endtry, so all cleanup must happen here
						ExecuteHooks(TEST_CASE_END_CONST, s.procHooks, s.juProps, fullFuncName + s.tcSuffix, procWin, param = s.keepDataFolder)

						ExecuteHooks(TEST_SUITE_END_CONST, s.procHooks, s.juProps, procWin, procWin)

						ExecuteHooks(TEST_END_CONST, s.hooks, s.juProps, s.name, NO_SOURCE_PROCEDURE, param = s.debugMode)

						ClearReentrytoUTF()
						QuitOnAutoRunFull()
						return global_error_count
					endif
				endtry

			endif

			reentry = 0

			if(IsBckgRegistered())
				// save state
				NewDataFolder $PKG_FOLDER_SAVE
				DFREF dfSave = $PKG_FOLDER_SAVE
				SaveState(dfSave, s)

				return RUNTEST_RET_BCKG
			endif

			if(!tap_skipCase)
				ExecuteHooks(TEST_CASE_END_CONST, s.procHooks, s.juProps, fullFuncName + s.tcSuffix, procWin, param = s.keepDataFolder)
			endif

			if(shouldDoAbort())
				break
			endif

			TAP_WriteCaseIfReq(s.i + 1, tap_skipCase)

			s.dgenIndex += 1

		while(s.mdMode && s.dgenIndex < s.dgenSize)

		if(shouldDoAbort())
			break
		endif

	endfor

	ExecuteHooks(TEST_SUITE_END_CONST, s.procHooks, s.juProps, procWin, procWin)
	ExecuteHooks(TEST_END_CONST, s.hooks, s.juProps, s.name, NO_SOURCE_PROCEDURE, param = s.debugMode)

	ClearReentrytoUTF()

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
	if(s.htmlCreation)
		UTF_Tracing#AnalyzeTracingResult()
	endif
#endif

	QuitOnAutoRunFull()

	return global_error_count
End
