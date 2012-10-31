#pragma rtGlobals=3		// Use modern global access method.

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

Function ENABLED_DEBUG()
	NVAR/Z verbose = root:verbose

	if(NVAR_EXISTS(verbose) && verbose == 1)
		return 1
	endif
	
	return 0
End

Function DEBUG_OUTPUT(str, booleanValue)
	string str
	variable booleanValue
	
	if(ENABLED_DEBUG())
		str += ": is " + SelectString(booleanValue,"false","true")
		print str
	endif
End

Function incrError()
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
/// that means the call stack is e. g. CHECK_SMALL_VAR -> printFailInfo -> printInfo(0)
static Function printInfo(result)
	variable result

	string callStack = GetRTStackInfo(3)
	
	string initialCaller 	= StringFromList(1,callStack,";")
	string procedure	= StringFromList(1,initialCaller,",")
	string line		= StringFromList(2,initialCaller,",")

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
static Function/S getFullFunctionName(funcName, procName)
	string funcName, procName

	string infoString = FunctionInfo(funcName, procName)
	string module = StringByKey("MODULE", infoString)
	if(strlen(module) == 0 )
		module = "ProcGlobal"
	endif
	
	return module + "#" + funcName
End

// add possibility to run only a single function
Function RUN_TEST_SUITE(procName)
	string procName
	
	if(strlen(procName) == 0)
		procName = "Procedure"
	endif
	
	// 18 == 16 (static function) or 2 (userdefined functions)
	string testCaseList = FunctionList("!*_IGNORE",";","KIND:18,NPARAMS:0,WIN:" + procName)

	struct TestHooks hooks
	// 1.) set the hooks to the default implementations
	SetDefaultHooks(hooks)
	// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
	getGlobalHooks(hooks)
	// 3.) get local user hooks which reside in the same Module as the requested procedure
	getLocalHooks(hooks, procName)
	
	Execute	hooks.testSuiteBegin + "(\"" + procName + "\")"

	variable i
	for(i = 0; i < ItemsInList(testCaseList); i+=1)
		string funcName = StringFromList(i,testCaseList)
		string fullFuncName = getFullFunctionName(funcName, procName)
	
		Execute	hooks.testCaseBegin + "(\"" + funcName + "\")"
		Execute/Q fullFuncName + "()"
		Execute	hooks.testCaseEnd + "(\"" + funcName + "\")"
	endfor

	Execute	hooks.testSuiteEnd + "(\"" + procName + "\")"
End
