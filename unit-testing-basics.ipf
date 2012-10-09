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

Function DEBUG_OUTPUT(str, booleanValue)
	string str
	variable booleanValue
	
	str += ": is " + SelectString(booleanValue,"false","true")
	NVAR/Z verbose = root:verbose
	if(NVAR_EXISTS(verbose) && verbose == 1)
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

Function RUN_TEST_SUITE(procName)
	string procName
	
	if(strlen(procName) == 0)
		procName = "Procedure"
	endif
	String testCaseList = FunctionList("*",";","NPARAMS:0,VALTYPE:1,WIN:" + procName)

	// custom user hooks
	String userHooks = FunctionList("*_OVERRIDE",";","NPARAMS:1,VALTYPE:1")
	
	string funcTestSuiteBegin = "TEST_SUITE_BEGIN"
	string funcTestSuiteEnd	= "TEST_SUITE_END"
	string funcTestCaseBegin 	= "TEST_CASE_BEGIN"
	string funcTestCaseEnd		= "TEST_CASE_END"

	variable i
	for(i = 0; i < ItemsInList(userHooks); i+=1)
		string userHook = StringFromList(i,userHooks)
		strswitch(userHook)
			case "TEST_SUITE_BEGIN_OVERRIDE":
				funcTestSuiteBegin = userHook
				break
			case "TEST_SUITE_END_OVERRIDE":
				funcTestSuiteEnd = userHook
				break
			case "TEST_CASE_BEGIN_OVERRIDE":
				funcTestCaseBegin = userHook
				break
			case "TEST_CASE_END_OVERRIDE":
				funcTestCaseEnd = userHook
				break
			default:
				print "Found unknown override function \"%s\"\r", userHook
				break
		endswitch
	endfor
	
	Execute	funcTestSuiteBegin + "(\"" + procName + "\")"

	for(i = 0; i < ItemsInList(testCaseList); i+=1)
		string funcName = StringFromList(i,testCaseList)

		Execute	funcTestCaseBegin + "(\"" + funcName + "\")"
		Execute/Q funcName + "()"
		Execute	funcTestCaseEnd + "(\"" + funcName + "\")"
	endfor

	Execute	funcTestSuiteEnd + "(\"" + procName + "\")"
End