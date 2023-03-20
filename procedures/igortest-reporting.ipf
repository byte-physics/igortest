#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Reporting

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

	variable length = IUTF_Utils_Vector#GetLength(childWave)

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
///   - VERSION: version number of the used IUTF
///   - EXPERIMENT: name of the experiment file
///   - CHILD_START: the start index (inclusive) for all test suites that belong to this test run
///   - CHILD_END: the end index (exclusive) for all test suites that belong to this test run
///
/// Warning: You have to initialize the TestRunWave with IUTF_Reporting_Control#SetupTestRun()
/// before its first usage. This should usually be done at the start of IUTF_Basics#RunTest() after
/// clearing the waves.
static Function/WAVE GetTestRunWave()
	DFREF dfr = GetPackageFolder()
	string name = "TestRunResult"
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	WAVE/T wv = IUTF_Utils_TextGrid#Create("HOSTNAME;USERNAME;STARTTIME;ENDTIME;NUM_ERROR;NUM_SKIPPED;NUM_TESTS;NUM_ASSERT;NUM_ASSERT_ERROR;SYSTEMINFO;IGORINFO;VERSION;EXPERIMENT;CHILD_START;CHILD_END;")
	MoveWave wv, dfr:$name

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

	WAVE/T wv = IUTF_Utils_TextGrid#Create("PROCEDURENAME;STARTTIME;ENDTIME;NUM_ERROR;NUM_SKIPPED;NUM_TESTS;NUM_ASSERT;NUM_ASSERT_ERROR;STDOUT;STDERR;CHILD_START;CHILD_END;")
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
///     IUTF_STATUS_ERROR, IUTF_STATUS_FAIL, IUTF_STATUS_SKIP, IUTF_STATUS_SUCCESS or
///     IUTF_STATUS_RETRY.
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

	WAVE/T wv = IUTF_Utils_TextGrid#Create("NAME;STARTTIME;ENDTIME;STATUS;NUM_ASSERT;NUM_ASSERT_ERROR;STDOUT;STDERR;CHILD_START;CHILD_END;")
	MoveWave wv, dfr:$name

	return wv
End

/// @brief Get the results wave for the test assertions. This wave contains the following column
/// dimension labels:
///   - MESSAGE: the full message of this assertion
///   - TYPE: the type of this assertion. Currently used are IUTF_STATUS_ERROR and IUTF_STATUS_FAIL.
///   - SEVERITY: the severity of this assertion. Currently used are IUTF_SEVERITY_WARN and
///     IUTF_SEVERITY_ERROR.
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

	WAVE/T wv = IUTF_Utils_TextGrid#Create("MESSAGE;TYPE;SEVERITY;STACKTRACE;CHILD_START;CHILD_END;")
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

	WAVE/T wv = IUTF_Utils_TextGrid#Create("MESSAGE;")
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
/// @param message          The message to add to this assertion.
/// @param type             The type of failed assertion
/// @param incrErrorCounter [optional, default enabled] If set different to zero it  will increment
///                         the current assertion error counter of the current test case.
static Function AddError(message, type, [incrErrorCounter])
	string message, type
	variable incrErrorCounter

	string msg
	variable i, length, startIndex

	incrErrorCounter = ParamIsDefault(incrErrorCounter) ? 1 : !!incrErrorCounter

	WAVE/T wvAssertion = GetTestAssertionWave()
	IUTF_Utils_Vector#AddRow(wvAssertion)
	wvAssertion[%CURRENT][%MESSAGE] = message
	wvAssertion[%CURRENT][%TYPE] = type
	wvAssertion[%CURRENT][%SEVERITY] = SelectString(incrErrorCounter, IUTF_SEVERITY_WARN, IUTF_SEVERITY_ERROR)

	WAVE/T wvTestCase = GetTestCaseWave()
	UpdateChildRange(wvTestCase, wvAssertion)
	if(incrErrorCounter)
		wvTestCase[%CURRENT][%STATUS] = type
		wvTestCase[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestCase[%CURRENT][%NUM_ASSERT_ERROR]) + 1)
	endif
	if(!IUTF_Utils#IsEmpty(message))
		wvTestCase[%CURRENT][%STDERR] = AddListItem(message, wvTestCase[%CURRENT][%STDERR], "\n", Inf)
	endif

	WAVE/T wvInfo = GetTestInfoWave()
	UpdateChildRange(wvAssertion, wvInfo, init = 1)

	WAVE/T wvInfoMsg = GetInfoMsg()
	length = IUTF_Utils_Vector#GetLength(wvInfoMsg)
	if(length > 0)
		startIndex = IUTF_Utils_Vector#GetLength(wvInfo)
		IUTF_Utils_Vector#AddRows(wvInfo, length)
		UpdateChildRange(wvAssertion, wvInfo)
		wvInfo[startIndex, startIndex + length - 1][%MESSAGE] = wvInfoMsg[p - startIndex]

		for(i = 0; i < length; i += 1)
			msg = "  " + TC_ASSERTION_INFO_INDICATOR + " " + wvInfoMsg[i]
			wvTestCase[%CURRENT][%STDERR] = AddListItem(msg, wvTestCase[%CURRENT][%STDERR], "\n", Inf)
		endfor
	endif
End

/// Increments the assertion counter for the current test case
static Function incrAssert()
	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%NUM_ASSERT] = num2istr(str2num(wvTestCase[%CURRENT][%NUM_ASSERT]) + 1)
End

/// Increments the global error counter for the complete test run. This wont change the error
/// counter for test cases. Use AddError for these cases.
static Function incrGlobalError()
	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
	wvTestRun[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestRun[%CURRENT][%NUM_ASSERT_ERROR]) + 1)
End

/// Get the wave that can store information for the next assertion. These wave is cleared
/// automatically at the end of the test case or assertion. This wave is considered as a list. Use
/// IUTF_Utils_Waves#GetListLength to retrieve its length.
static Function/WAVE GetInfoMsg()
	DFREF dfr = GetPackageFolder()
	string name = "InfoMsg"
	WAVE/T/Z wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	MAKE/FREE/T/N=(IUTF_WAVECHUNK_SIZE) wv
	IUTF_Utils_Vector#SetLength(wv, 0)
	MoveWave wv, dfr:$name

	return wv
End

/// Clears all stored information for the next assertion. This will only update the length of the
/// list and not its contents.
static Function CleanupInfoMsg()
	WAVE/T wv = GetInfoMsg()

	IUTF_Utils_Vector#SetLength(wv, 0)
	wv[] = ""
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
	IUTF_Utils_Vector#SetLength(wv, 0)

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

	index = IUTF_Utils_Vector#GetLength(wvFailed)
	IUTF_Utils_Vector#EnsureCapacity(wvFailed, index)
	IUTF_Utils_Vector#SetLength(wvFailed, index + 1)
	wvFailed[index] = msg
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
///                 end of the test run. If this parameter is omitted it will use message for the
///                 summary.
/// @param isFailure (optional, default disabled) If set to non zero this will be handled as a
///                 FAILURE instead an ERROR. This changes the following:
///                 - the test case status is set to IUTF_STATUS_FAIL
///                 - updateStatus is set to 0 in AddError
/// @param incrErrorCounter (optional, default enabled) Enabled if set to a value different to 0.
///                 Increases the assertion error counter for the current test case.
static Function TestCaseFail(message, [summaryMsg, isFailure, incrErrorCounter])
	string message
	string summaryMsg
	variable isFailure, incrErrorCounter

	variable i, length

	summaryMsg = SelectString(ParamIsDefault(summaryMsg), summaryMsg, message)
	isFailure = ParamIsDefault(isFailure) ? 0 : !!isFailure
	incrErrorCounter = ParamIsDefault(incrErrorCounter) ? 1 : !!incrErrorCounter

	AddError(message, SelectString(isFailure, IUTF_STATUS_ERROR, IUTF_STATUS_FAIL), incrErrorCounter = incrErrorCounter)

	// We are increasing the local error counter so there is no need to increase the global error
	// counter.
	ReportError(message, incrGlobalErrorCounter = 0)
	WAVE/T wvInfoMsg = GetInfoMsg()
	length = IUTF_Utils_Vector#GetLength(wvInfoMsg)
	for(i = 0; i < length; i += 1)
		ReportError("  " + TC_ASSERTION_INFO_INDICATOR + " " + wvInfoMsg[i], incrGlobalErrorCounter = 0)
	endfor

	AddFailedSummaryInfo(summaryMsg)
End

/// Prints an informative message that the test case failed
///
/// @param message          the fail message to print to the output
/// @param expectedFailure  if set to non zero the error will be considered as expected
/// @param incrErrorCounter if set to non zero the assertion error counter for the current test case
///                         will be updated. This setting is ignored if expectedFailure is set to
///                         non zero
/// @param callStack        [optional, default current callStack] Can be used to set the callStack
///                         to a previous recorded callStack (GetRTStackInfo(3)).
static Function PrintFailInfo(message, expectedFailure, incrErrorCounter, [callStack])
	string message
	variable expectedFailure, incrErrorCounter
	string callStack

	string str, partialStack
	string prefix = SelectString(expectedFailure, "", "Expected Failure: ")

	if(ParamIsDefault(callStack))
		str = getInfo(0, partialStack)
	else
		str = getInfo(0, partialStack, callStack = callStack)
	endif
	message = prefix + message + " " + str

	TestCaseFail(message, summaryMsg = str, isFailure = 1, incrErrorCounter = incrErrorCounter)

	if(!expectedFailure)
		WAVE/T wvAssertion = GetTestAssertionWave()
		wvAssertion[%CURRENT][%STACKTRACE] = partialStack
	endif
End

/// @brief returns the informative message about the assertions state and location.
///
/// @param result            Assertion states: 0 failed, 1 succeeded
/// @param[out] partialStack The partial stacktrace between the entry of the test case and the call
///                          of the assertion.
/// @param callStack         [optional, default current callStack] Can be used to set the callStack
///                          to a previous recorded callStack (GetRTStackInfo(3)).
///
/// @returns The informative message
static Function/S getInfo(result, partialStack, [callStack])
	variable result
	string &partialStack
	string callStack

	string caller, func, procedure, contents, moduleName
	string text, cleanText, line, callerTestCase, tmpStr
	variable numCallers, i, assertLine, err
	variable callerIndex = NaN
	variable testCaseIndex

	callStack = SelectString(ParamIsDefault(callStack), callStack, GetRTStackInfo(3))
	numCallers = ItemsInList(callStack)
	moduleName = ""
	partialStack = ""

	// traverse the callstack from bottom up,
	// the first function not in one of the igortest procedures is
	// the one we want to report. Except if helper functions are involved.
	for(i = numCallers - 1; i >= 0; i -= 1)
		caller    = StringFromList(i, callStack)
		procedure = StringFromList(1, caller, ",")

		if(StringMatch(procedure, "igortest*"))
			if(IUTF_Utils#IsNaN(callerIndex))
				continue
			endif
			testCaseIndex = i + 1
			break
		else
			if(IUTF_Utils#IsNaN(callerIndex))
				callerIndex = i
			endif
		endif
	endfor

	if(IUTF_Utils#IsNaN(callerIndex))
		WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
		if(str2num(wvTestCase[%CURRENT][%NUM_ASSERT]) == 0)
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

	text = IUTF_Basics#getFullFunctionName(err, func, procedure)
	if(!err)
		func = text
	endif

	if(callerIndex != testcaseIndex)
		tmpStr = StringFromList(0, callerTestCase, ",")
		text = IUTF_Basics#getFullFunctionName(err, tmpStr, StringFromList(1, callerTestCase, ","))
		if(!err)
			tmpStr = text
		endif

		func = tmpStr + TC_ASSERTION_MLINE_INDICATOR + func
		line = StringFromList(2, callerTestCase, ",") + TC_ASSERTION_MLINE_INDICATOR + line
	endif

	for(i = testcaseIndex; i <= callerIndex; i += 1)
		partialStack = AddListItem(StringFromList(i, callStack), partialStack, ";", Inf)
	endfor

	if(!IUTF_Basics#IsProcGlobal())
		moduleName = " [" + GetIndependentModuleName() + "]"
	endif

	contents = ProcedureText("", -1, procedure + moduleName)
	text = StringFromList(assertLine, contents, "\r")

	cleanText = trimstring(text)

	tmpStr = IUTF_Utils#IUTF_PrepareStringForOut(cleanText)
	sprintf text, "Assertion \"%s\" %s in %s%s (%s, line %s)", tmpStr, SelectString(result, "failed", "succeeded"), func, moduleName, procedure, line
	return text
End

/// @brief Wrapper function result reporting. This functions should only be called for
///        assertions in user test cases. For internal errors use ReportError* functions.
///
/// @param result Return value of a check function from `igortest-assertion-checks.ipf`
/// @param str    Message string
/// @param flags  Wrapper function `flags` argument
/// @param cleanupInfo [optional, default enabled] If set different to zero it will cleanup
///               any assertion info message at the end of this function.
///               Cleanup is enforced if flags contains the ABORT_FUNCTION flag.
/// @param callStack [optional, default current callStack] Can be used to set the callStack
///               to a previous recorded callStack (GetRTStackInfo(3)).
static Function ReportResults(result, str, flags, [cleanupInfo, callStack])
	variable result, flags
	string str
	variable cleanupInfo
	string callStack

	variable expectedFailure

	cleanupInfo = ParamIsDefault(cleanupInfo) ? 1 : !!cleanupInfo

	IUTF_Debug#DebugOutput(str, result)

	if(!result)
		expectedFailure = IsExpectedFailure()

		if(flags & OUTPUT_MESSAGE)
			if(ParamIsDefault(callStack))
				PrintFailInfo(str, expectedFailure, flags & INCREASE_ERROR)
			else
				PrintFailInfo(str, expectedFailure, flags & INCREASE_ERROR, callStack = callStack)
			endif
		endif

		if(!expectedFailure && (flags & ABORT_FUNCTION))
			IUTF_Reporting#CleanupInfoMsg()
			IUTF_Basics#setAbortFlag()
			Abort
		endif
	endif

	if(cleanupInfo)
		IUTF_Reporting#CleanupInfoMsg()
	endif
End

/// @brief Print the given message to the Igor history area and to stdout (IP8 only)
///
/// Always use this function if you want to inform the user about something.
///
/// @param msg message to be outputted, without trailing end-of-line
/// @param allowEmptyLine (optional, default 0 disabled) If set to 1 it will allow to print empty
///            strings to the output. The default behavior is to skip printing empty strings.
threadsafe static Function IUTF_PrintStatusMessage(msg, [allowEmptyLine])
	string msg
	variable allowEmptyLine

	string tmpStr
	variable len

	allowEmptyLine = ParamIsDefault(allowEmptyLine) ? 0 : !!allowEmptyLine

	// Copy of IUTF_Tracing#IsNull() and IUTF_Tracing#IsEmpty().
	// These functions cannot be used here as in Igor <= 8.0 can no threadsafe function use another
	// static threadsafe function with the full name when using Independent Modules.
	len = strlen(msg)
	if(!allowEmptyLine && (numtype(len) == 2 || len <= 0))
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
	tmpStr = IUTF_PrepareStringForOut(msg, maxLen = IP8_PRINTF_STR_MAX_LENGTH - 2)
	fprintf -1, "%s\r\n", tmpStr
#endif
End

/// @brief Reports an internal error.
/// The execution of the current testcase will NOT be aborted!
///
/// @param	message		The message to output to the history.
/// @param  incrGlobalErrorCounter (optional, default enabled) Enabled if set to a value different
///                     to 0. Increases the global error counter.
static Function ReportError(message, [incrGlobalErrorCounter])
	string message
	variable incrGlobalErrorCounter

	variable currentIndex

	incrGlobalErrorCounter = ParamIsDefault(incrGlobalErrorCounter) ? 1 : !!incrGlobalErrorCounter

	IUTF_PrintStatusMessage(message)

	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	currentIndex = FindDimLabel(wvTestCase, UTF_COLUMN, "CURRENT")
	if(currentIndex >= 0)
		wvTestCase[currentIndex][%STDERR] += message + "\r"
	endif

	if(incrGlobalErrorCounter)
		incrGlobalError()
	endif
End

/// @brief Reports an internal error that prevents further execution of the current test case.
/// The current testcase is always aborted afterwards.
///
/// @param	message		The message to output to the history.
/// @param  setFlagOnly (optional, default: 0) If set to zero it will call abort at the end of
///                     the execution. If set to something different to zero it will only set
///                     the abort flag.
static Function ReportErrorAndAbort(message, [setFlagOnly])
	string message
	variable setFlagOnly

	setFlagOnly = ParamIsDefault(setFlagOnly) ? 0 : !!setFlagOnly

	ReportError("Fatal: " + message, incrGlobalErrorCounter = 1)
	IUTF_Basics#setAbortFlag()
	if(!setFlagOnly)
		Abort
	endif
End
