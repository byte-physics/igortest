#pragma rtGlobals=3
#pragma version=1.06
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt

///@cond HIDDEN_SYMBOL

static Constant FFNAME_OK        = 0x00
static Constant FFNAME_NOT_FOUND = 0x01
static Constant FFNAME_NO_MODULE = 0x02

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

static Constant TEST_CASE_TYPE = 0x01
static Constant USER_HOOK_TYPE = 0x02

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

	sprintf str, "%s: is %s\r", str, SelectString(booleanValue, "false", "true")
	if(EnabledDebug())
		printf "%s", str
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

/// Disable the Igor Pro Debugger and return its state prior to deactivation
static Function DisableIgorDebugger()

	variable debuggerState

	DebuggerOptions
	debuggerState = V_enable

	DebuggerOptions enable=0

	return debuggerState
End

/// Restore the Igor Pro Debugger to its prior state
static Function RestoreIgorDebugger(debuggerState)
	variable debuggerState

	DebuggerOptions enable=debuggerState
End

/// Create the variable igorDebugState in PKG_FOLDER
/// and initialize it to zero
static Function InitIgorDebugState()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:igor_debug_state = 0
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

	error_count +=1
End

/// Creates the variable assert_count in PKG_FOLDER
/// and initializes it to zero
static Function initAssertCount()
	dfref dfr = GetPackageFolder()
	variable/G dfr:assert_count = 0
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

/// Prints an informative message that the test failed
Function printFailInfo()
	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr status
	SVAR/SDFR=dfr type
	SVAR/SDFR=dfr systemErr

	sprintf message, "%s  %s", status, getInfo(0)

	print message
	type = "FAIL"
	systemErr = message

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


Function abortNow()
	setAbortFlag()
	Abort
End

/// Resets the abort flag
static Function InitAbortFlag()
	dfref dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 0
End

/// Return true if running in `ProcGlobal`, false otherwise
static Function IsProcGlobal()

	return !cmpstr("ProcGlobal", GetIndependentModuleName())
End

/// Prints an informative message about the test's success or failure
// 0 failed, 1 succeeded
static Function/S getInfo(result)
	variable result

	string caller, procedure, callStack, contents
	string text, cleanText, line
	variable numCallers, i
	variable callerIndex = NaN

	callStack = GetRTStackInfo(3)
	numCallers = ItemsInList(callStack)

	// traverse the callstack from bottom up,
	// the first function not in one of the unit testing procedures is
	// the one we want to report.
	for(i = numCallers - 1; i >= 0; i -= 1)
		caller    = StringFromList(i, callStack)
		procedure = StringFromList(1, caller, ",")

		if(StringMatch(procedure, "unit-testing*"))
			continue
		else
			callerIndex = i
			break
		endif

	endfor

	if(numtype(callerIndex) != 0)
		return "Assertion failed in unknown location"
	endif

	caller    = StringFromList(callerIndex, callStack)
	procedure = StringFromList(1, caller, ",")
	line      = StringFromList(2, caller, ",")

	if(!IsProcGlobal())
		procedure += " [" + GetIndependentModuleName() + "]"
	endif

	contents = ProcedureText("", -1, procedure)
	text = StringFromList(str2num(line), contents, "\r")

	cleanText = trimstring(text)

	sprintf text, "Assertion \"%s\" %s in line %s, procedure \"%s\"\r", cleanText,  SelectString(result, "failed", "succeeded"), line, procedure
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

/// Returns the full name of a function including its module
/// @param   &err	returns 0 for no error, 1 if function not found, 2 is static function in proc without ModuleName
static Function/S getFullFunctionName(err, funcName, procName)
	variable &err
	string funcName, procName

	err = FFNAME_OK
	string infoStr = FunctionInfo(funcName, procName)
	string errMsg

	if(strlen(infoStr) <= 0)
		sprintf errMsg, "Function %s in procedure file %s is unknown\r", funcName, procName
		err = FFNAME_NOT_FOUND
		return errMsg
	endif

	string module = StringByKey("MODULE", infoStr)

	if(strlen(module) <= 0)

		// we can only use static functions if they live in a module
		if(cmpstr(StringByKey("SPECIAL", infoStr), "static") == 0)
			sprintf errMsg, "The procedure file %s is missing a \"#pragma ModuleName=myName\" declaration.\r", procName
			err = FFNAME_NO_MODULE
			return errMsg
		endif

		return funcName
	endif

	// even if we are running in an independent module we don't need its name prepended as we
	// 1.) run in the same IM anyway
	// 2.) FuncRef does not accept that

	return module + "#" + funcName
End

/// Prototype for test cases
Function TEST_CASE_PROTO()
End

/// Prototype for run functions in autorun mode
Function AUTORUN_MODE_PROTO()
End

/// Prototype for hook functions
Function USER_HOOK_PROTO(str)
	string str
End

///@endcond // HIDDEN_SYMBOL

///@addtogroup TestRunnerAndHelper
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
	SVAR/SDFR=dfr systemErr
	SVAR/SDFR=dfr type
	string str, funcTypeString

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
		sprintf str, "Uncaught runtime error %d:\"%s\" in %s \"%s\", procedure file \"%s\"\r", err, errmessage, funcTypeString, funcName, procWin
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
				sprintf str, "User aborted Test Run manually in %s \"%s\", procedure file \"%s\"\r", funcTypeString, funcName, procWin
				break
			case -2:
				sprintf str, "Stack Overflow in %s \"%s\", procedure file \"%s\"\r", funcTypeString, funcName, procWin
				break
			case -3:
				sprintf str, "Encountered \"Abort\" in %s \"%s\", procedure file \"%s\"\r", funcTypeString, funcName, procWin
				break
			default:
				break
		endswitch
		message += str
		if(abortCode > 0)
			sprintf str, "Encountered \"AbortOnvalue\" Code %d in %s \"%s\", procedure file \"%s\"\r", abortCode, funcTypeString, funcName, procWin
			message += str
		endif
	endif

	printf message
	systemErr = message

	CheckAbortCondition(abortCode)
	if(TAP_IsOutputEnabled())
		SVAR/SDFR=dfr tap_diagnostic
		tap_diagnostic += message
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
static Function TestBegin(name, allowDebug)
	string name
	variable allowDebug

	variable reEnableDebugOutput, runCountStored

	// remember some state variables
	if(DataFolderExists(PKG_FOLDER))
		reEnableDebugOutput = EnabledDebug()

		DFREF dfr = GetPackageFolder()
		NVAR/SDFR=dfr/Z run_count

		// existing experiments don't have run_count
		if(NVAR_Exists(run_count))
			runCountStored = run_count
		endif
	endif

	KillDataFolder/Z $PKG_FOLDER

	initGlobalError()
	initRunCount()
	InitAbortFlag()
	initTestStatus()

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr run_count
	run_count = runCountStored

	if(reEnableDebugOutput)
		EnableDebugOutput()
	endif

	if(!allowDebug)
		initIgorDebugState()
		NVAR/SDFR=dfr igor_debug_state
		igor_debug_state = DisableIgorDebugger()
	endif

	string/G dfr:message = ""
	string/G dfr:type = "0"
	string/G dfr:systemErr = ""

	ClearBaseFilename()

	printf "Start of test \"%s\"\r", name
End

/// Internal Cleanup for Testrun
/// @param name   name of the test suite group
static Function TestEnd(name, allowDebug)
	string name
	variable allowDebug

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr global_error_count

	if(global_error_count == 0)
		printf "Test finished with no errors\r"
	else
		printf "Test finished with %d errors\r", global_error_count
	endif

	printf "End of test \"%s\"\r", name

	if (!allowDebug)
		NVAR/SDFR=dfr igor_debug_state
		RestoreIgorDebugger(igor_debug_state)
	endif
End

/// Internal Setup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteBegin(testSuite)
	string testSuite

	initError()
	incrRunCount()
	printf "Entering test suite \"%s\"\r", testSuite
End

/// Internal Cleanup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteEnd(testSuite)
	string testSuite

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr error_count

	if(error_count == 0)
		printf "Finished with no errors\r"
	else
		printf "Failed with %d errors\r", error_count
	endif

	NVAR/SDFR=dfr global_error_count
	global_error_count += error_count

	printf "Leaving test suite \"%s\"\r", testSuite
End

/// Internal Setup for Test Case
/// @param testCase name of the test case
static Function TestCaseBegin(testCase)
	string testCase

	initAssertCount()

	// create a new unique folder as working folder
	dfref dfr = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	SetDataFolder root:
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/O/S $workFolder

	string/G dfr:systemErr = ""

	printf "Entering test case \"%s\"\r", testCase
End

/// Internal Cleanup for Test Case
/// @param testCase name of the test case
static Function TestCaseEnd(testCase, keepDataFolder)
	string testCase
	variable keepDataFolder

	dfref dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr lastFolder
	SVAR/Z/SDFR=dfr workFolder
	NVAR/SDFR=dfr assert_count

	if(assert_count == 0)
		printf "The test case \"%s\" did not make any assertions!\r", testCase
	endif

	if(SVAR_Exists(lastFolder) && DataFolderExists(lastFolder))
		SetDataFolder $lastFolder
	endif
	if (!keepDataFolder)
		if(SVAR_Exists(workFolder) && DataFolderExists(workFolder))
			KillDataFolder $workFolder
		endif
	endif

	printf "Leaving test case \"%s\"\r", testCase
End

/// Returns List of Test Functions in Procedure Window procWin
static Function/S getTestCaseList(procWin)
	string procWin
	return (FunctionList("!*_IGNORE", ";", "KIND:18,NPARAMS:0,WIN:" + procWin))
End

/// Returns FullName List of Test Functions in all Procedure Windows from procWinList that match ShortName Function matchStr
static Function/S getTestCasesMatch(procWinList, matchStr, enableRegExp)
	string procWinList
	string matchStr
	variable enableRegExp

	string procWin
	string funcName
	string funcList
	string fullFuncName
	string testCaseList
	variable err
	variable numpWL, numFL
	variable i,j

	if(enableRegExp)
		sprintf matchStr, "^(?i)%s$", matchStr
	endif

	testCaseList = ""
	numpWL = ItemsInList(procWinList)
	for(i = 0; i < numpWL; i += 1)
		procWin = StringFromList(i, procWinList)
		if(enableRegExp)
			funcList = getTestCaseList(procWin)
			funcList = GrepList(funcList, matchStr, 0, ";")
		else
			funcList = matchStr
		endif
		numFL = ItemsInList(funcList)
		for(j = 0; j < numFL; j += 1)
			funcName = StringFromList(j, funcList)
			fullFuncName = getFullFunctionName(err, funcName, procWin)
			if(!err)
				testCaseList = AddListItem(fullFuncName, testCaseList, ";")
			endif
		endfor
	endfor
	return testCaseList
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
	if(!IsProcGlobal())
		if(!QueryIgorOption("IndependentModuleDev"))
			printf "Error: The unit-testing framework lives in the IM \"%s\" but \"SetIgorOption IndependentModuleDev=1\" is not set.\r", GetIndependentModuleName()
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
	variable numItemsPW
	variable numMatches
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
			procWinMatch = GrepList(allProcWindows, procWin, 0, ";")
		else
			procWinMatch = StringFromList(WhichListItem(procWin, allProcWindows, ";", 0, 0), allProcWindows)
		endif

		numMatches = ItemsInList(procWinMatch)
		if(numMatches <= 0)
			printf "Error: A procedure window named \"%s\" could not be found.\r", procWin
			return ""
		endif

		for(j = 0; j < numMatches; j += 1)
			procWin = StringFromList(j, procWinMatch)
			if(FindListItem(procWin, procWinListOut, ";", 0, 0) == -1)
				procWinListOut = AddListItem(procWin, procWinListOut, ";", INF)
			else
				printf "Error: The procedure window named \"%s\" is a duplicate entry in the input list of procedures.\r", procWin
				return ""
			endif
		endfor
	endfor

	return procWinListOut
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

				TAP_TestCaseBegin()
				JU_TestCaseBegin(juProps, name, procWin)
				TestCaseBegin(name)
				userHook(name); AbortOnRTE
				break
			case TEST_CASE_END_CONST:
				AbortOnValue ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseEnd

				userHook(name); AbortOnRTE
				TestCaseEnd(name, param)
				JU_TestCaseEnd(juProps, name, procWin)
				TAP_TestCaseEnd()
				break
			case TEST_SUITE_END_CONST:
				AbortOnValue !ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testSuiteEnd

				userHook(name); AbortOnRTE
				TestSuiteEnd(name)
				JU_TestSuiteEnd(juProps)
				break
			case TEST_END_CONST:
				AbortOnValue ParamIsDefault(param), 1

				FUNCREF USER_HOOK_PROTO userHook = $hooks.testEnd

				userHook(name); AbortOnRTE
				TestEnd(name, param)
				JU_WriteOutput(juProps)
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
		incrError()
	endtry
End

///@endcond // HIDDEN_SYMBOL

///@addtogroup TestRunnerAndHelper
///@{

/// Main function to execute one or more test suites.
/// @param   procWinList   semicolon (";") separated list of procedure files (must not include Independent Module specifications)
/// @param   name           (optional) descriptive name for the executed test suites
/// @param   testCase       (optional) function name, resembling one test case, which should be executed only for each test suite
/// @param   enableJU       (optional) enables JUNIT xml output when set to 1
/// @param   enableTAP      (optional) enables Test Anything Protocol (TAP) output when set to 1
/// @param   enableRegExp   (optional) enables parsing of regular expressions within procWinList when set to 1. disabled on default.
/// @param   allowDebug     (optional) when set != 0 then the Debugger does not get disabled while running the tests
/// @param   keepDataFolder (optional) when set != 0 then the temporary Data Folder where the Test Case is executed in is not removed after the Test Case finishes
/// @return                 total number of errors
Function RunTest(procWinList, [name, testCase, enableJU, enableTAP, enableRegExp, allowDebug, keepDataFolder])
	string procWinList, name, testCase
	variable enableJU, enableTAP, enableRegExp
	variable allowDebug, keepDataFolder

	string procWin
	string testCaseList
	string allTestCasesList
	string FuncName
	string fullFuncName
	string fullFuncNameList
	variable numItemsPW
	variable numItemsTC
	variable numItemsFFN
	variable tap_skipCase
	variable tap_caseCount
	variable enableRegExpTC, enableRegExpTS
	DFREF dfr = GetPackageFolder()
	STRUCT JU_Props juProps
	struct TestHooks hooks
	struct TestHooks procHooks
	variable i, j, err

	// Arguments check
	enableRegExpTC = ParamIsDefault(enableRegExp) ? 0 : !!enableRegExp
	enableRegExpTS = enableRegExpTC

	ClearBaseFilename()
	CreateHistoryLog()

	PathInfo home
	if(!V_flag)
		printf "Error: Please Save experiment first.\r"
		return NaN
	endif

	procWinList = AdaptProcWinList(procWinList, enableRegExpTS)
	procWinList = FindProcedures(procWinList, enableRegExpTS)

	numItemsPW = ItemsInList(procWinList)
	if(numItemsPW <= 0)
		printf "Error: The list of procedure windows is empty or invalid.\r"
		return NaN
	endif
	for(i = 0; i < numItemsPW; i += 1)
		procWin = StringFromList(i, procWinList)
		testCaseList = getTestCaseList(procWin)
		numItemsTC = ItemsInList(testCaseList)
		if(!numItemsTC)
			printf "Error: Procedure window %s does not define any test case(s).\r", procWin
			return NaN
		endif
		for(j = 0; j < numItemsTC; j += 1)
			funcName = StringFromList(j, testCaseList)
			fullFuncName = getFullFunctionName(err, funcName, procWin)
			if(err)
				printf fullFuncName
				return NaN
			endif
		endfor
	endfor

	if(ParamIsDefault(name))
		name = "Unnamed"
	endif
	if(ParamIsDefault(enableJU))
		juProps.enableJU = 0
	else
		juProps.enableJU = !!enableJU
	endif
	if(ParamIsDefault(enableTAP))
		enableTAP = 0
	else
		enableTAP = !!enableTAP
	endif
	if(ParamIsDefault(allowDebug))
		allowDebug = 0
	else
		allowDebug = !!allowDebug
	endif
	if(ParamIsDefault(keepDataFolder))
		keepDataFolder = 0
	else
		keepDataFolder = !!keepDataFolder
	endif
	if(ParamIsDefault(testCase))
		testCase = ".*"
		enableRegExpTC = 1
	endif

	allTestCasesList = getTestCasesMatch(procWinList, testCase, enableRegExpTC)
	if(!strlen(allTestCasesList))
		printf "Error: Could not find test case \"%s\" in procedure(s) \"%s\"\r", testcase, procWinList
		printf "Note: The list of valid test case(s) is \"%s\"\r", allTestCasesList
		return NaN
	endif

	// 1.) set the hooks to the default implementations
	setDefaultHooks(hooks)
	// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
	getGlobalHooks(hooks)

	ExecuteHooks(TEST_BEGIN_CONST, hooks, juProps, name, "Undefined Procedure", param=allowDebug)

	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	NVAR/SDFR=dfr global_error_count

	// TAP Handling, find out if all should be skipped and number of all test cases
	if(enableTAP)
		TAP_EnableOutput()
		TAP_CreateFile()

		if(TAP_CheckAllSkip(allTestCasesList))
			TAP_WriteOutputIfReq("1..0 All test cases marked SKIP")
			ExecuteHooks(TEST_END_CONST, hooks, juProps, name, "Undefined Procedure", param=allowDebug)
			Abort
		else
			TAP_WriteOutputIfReq("1.." + num2str(ItemsInList(allTestCasesList)))
		endif
	endif

	tap_caseCount = 1

	// The Test Run itself is split into Test Suites for each Procedure File
	for(i = 0; i < numItemsPW; i += 1)
		procWin = StringFromList(i, procWinList)
		testCaseList = getTestCasesMatch(procWin, testCase, enableRegExpTC)

		fullFuncNameList = ""
		numItemsTC = ItemsInList(testCaseList)
		for(j = 0; j < numItemsTC; j += 1)
			funcName = StringFromList(j, testCaseList)
			fullFuncName = getFullFunctionName(err, funcName, procWin)
			if(!err)
				fullFuncNameList = AddListItem(fullFuncName, fullFuncNameList, ";")
			endif
		endfor
		if (!strlen(fullFuncNameList))
			continue
		endif

		procHooks = hooks
		// 3.) get local user hooks which reside in the same Module as the requested procedure
		getLocalHooks(procHooks, procWin)

		juProps.testCaseList = testCaseList
		juProps.testSuiteNumber = i
		ExecuteHooks(TEST_SUITE_BEGIN_CONST, procHooks, juProps, procWin, procWin)

		NVAR/SDFR=dfr error_count

		numItemsFFN = ItemsInList(fullFuncNameList)
		for(j = numItemsFFN-1; j >= 0; j -= 1)
			fullFuncName = StringFromList(j, fullFuncNameList)
			FUNCREF TEST_CASE_PROTO TestCaseFunc = $fullFuncName

			// get Description and Directive of current Function for TAP
			tap_skipCase = 0
			if(TAP_IsOutputEnabled())
				tap_skipCase = TAP_GetNotes(fullFuncName)
			endif

			if(!tap_skipCase)
				ExecuteHooks(TEST_CASE_BEGIN_CONST, procHooks, juProps, fullFuncName, procWin)

				try
					TestCaseFunc(); AbortOnRTE
				catch
					// only complain here if the error counter if the abort happened not in our code
					if(!shouldDoAbort())
						message = GetRTErrMessage()
						err = GetRTError(1)
						EvaluateRTE(err, message, V_AbortCode, fullFuncName, TEST_CASE_TYPE, procWin)
						incrError()
					endif

					if(shouldDoAbort())
						// abort condition is on hold while in catch/endtry, so all cleanup must happen here
						ExecuteHooks(TEST_CASE_END_CONST, procHooks, juProps, fullFuncName, procWin, param = keepDataFolder)

						ExecuteHooks(TEST_SUITE_END_CONST, procHooks, juProps, procWin, procWin)

						ExecuteHooks(TEST_END_CONST, hooks, juProps, name, "Undefined Procedure", param = allowDebug)
						return global_error_count
					endif
				endtry

				ExecuteHooks(TEST_CASE_END_CONST, procHooks, juProps, fullFuncName, procWin, param = keepDataFolder)
			endif

			if(shouldDoAbort())
				break
			endif

			TAP_WriteCaseIfReq(tap_caseCount, tap_skipCase)
			tap_caseCount += 1
		endfor

		ExecuteHooks(TEST_SUITE_END_CONST, procHooks, juProps, procWin, procWin)

		if(shouldDoAbort())
			break
		endif
	endfor

	ExecuteHooks(TEST_END_CONST, hooks, juProps, name, "Undefined Procedure", param = allowDebug)

	return global_error_count
End

///@}
