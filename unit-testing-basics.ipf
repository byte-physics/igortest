#pragma rtGlobals=3		// Use modern global access method.

//#define USE_THREADS

Function ENABLE_DEBUG_OUTPUT()
	variable/G root:verbose
	NVAR verbose = root:verbose
	verbose = 1
End

Function DISABLE_DEBUG_OUTPUT()
	variable/G root:verbose
	NVAR verbose = root:verbose
	verbose = 0
End

ThreadSafe Function ENABLED_DEBUG()
	NVAR/Z verbose = root:verbose

	if(NVAR_EXISTS(verbose) && verbose == 1)
		return 1
	endif
	
	return 0
End

ThreadSafe Function DEBUG_OUTPUT(str, booleanValue)
	string str
	variable booleanValue
	
	if(ENABLED_DEBUG())
		str += ": is " + SelectString(booleanValue,"false","true")
		print str
	endif
End

ThreadSafe Function incrError()
	NVAR/Z error_count = root:error_count
	
	if(!NVAR_Exists(error_count))
		variable/G root:error_count
		NVAR error_count = root:error_count
		error_count = 0
	endif
	
	error_count +=1
End

Function CHECK_EMPTY_FOLDER()

	string folder = ":"
	if ( CountObjects(folder,1) + CountObjects(folder,2) + CountObjects(folder,3) + CountObjects(folder,4)  == 0 )
		// debug out
	else
		incrError()
		printf "folder %s is not empty\r", folder
	endif
End

// Prints an informative message that the test failed
Function printFailInfo()
	printInfo(0)
End

// Prints an informative message that the test suceeded
Function printSuccessInfo()
	printInfo(1)
End

/// Prints an informative message about the test's success or failure
/// It is assumed that the test function CHECK_*_*, REQUIRE_*_*, WARN_*_* is the caller of the calling function, 
/// that means the call stack is e. g. RUN_TEST_SUITE -> testCase -> CHECK_SMALL_VAR -> printFailInfo -> printInfo
Function printInfo(result)
	variable result
	
	string callStack = GetRTStackInfo(3)

	variable indexThisFunction  = ItemsInList(callStack) - 1 // 0-based indizes
	variable indexCheckFunction = indexThisFunction - 4
	
	if(indexCheckFunction < 0 || indexCheckFunction > indexThisFunction)
		return 0
	endif
	
	string initialCaller 	= StringFromList(indexCheckFunction,callStack,";")
	string procedure		= StringFromList(1,initialCaller,",")
	string line				= StringFromList(2,initialCaller,",")

	// get the line which called the caller of this function
	string procedureContents = ProcedureText("",-1,procedure)
	string text = StringFromList(str2num(line),procedureContents,"\r")
	
	// remove leading and trailing whitespace
	string cleanText
	SplitString/E="^[[:space:]]*(.+?)[[:space:]]*$" text, cleanText

	printf "Assertion \"%s\" %s in line %s, procedure %s\r", cleanText,  SelectString(result,"failed","suceeded"), line, procedure
End

/// Groups all hooks which are executed at test case/suite begin/end
Structure TestHooks
	string testSuiteBegin
	string testSuiteEnd
	string testCaseBegin
	string testCaseEnd
EndStructure

/// Sets the hooks to the builtin defaults
Function setDefaultHooks(hooks)
	Struct TestHooks &hooks
	
	hooks.testSuiteBegin  = "TEST_SUITE_BEGIN"
	hooks.testSuiteEnd	   = "TEST_SUITE_END"
	hooks.testCaseBegin  = "TEST_CASE_BEGIN"
	hooks.testCaseEnd	   = "TEST_CASE_END"
End

/// Looks for global override hooks in the module ProcGlobal
static Function getGlobalHooks(hooks)
	Struct TestHooks& hooks

	string userHooks = FunctionList("*_OVERRIDE",";","KIND:2,NPARAMS:1,VALTYPE:1")
	
	variable i
	for(i = 0; i < ItemsInList(userHooks); i+=1)
		string userHook = StringFromList(i,userHooks)
		strswitch(userHook)
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
				printf "Found unknown override function \"%s\"\r", userHook
				break
		endswitch
	endfor
End

/// Looks for local override hooks in a specific procedure file
static Function getLocalHooks(hooks, procName)
	string procName
	Struct TestHooks& hooks
	
	string userHooks = FunctionList("*_OVERRIDE", ";", "KIND:18,NPARAMS:1,VALTYPE:1,WIN:" + procName)

	variable i
	for(i = 0; i < ItemsInList(userHooks); i+=1)
		string userHook = StringFromList(i,userHooks)
		
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
				printf "Found unknown override function \"%s\"\r", userHook
				break
		endswitch
	endfor
End

/// Returns the full name of a function including its module
Function/S getFullFunctionName(funcName, procName)
	string funcName, procName

	string infoString = FunctionInfo(funcName, procName)
	if(strlen(infoString) <= 0)
		string errMsg
		sprintf errMsg, "Function %s in procedure file %s is unknown\r", funcName, procName
		Abort errMsg
	endif
	string module = StringByKey("MODULE", infoString)
	if(strlen(module) <= 0 )
		module = "ProcGlobal"
	endif
	
	return module + "#" + funcName
End

/// Prototype for test cases
Function TEST_CASE_PROTO()
End

/// Prototype for hook functions
Function USER_HOOK_PROTO(str)
	string str
End

/// Runs all test cases of test suite or just a single test case
/// @param 	testSuite		Can be a procedure or module name
/// @param 	testCase		(optional) function, one test case, which should be executed only
/// @return					number of errors 
Function RUN_TEST(testSuite, [testCase])
	string testSuite, testCase
	
	string procWinList = ""
	variable i, j
	
	// check if testSuite is a procedure window
	string allProcWindows = WinList("*",";","WIN:128")
	if(FindListItem(testSuite, allProcWindows) != -1)
		procWinList = testSuite
	else
		// if not we collect all procedure windows which hold a function in a regular module named $testSuite
		for(i = 0; i < ItemsInList(allProcWindows); i += 1)
			string procWin  		= StringFromList(i,allProcWindows)
			string funcList 		= FunctionList("!*_IGNORE",";","KIND:18,NPARAMS:0,WIN:" + procWin)
			for(j = 0; j < ItemsInList(funcList); j+=1)
				string func 		= StringFromList(j,funcList)
				string funcInfo 	= FunctionInfo(func,procWin)
				string module 		= StringByKey("MODULE",funcInfo)
				
//				printf "procWin=%s, module=%s, testSuite=%s, procWinList=%s\r", procWin, module, testSuite, procWinList
			
				if(cmpstr(module, testSuite) == 0 && FindListItem(procWin, procWinList) == -1)
					procWinList = AddListItem(procWin,procWinList)
				endif
				break
			endfor
		endfor
	endif
	
	if(ItemsInList(procWinList) == 0)
		printf "A procedure window/regular module named %s could not be found.\r", testSuite
		return 0
	endif
	
	variable abortNow = 0
	for(i = 0; i < ItemsInList(procWinList); i+=1)
	
		procWin = StringFromList(i, procWinList)
	
		string testCaseList
		if(ParamIsDefault(testCase))
			// 18 == 16 (static function) or 2 (userdefined functions)
			testCaseList = FunctionList("!*_IGNORE",";","KIND:18,NPARAMS:0,WIN:" + procWin)
		else
			testCaseList = testCase
		endif	
	
		struct TestHooks hooks
		// 1.) set the hooks to the default implementations
		SetDefaultHooks(hooks)
		// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
		getGlobalHooks(hooks)
		// 3.) get local user hooks which reside in the same Module as the requested procedure
		getLocalHooks(hooks, procWin)
		
		FUNCREF USER_HOOK_PROTO testSuiteBegin = $hooks.testSuiteBegin
		FUNCREF USER_HOOK_PROTO testSuiteEnd   = $hooks.testSuiteEnd
		FUNCREF USER_HOOK_PROTO testCaseBegin	  = $hooks.testCaseBegin
		FUNCREF USER_HOOK_PROTO testCaseEnd	  = $hooks.testCaseEnd

		testSuiteBegin(procWin)
	
		for(j = 0; j < ItemsInList(testCaseList); j += 1)
			string funcName = StringFromList(j,testCaseList)
			string fullFuncName = getFullFunctionName(funcName, procWin)
			
			FUNCREF TEST_CASE_PROTO testCaseFunc = $fullFuncName
		
			testCaseBegin(funcName)
			try
				testCaseFunc()
			catch
				abortNow = 1
			endtry

			testCaseEnd(funcName)

			if( abortNow )
				break
			endif
		endfor
	
		testSuiteEnd(procWin)

		if( abortNow )
			break
		endif
	endfor
	
	NVAR/Z error_count = root:error_count
	if(!NVAR_Exists(error_count))
		return 0
	endif
	return error_count
End
