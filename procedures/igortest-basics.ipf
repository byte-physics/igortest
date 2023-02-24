#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Basics


///@cond HIDDEN_SYMBOL

static Constant FFNAME_OK        = 0x00
static Constant FFNAME_NOT_FOUND = 0x01
static Constant FFNAME_NO_MODULE = 0x02
static Constant TC_MATCH_OK      = 0x00
static Constant TC_REGEX_INVALID = 0x04
static Constant TC_NOT_FOUND     = 0x08
static Constant TC_LIST_EMPTY    = 0x10
static Constant GREPLIST_ERROR   = 0x20

static Constant IGOR_MAX_DIMENSIONS = 4

static StrConstant FIXED_LOG_FILENAME = "IUTF_Test"

static StrConstant NO_SOURCE_PROCEDURE = "No source procedure"

static StrConstant BACKGROUNDMONTASK   = "IUTFBackgroundMonitor"
static StrConstant BACKGROUNDMONFUNC   = "IUTFBackgroundMonitor"
static StrConstant BACKGROUNDINFOSTR   = ":UNUSED_FOR_REENTRY:"

static Constant TC_MODE_NORMAL = 0
static Constant TC_MODE_MD = 1
static Constant TC_MODE_MMD = 2

/// @brief Returns a global wave that stores data about this testrun
static Function/WAVE GetTestRunData()

	string name = "TestRunData"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/T/N=(0, 6) dfr:$name/WAVE=wv

	SetDimLabel UTF_COLUMN, 0, PROCWIN, wv
	SetDimLabel UTF_COLUMN, 1, TESTCASE, wv
	SetDimLabel UTF_COLUMN, 2, FULLFUNCNAME, wv
	SetDimLabel UTF_COLUMN, 3, DGENLIST, wv
	SetDimLabel UTF_COLUMN, 4, SKIP, wv
	SetDimLabel UTF_COLUMN, 5, EXPECTFAIL, wv

	return wv
End

/// @brief Helper function for try/catch with AbortOnRTE
///
/// Not clearing the RTE before calling `AbortOnRTE` will always trigger the RTE no
/// matter what you do in that line.
///
/// Usage:
/// @code
///
///    try
///       ClearRTError()
///       myFunc(); AbortOnRTE
///    catch
///      err = GetRTError(1)
///    endtry
///
/// @endcode
static Function ClearRTError()

	variable err = GetRTError(1)
End

/// @brief Convert the mode parameter for `EqualWaves` to a string
Function/S EqualWavesModeToString(mode)
	variable mode

	switch(mode)
		case WAVE_DATA:
			return "WAVE_DATA"
		case WAVE_DATA_TYPE:
			return "WAVE_DATA_TYPE"
		case WAVE_SCALING:
			return "WAVE_SCALING"
		case DATA_UNITS:
			return "DATA_UNITS"
		case DIMENSION_UNITS:
			return "DIMENSION_UNITS"
		case DIMENSION_LABELS:
			return "DIMENSION_LABELS"
		case WAVE_NOTE:
			return "WAVE_NOTE"
		case WAVE_LOCK_STATE:
			return "WAVE_LOCK_STATE"
		case DATA_FULL_SCALE:
			return "DATA_FULL_SCALE"
		case DIMENSION_SIZES:
			return "DIMENSION_SIZES"
		default:
			return "unknown mode"
	endswitch
End

/// @class FUNC_REF_IS_ASSIGNED_DOCU
/// @brief Check wether the function reference points to
/// the prototype function or to an assigned function
///
/// Due to Igor Pro limitations you need to pass the function
/// info from `FuncRefInfo` and not the function reference itself.
///
/// @return 0 if pointing to prototype function, 1 otherwise
Function IUTF_FuncRefIsAssigned(funcInfo)
	string funcInfo

	return NumberByKey("ISPROTO", funcInfo) == 0
End

/// @copydoc FUNC_REF_IS_ASSIGNED_DOCU
/// @deprecated Use IUTF_FuncRefIsAssigned instead
Function UTF_FuncRefIsAssigned(funcInfo)
	string funcInfo

	return IUTF_FuncRefIsAssigned(funcInfo)
End

/// @brief Return a free text wave with the dimension labels of the
///        given dimension of the wave
static Function/WAVE GetDimLabels(wv, dim)
	WAVE/Z wv
	variable dim

	variable size

	if(!WaveExists(wv))
		return $""
	endif

	size = DimSize(wv, dim)

	if(size == 0)
		return $""
	endif

	Make/FREE/T/N=(size) labels = GetDimLabel(wv, dim, p)

	return labels
End

/// @brief Create a diagnostic message of the differing dimension labels
///
/// @param[in] wv1  Possible non-existing wave
/// @param[in] wv2  Possible non-existing wave
/// @param[out] str Diagnostic message indicating the deviations, empty string on success
///
/// @return 1 with no differences, 0 with differences
Function GenerateDimLabelDifference(wv1, wv2, msg)
	WAVE/Z wv1, wv2
	string &msg

	variable i, j, numEntries
	string str1, str2, tmpStr1, tmpStr2
	variable ret

	msg = ""

	for(i = 0; i < IGOR_MAX_DIMENSIONS; i += 1)

		WAVE/T/Z label1 = GetDimLabels(wv1, i)
		WAVE/T/Z label2 = GetDimLabels(wv2, i)

		if(!WaveExists(label1) && !WaveExists(label2))
			break
		endif

		if(!WaveExists(label1))
			sprintf msg, "Empty dimension vs non-empty dimension"
			return 0
		elseif(!WaveExists(label2))
			sprintf msg, "Non-empty dimension vs empty dimension"
			return 0
		else
			 // both exist but differ
			str1 = GetDimLabel(wv1, i, -1)
			str2 = GetDimLabel(wv2, i, -1)

			if(cmpstr(str1, str2))
				tmpStr1 = IUTF_Utils#IUTF_PrepareStringForOut(str1)
				tmpStr2 = IUTF_Utils#IUTF_PrepareStringForOut(str2)
				sprintf msg, "Dimension labels for the entire dimension %d differ: %s vs %s", i, tmpStr1, tmpStr2
				return 0
			endif

			if(EqualWaves(label1, label2, WAVE_DATA))
				continue
			endif

			if(DimSize(label1, i) != DimSize(label2, i))
				sprintf msg, "The sizes for dimension %d don't match: %d vs %d", i, DimSize(label1, i), DimSize(label2, i)
				return 0
			endif

			numEntries = DimSize(label1, i)
			for(j = 0; j < numEntries; j += 1)
				if(!cmpstr(label1[j], label2[j]))
					continue
				endif
				str1 = label1[j]
				str2 = label2[j]
				tmpStr1 = IUTF_Utils#IUTF_PrepareStringForOut(str1)
				tmpStr2 = IUTF_Utils#IUTF_PrepareStringForOut(str2)
				sprintf msg, "Differing dimension label in dimension %d at index %d: %s vs %s", i, j, tmpStr1, tmpStr2
				return 0
			endfor
		endif
	endfor

	return 1
End

Function/S GetVersion()
	string version
	sprintf version, "%.2f", PKG_VERSION

	return version
End

/// Returns the package folder
Function/DF GetPackageFolder()
	if(!DataFolderExists(PKG_FOLDER))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:igortest
	endif

	DFREF dfr = $PKG_FOLDER
	return dfr
End

/// Evaluate the result of an assertion that was used in a testcase. For evaluating internal errors use
/// ReportError* functions.
/// @param result          Set to 0 to signal an error. Any value different to 0 will be considered as success.
/// @param str             The message to report.
/// @param flags           A combination flags that are used by ReportResults() to determine what to do if result
///                        is in an error state.
/// @param cleanupInfo [optional, default enabled] If set different to zero it will cleanup
///               any assertion info message at the end of this function.
///               Cleanup is enforced if flags contains the ABORT_FUNCTION flag.
Function EvaluateResults(result, str, flags, [cleanupInfo])
	variable result, flags
	string str
	variable cleanupInfo

	cleanupInfo = ParamIsDefault(cleanupInfo) ? 1 : !!cleanupInfo

	IUTF_Debug#DebugFailedAssertion(result)
	IUTF_Reporting#ReportResults(result, str, flags, cleanupInfo = cleanupInfo)
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
	DFREF dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 1
End

/// Resets the abort flag
static Function InitAbortFlag()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:abortFlag = 0
End

/// @brief returns 1 if the current testcase is marked as expected failure, zero otherwise
///
/// @returns 1 if the current testcase is marked as expected failure, zero otherwise
Function IsExpectedFailure()
	NVAR/Z/SDFR=GetPackageFolder() expected_failure_flag

	if(NVAR_Exists(expected_failure_flag) && expected_failure_flag == 1)
		return 1
	else
		return 0
	endif
End

/// Sets the expected_failure_flag global
static Function SetExpectedFailure(val)
	variable val

	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr expected_failure_flag

	if(!NVAR_Exists(expected_failure_flag))
		Variable/G dfr:expected_failure_flag
		NVAR/SDFR=dfr expected_failure_flag
	endif

	expected_failure_flag = val
End

/// Return true if running in `ProcGlobal`, false otherwise
static Function IsProcGlobal()

	return !cmpstr("ProcGlobal", GetIndependentModuleName())
End

/// Returns the full name of a function including its module
/// @param &err returns 0 for no error, 1 if function not found, 2 is static function in proc without ModuleName
static Function/S getFullFunctionName(err, funcName, procName)
	variable &err
	string funcName, procName

	err = FFNAME_OK
	string errMsg, module, infoStr, funcNameReturn

	infoStr = FunctionInfo(funcName, procName)

	if(IUTF_Utils#IsEmpty(infoStr))
		sprintf errMsg, "Function %s in procedure file %s is unknown", funcName, procName
		err = FFNAME_NOT_FOUND
		return errMsg
	endif

	funcNameReturn = StringByKey("NAME", infoStr)

	if(!cmpstr(StringByKey("SPECIAL", infoStr), "static"))
		module = StringByKey("MODULE", infoStr)

		// we can only use static functions if they live in a module
		if(IUTF_Utils#IsEmpty(module))
			sprintf errMsg, "The procedure file %s is missing a \"#pragma ModuleName=myName\" declaration.", procName
			err = FFNAME_NO_MODULE
			return errMsg
		endif

		funcNameReturn = module + "#" + funcNameReturn
	endif

	// even if we are running in an independent module we don't need its name prepended as we
	// 1.) run in the same IM anyway
	// 2.) FuncRef does not accept that

	return funcNameReturn
End

/// Evaluates an RTE and puts a composite error message into message/type
static Function EvaluateRTE(err, errmessage, abortCode, funcName, funcType, procWin)
	variable err
	string errmessage
	variable abortCode, funcType
	string funcName
	string procWin

	DFREF dfr = GetPackageFolder()
	string message = ""
	string str, funcTypeString
	variable i, length

	if(!err && !abortCode)
		return NaN
	endif

	switch(funcType)
		case IUTF_TEST_CASE_TYPE:
			funcTypeString = "test case"
			break
		case IUTF_USER_HOOK_TYPE:
			funcTypeString = "user hook"
			break
		case IUTF_DATA_GEN_TYPE:
			funcTypeString = "data generator"
			break
		default:
			IUTF_Reporting#ReportErrorAndAbort("Unknown func type in EvaluateRTE")
			break
	endswitch

	if(err)
		sprintf str, "Uncaught runtime error %d:\"%s\" in %s \"%s\" (%s)", err, errmessage, funcTypeString, funcName, procWin
		IUTF_Reporting#AddFailedSummaryInfo(str)
		IUTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
		message = str
	endif
	if(abortCode != -4)
		str = ""
		switch(abortCode)
			case -1:
				sprintf str, "User aborted Test Run manually in %s \"%s\" (%s)", funcTypeString, funcName, procWin
				IUTF_Reporting#AddFailedSummaryInfo(str)
				IUTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
				break
			case -2:
				sprintf str, "Stack Overflow in %s \"%s\" (%s)", funcTypeString, funcName, procWin
				IUTF_Reporting#AddFailedSummaryInfo(str)
				IUTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
				break
			case -3:
				sprintf str, "Encountered \"Abort\" in %s \"%s\" (%s)", funcTypeString, funcName, procWin
				IUTF_Reporting#AddFailedSummaryInfo(str)
				IUTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
				break
			default:
				break
		endswitch
		message += str
		if(abortCode > 0)
			sprintf str, "Encountered \"AbortOnValue\" Code %d in %s \"%s\" (%s)", abortCode, funcTypeString, funcName, procWin
			IUTF_Reporting#AddFailedSummaryInfo(str)
			IUTF_Reporting#AddError(str, IUTF_STATUS_ERROR)
			message += str
		endif
	endif

	IUTF_Reporting#ReportError(message, incrGlobalErrorCounter = 0)
	WAVE/T wvInfoMsg = IUTF_Reporting#GetInfoMsg()
	length = IUTF_Utils_Vector#GetLength(wvInfoMsg)
	for(i = 0; i < length; i += 1)
		IUTF_Reporting#ReportError(wvInfoMsg[i], incrGlobalErrorCounter = 0)
	endfor

	CheckAbortCondition(abortCode)
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

/// Returns List of Test Functions in Procedure Window procWin
static Function/S GetTestCaseList(procWin)
	string procWin

	string testCaseList = FunctionList("!*_IGNORE", ";", "KIND:18,NPARAMS:0,VALTYPE:1,WIN:" + procWin)
	string testCaseMDList = FunctionList("!*_IGNORE", ";", "KIND:18,NPARAMS:1,VALTYPE:1,WIN:" + procWin)

	testCaseList = GrepList(testCaseList, PROCNAME_NOT_REENTRY)
	testCaseMDList = GrepList(testCaseMDList, PROCNAME_NOT_REENTRY)

	if(!IUTF_Utils#IsEmpty(testCaseMDList))
		testCaseList = testCaseList + testCaseMDList
	endif

	return SortTestCaseList(procWin, testCaseList)
End

/// Returns the list of testcases sorted by line number
static Function/S SortTestCaseList(procWin, testCaseList)
	string procWin, testCaseList

	if(IUTF_Utils#IsEmpty(testCaseList))
		return ""
	endif

	Wave/T testCaseWave = ListToTextWave(testCaseList, ";")

	Make/FREE/N=(ItemsInList(testCaseList)) lineNumberWave
	lineNumberWave[] = str2num(StringByKey("PROCLINE", FunctionInfo(testCaseWave[p], procWin)))

	Sort lineNumberWave, testCaseWave

	return IUTF_Utils#TextWaveToList(testCaseWave, ";")
End

/// @brief get test cases matching a certain pattern and fill TesRunSetup wave
///
/// This function searches for test cases in a given list of test suites. The
/// search can be performed either using a regular expression or on a defined
/// list of test cases. All Matches are checked.
/// The function returns an error
/// * If a given test case is not found
/// * If no test case was found
/// * if fullFunctionName returned an error
///
/// @param[in]  procWinList List of test suites, separated by ";"
/// @param[in]  matchStr    * List of test cases, separated by ";" (enableRegExp = 0)
///                         * *one* regular expression without ";" (enableRegExp = 1)
/// @param[in]  enableRegExp (0,1) defining the type of search for matchStr
/// @param[out] errMsg error message in case of error
///
/// @returns Numeric Error Code
static Function CreateTestRunSetup(procWinList, matchStr, enableRegExp, errMsg, enableTAP, debugMode)
	string procWinList
	string matchStr
	variable enableRegExp
	string &errMsg
	variable enableTAP, debugMode

	string procWin
	string funcName
	string funcList
	string fullFuncName, dgenList
	string testCase, testCaseMatch
	variable numTC, numpWL, numFL, markSkip
	variable i, j, tdIndex
	variable err = TC_MATCH_OK
	variable hasDGen = 0

	if(enableRegExp && !(strsearch(matchStr, ";", 0) < 0))
		errMsg = "semicolon is not allowed in given regex pattern: " + matchStr
		return TC_REGEX_INVALID
	endif

	if(enableRegExp)
		sprintf matchStr, "^(?i)%s$", matchStr
	endif

	WAVE/T testRunData = GetTestRunData()

	numTC = ItemsInList(matchStr)
	numpWL = ItemsInList(procWinList)
	Make/FREE/N=(numTC) usedTC
	for(i = 0; i < numpWL; i += 1)
		procWin = StringFromList(i, procWinList)
		funcList = getTestCaseList(procWin)
		testCaseMatch = ""

		if(enableRegExp)
			try
				ClearRTError()
				testCaseMatch = GrepList(funcList, matchStr, 0, ";"); AbortOnRTE
			catch
				testCaseMatch = ""
				err = GetRTError(1)
				switch(err)
					case 1233:
						errMsg = "Regular expression error: " + matchStr
						err = TC_REGEX_INVALID
						break
					default:
						errMsg = GetErrMessage(err)
						err = GREPLIST_ERROR
				endswitch
				sprintf errMsg, "Error executing GrepList: %s", errMsg
				return err
			endtry
		else
			for(j = 0; j < numTC; j += 1)
				testCase = StringFromList(j, matchStr)
				if(WhichListItem(testCase, funcList, ";", 0, 0) < 0)
					continue
				endif
				testCaseMatch = AddListItem(testCase, testCaseMatch, ";", Inf)
				usedTC[j] = 1
			endfor
		endif

		numFL = ItemsInList(testCaseMatch)
		for(j = 0; j < numFL; j += 1)
			funcName = StringFromList(j, testCaseMatch)
			fullFuncName = getFullFunctionName(err, funcName, procWin)
			if(err)
				sprintf errMsg, "Could not get full function name: %s", fullFuncName
				return err
			endif

			IUTF_FunctionTags#AddFunctionTagWave(fullFuncName)

			if(IUTF_Test_MD#GetDataGeneratorListTC(procWin, fullFuncName, dgenList))
				continue
			endif

			IUTF_Utils_Vector#EnsureCapacity(testRunData, tdIndex)
			testRunData[tdIndex][%PROCWIN] = procWin
			testRunData[tdIndex][%TESTCASE] = fullFuncName
			testRunData[tdIndex][%FULLFUNCNAME] = fullFuncName
			testRunData[tdIndex][%DGENLIST] = dgenList
			markSkip = IUTF_FunctionTags#HasFunctionTag(fullFuncName, UTF_FTAG_SKIP)
			testRunData[tdIndex][%SKIP] = SelectString(enableTAP, num2istr(markSkip), num2istr(IUTF_TAP#TAP_IsFunctionSkip(fullFuncName) | markSkip))
			testRunData[tdIndex][%EXPECTFAIL] = num2istr(IUTF_FunctionTags#HasFunctionTag(fullFuncName, UTF_FTAG_EXPECTED_FAILURE))
			tdIndex += 1

			hasDGen = hasDGen | !IUTF_Utils#IsEmpty(dgenList)
		endfor
	endfor

	if(!enableRegExp)
		for(i = 0; i < numTC; i += 1)
			if(!usedTC[i])
				testCase = StringFromList(i, matchStr)
				sprintf errMsg, "Could not find test case \"%s\" in procedure list \"%s\".", testCase, procWinList
				return TC_NOT_FOUND
			endif
		endfor
	endif

	Redimension/N=(tdIndex, -1, -1, -1) testRunData

	if(hasDGen)
		IUTF_Test_MD_Gen#ExecuteAllDataGenerators(debugMode)
	endif

	for(i = 0; i < tdIndex; i += 1)
		dgenList = testRunData[i][%DGENLIST]

		if(IUTF_Utils#IsEmpty(dgenList))
			continue
		endif

		procWin = testRunData[i][%PROCWIN]
		fullFuncName = testRunData[i][%FULLFUNCNAME]

		if(IUTF_Test_MD#CheckFunctionSignatureTC(procWin, fullFuncName, markSkip))
			// There is something wrong which is already reported. The old approach was to remove
			// this test case from the list which isn't possible anymore. So let's skip it safely.
			testRunData[i][%SKIP] = "1"
			continue
		endif

		if(markSkip)
			testRunData[i][%SKIP] = "1"
		endif
	endfor

	if(!tdIndex)
		errMsg = "No test cases found."
		return TC_LIST_EMPTY
	endif

	return TC_MATCH_OK
End

/// Function determines the total number of test cases
/// Normal test cases are counted with 1
/// MD test cases are counted by multiplying all data generator wave sizes
/// When the optional string procWin is given then the number of test cases for that
/// procedure window (test suite) is returned.
/// Returns the total number of all test cases to be called
static Function GetTestCaseCount([procWin])
	string procWin

	variable i, j, size, dgenSize, index
	variable tcCount, dgenCount
	string dgenList, dgen

	WAVE/WAVE dgenWaves = IUTF_Test_MD_Gen#GetDataGeneratorWaves()
	WAVE/T testRunData = GetTestRunData()
	size = DimSize(testRunData, UTF_ROW)
	for(i = 0; i < size; i += 1)
		if(!ParamIsDefault(procWin) && CmpStr(procWin, testRunData[i][%PROCWIN]))
			continue
		endif

		dgenCount = 1
		dgenList = testRunData[i][%DGENLIST]
		dgenSize = ItemsInList(dgenList)
		for(j = 0; j < dgenSize; j += 1)
			dgen = StringFromList(j, dgenList)
			index = IUTF_Test_MD_Gen#GetDataGeneratorRef(dgen)
			WAVE wv = dgenWaves[index]
			dgenCount *= DimSize(wv, UTF_ROW)
		endfor
		tcCount += dgenCount
	endfor

	return tcCount
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

	string msg

	if(!IsProcGlobal())
		if(!QueryIgorOption("IndependentModuleDev"))
			sprintf msg, "Error: The universal testing framework lives in the IM \"%s\" but \"SetIgorOption IndependentModuleDev=1\" is not set.", GetIndependentModuleName()
			IUTF_Reporting#ReportError(msg)
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
	string errMsg, msg
	variable numItemsPW
	variable numMatches
	variable err
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
			try
				ClearRTError()
				procWinMatch = GrepList(allProcWindows, procWin, 0, ";"); AbortOnRTE
			catch
				procWinMatch = ""
				err = GetRTError(1)
				switch(err)
					case 1233:
						errMsg = "Regular expression error"
						break
					default:
						errMsg = GetErrMessage(err)
				endswitch
				sprintf msg, "Error executing GrepList: %s", errMsg
				IUTF_Reporting#ReportError(msg)
			endtry
		else
			procWinMatch = StringFromList(WhichListItem(procWin, allProcWindows, ";", 0, 0), allProcWindows)
		endif

		numMatches = ItemsInList(procWinMatch)
		if(numMatches <= 0)
			sprintf msg, "Error: A procedure window matching the pattern \"%s\" could not be found.", procWin
			IUTF_Reporting#ReportError(msg)
			return ""
		endif

		for(j = 0; j < numMatches; j += 1)
			procWin = StringFromList(j, procWinMatch)
			if(FindListItem(procWin, procWinListOut, ";", 0, 0) == -1)
				procWinListOut = AddListItem(procWin, procWinListOut, ";", INF)
			else
				sprintf msg, "Error: The procedure window named \"%s\" is a duplicate entry in the input list of procedures.", procWin
				IUTF_Reporting#ReportError(msg)
				return ""
			endif
		endfor
	endfor

	return procWinListOut
End

/// @copydoc BACKGROUND_MONITOR_DOCU
/// @deprecated use IUTFBackgroundMonitor instead
Function UTFBackgroundMonitor(s)
	STRUCT WMBackgroundStruct &s

	IUTFBackgroundMonitor(s)
End

/// @class BACKGROUND_MONITOR_DOCU
/// @brief Background monitor of the Universal Testing Framework
Function IUTFBackgroundMonitor(s)
	STRUCT WMBackgroundStruct &s

	variable i, numTasks, result, stopState
	string task

	DFREF df = GetPackageFolder()
	SVAR/Z tList = df:BCKG_TaskList
	SVAR/Z rFunc = df:BCKG_ReentryFunc
	NVAR/Z timeout = df:BCKG_EndTime
	NVAR/Z mode = df:BCKG_Mode
	NVAR/Z failOnTimeout = df:BCKG_failOnTimeout

	if(!SVAR_Exists(tList) || !SVAR_Exists(rFunc) || !NVAR_Exists(mode) || !NVAR_Exists(timeout) || !NVAR_Exists(failOnTimeout))
		IUTF_Reporting#ReportErrorAndAbort("IUTF BackgroundMonitor can not find monitoring data in package DF, aborting monitoring.", setFlagOnly = 1)
		ClearReentrytoIUTF()
		QuitOnAutoRunFull()
		return 2
	endif

	if(mode == BACKGROUNDMONMODE_OR)
		result = 0
	elseif(mode == BACKGROUNDMONMODE_AND)
		result = 1
	else
		IUTF_Reporting#ReportErrorAndAbort("Unknown mode set for background monitor", setFlagOnly = 1)
		ClearReentrytoIUTF()
		QuitOnAutoRunFull()
		return 2
	endif

	if(timeout && datetime > timeout)
		IUTF_Reporting#ReportError("IUTF background monitor has reached the timeout for reentry", incrGlobalErrorCounter = failOnTimeout)

		RunTest(BACKGROUNDINFOSTR)
		return 0
	endif

	numTasks = ItemsInList(tList)
	for(i = 0; i < numTasks; i += 1)
		task = StringFromList(i, tList)
		CtrlNamedBackground $task, status
		stopState = !NumberByKey("RUN", S_Info)
		if(mode == BACKGROUNDMONMODE_OR)
			result = result | stopState
		elseif(mode == BACKGROUNDMONMODE_AND)
			result = result & stopState
		endif
	endfor

	if(result)
		RunTest(BACKGROUNDINFOSTR)
	endif

	return 0
End

/// @brief Clear the glboal reentry flag, removes any saved RunTest state and stops the IUTF monitoring task
static Function ClearReentrytoIUTF()

	ResetBckgRegistered()
	KillDataFolder/Z $PKG_FOLDER_SAVE
	CtrlNamedBackground $BACKGROUNDMONTASK, stop
End

/// @brief Saves the variable state of RunTest from a strRunTest structure to a dfr
static Function SaveState(dfr, s)
	DFREF dfr
	STRUCT strRunTest &s

	// save all local vars
	string/G dfr:SprocWinList = s.procWinList
	string/G dfr:Sname = s.name
	string/G dfr:StestCase = s.testCase
	variable/G dfr:SenableJU = s.enableJU
	variable/G dfr:SenableTAP = s.enableTAP
	variable/G dfr:SenableRegExp = s.enableRegExp
	variable/G dfr:SkeepDataFolder = s.keepDataFolder
	variable/G dfr:SenableRegExpTC = s.enableRegExpTC
	variable/G dfr:SenableRegExpTS = s.enableRegExpTS
	variable/G dfr:SdgenIndex = s.dgenIndex
	variable/G dfr:SdgenSize = s.dgenSize
	variable/G dfr:SmdMode = s.mdMode
	variable/G dfr:StracingEnabled = s.tracingEnabled
	variable/G dfr:ShtmlCreation = s.htmlCreation
	string/G dfr:StcSuffix = s.tcSuffix
	variable/G dfr:SretryMode = s.retryMode
	variable/G dfr:SretryCount = s.retryCount
	variable/G dfr:SretryIndex = s.retryIndex
	variable/G dfr:SretryFailedProc = s.retryFailedProc

	variable/G dfr:Si = s.i
	variable/G dfr:Serr = s.err
	IUTF_Hooks#StoreHooks(dfr, s.hooks, "TH")
	IUTF_Hooks#StoreHooks(dfr, s.procHooks, "PH")
End

/// @brief Restores the variable state of RunTest from dfr to a strRunTest structure
static Function RestoreState(dfr, s)
	DFREF dfr
	STRUCT strRunTest &s

	SVAR str = dfr:SprocWinList
	s.procWinList = str
	SVAR str = dfr:Sname
	s.name = str
	SVAR str = dfr:StestCase
	s.testCase = str
	NVAR var = dfr:SenableJU
	s.enableJU = var
	NVAR var = dfr:SenableTAP
	s.enableTAP = var
	NVAR var = dfr:SenableRegExp
	s.enableRegExp = var
	NVAR var = dfr:SkeepDataFolder
	s.keepDataFolder = var
	NVAR var = dfr:SenableRegExpTC
	s.enableRegExpTC = var
	NVAR var = dfr:SenableRegExpTS
	s.enableRegExpTS = var

	NVAR var = dfr:SdgenIndex
	s.dgenIndex = var
	NVAR var = dfr:SdgenSize
	s.dgenSize = var
	NVAR var = dfr:SmdMode
	s.mdMode = var
	NVAR var = dfr:StracingEnabled
	s.tracingEnabled = var
	NVAR var = dfr:ShtmlCreation
	s.htmlCreation = var
	SVAR str = dfr:StcSuffix
	s.tcSuffix = str

	NVAR var = dfr:SretryMode
	s.retryMode = var
	NVAR var = dfr:SretryCount
	s.retryCount = var
	NVAR var = dfr:SretryIndex
	s.retryIndex = var
	NVAR var = dfr:SretryFailedProc
	s.retryFailedProc = var

	NVAR var = dfr:Si
	s.i = var
	NVAR var = dfr:Serr
	s.err = var

	IUTF_Hooks#RestoreHooks(dfr, s.hooks, "TH")
	IUTF_Hooks#RestoreHooks(dfr, s.procHooks, "PH")
End

static Function IsBckgRegistered()
	DFREF dfr = GetPackageFolder()
	NVAR/Z bckgRegistered = dfr:BCKG_Registered
	return NVAR_Exists(bckgRegistered) && bckgRegistered == 1
End

static Function ResetBckgRegistered()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:BCKG_Registered = 0
End

static Function CallTestCase(s, reentry)
	STRUCT strRunTest &s
	variable reentry

	STRUCT IUTF_mData mData

	variable wType0, wType1, wRefSubType, err, tcIndex, refIndex
	string func, msg, dgenFuncName, origTCName, funcInfo

	WAVE/T testRunData = GetTestRunData()
	tcIndex = s.i

	if(reentry)
		DFREF dfr = GetPackageFolder()
		SVAR reentryFuncName = dfr:BCKG_ReentryFunc
		func = reentryFuncName

		// Require only optional parameter
		funcInfo = FunctionInfo(func)
		if (NumberByKey("N_PARAMS", funcInfo) != NumberByKey("N_OPT_PARAMS", funcInfo))
			sprintf msg, "Reentry functions require all its parameter as optional: \"%s\"", func
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif

		sprintf msg, "Entering reentry \"%s\"", func
		IUTF_Reporting#IUTF_PrintStatusMessage(msg)
	else
		func = testRunData[tcIndex][%FULLFUNCNAME]
	endif

	if(s.mdMode  == TC_MODE_MD)

		WAVE/WAVE dgenWaves = IUTF_Test_MD_Gen#GetDataGeneratorWaves()
		dgenFuncName = StringFromList(0, testRunData[tcIndex][%DGENLIST])
		refIndex = IUTF_Test_MD_Gen#GetDataGeneratorRef(dgenFuncName)
		WAVE wGenerator = dgenWaves[refIndex]
		wType0 = WaveType(wGenerator)
		wType1 = WaveType(wGenerator, 1)
		if(wType1 == IUTF_WAVETYPE1_NUM)
			if(wType0 & IUTF_WAVETYPE0_CMPL)

				FUNCREF TEST_CASE_PROTO_MD_CMPL fTCMD_CMPL = $func
				if(reentry && !IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_CMPL)))
					sprintf msg, "Reentry function %s does not meet required format for Complex argument.", func
					IUTF_Reporting#ReportErrorAndAbort(msg)
				endif
				fTCMD_CMPL(cmpl=wGenerator[s.dgenIndex]); AbortOnRTE

			elseif(wType0 & IUTF_WAVETYPE0_INT64)

				FUNCREF TEST_CASE_PROTO_MD_INT fTCMD_INT = $func
				if(reentry && !IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_INT)))
					sprintf msg, "Reentry function %s does not meet required format for INT64 argument.", func
					IUTF_Reporting#ReportErrorAndAbort(msg)
				endif
				fTCMD_INT(int=wGenerator[s.dgenIndex]); AbortOnRTE

			else

				FUNCREF TEST_CASE_PROTO_MD_VAR fTCMD_VAR = $func
				if(reentry && !IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_VAR)))
					sprintf msg, "Reentry function %s does not meet required format for numeric argument.", func
					IUTF_Reporting#ReportErrorAndAbort(msg)
				endif
				fTCMD_VAR(var=wGenerator[s.dgenIndex]); AbortOnRTE

			endif
		elseif(wType1 == IUTF_WAVETYPE1_TEXT)

			WAVE/T wGeneratorStr = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_STR fTCMD_STR = $func
			if(reentry && !IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_STR)))
				sprintf msg, "Reentry function %s does not meet required format for string argument.", func
				IUTF_Reporting#ReportErrorAndAbort(msg)
			endif
			fTCMD_STR(str=wGeneratorStr[s.dgenIndex]); AbortOnRTE

		elseif(wType1 == IUTF_WAVETYPE1_DFR)

			WAVE/DF wGeneratorDF = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_DFR fTCMD_DFR = $func
			if(reentry && !IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_DFR)))
				sprintf msg, "Reentry function %s does not meet required format for data folder reference argument.", func
				IUTF_Reporting#ReportErrorAndAbort(msg)
			endif
			fTCMD_DFR(dfr=wGeneratorDF[s.dgenIndex]); AbortOnRTE

		elseif(wType1 == IUTF_WAVETYPE1_WREF)

			WAVE/WAVE wGeneratorWV = wGenerator
			FUNCREF TEST_CASE_PROTO_MD_WV fTCMD_WV = $func
			if(IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WV)))
				fTCMD_WV(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
			else
				wRefSubType = WaveType(wGeneratorWV[s.dgenIndex], 1)
				if(wRefSubType == IUTF_WAVETYPE1_TEXT)
					FUNCREF TEST_CASE_PROTO_MD_WVTEXT fTCMD_WVTEXT = $func
					if(IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVTEXT)))
						fTCMD_WVTEXT(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				elseif(wRefSubType == IUTF_WAVETYPE1_DFR)
					FUNCREF TEST_CASE_PROTO_MD_WVDFREF fTCMD_WVDFREF = $func
					if(IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVDFREF)))
						fTCMD_WVDFREF(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				elseif(wRefSubType == IUTF_WAVETYPE1_WREF)
					FUNCREF TEST_CASE_PROTO_MD_WVWAVEREF fTCMD_WVWAVEREF = $func
					if(IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD_WVWAVEREF)))
						fTCMD_WVWAVEREF(wv=wGeneratorWV[s.dgenIndex]); AbortOnRTE
					else
						err = 1
					endif
				else
					sprintf msg, "Got wave reference wave from Data Generator %s with waves of unsupported type for reentry of test case %s.", dgenFuncName, func
					IUTF_Reporting#ReportErrorAndAbort(msg)
				endif
				if(err)
					sprintf msg, "Reentry function %s does not meet required format for wave reference argument from data generator %s.", func, dgenFuncName
					IUTF_Reporting#ReportErrorAndAbort(msg)
				endif
			endif

		endif
	elseif(s.mdMode  == TC_MODE_MMD)
		origTCName = testRunData[tcIndex][%FULLFUNCNAME]
		IUTF_Test_MD_MMD#SetupMMDStruct(mData, origTCName)
		FUNCREF TEST_CASE_PROTO_MD fTCMD = $func
		if(!IUTF_FuncRefIsAssigned(FuncRefInfo(fTCMD)))
			sprintf msg, "Reentry function %s does not meet required format for multi-multi-data test case.", func
			IUTF_Reporting#ReportErrorAndAbort(msg)
		else
			fTCMD(md=mData); AbortOnRTE
		endif
	elseif(s.mdMode  == TC_MODE_NORMAL)
		FUNCREF TEST_CASE_PROTO TestCaseFunc = $func
		TestCaseFunc(); AbortOnRTE
	else
		sprintf msg, "Unknown test case mode for function %s.", func
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif
End

/// @brief initialize all strings in strRunTest structure to be non <null>
static Function InitStrRunTest(s)
	STRUCT strRunTest &s

	s.procWinList = ""
	s.name = ""
	s.testCase = ""

	s.tcSuffix = ""

	IUTF_Hooks#InitHooks(s.hooks)
	IUTF_Hooks#InitHooks(s.procHooks)
End

/// @brief this structure stores all local variables used in RunTest. It is used to store the complete function state.
static Structure strRunTest
	string procWinList
	string name
	string testCase
	variable enableJU
	variable enableTAP
	variable enableRegExp
	variable debugMode
	variable keepDataFolder
	variable enableRegExpTC
	variable enableRegExpTS
	variable dgenIndex
	variable dgenSize
	variable mdMode
	variable tracingEnabled
	variable htmlCreation
	string tcSuffix
	STRUCT IUTF_TestHooks hooks
	STRUCT IUTF_TestHooks procHooks
	variable retryMode
	variable retryCount
	variable retryIndex
	variable retryFailedProc
	variable i
	variable err
EndStructure

///@endcond // HIDDEN_SYMBOL

/// @copydoc REGISTER_IUTF_MONITOR_DOCU
/// @deprecated use RegisterIUTFMonitor instead
Function RegisterUTFMonitor(taskList, mode, reentryFunc, [timeout, failOnTimeout])
	string taskList
	variable mode
	string reentryFunc
	variable timeout, failOnTimeout

	if(ParamIsDefault(timeout))
		if(ParamIsDefault(failOnTimeout))
			RegisterIUTFMonitor(taskList, mode, reentryFunc)
		else
			RegisterIUTFMonitor(taskList, mode, reentryFunc, failOnTimeout = failOnTimeout)
		endif
	else
		if(ParamIsDefault(failOnTimeout))
			RegisterIUTFMonitor(taskList, mode, reentryFunc, timeout = timeout)
		else
			RegisterIUTFMonitor(taskList, mode, reentryFunc, timeout = timeout, failOnTimeout = failOnTimeout)
		endif
	endif
End

/// @class REGISTER_IUTF_MONITOR_DOCU
/// @brief Registers a background monitor for a list of other background tasks
///
/// @verbatim embed:rst:leading-slashes
///     .. code-block:: igor
///        :caption: usage example
///
///        RegisterIUTFMonitor("TestCaseTask1;TestCaseTask2", BACKGROUNDMONMODE_OR, \
///                           "testcase_REENTRY", timeout = 60)
///
///     This command will register the IUTF background monitor task to monitor
///     the state of `TestCaseTask1` and `TestCaseTask2`. As mode is set to
///     `BACKGROUNDMONMODE_OR`, when `TestCaseTask1` OR `TestCaseTask2` has
///     finished the function `testcase_REENTRY()` is called to  continue the
///     current test case. The reentry function is also called if after 60 seconds
///     both tasks are still running.
///
/// @endverbatim
///
/// @param   taskList      A list of background task names that should be monitored by the universal testing framework
///                        @n The list should be given semicolon (";") separated.
///
/// @param   mode          Mode sets how multiple tasks are evaluated. If set to
///                        `BACKGROUNDMONMODE_AND` all tasks of the list must finish (AND).
///                        If set to `BACKGROUNDMONMODE_OR` one task of the list must finish (OR).
///
/// @param   reentryFunc   Name of the function that the universal testing framework calls when the monitored background tasks finished.
///                        The function name must end with _REENTRY and it must be of the form `$fun_REENTRY()` (same format as test cases).
///                        The reentry function *continues* the current test case therefore no hooks are called.
///
/// @param   timeout       (optional) default 0. Timeout in seconds that the background monitor waits for the test case task(s).
///                        A timeout of 0 equals no timeout. If the timeout is reached the registered reentry function is called.
/// @param   failOnTimeout (optional) default to false. If the test case should be failed on reaching the timeout.
Function RegisterIUTFMonitor(taskList, mode, reentryFunc, [timeout, failOnTimeout])
	string taskList
	variable mode
	string reentryFunc
	variable timeout, failOnTimeout

	string procWinList, rFunc
	variable tmpVar
	DFREF dfr = GetPackageFolder()

	if(ParamIsDefault(timeout))
		timeout = 0
	endif
	timeout = timeout <= 0 ? 0 : datetime + timeout

	failOnTimeout = ParamIsDefault(failOnTimeout) ? 0 : !!failOnTimeout

	if(IUTF_Utils#IsEmpty(tasklist))
		IUTF_Reporting#ReportErrorAndAbort("Tasklist is empty.")
	endif

	if(!(mode == BACKGROUNDMONMODE_OR || mode == BACKGROUNDMONMODE_AND))
		IUTF_Reporting#ReportErrorAndAbort("Unknown mode set")
	endif

	if(FindListItem(BACKGROUNDMONTASK, taskList) != -1)
		IUTF_Reporting#ReportErrorAndAbort("Igor Universal Testing framework will not monitor its own monitoring task (" + BACKGROUNDMONTASK + ").")
	endif

	// check valid reentry function
	if(GrepString(reentryFunc, PROCNAME_NOT_REENTRY))
		IUTF_Reporting#ReportErrorAndAbort("Name of Reentry function must end with _REENTRY")
	endif
	FUNCREF TEST_CASE_PROTO rFuncRef = $reentryFunc
	FUNCREF TEST_CASE_PROTO_MD rFuncRefMMD = $reentryFunc
	if(!IUTF_FuncRefIsAssigned(FuncRefInfo(rFuncRef)) && !IUTF_FuncRefIsAssigned(FuncRefInfo(rFuncRefMMD)) && !IUTF_Test_MD#GetFunctionSignatureTCMD(reentryFunc, tmpVar, tmpVar, tmpVar))
		IUTF_Reporting#ReportErrorAndAbort("Specified reentry procedure has wrong format. The format must be function_REENTRY() or for multi data function_REENTRY([type]).")
	endif

	string/G dfr:BCKG_TaskList = taskList
	string/G dfr:BCKG_ReentryFunc = reentryFunc
	variable/G dfr:BCKG_Mode = mode

	variable/G dfr:BCKG_EndTime = timeout
	variable/G dfr:BCKG_Registered = 1
	variable/G dfr:BCKG_FailOnTimeout = failOnTimeout

	CtrlNamedBackground $BACKGROUNDMONTASK, proc=IUTFBackgroundMonitor, period=10, start
End

// Checks if a test case can be retried with the given conditions. Returns 1 if the test case can be
// retried and 0 if not.
static Function CanRetry(skip, s, fullFuncName, tcResultIndex)
	variable skip, tcResultIndex
	STRUCT strRunTest &s
	string fullFuncName

	// if the test case is marked as skipped, the maximum retries are reached the test case will
	// no longer be retried or if retry is not enabled
	if(skip || s.retryIndex >= s.retryCount || !(s.retryMode & IUTF_RETRY_FAILED_UNTIL_PASS))
		return 0
	endif

	// check if the test run should be aborted and IUTF_RETRY_REQUIRES is not set
	if(!(s.retryMode & IUTF_RETRY_REQUIRES) && shouldDoAbort())
		return 0
	endif

	// check if test case succeeded
	WAVE/T wvTestCaseResults = IUTF_Reporting#GetTestCaseWave()
	if(!CmpStr(wvTestCaseResults[tcResultIndex][%STATUS], IUTF_STATUS_SUCCESS))
		return 0
	endif

	// check if function is not allowed to be retried
	if(!((s.retryMode & IUTF_RETRY_MARK_ALL_AS_RETRY) || IUTF_FunctionTags#HasFunctionTag(fullFuncName, UTF_FTAG_RETRY_FAILED)))
		return 0
	endif

	// function has to be retried!
	return 1
End

static Function CleanupRetry(s, tcResultIndex)
	STRUCT strRunTest &s
	variable tcResultIndex

	// increment retry counter
	s.retryIndex += 1
	// update test case status
	WAVE/T wvTestCaseResults = IUTF_Reporting#GetTestCaseWave()
	wvTestCaseResults[tcResultIndex][%STATUS] = IUTF_STATUS_RETRY
	// remove errors from test suite
	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
	wvTestSuite[%CURRENT][%NUM_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ERROR]) - 1)
	wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR] = num2istr(str2num(wvTestSuite[%CURRENT][%NUM_ASSERT_ERROR]) - str2num(wvTestCaseResults[tcResultIndex][%NUM_ASSERT_ERROR]))
	// cleanup test summary
	WAVE/T wvFailedProc = IUTF_Reporting#GetFailedProcWave()
	IUTF_Utils_Vector#SetLength(wvFailedProc, s.retryFailedProc)
	IUTF_Utils_Waves#MoveDimLabel(wvFailedProc, UTF_ROW, "CURRENT", s.retryFailedProc - 1)
	// cleanup abort flag to allow failed REQUIRE
	InitAbortFlag()
End


static Function ClearTestSetupWaves()

	WAVE/T testRunData = GetTestRunData()
	WAVE/WAVE dgenWaves = IUTF_Test_MD_Gen#GetDataGeneratorWaves()
	WAVE/T dgenRefs = IUTF_Test_MD_Gen#GetDataGeneratorRefs()
	WAVE/WAVE ftagWaves = IUTF_FunctionTags#GetFunctionTagWaves()
	WAVE/WAVE ftagRefs = IUTF_FunctionTags#GetFunctionTagRefs()
	WAVE/WAVE mdState = IUTF_Test_MD_MMD#GetMMDataState()
	WAVE/T mdStateRefs = IUTF_Test_MD_MMD#GetMMDataStateRefs()

	KillWaves testRunData, dgenWaves, dgenRefs, ftagWaves, ftagRefs, mdState, mdStateRefs
End

/// @brief Detects if deprecated files are included and prompt a warning.
static Function DetectDeprecation()
	string text = ProcedureText("", 0, "unit-testing.ipf")
	if(IUTF_Utils#IsEmpty(text))
		return NaN
	endif

	IUTF_Reporting#IUTF_PrintStatusMessage("WARNING: You are using a deprecated method to include the Igor Pro Universal Testing Framework!")
	IUTF_Reporting#IUTF_PrintStatusMessage("WARNING: Search in your code for all")
	IUTF_Reporting#IUTF_PrintStatusMessage("WARNING:     #include \"unit-testing\"")
	IUTF_Reporting#IUTF_PrintStatusMessage("WARNING: and replace it with")
	IUTF_Reporting#IUTF_PrintStatusMessage("WARNING:     #include \"igortest\"")
	IUTF_Reporting#IUTF_PrintStatusMessage("WARNING: In a future release will this warning and the deprecated file removed.")
	IUTF_Reporting#IUTF_PrintStatusMessage("", allowEmptyLine = 1)
End

/// @brief Main function to execute test suites with the universal testing framework.
///
/// You can abort the test run using Command-dot on Macintosh, Ctrl+Break on Windows or Shift+Escape
/// on all platforms.
///
/// @verbatim embed:rst:leading-slashes
///     .. code-block:: igor
///        :caption: usage example
///
///        RunTest("proc0;proc1", name="myTest")
///
///     This command will run the test suites `proc0` and `proc1` in a test named `myTest`.
/// @endverbatim
///
/// @param   procWinList    A list of procedure files that should be treated as test suites.
///                         @n The list should be given semicolon (";") separated.
///                         @n The procedure name must not include Independent Module specifications.
///                         @n This parameter can be given as a regular expression with enableRegExp set to 1.
///
/// @param   name           (optional) default "Unnamed" @n
///                         descriptive name for the executed test suites. This can be
///                         used to group multiple test suites into a single test run.
///
/// @param   testCase       (optional) default ".*" (all test cases in the list of test suites) @n
///                         function names, resembling test cases, which should be
///                         executed in the given list of test suites (procWinList).
///                         @n The list should be given semicolon (";") separated.
///                         @n This parameter can be treated as a regular expression with enableRegExp set to 1.
///
/// @param   enableJU       (optional) default disabled, enabled when set to 1: @n
///                         A JUNIT compatible XML file is written at the end of the Test Run.
///                         It allows the combination of this framework with continuous integration
///                         servers like Atlassian Bamboo/GitLab/etc.
///                         The experiment is required to be saved somewhere on the disk. (it is okay to have unsaved changes.)
///
/// @param   enableTAP      (optional) default disabled, enabled when set to 1: @n
///                         A TAP compatible file is written at the end of the test run.
///                         @verbatim embed:rst:leading-slashes
///                             `Test Anything Protocol (TAP) <https://testanything.org>`__
///                             `standard 13 <https://testanything.org/tap-version-13-specification.html>`__
///                         @endverbatim
///                         The experiment is required to be saved somewhere on the disk. (it is okay to have unsaved changes.)
///
/// @param   enableRegExp   (optional) default disabled, enabled when set to 1: @n
///                         The input for test suites (procWinList) and test cases (testCase) is
///                         treated as a regular expression.
///                         @verbatim embed:rst:leading-slashes
///                             .. code-block:: igor
///                                :caption: Example
///
///                                RunTest("example[1-3]-plain\\.ipf", enableRegExp=1)
///
///                             This command will run all test cases in the following test suites:
///
///                             * :ref:`example1-plain.ipf<example1>`
///                             * :ref:`example2-plain.ipf<example2>`
///                             * :ref:`example3-plain.ipf<example3>`
///                         @endverbatim
///
/// @param   allowDebug     (optional) default disabled, enabled when set to 1: @n
///                         The Igor debugger will be left in its current state when running the
///                         tests. Is ignored when debugMode is also enabled.
///
/// @param	debugMode      (optional) default disabled, enabled when set to 1-15: @n
///                         The Igor debugger will be turned on in the state: @n
///								  1st bit = 1 (IUTF_DEBUG_ENABLE): Enable Debugger (only breakpoints) @n
///                         2nd bit = 1 (IUTF_DEBUG_ON_ERROR): Debug on Error @n
///								  3rd bit = 1 (IUTF_DEBUG_NVAR_SVAR_WAVE): Check NVAR SVAR WAVE @n
///                         4th bit = 1 (IUTF_DEBUG_FAILED_ASSERTION): Debug on failed assertion
///                         @verbatim embed:rst:leading-slashes
///                             .. code-block:: igor
///                                :caption: Example
///
///                                RunTest(..., debugMode = IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_FAILED_ASSERTION)
///
///                             This will enable the debugger with Debug On Error and debugging on failed assertion.
///                         @endverbatim
///
/// @param   keepDataFolder (optional) default disabled, enabled when set to 1: @n
///                         The temporary data folder wherein each test case is executed is not
///                         removed at the end of the test case. This allows to review the
///                         produced data.
///
/// @param   traceWinList   (optional) default ""
///                         A list of windows where execution gets traced. The universal testing framework saves a RTF document
///                         for each traced procedure file. When REGEXP was set in traceOptions then traceWinList is also interpreted
///                         as a regular expression.
///                         The experiment is required to be saved somewhere on the disk. (it is okay to have unsaved changes.)
///
/// @param   traceOptions   (optional) default ""
///                         A key:value pair list of additional tracing options. Currently supported is:
///                         INSTRUMENTONLY:boolean When set, run instrumentation only and return. No tests are executed.
///                         HTMLCREATION:boolean When set to zero, no htm result files are created at the end of the run
///                         REGEXP:boolean When set, traceWinList is interpreted as regular expression
///
/// @param   fixLogName     (optional) default 0 disabled, enabled when set to 1: @n
///                         If enabled the output files that will be generated after an autorun will have predictable names like
///                         "IUTF_Test.log". If disabled the file names will always contain the name of the procedure file and a
///                         timestamp.
///
/// @param   waveTrackingMode (optional) default disabled, enabled when set to a value different than 0: @n
///                         Monitors the number of free waves before and after a test case run. If for some reasons the number is not
///                         the same as before this considered as an error. If you want to opt-out a single test case you have to tag
///                         it with IUTF_NO_WAVE_TRACKING.
///                         This uses the flags UTF_WAVE_TRACKING_FREE, UTF_WAVE_TRACKING_LOCAL and UTF_WAVE_TRACKING_ALL.
///                         This feature is only available since Igor Pro 9.
///
/// @param   retry          (optional) default IUTF_RETRY_NORETRY
///                         Set the conditions and options when IUTF should retry a test case. The following flags are allowed:
///                         IUTF_RETRY_FAILED_UNTIL_PASS: Reruns every failed flaky test up to retryMaxCount. A flaky test case needs
///                           the IUTF_RETRY_FAILED function tag.
///                         IUTF_RETRY_MARK_ALL_AS_RETRY: Treats all test cases as flaky. There is no need to use the IUTF_RETRY_FAILED
///                           function tag. This option does nothing if IUTF_RETRY_FAILED_UNTIL_PASS is not set.
///                         IUTF_RETRY_REQUIRES: Allow to retry failed REQUIRE assertions. This option does nothing if
///                           IUTF_RETRY_FAILED_UNTIL_PASS is not set.
///
/// @param   retryMaxCount  (optional) default IUTF_MAX_SUPPORTED_RETRY
///                         Sets the maximum number of retries if rerunning of flaky tests is enabled. Setting this number
///                         higher than IUTF_MAX_SUPPORTED_RETRY is not allowed.
///
/// @return                 total number of errors
Function RunTest(procWinList, [name, testCase, enableJU, enableTAP, enableRegExp, allowDebug, debugMode, keepDataFolder, traceWinList, traceOptions, fixLogName, waveTrackingMode, retry, retryMaxCount])
	string procWinList, name, testCase
	variable enableJU, enableTAP, enableRegExp
	variable allowDebug, debugMode, keepDataFolder
	string traceWinList, traceOptions
	variable fixLogName
	variable waveTrackingMode, retry, retryMaxCount

	// All variables that are needed to keep the local function state are wrapped in s
	// new var/str must be added to strRunTest and added in SaveState/RestoreState functions
	STRUCT strRunTest s
	InitStrRunTest(s)

	DFREF dfr = GetPackageFolder()

	// do not save these for reentry
	//
	variable reentry
	variable testSuiteCreated = 0
	// these use a very local scope where used
	// loop counter and loop end derived vars
	variable i, j, tcFuncCount, startNextTS, skip, tcCount, reqSave, tcResultIndex
	string procWin, fullFuncName, previousProcWin, dgenFuncName
	// used as temporal locals
	variable var, err
	string msg, errMsg

	fixLogName = ParamIsDefault(fixLogName) ? 0 : !!fixLogName
	waveTrackingMode = ParamIsDefault(waveTrackingMode) ? UTF_WAVE_TRACKING_NONE : waveTrackingMode

	reentry = IsBckgRegistered()
	ResetBckgRegistered()
	if(reentry)

		// check also if a saved state is existing
		if(!DataFolderExists(PKG_FOLDER_SAVE))
			IUTF_Reporting#ReportErrorAndAbort("No saved test state found, aborting. (Did you RegisterIUTFMonitor in an End Hook?)")
		endif
	  // check if the reentry call originates from our own background monitor
		if(CmpStr(GetRTStackInfo(2), BACKGROUNDMONFUNC))
			ClearReentrytoIUTF()
			IUTF_Reporting#ReportErrorAndAbort("RunTest was called by user after background monitoring was registered. This is not supported.")
		endif

		// a test suite must have been created if this is a reentry
		testSuiteCreated = 1

	else
		// no early return/abort above this point
		DetectDeprecation()
		IUTF_Utils_Paths#ClearHomePath()
		DFREF dfr = GetPackageFolder()
		string/G dfr:baseFilenameOverwrite = SelectString(fixLogName, "", FIXED_LOG_FILENAME)
		ClearTestSetupWaves()
		IUTF_Reporting#ClearTestResultWaves()
		ClearBaseFilename()
		CreateHistoryLog()
		IUTF_Reporting_Control#SetupTestRun()

		allowDebug = ParamIsDefault(allowDebug) ? 0 : !!allowDebug

		// transfer parameters to s. variables
		s.enableRegExp = enableRegExp
		s.enableRegExpTC = ParamIsDefault(enableRegExp) ? 0 : !!enableRegExp
		s.enableRegExpTS = s.enableRegExpTC
		s.enableJU = ParamIsDefault(enableJU) ? 0 : !!enableJU
		s.enableTAP = ParamIsDefault(enableTAP) ? 0 : !!enableTAP
		s.debugMode = ParamIsDefault(debugMode) ? 0 : debugMode
		s.keepDataFolder = ParamIsDefault(keepDataFolder) ? 0 : !!keepDataFolder
		s.retryMode = ParamIsDefault(retry) ? IUTF_RETRY_NORETRY : retry
		s.retryCount = ParamIsDefault(retryMaxCount) ? IUTF_MAX_SUPPORTED_RETRY : retryMaxCount

		s.tracingEnabled = !ParamIsDefault(traceWinList) && !IUTF_Utils#IsEmpty(traceWinList)

		if(s.enableJU || s.enableTAP || s.tracingEnabled)
			// the path is only needed locally
			msg = IUTF_Utils_Paths#GetHomePath()
			if(IUTF_Utils#IsEmpty(msg))
				IUTF_Reporting#ReportError("Error: Please Save experiment first.")
				return NaN
			endif
		endif

		var = IUTF_DEBUG_ENABLE | IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE | IUTF_DEBUG_FAILED_ASSERTION
		if(s.debugMode > var || s.debugMode < 0 || !IUTF_Utils#IsInteger(s.debugMode))
			sprintf msg, "debugMode can only be an integer between 0 and %d. The input %g is wrong, aborting!.\r", var, s.debugMode
			msg = msg + "Use the constants IUTF_DEBUG_ENABLE, IUTF_DEBUG_ON_ERROR,\r"
			msg = msg + "IUTF_DEBUG_NVAR_SVAR_WAVE and IUTF_DEBUG_FAILED_ASSERTION for debugMode.\r\r"
			msg = msg + "Example: debugMode = IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE"
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif

		if(s.debugMode > 0 && allowDebug > 0)
			print "Note: debugMode parameter is set, allowDebug parameter is ignored."
		endif
		if(s.debugMode == 0 && allowDebug > 0)
			s.debugMode = IUTF_Debug#GetCurrentDebuggerState()
		endif

#if IgorVersion() < 9.00
		if(waveTrackingMode)
			IUTF_Reporting#ReportErrorAndAbort("Error: wave tracking is only allowed to be used in Igor Pro 9 or higher.")
		else
			variable/G dfr:waveTrackingMode = UTF_WAVE_TRACKING_NONE
		endif
#else
		if((waveTrackingMode & UTF_WAVE_TRACKING_ALL) != waveTrackingMode)
			sprintf msg, "Error: Invalid wave tracking mode %d", waveTrackingMode
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif
		variable/G dfr:waveTrackingMode = waveTrackingMode
#endif

		if(s.retryMode & ~(IUTF_RETRY_FAILED_UNTIL_PASS | IUTF_RETRY_MARK_ALL_AS_RETRY | IUTF_RETRY_REQUIRES))
			sprintf msg, "Error: Invalid retry mode %d", s.retryMode
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif

		if(!IUTF_Utils#IsFinite(s.retryCount) || s.retryCount < 0 || s.retryCount > IUTF_MAX_SUPPORTED_RETRY)
			sprintf msg, "Error: Invalid number of maximum retries: %d (maximum supported: %d)", s.retryCount, IUTF_MAX_SUPPORTED_RETRY
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif

		traceOptions = SelectString(ParamIsDefault(traceOptions), traceOptions, "")

		if(ParamIsDefault(name))
			s.name = "Unnamed"
		else
			s.name = name
		endif

		if(ParamIsDefault(testCase))
			s.testCase = ".*"
			s.enableRegExpTC = 1
		else
			s.testCase = testCase
		endif
		s.procWinList = procWinList

		if(s.tracingEnabled)
#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
			if(!CmpStr(traceWinList, IUTF_TRACE_REENTRY_KEYWORD))
				DFREF dfSave = $PKG_FOLDER_SAVE
				RestoreState(dfSave, s)
				ClearReentrytoIUTF()
			else
				ClearReentrytoIUTF()

				var = NumberByKey(UTF_KEY_HTMLCREATION, traceOptions)
				s.htmlCreation = IUTF_Utils#IsNaN(var) ? 1 : var

				NewDataFolder $PKG_FOLDER_SAVE
				DFREF dfSave = $PKG_FOLDER_SAVE
				SaveState(dfSave, s)
				TUFXOP_Init/N="IUTF_Testrun"
				TUFXOP_Clear/Q/Z/N="IUTF_Error"
				IUTF_Tracing#SetupTracing(traceWinList, traceOptions)
				return NaN
			endif
#else
			IUTF_Reporting#ReportErrorAndAbort("Tracing requires Igor Pro 9 Build 38812 (or later) and the Thread Utilities XOP.")
#endif
		else
#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
			TUFXOP_Init/N="IUTF_Testrun"
#endif
		endif

		// below here use only s. variables to keep local state in struct

		s.procWinList = AdaptProcWinList(s.procWinList, s.enableRegExpTS)
		s.procWinList = FindProcedures(s.procWinList, s.enableRegExpTS)

		if(ItemsInList(s.procWinList) <= 0)
			IUTF_Reporting#ReportError("Error: The list of procedure windows is empty or invalid.")
			return NaN
		endif

		err = CreateTestRunSetup(s.procWinList, s.testCase, s.enableRegExpTC, errMsg, s.enableTAP, s.debugMode)
		tcCount = GetTestCaseCount()

		if(err != TC_MATCH_OK)
			if(err == TC_LIST_EMPTY)
				errMsg = s.procWinList
				errMsg = IUTF_Utils#IUTF_PrepareStringForOut(errMsg)
				sprintf msg, "Error: A test case matching the pattern \"%s\" could not be found in test suite(s) \"%s\".", s.testcase, errMsg
				IUTF_Reporting#ReportError(msg)
				return NaN
			endif

			errMsg = IUTF_Utils#IUTF_PrepareStringForOut(errMsg)
			sprintf msg, "Error %d in CreateTestRunSetup: %s", err, errMsg
			IUTF_Reporting#ReportError(msg)
			return NaN
		endif

		// 1.) set the hooks to the default implementations
		IUTF_Hooks#setDefaultHooks(s.hooks)
		// 2.) get global user hooks which reside in ProcGlobal and replace the default ones
		IUTF_Hooks#getGlobalHooks(s.hooks)

		// Reinitializes
		IUTF_Hooks#ExecuteHooks(IUTF_TEST_BEGIN_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param=s.debugMode)

		// TAP Handling, find out if all should be skipped and number of all test cases
		if(s.enableTAP)
			if(IUTF_TAP#TAP_AreAllFunctionsSkip())
				IUTF_Hooks#ExecuteHooks(IUTF_TEST_END_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param=s.debugMode)
				return 0
			endif
		endif

	endif

	// The Test Run itself is split into Test Suites for each Procedure File
	WAVE/WAVE dgenWaves = IUTF_Test_MD_Gen#GetDataGeneratorWaves()
	WAVE/T testRunData = GetTestRunData()
	tcFuncCount = DimSize(testRunData, UTF_ROW)
	for(i = 0; i < tcFuncCount; i += 1)
		s.i = i

		procWin = testRunData[i][%PROCWIN]
		fullFuncName = testRunData[i][%FULLFUNCNAME]
		if(s.i > 0)
			previousProcWin = testRunData[s.i - 1][%PROCWIN]
		else
			previousProcWin = ""
		endif
		startNextTS = !!CmpStr(previousProcWin, procWin)

		if(!reentry)

			if(startNextTS)
				if(i > 0)
					s.procHooks = s.hooks
					// 3.) get local user hooks which reside in the same Module as the requested procedure
					IUTF_Hooks#getLocalHooks(s.procHooks, previousProcWin)
					IUTF_Hooks#ExecuteHooks(IUTF_TEST_SUITE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, previousProcWin, previousProcWin, s.i - 1)
				endif

				if(shouldDoAbort())
					break
				endif
			endif

			s.procHooks = s.hooks
			// 3.) dito
			IUTF_Hooks#getLocalHooks(s.procHooks, procWin)

			if(startNextTS)
				IUTF_Hooks#ExecuteHooks(IUTF_TEST_SUITE_BEGIN_CONST, s.procHooks, s.enableTAP, s.enableJU, procWin, procWin, s.i)
				testSuiteCreated = 1
			endif

			SetExpectedFailure(str2num(testRunData[s.i][%EXPECTFAIL]))
			skip = str2num(testRunData[s.i][%SKIP])
			s.dgenIndex = 0
			s.tcSuffix = ""
			FUNCREF TEST_CASE_PROTO TestCaseFunc = $fullFuncName
			FUNCREF TEST_CASE_PROTO_MD TestCaseFuncMMD = $fullFuncName
			if(IUTF_FuncRefIsAssigned(FuncRefInfo(TestCaseFunc)))
				s.mdMode = TC_MODE_NORMAL
			elseif(IUTF_FuncRefIsAssigned(FuncRefInfo(TestCaseFuncMMD)))
				s.mdMode = TC_MODE_MMD
			else
				s.mdMode = TC_MODE_MD
				dgenFuncName = StringFromList(0, testRunData[s.i][%DGENLIST])
				var = IUTF_Test_MD_Gen#GetDataGeneratorRef(dgenFuncName)
				WAVE wGenerator = dgenWaves[var]
				s.dgenSize = DimSize(wGenerator, UTF_ROW)
			endif

		endif

		s.retryIndex = 0

		do

			if(!reentry)

				if(s.mdMode == TC_MODE_MD)
					dgenFuncName = StringFromList(0, testRunData[s.i][%DGENLIST])
					var = IUTF_Test_MD_Gen#GetDataGeneratorRef(dgenFuncName)
					WAVE wGenerator = dgenWaves[var]
					s.tcSuffix = ":" + GetDimLabel(wGenerator, UTF_ROW, s.dgenIndex)
					if(strlen(s.tcSuffix) == 1)
						s.tcSuffix = IUTF_TC_SUFFIX_SEP + num2istr(s.dgenIndex)
					endif
				elseif(s.mdMode == TC_MODE_MMD)
					s.tcSuffix = IUTF_Test_MD_MMD#GetMMDTCSuffix(i)
				endif

				IUTF_Hooks#ExecuteHooks(IUTF_TEST_CASE_BEGIN_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i)
			else

				DFREF dfSave = $PKG_FOLDER_SAVE
				RestoreState(dfSave, s)
				// restore state done
				DFREF dfSave = $""
				ClearReentrytoIUTF()
				// restore all loop counters and end loop locals
				i = s.i
				procWin = testRunData[s.i][%PROCWIN]
				fullFuncName = testRunData[s.i][%FULLFUNCNAME]
				skip = str2num(testRunData[s.i][%SKIP])

			endif

			if(!skip)

				WAVE/T wvFailedProc = IUTF_Reporting#GetFailedProcWave()
				s.retryFailedProc = IUTF_Utils_Vector#GetLength(wvFailedProc)

				if(GetRTError(0))
					msg = GetRTErrMessage()
					err = GetRTError(1)
					sprintf msg, "Internal runtime error in IUTF %d:\"%s\" before executing test case \"%s\".", err, msg, fullFuncName
					IUTF_Reporting#ReportErrorAndAbort(msg, setFlagOnly = 1)
				endif

				try
					CallTestCase(s, reentry)
				catch
					msg = GetRTErrMessage()
					s.err = GetRTError(1)
					// clear the abort code from setAbortFlag()
					V_AbortCode = shouldDoAbort() ? 0 : V_AbortCode
					EvaluateRTE(s.err, msg, V_AbortCode, fullFuncName, IUTF_TEST_CASE_TYPE, procWin)

					if(shouldDoAbort() && !(s.enableTAP && IUTF_TAP#TAP_IsFunctionTodo(fullFuncName)))
						// check if a retry is possible
						WAVE/T wvTestCaseResults = IUTF_Reporting#GetTestCaseWave()
						tcResultIndex = FindDimLabel(wvTestCaseResults, UTF_ROW, "CURRENT")

						if(CanRetry(skip, s, fullFuncName, tcResultIndex))
							IUTF_Hooks#ExecuteHooks(IUTF_TEST_CASE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i, param = s.keepDataFolder)
							CleanupRetry(s, tcResultIndex)
							continue
						endif

						// abort condition is on hold while in catch/endtry, so all cleanup must happen here
						IUTF_Hooks#ExecuteHooks(IUTF_TEST_CASE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i, param = s.keepDataFolder)

						IUTF_Hooks#ExecuteHooks(IUTF_TEST_SUITE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, procWin, procWin, s.i)

						IUTF_Hooks#ExecuteHooks(IUTF_TEST_END_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param = s.debugMode)

						ClearReentrytoIUTF()
						QuitOnAutoRunFull()

						WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
						return str2num(wvTestRun[%CURRENT][%NUM_ERROR])
					endif
				endtry

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
				// check if Z_ has stored some errors
				if(s.tracingEnabled)
					TUFXOP_GetStorage/Z/Q/N="IUTF_Error" wvAllStorage
					if(!V_flag)
						variable numThreads = NumberByKey("Index", note(wvAllStorage))
						for(j = 0; j < numThreads; ++j)
							Wave/WAVE wvStorage = wvAllStorage[j]
							Wave/T data = wvStorage[0]
							IUTF_Reporting#ReportError(data[0])
						endfor
					endif
				endif
#endif

			endif

			reentry = 0

			if(IsBckgRegistered())
				// save state
				NewDataFolder $PKG_FOLDER_SAVE
				DFREF dfSave = $PKG_FOLDER_SAVE
				SaveState(dfSave, s)

				return RUNTEST_RET_BCKG
			endif

			WAVE/T wvTestCaseResults = IUTF_Reporting#GetTestCaseWave()
			tcResultIndex = FindDimLabel(wvTestCaseResults, UTF_ROW, "CURRENT")

			IUTF_Hooks#ExecuteHooks(IUTF_TEST_CASE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, fullFuncName + s.tcSuffix, procWin, s.i, param = s.keepDataFolder)

			if(CanRetry(skip, s, fullFuncName, tcResultIndex))
				CleanupRetry(s, tcResultIndex)
				// retry the the current test case. If this is a multi-data test case or
				// multi-multi-data test case it will retry the current index which failed and not
				// all previous runs.
				continue
			else
				s.retryIndex = 0
			endif

			if(shouldDoAbort())
				break
			endif

			if(s.mdMode == TC_MODE_MD)
				s.dgenIndex += 1
			elseif(s.mdMode == TC_MODE_MMD)
				s.dgenIndex = IUTF_Test_MD_MMD#IncreaseMMDIndices(fullFuncName)
			endif

		while((s.mdMode == TC_MODE_MD && s.dgenIndex < s.dgenSize) || (s.mdMode == TC_MODE_MMD && !s.dgenIndex))

		if(shouldDoAbort())
			break
		endif

	endfor

	// at this code path it is unclear if a test suite was ever started, so we have to check this manually
	if(testSuiteCreated)
		IUTF_Hooks#ExecuteHooks(IUTF_TEST_SUITE_END_CONST, s.procHooks, s.enableTAP, s.enableJU, procWin, procWin, s.i)
	endif
	IUTF_Hooks#ExecuteHooks(IUTF_TEST_END_CONST, s.hooks, s.enableTAP, s.enableJU, s.name, NO_SOURCE_PROCEDURE, s.i, param = s.debugMode)

	ClearReentrytoIUTF()

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
	if(s.htmlCreation)
		IUTF_Tracing#AnalyzeTracingResult()
	endif
#endif

	QuitOnAutoRunFull()

	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
	return str2num(wvTestRun[%CURRENT][%NUM_ERROR])
End
