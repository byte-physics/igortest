#pragma rtGlobals=3
#pragma version=1.03

// Author: Thomas Braun and contributors (c) 2013-2017
// Email: support at byte-physics dott de

///@cond HIDDEN_SYMBOL

/// Returns the package folder
Function/DF GetPackageFolder()
	if(!DataFolderExists(PKG_FOLDER))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:UnitTesting
	endif

	dfref dfr = $PKG_FOLDER
	return dfr
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
Function DebugOutput(str, booleanValue)
	string str
	variable booleanValue

	if(EnabledDebug())
		str += ": is " + SelectString(booleanValue, "false", "true")
		print str
	endif
End

/// Disable the Igor Pro Debugger and return its state prior to deactivation
Function DisableIgorDebugger()

	variable debuggerState

	DebuggerOptions
	debuggerState = V_enable

	DebuggerOptions enable=0

	return debuggerState
End

/// Restore the Igor Pro Debugger to its prior state
Function RestoreIgorDebugger(debuggerState)
	variable debuggerState

	DebuggerOptions enable=debuggerState
End

/// Create the variable igorDebugState in PKG_FOLDER
/// and initialize it to zero
Function InitIgorDebugState()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:igor_debug_state = 0
End

/// Creates the variable global_error_count in PKG_FOLDER
/// and initializes it to zero
Function initGlobalError()
	dfref dfr = GetPackageFolder()
	variable/G dfr:global_error_count = 0
End

/// Creates the variable error_count in PKG_FOLDER
/// and initializes it to zero
Function initError()
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
Function initAssertCount()
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
	print getInfo(0)
End

/// Prints an informative message that the test succeeded
Function printSuccessInfo()
	print getInfo(1)
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
Function abortNow()
	dfref dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 1

	Abort
End

/// Resets the abort flag
Function InitAbortFlag()
	dfref dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 0
End


/// Prints an informative message about the test's success or failure
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

	contents = ProcedureText("", -1, procedure)
	text = StringFromList(str2num(line), contents, "\r")

	// remove leading and trailing whitespace
	SplitString/E="^[[:space:]]*(.+?)[[:space:]]*$" text, cleanText

	sprintf text, "Assertion \"%s\" %s in line %s, procedure \"%s\"\r", cleanText,  SelectString(result, "failed", "suceeded"), line, procedure
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

/// Looks for global override hooks in the module ProcGlobal
static Function getGlobalHooks(hooks)
	Struct TestHooks& hooks

	string userHooks = FunctionList("*_OVERRIDE", ";", "KIND:2")

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

	string userHooks = FunctionList("*_OVERRIDE", ";", "KIND:18,WIN:" + procName)

	variable i
	for(i = 0; i < ItemsInList(userHooks); i += 1)
		string userHook = StringFromList(i, userHooks)

		string fullFunctionName = getFullFunctionName(userHook, procName)
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
static Function/S getFullFunctionName(funcName, procName)
	string funcName, procName

	string infoStr = FunctionInfo(funcName, procName)
	string errMsg

	if(strlen(infoStr) <= 0)
		sprintf errMsg, "Function %s in procedure file %s is unknown\r", funcName, procName
		Abort errMsg
	endif

	string module = StringByKey("MODULE", infoStr)

	if(strlen(module) <= 0)
		module = "ProcGlobal"

		// we can only use static functions if they live in a module
		if(cmpstr(StringByKey("SPECIAL", infoStr), "static") == 0)
			sprintf errMsg, "The procedure file %s is missing a \"#pragma ModuleName=myName\" declaration.\r", procName
			Abort errMsg
		endif
	endif

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

/// Evaluates an RTE and puts a composite error message into message/type
Function EvaluateRTE(err, errmessage, abortCode, funcName, procWin)
	variable err
	string errmessage
	variable abortCode
	string funcName
	string procWin

	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	string str

	type = ""
	message = ""
	if(err)
		sprintf str, "Uncaught runtime error %d:\"%s\" in test case \"%s\", procedure file \"%s\"\r", err, errmessage, funcName, procWin
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
				sprintf str, "User aborted Test Run manually in test case \"%s\", procedure file \"%s\"\r", funcName, procWin
				break
			case -2:
				sprintf str, "Stack Overflow in test case \"%s\", procedure file \"%s\"\r", funcName, procWin
				break
			case -3:
				sprintf str, "Encountered \"Abort\" in test case \"%s\", procedure file \"%s\"\r", funcName, procWin
				break
			default:
		endswitch
		message += str
		if(abortCode > 0)
			sprintf str, "Encountered \"AbortOnvalue\" Code %d in test case \"%s\", procedure file \"%s\"\r", abortCode, funcName, procWin
			message += str
		endif
	endif
End

/// Internal Setup for Testrun
/// @param name   name of the test suite group
Function TestBegin(name)
	string name

	// we have to remember the state of debugging
	variable reEnableDebugOutput=EnabledDebug()

	KillDataFolder/Z $PKG_FOLDER
	initGlobalError()

	if(reEnableDebugOutput)
		EnableDebugOutput()
	endif

	initIgorDebugState()

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_state
	igor_debug_state = DisableIgorDebugger()

	InitAbortFlag()
	
	string/G dfr:message = ""
	string/G dfr:type = "0"
	string/G dfr:systemErr = ""

	ClearBaseFilename()

	printf "Start of test \"%s\"\r", name
End

/// Internal Cleanup for Testrun
/// @param name   name of the test suite group
Function TestEnd(name)
	string name

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr global_error_count

	if(global_error_count == 0)
		printf "Test finished with no errors\r"
	else
		printf "Test finished with %d errors\r", global_error_count
	endif

	printf "End of test \"%s\"\r", name

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_state

	RestoreIgorDebugger(igor_debug_state)
End

/// Internal Setup for Test Suite
/// @param testSuite name of the test suite
Function TestSuiteBegin(testSuite)
	string testSuite

	initError()
	printf "Entering test suite \"%s\"\r", testSuite
End

/// Internal Cleanup for Test Suite
/// @param testSuite name of the test suite
Function TestSuiteEnd(testSuite)
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
Function TestCaseBegin(testCase)
	string testCase

	initAssertCount()

	// create a new unique folder as working folder
	dfref dfr = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	SetDataFolder root:
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/O/S $workFolder

	printf "Entering test case \"%s\"\r", testCase
End

/// Internal Cleanup for Test Case
/// @param testCase name of the test case
Function TestCaseEnd(testCase)
	string testCase

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
	if(SVAR_Exists(workFolder) && DataFolderExists(workFolder))
		KillDataFolder $workFolder
	endif

	printf "Leaving test case \"%s\"\r", testCase
End

/// Main function to execute one or more test suites.
/// @param   procWinList   semicolon (";") separated list of procedure files
/// @param   name          (optional) descriptive name for the executed test suites
/// @param   testCase      (optional) function name, resembling one test case, which should be executed only
/// @return                total number of errors
Function RunTest(procWinList, [name, testCase])
	string procWinList, testCase, name

	DFREF dfr = GetPackageFolder()

	if(strlen(procWinList) <= 0)
		printf "The list of procedure windows is empty\r"
		return NaN
	endif

	variable i, j, err

	string allProcWindows = WinList("*", ";", "WIN:128")

	for(i = 0; i < ItemsInList(procWinList); i += 1)
		string procWin = StringFromList(i, procWinList)
		if(FindListItem(procWin, allProcWindows, ";", 0, 0) == -1)
			printf "A procedure window named %s could not be found.\r", procWin
			return NaN
		endif
	endfor

	if(ParamIsDefault(name))
		name = "Unnamed"
	endif

	struct TestHooks hooks
	// 1.) set the hooks to the default implementations
	setDefaultHooks(hooks)
	// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
	getGlobalHooks(hooks)

	FUNCREF USER_HOOK_PROTO TestBeginUser = $hooks.testBegin
	FUNCREF USER_HOOK_PROTO TestEndUser   = $hooks.testEnd

	TestBegin(name)
	TestBeginUser(name)
	
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	SVAR/SDFR=dfr systemErr

	for(i = 0; i < ItemsInList(procWinList); i += 1)

		procWin = StringFromList(i, procWinList)

		string testCaseList
		if(ParamIsDefault(testCase))
			// 18 == 16 (static function) or 2 (userdefined functions)
			testCaseList = FunctionList("!*_IGNORE", ";", "KIND:18,NPARAMS:0,WIN:" + procWin)
		else
			testCaseList = testCase
		endif

		struct TestHooks procHooks
		procHooks = hooks
		// 3.) get local user hooks which reside in the same Module as the requested procedure
		getLocalHooks(procHooks, procWin)

		FUNCREF USER_HOOK_PROTO TestSuiteBeginUser = $procHooks.testSuiteBegin
		FUNCREF USER_HOOK_PROTO TestSuiteEndUser   = $procHooks.testSuiteEnd
		FUNCREF USER_HOOK_PROTO TestCaseBeginUser  = $procHooks.testCaseBegin
		FUNCREF USER_HOOK_PROTO TestCaseEndUser    = $procHooks.testCaseEnd

		TestSuiteBegin(procWin)
		TestSuiteBeginUser(procWin)

		for(j = 0; j < ItemsInList(testCaseList); j += 1)
			string funcName = StringFromList(j, testCaseList)
			string fullFuncName = getFullFunctionName(funcName, procWin)

			FUNCREF TEST_CASE_PROTO TestCaseFunc = $fullFuncName

			TestCaseBegin(funcName)
			TestCaseBeginUser(funcName)

			try
				TestCaseFunc(); AbortOnRTE
			catch
				// only complain here if the error counter if the abort happened not in our code
				if(!shouldDoAbort())
					message = GetRTErrMessage()
					err = GetRTError(1)
					EvaluateRTE(err, message, V_AbortCode, funcName, procWin)
					printf message
					systemErr = message
										
					incrError()
				endif
			endtry

			TestCaseEnd(funcName)
			TestCaseEndUser(funcName)

			if(shouldDoAbort())
				break
			endif
		endfor

		TestSuiteEnd(procWin)
		TestSuiteEndUser(procWin)

		if(shouldDoAbort())
			break
		endif
	endfor

	TestEnd(name)
	TestEndUser(name)

	NVAR/SDFR=GetPackageFolder() error_count
	return error_count
End

///@}
