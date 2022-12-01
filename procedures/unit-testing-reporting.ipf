#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Reporting

static Constant IP8_PRINTF_STR_MAX_LENGTH = 2400

/// Get or create the wave that contains the failed procedures
static Function/WAVE GetFailedProcWave()
	string name = "FailedProcWave"

	dfref dfr = GetPackageFolder()
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

	UTF_Basics#SetTestStatus(message)
	type = "FAIL"
	ReportError(message, incrErrorCounter = incrErrorCounter)
	if(SVAR_Exists(AssertionInfo) && strlen(AssertionInfo))
		ReportError(AssertionInfo, incrErrorCounter = 0)
	endif

	if(!hideInSummary)
		AddFailedSummaryInfo(summaryMsg)
	endif

	if(TAP_IsOutputEnabled())
		SVAR/SDFR=dfr tap_diagnostic
		tap_diagnostic = tap_diagnostic + message
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

	prefix = SelectString(expectedFailure, "", "Expected Failure: ")
	str = UTF_Basics#getInfo(0)
	message = prefix + status + " " + str

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
