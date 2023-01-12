#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Reporting_Control

// This procedure file combines functions that control the output like test suite begin/end or test
// case begin/end.

/// @brief Setup the test run result wave with data.
static Function SetupTestRun()
	variable id

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	id = UTF_Utils_Vector#AddRow(wvTestRun)

	wvTestRun[id][%HOSTNAME] = "localhost"
#if (IgorVersion() >= 7.00)
	strswitch(IgorInfo(2))
		case "Windows":
			wvTestRun[id][%HOSTNAME] = GetEnvironmentVariable("COMPUTERNAME")
			break
		case "Macintosh":
			wvTestRun[id][%HOSTNAME] = GetEnvironmentVariable("HOSTNAME")
			break
		default:
			break
	endswitch
	wvTestRun[id][%USERNAME] = IgorInfo(7)
#endif
	wvTestRun[id][%NUM_ERROR] = "0"
	wvTestRun[id][%NUM_SKIPPED] = "0"
	wvTestRun[id][%NUM_TESTS] = "0"
	wvTestRun[id][%NUM_ASSERT] = "0"
	wvTestRun[id][%NUM_ASSERT_ERROR] = "0"
	wvTestRun[id][%SYSTEMINFO] = IgorInfo(3)
	wvTestRun[id][%IGORINFO] = IgorInfo(0)
	wvTestRun[id][%VERSION] = UTF_Basics#GetVersion()
	wvTestRun[id][%EXPERIMENT] = IgorInfo(1)
	wvTestRun[id][%CHILD_START] = "0"
	wvTestRun[id][%CHILD_END] = "0"
End

/// @brief Begin a new test run. This test run has to be initialized with SetupTestRun first.
static Function TestBegin()
	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%STARTTIME] = UTF_Reporting#GetTimeString()
End

/// @brief End the current test run.
static Function TestEnd()
	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%ENDTIME] = UTF_Reporting#GetTimeString()
End

/// @brief Begin a new test suite.
///
/// @param testSuite  The name of the test suite.
static Function TestSuiteBegin(testSuite)
	string testSuite

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
End

/// @brief End the current test suite
static Function TestSuiteEnd()
	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	wvTestSuite[%CURRENT][%ENDTIME] = UTF_Reporting#GetTimeString()

	WAVE/T wvTestRun = UTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ASSERT]) + str2num(wvTestSuite[%CURRENT][%NUM_ASSERT]))
	wvTestRun[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ASSERT_ERROR]) + str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]))
	wvTestRun[%CURRENT][%NUM_ERROR] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ERROR]) + str2num(wvTestSuite[%CURRENT][%NUM_ERROR]))
	wvTestRun[%CURRENT][%NUM_SKIPPED] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_SKIPPED]) + str2num(wvTestSuite[%CURRENT][%NUM_SKIPPED]))
End

/// @brief Begin a new test case.
///
/// @param testCase  The name of the test case
/// @param skip      A value different to zero will mark this test case as skipped. No TestCaseEnd()
///                  call is required. Setting this to zero will start the test case normally.
static Function TestCaseBegin(testCase, skip)
	string testCase
	variable skip

	variable testId

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	testId = UTF_Utils_Vector#AddRow(wvTestCase)

	wvTestCase[testId][%NAME] = testCase
	wvTestCase[testId][%STARTTIME] = UTF_Reporting#GetTimeString()
	wvTestCase[testId][%NUM_ASSERT] = "0"
	wvTestCase[testId][%NUM_ASSERT_ERROR] = "0"
	wvTestCase[testId][%STATUS] = IUTF_STATUS_RUNNING

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
	else
		Notebook HistoryCarbonCopy, getData = 1
		wvTestCase[%CURRENT][%STDOUT] = S_Value
	endif
End

/// @brief End the current test case
static Function TestCaseEnd()
	string name, msg

	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%ENDTIME] = UTF_Reporting#GetTimeString()

	if(!CmpStr(wvTestCase[%CURRENT][%STATUS], IUTF_STATUS_UNKNOWN))
		name = wvTestCase[%CURRENT][%NAME]
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

	Notebook HistoryCarbonCopy, getData = 1
	wvTestCase[%CURRENT][%STDOUT] = S_Value[strlen(wvTestCase[%CURRENT][%STDOUT]), Inf]

	WAVE/T wvTestSuite = UTF_Reporting#GetTestSuiteWave()
	wvTestSuite[%CURRENT][%STDOUT] += wvTestCase[%CURRENT][%STDOUT]
	wvTestSuite[%CURRENT][%STDERR] += wvTestCase[%CURRENT][%STDERR]
	wvTestSuite[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT]) + str2num(wvTestCase[%CURRENT][%NUM_ASSERT]))
	wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]) + str2num(wvTestCase[%CURRENT][%NUM_ASSERT_ERROR]))
End
