#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Test_MD_Gen

///@cond HIDDEN_SYMBOL

/// @brief Returns a global wave that stores the results of the DataGenerators of this testrun
static Function/WAVE GetDataGeneratorWaves()

	string name = "DataGeneratorWaves"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=(IUTF_WAVECHUNK_SIZE) dfr:$name/WAVE=wv
	IUTF_Utils_Vector#SetLength(wv, 0)

	return wv
End

/// Returns the functionName of the specified DataGenerator. The priority is first local then ProcGlobal.
/// If funcName is specified with Module then in all procedures is looked. No ProcGlobal function is returned in that case.
static Function/S GetDataGeneratorFunctionName(err, funcName, procName)
	variable &err
	string funcName, procName

	string infoStr, modName, pName, errMsg

	err = 0
	if(ItemsInList(funcName, "#") > 2)
		sprintf errMsg, "Data Generator Function %s is specified with Independent Module, this is not supported.", funcName
		err = 1
		return errMsg
	endif
	// if funcName is specified without Module then FunctionInfo looks in procedure procName only.
	// if funcName is specified with Module then FunctionInfo looks in all procedures of current compile unit, independent of procName
	infoStr = FunctionInfo(funcName, procName)
	if(!IUTF_Utils#IsEmpty(infoStr))
		modName = StringByKey("MODULE", infoStr)
		pName = StringByKey("NAME", infoStr)
		if(!CmpStr(StringByKey("SPECIAL", infoStr), "static") && IUTF_Utils#IsEmpty(modName))
			sprintf errMsg, "Data Generator Function %s is declared static but the procedure file %s is missing a \"#pragma ModuleName=myName\" declaration.", pName, procName
			err = 1
			return errMsg
		endif
		if(IUTF_Utils#IsEmpty(modName))
			return pName
		endif
		return modName + "#" + pName
	else
		// look in ProcGlobal of current compile unit
		infoStr = FunctionInfo(funcName)
		if(!IUTF_Utils#IsEmpty(infoStr))
			pName = StringByKey("NAME", infoStr)
			return pName
		endif
	endif
	infoStr = GetIndependentModuleName()
	if(!CmpStr(infoStr, "ProcGlobal"))
		sprintf errMsg, "Data Generator Function %s not found in %s or ProcGlobal.", funcName, procName
	else
		sprintf errMsg, "In Independent Module %s, data Generator Function %s not found in %s or globally in IM.", infoStr, funcName, procName
	endif
	err = 1

	return errMsg
End

///@endcond // HIDDEN_SYMBOL

static Function/S GetDataGenFullFunctionName(procWin, fullTestCase)
	string fullTestCase
	string procWin

	variable err
	string dgen, msg

	dgen = IUTF_FunctionTags#GetFunctionTagValue(fullTestCase, UTF_FTAG_TD_GENERATOR, err)
	if(err)
		sprintf msg, "Could not find data generator specification for multi data test case %s. %s", fullTestCase, dgen
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif

	dgen = GetDataGeneratorFunctionName(err, dgen, procWin)
	if(err)
		sprintf msg, "Could not get full function name of data generator: %s", dgen
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif

	return dgen
End

static Function/S GetDataGeneratorForMMD(procWin, fullFuncName)
	string procWin, fullFuncName

	variable i, j, numTypes
	string msg, dgen
	string dgenList = ""

	WAVE/T templates = IUTF_Test_MD_MMD#GetMMDVarTemplates()
	Make/FREE/D wType0 = {0xff %^ IUTF_WAVETYPE0_CMPL %^ IUTF_WAVETYPE0_INT64, NaN, NaN, NaN, IUTF_WAVETYPE0_CMPL, IUTF_WAVETYPE0_INT64}
	Make/FREE/D wType1 = {IUTF_WAVETYPE1_NUM, IUTF_WAVETYPE1_TEXT, IUTF_WAVETYPE1_DFR, IUTF_WAVETYPE1_WREF, IUTF_WAVETYPE1_NUM, IUTF_WAVETYPE1_NUM}

	numTypes = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTypes; i += 1)
		for(j = 0; j < IUTF_DGEN_NUM_VARS; j += 1)
			dgen = GetSingleDataGeneratorForMMD(procWin, fullFuncName, templates[i], j)
			if(!IUTF_Utils#IsEmpty(dgen))
				dgenList = AddListItem(dgen, dgenList, ";", Inf)
			endif
		endfor
	endfor

	if(IUTF_Utils#IsEmpty(dgenList))
		sprintf msg, "No data generator functions specified for test case %s in test suite %s.", fullFuncName, procWin
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif

	return dgenList
End

static Function CheckFunctionSignatureMDgen(procWin, fullFuncName, markSkip)
	string procWin, fullFuncName
	variable &markSkip

	variable i, j, numTypes

	WAVE/T templates = IUTF_Test_MD_MMD#GetMMDVarTemplates()
	Make/FREE/D wType0 = {0xff %^ IUTF_WAVETYPE0_CMPL %^ IUTF_WAVETYPE0_INT64, NaN, NaN, NaN, IUTF_WAVETYPE0_CMPL, IUTF_WAVETYPE0_INT64}
	Make/FREE/D wType1 = {IUTF_WAVETYPE1_NUM, IUTF_WAVETYPE1_TEXT, IUTF_WAVETYPE1_DFR, IUTF_WAVETYPE1_WREF, IUTF_WAVETYPE1_NUM, IUTF_WAVETYPE1_NUM}

	numTypes = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTypes; i += 1)
		for(j = 0; j < IUTF_DGEN_NUM_VARS; j += 1)
			markSkip = markSkip | CheckMDgenOutput(procWin, fullFuncName, templates[i], j, wType0[i], wType1[i])
		endfor
	endfor
End

/// Get a single data generator for a MMD test case. This returns an empty string if no data
/// generator could be found.
static Function/S GetSingleDataGeneratorForMMD(procWin, fullFuncName, varTemplate, index)
	string procWin, fullFuncName, varTemplate
	variable index

	string varName, tagName, dgen, msg
	variable err

	varName = varTemplate + num2istr(index)
	tagName = UTF_FTAG_TD_GENERATOR + " " + varName
	dgen = IUTF_FunctionTags#GetFunctionTagValue(fullFuncName, tagName, err)
	if(err == UTF_TAG_NOT_FOUND)
		return ""
	endif
	dgen = GetDataGeneratorFunctionName(err, dgen, procWin)
	if(err)
		sprintf msg, "Could not get full function name of data generator: %s", dgen
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif

	EvaluateDgenTagResult(err, fullFuncName, varName)

	return dgen
End

/// Check Multi-Multi Data Generator output
/// return 1 if one data generator has a zero sized wave, 0 otherwise
static Function CheckMDgenOutput(procWin, fullFuncName, varTemplate, index, wType0, wType1)
	string procWin, fullFuncName, varTemplate
	variable index, wType0, wType1

	string varName, tagName, dgen, msg
	variable err

	varName = varTemplate + num2istr(index)
	tagName = UTF_FTAG_TD_GENERATOR + " " + varName
	dgen = IUTF_FunctionTags#GetFunctionTagValue(fullFuncName, tagName, err)
	if(err == UTF_TAG_NOT_FOUND)
		return 0
	endif
	dgen = GetDataGeneratorFunctionName(err, dgen, procWin)
	if(err)
		sprintf msg, "Could not get full function name of data generator: %s", dgen
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif

	EvaluateDgenTagResult(err, fullFuncName, varName)

	WAVE wGenerator = CheckDGenOutput(fullFuncName, dgen, wType0, wType1, NaN)

	IUTF_Test_MD_MMD#AddMMDTestCaseData(fullFuncName, dgen, varName, DimSize(wGenerator, UTF_ROW))

	return CheckDataGenZeroSize(wGenerator, fullFuncName, dgen)
End

static Function CheckDataGenZeroSize(wGenerator, fullFuncName, dgen)
	WAVE wGenerator
	string fullFuncName, dgen

	string msg

	if(!DimSize(wGenerator, UTF_ROW))
		sprintf msg, "Note: In test case %s data generator function \"%s\" returns a zero sized wave. Test case marked SKIP.", fullFuncName, dgen
		IUTF_Reporting#ReportError(msg, incrGlobalErrorCounter = 0)
		return 1
	endif

	return 0
End

static Function EvaluateDgenTagResult(err, fullFuncName, varName)
	variable err
	string fullFuncName, varName

	string msg

	if(err == UTF_TAG_EMPTY)
		sprintf msg, "No data generator function specified for function \"%s\" data generator variable \"%s\".", fullFuncName, varName
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif
	if(err != UTF_TAG_OK)
		sprintf msg, "Problem determining data generator function specified for function \"%s\" data generator variable \"%s\".", fullFuncName, varName
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif
End

static Function/WAVE GetGeneratorWave(dgen)
	string dgen

	variable dimPos

	WAVE/WAVE wDgen = GetDataGeneratorWaves()
	dimPos = FindDimlabel(wDgen, UTF_ROW, dgen)
	if(dimPos == -2)
		return $""
	endif
	WAVE wGenerator = wDgen[dimPos]

	return wGenerator
End

static Function/WAVE CheckDGenOutput(fullFuncName, dgen, wType0, wType1, wRefSubType)
	string fullFuncName, dgen
	variable wType0, wType1, wRefSubType

	string msg

	WAVE/Z wGenerator = GetGeneratorWave(dgen)
	if(!WaveExists(wGenerator))
		// wave is not stored
		sprintf msg, "Data Generator function \"%s\" has no suitable data for test case \"%s\".", dgen, fullFuncName
		IUTF_Reporting#ReportErrorAndAbort(msg)
	elseif(!((wType1 == IUTF_WAVETYPE1_NUM && WaveType(wGenerator, 1) == wType1 && WaveType(wGenerator) & wType0) || (wType1 != IUTF_WAVETYPE1_NUM && WaveType(wGenerator, 1) == wType1)))
		sprintf msg, "Data Generator \"%s\" functions returned wave format does not fit to expected test case parameter. It is referenced by test case \"%s\".", dgen, fullFuncName
		IUTF_Reporting#ReportErrorAndAbort(msg)
	elseif(!IUTF_Utils#IsNaN(wRefSubType) && wType1 == IUTF_WAVETYPE1_WREF && !IUTF_Utils#HasConstantWaveTypes(wGenerator, wRefSubType))
		sprintf msg, "Test case \"%s\" expects specific wave type1 %u from the Data Generator \"%s\". The wave type from the data generator does not fit to expected wave type.", fullFuncName, wRefSubType, dgen
		IUTF_Reporting#ReportErrorAndAbort(msg)
	endif

	return wGenerator
End

static Function ExecuteAllDataGenerators(debugMode)
	variable debugMode

	variable i, j, size, length, dimPos, err
	string dgenList, dgen, fullFuncName, endTime, msg, procWin
	variable DGENLIST_Index

	WAVE/T testRunData = IUTF_Basics#GetTestRunData()
	size = DimSize(testRunData, UTF_ROW)
	DGENLIST_Index = FindDimLabel(testRunData, UTF_COLUMN, "DGENLIST")

	if(!size)
		return NaN
	endif

	WAVE/WAVE wDgen = GetDataGeneratorWaves()

	IUTF_Debug#SetDebugger(debugMode)
	IUTF_Reporting_Control#TestSuiteBegin("@DGEN_SUITE")

	for(i = 0; i < size; i += 1)
		dgenList = testRunData[i][DGENLIST_Index]
		WAVE/T dgenWave = ListToTextWave(dgenList, ";")
		length = DimSize(dgenWave, UTF_ROW)

		for(j = 0; j < length; j += 1)
			dgen = dgenWave[j]
			dimPos = FindDimLabel(wDgen, UTF_ROW, dgen)
			if(dimPos != -2)
				continue
			endif
			procWin = StringByKey("PROCWIN", FunctionInfo(dgen))

			FUNCREF TEST_CASE_PROTO_DGEN fDgen = $dgen
			if(!UTF_FuncRefIsAssigned(FuncRefInfo(fDgen)))
				fullFuncName = testRunData[i][%FULLFUNCNAME]
				sprintf msg, "Data Generator function \"%s\" has wrong format. It is referenced by test case \"%s\".", dgen, fullFuncName
				IUTF_Reporting#ReportErrorAndAbort(msg)
			endif

			IUTF_Reporting_Control#TestCaseBegin(dgen, 0)
			try
				IUTF_Basics#ClearRTError()
				WAVE/Z wGenerator = fDgen(); AbortOnRTE
			catch
				msg = GetRTErrMessage()
				err = GetRTError(1)
				IUTF_Basics#EvaluateRTE(err, msg, V_AbortCode, dgen, IUTF_DATA_GEN_TYPE, procWin)

				sprintf msg, "Invalid Data Generator \"%s\"", dgen
				IUTF_Reporting#ReportErrorAndAbort(msg)
			endtry
			endTime = IUTF_Reporting#GetTimeString()

			if(!WaveExists(wGenerator))
				sprintf msg, "Data Generator function \"%s\" (%s) returns a null wave.", dgen, procWin
				IUTF_Reporting#ReportErrorAndAbort(msg)
			elseif(DimSize(wGenerator, UTF_COLUMN) > 0)
				sprintf msg, "Data Generator function \"%s\" (%s) returns not a 1D wave.", dgen, procWin
				IUTF_Reporting#ReportErrorAndAbort(msg)
			endif

			IUTF_Reporting_Control#TestCaseEnd(endTime)

			AddDataGeneratorWave(dgen, wGenerator)
		endfor
	endfor

	IUTF_Reporting_Control#TestSuiteEnd() // of @DGEN_SUITE
	IUTF_Debug#RestoreDebugger()
End

static Function AddDataGeneratorWave(name, generator)
	string name
	WAVE generator

	variable index

	WAVE/WAVE wv = GetDataGeneratorWaves()
	index = IUTF_Utils_Vector#AddRow(wv)
	wv[index] = generator
	SetDimLabel UTF_ROW, index, $name, wv
End
