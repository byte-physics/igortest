#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Reporting

static Constant IP8_PRINTF_STR_MAX_LENGTH = 2400

/// @brief Get the current time in seconds since the start of the computer. This conversion is
/// required as the time has to be stored in a TextGrid later.
static Function/S GetTimeString()
	string msg

	sprintf msg, "%.6f", StopMSTimer(-2) * IUTF_MICRO_TO_ONE
	return msg
End

/// @brief Set parentWave[%CURRENT][%CHILD_END] to the length of the child wave. This is recommended
/// to do after a row is added to the child wave or a new entry in the parent wave is created.
///
/// @param parentWave   the parent wave to update
/// @param childWave    the child wave to get the length
/// @param init         [optional, default 0] if set to non zero this will also set
///                     parentWave[%CURRENT][%CHILD_START] to the length of the child wave.
static Function UpdateChildRange(parentWave, childWave, [init])
	WAVE/T parentWave, childWave
	variable init

	variable length = UTF_Utils_Vector#GetLength(childWave)

	init = ParamIsDefault(init) ? 0 : !!init

	if(init)
		parentWave[%CURRENT][%CHILD_START] = num2istr(length)
	endif
	parentWave[%CURRENT][%CHILD_END] = num2istr(length)
End

/// @brief Get the results wave for the whole test run. This wave contains the following column
/// dimension labels:
///   - HOSTNAME: the name of the computer
///   - USERNAME: the username for which Igor is run
///   - STARTTIME: time in seconds (since since computer start) when this test run was started
///   - ENDTIME: time in seconds (since since computer start) when this test run was finished. Empty
///     if still running.
///   - NUM_ERROR: number of failed test cases
///   - NUM_SKIPPED: number of skipped test cases
///   - NUM_TESTS: number of test cases
///   - NUM_ASSERT: number of called assertions in all test cases
///   - NUM_ASSERT_ERROR: number of failed or errored assertions in all test cases
///   - SYSTEMINFO: information of the current system
///   - IGORINFO: information of the current igor instance
///   - VERSION: version number of the used UTF
///   - EXPERIMENT: name of the experiment file
///   - CHILD_START: the start index (inclusive) for all test suites that belong to this test run
///   - CHILD_END: the end index (exclusive) for all test suites that belong to this test run
static Function/WAVE GetTestRunWave()
	DFREF dfr = GetPackageFolder()
	string name = "TestRunResult"
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	WAVE/T wv = UTF_Utils_TextGrid#Create("HOSTNAME;USERNAME;STARTTIME;ENDTIME;NUM_ERROR;NUM_SKIPPED;NUM_TESTS;NUM_ASSERT;NUM_ASSERT_ERROR;SYSTEMINFO;IGORINFO;VERSION;EXPERIMENT;CHILD_START;CHILD_END;")
	MoveWave wv, dfr:$name

	wv[0][%HOSTNAME] = "localhost"
#if (IgorVersion() >= 7.00)
	strswitch(IgorInfo(2))
		case "Windows":
			wv[0][%HOSTNAME] = GetEnvironmentVariable("COMPUTERNAME")
			break
		case "Macintosh":
			wv[0][%HOSTNAME] = GetEnvironmentVariable("HOSTNAME")
			break
		default:
			break
	endswitch
	wv[0][%USERNAME] = IgorInfo(7)
#endif
	wv[0][%NUM_ERROR] = "0"
	wv[0][%NUM_SKIPPED] = "0"
	wv[0][%NUM_TESTS] = "0"
	wv[0][%NUM_ASSERT] = "0"
	wv[0][%NUM_ASSERT_ERROR] = "0"
	wv[0][%SYSTEMINFO] = IgorInfo(3)
	wv[0][%IGORINFO] = IgorInfo(0)
	wv[0][%VERSION] = UTF_Basics#GetVersion()
	wv[0][%EXPERIMENT] = IgorInfo(1)
	wv[0][%CHILD_START] = "0"
	wv[0][%CHILD_END] = "0"

	SetDimLabel UTF_ROW, 0, CURRENT, wv

	return wv
End

/// @brief Get the results wave for the test suites. This wave contains the following column
/// dimension labels:
///   - PROCEDURENAME: the name of the procedure file
///   - STARTTIME: time in seconds (since since computer start) when this test suite was started
///   - ENDTIME: time in seconds (since since computer start) when this test suite was finished.
///     Empty if still running.
///   - NUM_ERROR: number of failed test cases
///   - NUM_SKIPPED: number of skipped test cases
///   - NUM_TESTS: number of test cases
///   - NUM_ASSERT: number of called assertions in all test cases
///   - NUM_ASSERT_ERROR: number of failed or errored assertions in all test cases
///   - STDOUT: the copy of the output that was printed to the history during execution of this test
///     suite
///   - STDERR: the error messages that are collected during execution of this test suite
///   - CHILD_START: the start index (inclusive) for all test cases that belong to this test suite
///   - CHILD_END: the end index (exclusive) for all test cases that belong to this test suite
static Function/WAVE GetTestSuiteWave()
	DFREF dfr = GetPackageFolder()
	string name = "TestSuiteResult"
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	WAVE/T wv = UTF_Utils_TextGrid#Create("PROCEDURENAME;STARTTIME;ENDTIME;NUM_ERROR;NUM_SKIPPED;NUM_TESTS;NUM_ASSERT;NUM_ASSERT_ERROR;STDOUT;STDERR;CHILD_START;CHILD_END;")
	MoveWave wv, dfr:$name

	return wv
End

/// @brief Get the results wave for the test cases. This wave contains the following column
/// dimension labels:
///   - NAME: the full name of the testcase
///   - STARTTIME: time in seconds (since since computer start) when this test case was started
///   - ENDTIME: time in seconds (since since computer start) when this test case was finished.
///     Empty if still running.
///   - STATUS: The resulting status of this test case. Its one of IUTF_STATUS_UNKNOWN,
///     IUTF_STATUS_ERROR, IUTF_STATUS_FAIL, IUTF_STATUS_SKIP or IUTF_STATUS_SUCCESS.
///   - NUM_ASSERT: number of called assertions in this test case
///   - NUM_ASSERT_ERROR: number of failed or errored assertions in this test case
///   - STDOUT: the copy of the output that was printed to the history during execution of this test
///     case
///   - STDERR: the error messages that are collected during execution of this test case
///   - CHILD_START: the start index (inclusive) for all assertion that belong to this test case
///   - CHILD_END: the end index (exclusive) for all assertion that belong to this test case
static Function/WAVE GetTestCaseWave()
	DFREF dfr = GetPackageFolder()
	string name = "TestCaseResult"
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	WAVE/T wv = UTF_Utils_TextGrid#Create("NAME;STARTTIME;ENDTIME;STATUS;NUM_ASSERT;NUM_ASSERT_ERROR;STDOUT;STDERR;CHILD_START;CHILD_END;")
	MoveWave wv, dfr:$name

	return wv
End

/// @brief Get the results wave for the test assertions. This wave contains the following column
/// dimension labels:
///   - MESSAGE: the full message of this assertion
///   - TYPE: the type of this assertion. Currently used are IUTF_STATUS_ERROR and IUTF_STATUS_FAIL.
///   - STACKTRACE: the partial stack trace between the entry of the test case and the call of the
///     assertion
///   - CHILD_START: the start index (inclusive) for all information that belong to this assertion
///   - CHILD_END: the end index (exclusive) for all information that belong to this assertion
static Function/WAVE GetTestAssertionWave()
	DFREF dfr = GetPackageFolder()
	string name = "TestAssertionResult"
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	WAVE/T wv = UTF_Utils_TextGrid#Create("MESSAGE;TYPE;STACKTRACE;CHILD_START;CHILD_END;")
	MoveWave wv, dfr:$name

	return wv
End

/// @brief Get the results wave for the test information. This wave contains the following column
/// dimension labels:
///   - MESSAGE: the full information text for the parent assertion
static Function/WAVE GetTestInfoWave()
	DFREF dfr = GetPackageFolder()
	string name = "TestInfoResult"
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	WAVE/T wv = UTF_Utils_TextGrid#Create("MESSAGE;")
	MoveWave wv, dfr:$name

	return wv
End

static Function ClearTestResultWaves()
	WAVE/T wvTestRun = GetTestRunWave()
	WAVE/T wvTestSuite = GetTestSuiteWave()
	WAVE/T wvTestCase = GetTestCaseWave()
	WAVE/T wvAssertion = GetTestAssertionWave()
	WAVE/T wvInfo = GetTestInfoWave()

	KillWaves wvTestRun, wvTestSuite, wvTestCase, wvAssertion, wvInfo
End

/// @brief Add a failed assertion to the current test case.
/// @param message      The message to add to this assertion.
/// @param type         The type of failed assertion
/// @param updateStatus [optional, default enabled] If set different to zero it will update the
///                     resulting status of the current testcase to the specified type. This will
///                     also increment the current assertion error counter of the test case.
static Function AddError(message, type, [updateStatus])
	string message, type
	variable updateStatus

	WAVE/T wvAssertion = GetTestAssertionWave()
	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr/Z AssertionInfo

	updateStatus = ParamIsDefault(updateStatus) ? 1 : !!updateStatus

	UTF_Utils_Vector#AddRow(wvAssertion)
	wvAssertion[%CURRENT][%MESSAGE] = message
	wvAssertion[%CURRENT][%TYPE] = type

	WAVE/T wvTestCase = GetTestCaseWave()
	UpdateChildRange(wvTestCase, wvAssertion)
	if(updateStatus)
		wvTestCase[%CURRENT][%STATUS] = type
	endif
	if(strlen(message))
		wvTestCase[%CURRENT][%STDERR] = AddListItem(message, wvTestCase[%CURRENT][%STDERR], "\n", Inf)
	endif

	WAVE/T wvInfo = GetTestInfoWave()
	UpdateChildRange(wvAssertion, wvInfo, init = 1)

	if(SVAR_Exists(AssertionInfo) && strlen(AssertionInfo))
		UTF_Utils_Vector#AddRow(wvInfo)
		UpdateChildRange(wvAssertion, wvInfo)
		wvInfo[%CURRENT][%MESSAGE] = AssertionInfo
	endif
End

/// Increments the assertion counter for the current test case
static Function incrAssert()
	WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestCase[%CURRENT][%NUM_ASSERT]) + 1)
End

/// Get or create the wave that contains the failed procedures
static Function/WAVE GetFailedProcWave()
	string name = "FailedProcWave"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/T/N=(IUTF_WAVECHUNK_SIZE) dfr:$name/WAVE=wv
	UTF_Utils_Vector#SetLength(wv, 0)

	return wv
End

/// @brief Add msg to the failed summary. This list will be printed to the
///        history area to reference errors briefly.
///
/// @param msg  The message to add to list
static Function AddFailedSummaryInfo(msg)
	string msg

	variable index
	WAVE/T wvFailed = GetFailedProcWave()

	index = UTF_Utils_Vector#GetLength(wvFailed)
	UTF_Utils_Vector#EnsureCapacity(wvFailed, index)
	UTF_Utils_Vector#SetLength(wvFailed, index + 1)
	wvFailed[index] = msg
End

/// Adds a string to the system error log, it is reset at each test case begin
static Function UTF_ToSystemErrorStream(message)
	string message

	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr systemErr

	systemErr += message + "\r"
End

/// Make a test case fail. This method is intended to use outside the user code
/// of the test case as such as it won't look in the stack trace which assertion
/// triggered the error.
///
/// This method is a short version of
/// 	ReportResults(0, msg, OUTPUT_MESSAGE | INCREASE_ERROR)
/// without the stack trace detection and special handling of output.
///
/// @param message  The message to output to the history
/// @param summaryMsg (optional, default is message) The message to output in the summary at the
///                 end of the test run. If this parameter is ommited it will use message for the
///                 summary.
/// @param hideInSummary (optional, default disabled) If set to non zero it will hide this message
///                 in the summary at the end of the test run.
/// @param  incrErrorCounter (optional, default enabled) Enabled if set to a value different to 0.
///                 Increases the internal error counter.
static Function TestCaseFail(message, [summaryMsg, hideInSummary, incrErrorCounter])
	string message
	string summaryMsg
	variable hideInSummary, incrErrorCounter

	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr type
	SVAR/SDFR=dfr/Z AssertionInfo

	summaryMsg = SelectString(ParamIsDefault(summaryMsg), summaryMsg, message)
	hideInSummary = ParamIsDefault(hideInSummary) ? 0 : !!hideInSummary
	incrErrorCounter = ParamIsDefault(incrErrorCounter) ? 1 : !!incrErrorCounter

	if(incrErrorCounter)
		AddError(message, IUTF_STATUS_ERROR)
	endif

	UTF_Basics#SetTestStatus(message)
	type = "FAIL"
	ReportError(message, incrErrorCounter = incrErrorCounter)
	if(SVAR_Exists(AssertionInfo) && strlen(AssertionInfo))
		ReportError(AssertionInfo, incrErrorCounter = 0)
	endif

	if(!hideInSummary)
		AddFailedSummaryInfo(summaryMsg)
	endif
End

/// Prints an informative message that the test failed
///
/// @param expectedFailure if set to non zero the error will be considered as expected
static Function PrintFailInfo(expectedFailure)
	variable expectedFailure

	string prefix, str

	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr status

	if(!expectedFailure)
		AddError("", IUTF_STATUS_FAIL, updateStatus = 0)
	endif

	prefix = SelectString(expectedFailure, "", "Expected Failure: ")
	str = UTF_Basics#getInfo(0, expectedFailure)
	message = prefix + status + " " + str

	if(!expectedFailure)
		WAVE/T wvAssertion = GetTestAssertionWave()
		WAVE/T wvTestCase = GetTestCaseWave()

		wvAssertion[%CURRENT][%MESSAGE] = message
		wvTestCase[%CURRENT][%STDERR] = AddListItem(message, wvTestCase[%CURRENT][%STDERR], "\n", Inf)
	endif

	TestCaseFail(message, summaryMsg = str, hideInSummary = !!expectedFailure, incrErrorCounter = 0)
End

/// @brief Wrapper function result reporting. This functions should only be called for
///        assertions in user test cases. For internal errors use ReportError* functions.
///
/// @param result Return value of a check function from `unit-testing-assertion-checks.ipf`
/// @param str    Message string
/// @param flags  Wrapper function `flags` argument
/// @param cleanupInfo [optional, default enabled] If set different to zero it will cleanup
///               any assertion info message at the end of this function.
///               Cleanup is enforced if flags contains the ABORT_FUNCTION flag.
static Function ReportResults(result, str, flags, [cleanupInfo])
	variable result, flags
	string str
	variable cleanupInfo

	variable expectedFailure

	cleanupInfo = ParamIsDefault(cleanupInfo) ? 1 : !!cleanupInfo

	SetTestStatusAndDebug(str, result)

	if(!result)
		expectedFailure = IsExpectedFailure()

		if(flags & OUTPUT_MESSAGE)
			PrintFailInfo(expectedFailure)
		endif

		if(!expectedFailure)
			if(flags & INCREASE_ERROR)
				incrError()

				WAVE/T wvTestCase = UTF_Reporting#GetTestCaseWave()
				wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_FAIL
			endif
			if(flags & ABORT_FUNCTION)
				UTF_Basics#CleanupInfoMsg()
				UTF_Basics#setAbortFlag()
				Abort
			endif
		endif
	endif

	if(cleanupInfo)
		UTF_Basics#CleanupInfoMsg()
	endif
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

/// @brief Reports an internal error.
/// The execution of the current testcase will NOT be aborted!
///
/// @param	message		The message to output to the history.
/// @param  incrErrorCounter (optional, default enabled) Enabled if set to a value different to 0.
///                     Increases the internal error counter.
static Function ReportError(message, [incrErrorCounter])
	string message
	variable incrErrorCounter

	incrErrorCounter = ParamIsDefault(incrErrorCounter) ? 1 : !!incrErrorCounter

	UTF_PrintStatusMessage(message)
	UTF_ToSystemErrorStream(message)
	if(incrErrorCounter)
		incrError()
	endif
End

/// @brief Reports an internal error that prevents further execution of the current test case.
/// The current testcase is always aborted afterwards.
///
/// @param	message		The message to output to the history.
/// @param  setFlagOnly (optiona, default: 0) If set to zero it will call abort at the end of
///                     the execution. If set to something different to zero it will only set
///                     the abort flag.
static Function ReportErrorAndAbort(message, [setFlagOnly])
	string message
	variable setFlagOnly

	setFlagOnly = ParamIsDefault(setFlagOnly) ? 0 : !!setFlagOnly

	ReportError("Fatal: " + message, incrErrorCounter = 1)
	UTF_Basics#setAbortFlag()
	if(!setFlagOnly)
		Abort
	endif
End
