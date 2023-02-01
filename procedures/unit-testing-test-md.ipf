#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Test_MD

/// Checks functions signature of each multi data test case candidate
/// returns 1 if ok, 0 otherwise
/// when 1 is returned the wave type variable contain the format
static Function GetFunctionSignatureTCMD(testCase, wType0, wType1, wrefSubType)
	string testCase
	variable &wType0
	variable &wType1
	variable &wrefSubType

	wType0 = NaN
	wType1 = NaN
	wrefSubType = NaN
	// Check function signature
	FUNCREF TEST_CASE_PROTO_MD_VAR fTCMDVAR = $testCase
	FUNCREF TEST_CASE_PROTO_MD_STR fTCMDSTR = $testCase
	FUNCREF TEST_CASE_PROTO_MD_DFR fTCMDDFR = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WV fTCMDWV = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WVTEXT fTCMDWVTEXT = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WVDFREF fTCMDWVDFREF = $testCase
	FUNCREF TEST_CASE_PROTO_MD_WVWAVEREF fTCMDWVWAVEREF = $testCase
	FUNCREF TEST_CASE_PROTO_MD_CMPL fTCMDCMPL = $testCase
	FUNCREF TEST_CASE_PROTO_MD_INT fTCMDINT = $testCase
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDVAR)))
		wType0 = 0xff %^ IUTF_WAVETYPE0_CMPL %^ IUTF_WAVETYPE0_INT64
		wType1 = IUTF_WAVETYPE1_NUM
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDSTR)))
		wType1 = IUTF_WAVETYPE1_TEXT
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDDFR)))
		wType1 = IUTF_WAVETYPE1_DFR
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWV)))
		wType1 = IUTF_WAVETYPE1_WREF
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWVTEXT)))
		wType1 = IUTF_WAVETYPE1_WREF
		wrefSubType = IUTF_WAVETYPE1_TEXT
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWVDFREF)))
		wType1 = IUTF_WAVETYPE1_WREF
		wrefSubType = IUTF_WAVETYPE1_DFR
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDWVWAVEREF)))
		wType1 = IUTF_WAVETYPE1_WREF
		wrefSubType = IUTF_WAVETYPE1_WREF
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDCMPL)))
		wType0 = IUTF_WAVETYPE0_CMPL
		wType1 = IUTF_WAVETYPE1_NUM
	elseif(UTF_FuncRefIsAssigned(FuncRefInfo(fTCMDINT)))
		wType0 = IUTF_WAVETYPE0_INT64
		wType1 = IUTF_WAVETYPE1_NUM
	else
		return 0
	endif

	return 1
End

/// @brief Load the list of the data generators that have to be executed for the specified testcase.
///
/// @param      procWin       The procedure window name
/// @param      fullFuncName  The full function name of the test case
/// @param[out] dgenList      The list of required data generator functions
///
/// @returns 1 on error, 0 on success
static Function GetDataGeneratorListTC(procWin, fullFuncName, dgenList)
	string procWin, fullFuncName
	string &dgenList

	variable wType1, wType0, wRefSubType
	string dgen

	dgenList = ""

	// Simple Test Cases
	FUNCREF TEST_CASE_PROTO fTC = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTC)))
		return 0
	endif
	// MMD Test Case
	FUNCREF TEST_CASE_PROTO_MD fTCmmd = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCmmd)))
		dgenList = UTF_Test_MD_Gen#GetDataGeneratorForMMD(procWin, fullFuncName)
		return 0
	endif

	// Multi Data Test Cases
	if(!GetFunctionSignatureTCMD(fullFuncName, wType0, wType1, wRefSubType))
		return 1
	endif

	dgen = UTF_Test_MD_Gen#GetDataGenFullFunctionName(procWin, fullFuncName)

	dgenList = AddListItem(dgen, dgenList, ";", Inf)

	return 0
End

/// Checks functions signature of a test case candidate
/// and its attributed data generator function
/// Returns 1 on error, 0 on success
static Function CheckFunctionSignatureTC(procWin, fullFuncName, markSkip)
	string procWin
	string fullFuncName
	variable &markSkip

	variable err, wType1, wType0, wRefSubType
	string dgen, msg
	string funcInfo

	markSkip = 0

	// Require only optional parameter
	funcInfo = FunctionInfo(fullFuncName)
	if (NumberByKey("N_PARAMS", funcInfo) != NumberByKey("N_OPT_PARAMS", funcInfo))
		return 1
	endif

	// Simple Test Cases
	FUNCREF TEST_CASE_PROTO fTC = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTC)))
		return 0
	endif
	// MMD Test Case
	FUNCREF TEST_CASE_PROTO_MD fTCmmd = $fullFuncName
	if(UTF_FuncRefIsAssigned(FuncRefInfo(fTCmmd)))
		UTF_Test_MD_Gen#CheckFunctionSignatureMDgen(procWin, fullFuncName, markSkip)
		return 0
	endif

	// Multi Data Test Cases
	if(!GetFunctionSignatureTCMD(fullFuncName, wType0, wType1, wRefSubType))
		return 1
	endif

	dgen = UTF_Test_MD_Gen#GetDataGenFullFunctionName(procWin, fullFuncName)
	WAVE wGenerator = UTF_Test_MD_Gen#CheckDGenOutput(fullFuncName, dgen, wType0, wType1, wRefSubType)
	markSkip = UTF_Test_MD_Gen#CheckDataGenZeroSize(wGenerator, fullFuncName, dgen)

	return 0
End
