#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=IUTF_Hooks

///@cond HIDDEN_SYMBOL

/// @name Hook execution level
/// @{
static Constant HOOK_LEVEL_TEST_RUN   = 0
static Constant HOOK_LEVEL_TEST_SUITE = 1
static Constant HOOK_LEVEL_TEST_CASE  = 2
/// @}

/// Groups all hooks which are executed at test case/suite begin/end
Structure IUTF_TestHooks
	string testBegin
	string testEnd
	string testSuiteBegin
	string testSuiteEnd
	string testCaseBegin
	string testCaseEnd
EndStructure

/// @brief initialize all strings in TestHook structure to be non <null>
static Function InitHooks(s)
	STRUCT IUTF_TestHooks &s

	s.testBegin      = ""
	s.testEnd        = ""
	s.testSuiteBegin = ""
	s.testSuiteEnd   = ""
	s.testCaseBegin  = ""
	s.testCaseEnd    = ""
End

/// @brief Execute the provided user hook and catches all runtime errors. If the name of the hook
/// function doesn't end in "_OVERRIDE" this hook will be considered as prototype and won't be
/// executed.
///
/// @param name      name of the test run/suite/case
/// @param userHook  the function reference to the user hook
/// @param procWIn   name of the procedure window
/// @return          Returns 1 if a user hook was executed and 0 if no user hook exists or an
///                  invalid configuration was found.
static Function ExecuteUserHook(name, userHook, procWin, level)
	FUNCREF USER_HOOK_PROTO userHook
	string name, procWin
	variable level

	variable err
	string errorMessage, endTime
	string hookName = StringByKey("Name", FuncRefInfo(userHook))

	if(!StringMatch(hookName, "*_OVERRIDE"))
		return 0
	endif

	switch(level)
		case HOOK_LEVEL_TEST_RUN:
			IUTF_Reporting_Control#TestSuiteBegin("@HOOK_SUITE")
			IUTF_Reporting_Control#TestCaseBegin(hookName, 0)
			break;
		case HOOK_LEVEL_TEST_SUITE:
			IUTF_Reporting_Control#TestCaseBegin(hookName, 0)
			break;
		case HOOK_LEVEL_TEST_CASE:
			IUTF_Reporting_Control#TestCaseBegin(hookName, 0)
			break;
		default:
			sprintf errorMessage, "Unknown hook level: %d", level
			IUTF_Reporting#ReportErrorAndAbort(errorMessage)
			return 0
	endswitch

	try
		IUTF_Basics#ClearRTError()
		userHook(name); AbortOnRTE
	catch
		errorMessage = GetRTErrMessage()
		err          = GetRTError(1)
		IUTF_Basics#EvaluateRTE(err, errorMessage, V_AbortCode, hookName, IUTF_USER_HOOK_TYPE, procWin)

		IUTF_Basics#setAbortFlag()
	endtry

	endTime = IUTF_Reporting#GetTimeString()

	switch(level)
		case HOOK_LEVEL_TEST_RUN:
			IUTF_Reporting_Control#TestCaseEnd(endTime)
			IUTF_Reporting_Control#TestSuiteEnd()
			break
		case HOOK_LEVEL_TEST_SUITE:
			IUTF_Reporting_Control#TestCaseEnd(endTime)
			break
		case HOOK_LEVEL_TEST_CASE:
			FinishWaveTracking(name)
			IUTF_Reporting_Control#TestCaseEnd(endTime)
			break
		default:
			sprintf errorMessage, "Unknown hook level: %d", level
			IUTF_Reporting#ReportErrorAndAbort(errorMessage)
			return 0
	endswitch

	return 1
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
	variable               hookType
	STRUCT IUTF_TestHooks &hooks
	variable enableTAP, enableJU
	string name, procWin
	variable tcIndex
	variable param

	variable err, skip, tcOutIndex, hookExecuted
	string errorMessage, hookName, endTime

	WAVE/T testRunData = IUTF_Basics#GetTestRunData()
	skip = str2num(testRunData[tcIndex][%SKIP])

	switch(hookType)
		case IUTF_TEST_BEGIN_CONST:
			AbortOnValue ParamIsDefault(param), 1

			FUNCREF USER_HOOK_PROTO userHook = $hooks.testBegin

			TestBegin(name, param)
			ExecuteUserHook(name, userHook, procWin, HOOK_LEVEL_TEST_RUN)
			break
		case IUTF_TEST_SUITE_BEGIN_CONST:
			AbortOnValue !ParamIsDefault(param), 1

			FUNCREF USER_HOOK_PROTO userHook = $hooks.testSuiteBegin

			TestSuiteBegin(name)
			ExecuteUserHook(name, userHook, procWin, HOOK_LEVEL_TEST_SUITE)
			break
		case IUTF_TEST_CASE_BEGIN_CONST:
			AbortOnValue !ParamIsDefault(param), 1

			FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseBegin

			if(!skip)
				TestCaseBegin(name)
				StartWaveTracking(name)
				ExecuteUserHook(name, userHook, procWin, HOOK_LEVEL_TEST_CASE)
			endif
			BeforeTestCase(name, skip)
			break
		case IUTF_TEST_CASE_END_CONST:
			AbortOnValue ParamIsDefault(param), 1

			// get the end time of the test case as fast as possible
			endTime = IUTF_Reporting#GetTimeString()
			// cache the current index in the results wave as a hook can change it
			WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
			tcOutIndex = FindDimLabel(wvTestCase, UTF_ROW, "CURRENT")

			AfterTestCase(name, skip)

			if(!skip)
				FUNCREF USER_HOOK_PROTO userHook = $hooks.testCaseEnd
				hookExecuted = ExecuteUserHook(name, userHook, procWin, HOOK_LEVEL_TEST_CASE)
				if(!hookExecuted)
					FinishWaveTracking(name)
				endif
			endif
			AfterTestCaseUserHook(name, param)

			if(!skip)
				// finalize the normal test case at tcOutIndex and reset the test case index to the
				// one after the hook
				TestCaseEnd(name, tcOutIndex, endTime)
			endif
			break
		case IUTF_TEST_SUITE_END_CONST:
			AbortOnValue !ParamIsDefault(param), 1

			FUNCREF USER_HOOK_PROTO userHook = $hooks.testSuiteEnd

			ExecuteUserHook(name, userHook, procWin, HOOK_LEVEL_TEST_SUITE)
			TestSuiteEnd(name)
			break
		case IUTF_TEST_END_CONST:
			AbortOnValue ParamIsDefault(param), 1

			FUNCREF USER_HOOK_PROTO userHook = $hooks.testEnd

			ExecuteUserHook(name, userHook, procWin, HOOK_LEVEL_TEST_RUN)
			TestEnd(name, param)
			if(enableJU)
				IUTF_JUnit#JU_WriteOutput()
			endif
			if(enableTAP)
				IUTF_TAP#TAP_Write()
			endif
			break
		default:
			IUTF_Reporting#ReportErrorAndAbort("Unknown hookType")
			break
	endswitch
End

/// Internal Setup for Testrun
/// @param name   name of the test suite group
static Function TestBegin(name, debugMode)
	string   name
	variable debugMode

	string msg

	IUTF_Reporting_Control#TestBegin()
	IUTF_Basics#InitAbortFlag()
	IUTF_Debug#SetDebugger(debugMode)

	WAVE/T wvFailed = IUTF_Reporting#GetFailedProcWave()
	IUTF_Utils_Vector#SetLength(wvFailed, 0)

	ClearBaseFilename()

	sprintf msg, "Start of test \"%s\"", name
	IUTF_Reporting#IUTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Testrun
/// @param name   name of the test suite group
static Function TestEnd(name, debugMode)
	string   name
	variable debugMode

	string msg
	variable i, index
	DFREF  dfr       = GetPackageFolder()
	WAVE/T wvFailed  = IUTF_Reporting#GetFailedProcWave()
	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()

	if(str2num(wvTestRun[%CURRENT][%NUM_ASSERT_ERROR]) == 0)
		sprintf msg, "Test finished with no errors"
	else
		sprintf msg, "Test finished with %s errors", wvTestRun[%CURRENT][%NUM_ASSERT_ERROR]
	endif

	IUTF_Reporting#IUTF_PrintStatusMessage(msg)

	index = IUTF_Utils_Vector#GetLength(wvFailed)
	for(i = 0; i < index; i += 1)
		msg = "  " + TC_ASSERTION_LIST_INDICATOR + " " + wvFailed[i]
		IUTF_Reporting#IUTF_PrintStatusMessage(msg)
	endfor

	sprintf msg, "End of test \"%s\"", name
	IUTF_Reporting#IUTF_PrintStatusMessage(msg)

	IUTF_Reporting_Control#TestEnd()
	IUTF_Debug#RestoreDebugger()
End

/// Internal Setup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteBegin(testSuite)
	string testSuite

	string msg

	IUTF_Reporting_Control#TestSuiteBegin(testSuite)

	sprintf msg, "Entering test suite \"%s\"", testSuite
	IUTF_Reporting#IUTF_PrintStatusMessage(msg)
End

/// Internal Cleanup for Test Suite
/// @param testSuite name of the test suite
static Function TestSuiteEnd(testSuite)
	string testSuite

	string msg

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()

	if(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]) == 0)
		sprintf msg, "Finished with no errors"
	else
		sprintf msg, "Failed with %s errors", wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]
	endif

	IUTF_Reporting#IUTF_PrintStatusMessage(msg)

	IUTF_Reporting_Control#TestSuiteEnd()

	sprintf msg, "Leaving test suite \"%s\"", testSuite
	IUTF_Reporting#IUTF_PrintStatusMessage(msg)
End

/// Internal Setup for Test Case
/// @param testCase name of the test case
static Function TestCaseBegin(testCase)
	string testCase

	string msg

	// create a new unique folder as working folder
	DFREF    dfr            = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	SetDataFolder root:
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/O/S $workFolder

	sprintf msg, "Entering test case \"%s\"", testCase
	IUTF_Reporting#IUTF_PrintStatusMessage(msg)
End

/// @brief Called after the test case begin user hook and before the test case function
static Function BeforeTestCase(name, skip)
	string   name
	variable skip

	IUTF_Reporting_Control#TestCaseBegin(name, skip)

End

/// @brief Called after the test case and after the test case end user hook
static Function AfterTestCaseUserHook(name, keepDataFolder)
	string   name
	variable keepDataFolder

	string msg

	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr lastFolder
	SVAR/Z/SDFR=dfr workFolder

	if(SVAR_Exists(lastFolder) && DataFolderExists(lastFolder))
		SetDataFolder $lastFolder
	endif
	if(!keepDataFolder)
		if(SVAR_Exists(workFolder) && DataFolderExists(workFolder))
			KillDataFolder/Z $workFolder
		endif
	endif
End

/// Internal Cleanup for Test Case
/// @param testCase name of the test case
static Function TestCaseEnd(testCase, tcIndex, endTime)
	string testCase, endTime
	variable tcIndex

	string   msg
	variable oldIndex

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	oldIndex = IUTF_Utils_Waves#MoveDimLabel(wvTestCase, UTF_ROW, "CURRENT", tcIndex)

	IUTF_Reporting_Control#TestCaseEnd(endTime)

	IUTF_Utils_Waves#MoveDimLabel(wvTestCase, UTF_ROW, "CURRENT", oldIndex)

	sprintf msg, "Leaving test case \"%s\"", testCase
	IUTF_Reporting#IUTF_PrintStatusMessage(msg)
End

/// @brief Called after the test case and before the test case end user hook
static Function AfterTestCase(name, skip)
	string   name
	variable skip

	string msg

	IUTF_Reporting#CleanupInfoMsg()

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()

	if(skip)
		return NaN
	endif

	if(IsExpectedFailure())
		if(str2num(wvTestCase[%CURRENT][%NUM_ASSERT_ERROR]) == 0)
			sprintf msg, "Test case \"%s\" doesn't contain at least one assertion error", name
			IUTF_Reporting#TestCaseFail(msg, isFailure = 1)
		else
			// reset the assertion error counter as all previous errors are intended
			wvTestCase[%CURRENT][%NUM_ASSERT_ERROR] = "0"
			if(!CmpStr(wvTestCase[%CURRENT][%STATUS], IUTF_STATUS_FAIL))
				wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_RUNNING
			endif
		endif
	else
		if(str2num(wvTestCase[%CURRENT][%NUM_ASSERT]) == 0)
			sprintf msg, "Test case \"%s\" doesn't contain at least one assertion", name
			IUTF_Reporting#TestCaseFail(msg)
		endif
	endif
End

/// Sets the hooks to the builtin defaults
static Function setDefaultHooks(hooks)
	STRUCT IUTF_TestHooks &hooks

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
	STRUCT IUTF_TestHooks &hooks

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
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif

		if(NumberByKey("RETURNTYPE", wvInfo[i]) != 0x4)
			sprintf msg, "The override test hook \"%s\" must return a numeric variable.", StringByKey("NAME", wvInfo[i])
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif
	endfor
End

/// Looks for global override hooks in the same indpendent module as the framework itself
/// is running in.
static Function getGlobalHooks(hooks)
	STRUCT IUTF_TestHooks &hooks

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
	string                 procName
	STRUCT IUTF_TestHooks &hooks

	variable err
	string userHooks = FunctionList("*_OVERRIDE", ";", "KIND:18,WIN:" + procName)

	variable i
	for(i = 0; i < ItemsInList(userHooks); i += 1)
		string userHook = StringFromList(i, userHooks)

		string fullFunctionName = IUTF_Basics#getFullFunctionName(err, userHook, procName)
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

/// @brief Stores the state of TestHook structure to DF dfr with key as template
static Function StoreHooks(dfr, s, key)
	DFREF                  dfr
	STRUCT IUTF_TestHooks &s
	string                 key

	key = "S" + key
	string/G dfr:$(key + "testBegin")      = s.testBegin
	string/G dfr:$(key + "testEnd")        = s.testEnd
	string/G dfr:$(key + "testSuiteBegin") = s.testSuiteBegin
	string/G dfr:$(key + "testSuiteEnd")   = s.testSuiteEnd
	string/G dfr:$(key + "testCaseBegin")  = s.testCaseBegin
	string/G dfr:$(key + "testCaseEnd")    = s.testCaseEnd
End

/// @brief Restores the state of TestHook structure from DF dfr with key as template
static Function RestoreHooks(dfr, s, key)
	DFREF                  dfr
	STRUCT IUTF_TestHooks &s
	string                 key

	key = "S" + key
	SVAR testBegin      = dfr:$(key + "testBegin")
	SVAR testEnd        = dfr:$(key + "testEnd")
	SVAR testSuiteBegin = dfr:$(key + "testSuiteBegin")
	SVAR testSuiteEnd   = dfr:$(key + "testSuiteEnd")
	SVAR testCaseBegin  = dfr:$(key + "testCaseBegin")
	SVAR testCaseEnd    = dfr:$(key + "testCaseEnd")
	s.testBegin      = testBegin
	s.testEnd        = testEnd
	s.testSuiteBegin = testSuiteBegin
	s.testSuiteEnd   = testSuiteEnd
	s.testCaseBegin  = testCaseBegin
	s.testCaseEnd    = testCaseEnd
End

static Function StartWaveTracking(name)
	string name

#if IgorVersion() >= 9.0
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr/Z waveTrackingMode

	if(NVAR_Exists(waveTrackingMode))
		WaveTracking/LOCL stop
		WaveTracking/FREE stop
		if(!IUTF_FunctionTags#HasFunctionTag(name, UTF_FTAG_NO_WAVE_TRACKING))
			if((waveTrackingMode & UTF_WAVE_TRACKING_FREE) == UTF_WAVE_TRACKING_FREE)
				WaveTracking/FREE counter
			endif
			if((waveTrackingMode & UTF_WAVE_TRACKING_LOCAL) == UTF_WAVE_TRACKING_LOCAL)
				WaveTracking/LOCL counter
			endif
		endif
	endif
#endif
End

static Function FinishWaveTracking(name)
	string name

	string msg

#if IgorVersion() >= 9.0
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr waveTrackingMode

	if(NVAR_Exists(waveTrackingMode))
		if((waveTrackingMode & UTF_WAVE_TRACKING_LOCAL) == UTF_WAVE_TRACKING_LOCAL)
			WaveTracking/LOCL count
			if(V_Flag == IUTF_WVTRACK_COUNT_MODE)
				if(V_numWaves)
					sprintf msg, "Local wave leak detected (leaked waves: %d) in \"%s\"", V_numWaves, name
					IUTF_Reporting#TestCaseFail(msg)
				endif
				WaveTracking/LOCL stop
			elseif(V_Flag != IUTF_WVTRACK_INACTIVE_MODE)
				// do nothing for IUTF_WVTRACK_INACTIVE_MODE.
				// Most likely the user has used a tag to opt out this test case for wave tracking.
				sprintf msg, "Test case \"%s\" modified WaveTracking mode to %d. IUTF can not track at the same time.", name, V_Flag
				IUTF_Reporting#TestCaseFail(msg)
			endif
		endif

		if((waveTrackingMode & UTF_WAVE_TRACKING_FREE) == UTF_WAVE_TRACKING_FREE)
			WaveTracking/FREE count
			if(V_Flag == IUTF_WVTRACK_COUNT_MODE)
				if(V_numWaves)
					sprintf msg, "Free wave leak detected (leaked waves: %d) in \"%s\"", V_numWaves, name
					IUTF_Reporting#TestCaseFail(msg)
				endif
				WaveTracking/FREE stop
			elseif(V_Flag != IUTF_WVTRACK_INACTIVE_MODE)
				// do nothing for IUTF_WVTRACK_INACTIVE_MODE.
				// Most likely the user has used a tag to opt out this test case for wave tracking.
				sprintf msg, "Test case \"%s\" modified WaveTracking mode to %d. IUTF can not track at the same time.", name, V_Flag
				IUTF_Reporting#TestCaseFail(msg)
			endif
		endif
	endif
#endif
End

///@endcond // HIDDEN_SYMBOL
