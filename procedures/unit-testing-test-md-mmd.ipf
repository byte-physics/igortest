#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Test_MD_MMD

///@cond HIDDEN_SYMBOL

static StrConstant DGEN_VAR_TEMPLATE = "v"
static StrConstant DGEN_STR_TEMPLATE = "s"
static StrConstant DGEN_DFR_TEMPLATE = "dfr"
static StrConstant DGEN_WAVE_TEMPLATE = "w"
static StrConstant DGEN_CMPLX_TEMPLATE = "c"
static StrConstant DGEN_INT64_TEMPLATE = "i"

/// @brief Returns a global wave that stores the multi-multi-data testcase (MMD TC) state waves
///        The getter function for the MMD TC state waves is GetMMDFuncState()
static Function/WAVE GetMMDataState()

	string name = "MMDataState"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=0 dfr:$name/WAVE=wv

	return wv
End

/// Creates a global with the allowed variable names for mmd data tests and returns the value
static Function/S GetMMDAllVariablesList()

	variable i, j, numTemplates
	string varName, varList

	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr mmdAllVariablesList

	if(SVAR_EXISTS(mmdAllVariablesList))
		return mmdAllVariablesList
	endif

	varList = ""

	WAVE/T templates = GetMMDVarTemplates()
	numTemplates = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTemplates; i += 1)
		for(j = 0; j < IUTF_DGEN_NUM_VARS; j += 1)
			varName = templates[i] + num2istr(j)
			varList = AddListItem(varName, varList)
		endfor
	endfor

	string/G dfr:mmdAllVariablesList = varList

	return varList
End

///@endcond // HIDDEN_SYMBOL

static Function/WAVE GetMMDVarTemplates()

	Make/FREE/T templates = {DGEN_VAR_TEMPLATE, DGEN_STR_TEMPLATE, DGEN_DFR_TEMPLATE, DGEN_WAVE_TEMPLATE, DGEN_CMPLX_TEMPLATE, DGEN_INT64_TEMPLATE}
	return templates
End

static Function/WAVE GetMMDFuncState()

	Make/FREE/T/N=(0, 3) mdFunState
	SetDimLabel UTF_COLUMN, 0, DATAGEN, mdFunState
	SetDimLabel UTF_COLUMN, 1, GENSIZE, mdFunState
	SetDimLabel UTF_COLUMN, 2, INDEX, mdFunState

	return mdFunState
End

static Function AddMMDTestCaseData(fullFuncName, dgen, varName, genSize)
	string fullFuncName, dgen, varName
	variable genSize

	variable funPos, size
	variable varPos, vSize

	WAVE/WAVE mdState = GetMMDataState()
	funPos = FindDimLabel(mdState, UTF_ROW, fullFuncName)
	if(funPos == -2)
		size = DimSize(mdState, UTF_ROW)
		Redimension/N=(size + 1) mdState
		SetDimLabel UTF_ROW, size, $fullFuncName, mdState
		funPos = size
		WAVE/T mdFunState = GetMMDFuncState()
		varPos = -2
	else
		WAVE/T mdFunState = mdState[funPos]
		varPos = FindDimLabel(mdFunState, UTF_ROW, varName)
	endif

	if(varPos == -2)
		vSize = DimSize(mdFunState, UTF_ROW)
		Redimension/N=(vSize + 1, -1) mdFunState
		SetDimLabel UTF_ROW, vSize, $varName, mdFunState
		varPos = vSize
	endif
	mdFunState[varPos][%DATAGEN] = dgen
	mdFunState[varPos][%GENSIZE] = num2istr(genSize)
	mdFunState[varPos][%INDEX] = num2istr(0)
	mdState[funPos] = mdFunState
End

/// Return 1 if the counting finished, 0 otherwise
static Function IncreaseMMDIndices(fullFuncName)
	string fullFuncName

	variable i, numVars, index, genSize

	WAVE/WAVE mdState = GetMMDataState()
	WAVE/T mdFunState = mdState[%$fullFuncName]
	numVars = DimSize(mdFunState, UTF_ROW)
	for(i = 0; i < numVars; i += 1)
		index = str2num(mdFunState[i][%INDEX])
		genSize = str2num(mdFunState[i][%GENSIZE])
		index += 1
		if(index < genSize)
			mdFunState[i][%INDEX] = num2istr(index)
			return 0
		else
			mdFunState[i][%INDEX] = num2istr(0)
		endif
	endfor

	return 1
End

static Function SetupMMDStruct(mData, fullFuncName)
	STRUCT IUTF_mData &mData
	string fullFuncName

	variable i, j, numTypes
	variable funPos, varPos, index, val
	variable/C cplx
	string msg, varName, dgen, str
#if (IgorVersion() >= 7.0)
	int64 i64
#endif

	WAVE/WAVE dgenWaves = UTF_Test_MD_Gen#GetDataGeneratorWaves()
	WAVE/WAVE mdState = GetMMDataState()
	WAVE/T templates = GetMMDVarTemplates()

	WAVE/T mdFunState = mdState[%$fullFuncName]

	numTypes = DimSize(templates, UTF_ROW)
	for(i = 0; i < numTypes; i += 1)
		for(j = 0; j < IUTF_DGEN_NUM_VARS; j += 1)
			varName = templates[i] + num2istr(j)
			varPos = FindDimLabel(mdFunState, UTF_ROW, varName)
			if(varPos == -2)
				continue
			endif
			dgen = mdFunState[varPos][%DATAGEN]
			index = str2num(mdFunState[varPos][%INDEX])

			strSwitch(templates[i])
				case DGEN_VAR_TEMPLATE:
					WAVE wGenerator = dgenWaves[%$dgen]
					val = wGenerator[index]

					switch(j)
						case 0:
							mData.v0 = val
							break
						case 1:
							mData.v1 = val
							break
						case 2:
							mData.v2 = val
							break
						case 3:
							mData.v3 = val
							break
						case 4:
							mData.v4 = val
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_STR_TEMPLATE:
					WAVE/T wGeneratorT = dgenWaves[%$dgen]
					str = wGeneratorT[index]

					switch(j)
						case 0:
							mData.s0 = str
							break
						case 1:
							mData.s1 = str
							break
						case 2:
							mData.s2 = str
							break
						case 3:
							mData.s3 = str
							break
						case 4:
							mData.s4 = str
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_DFR_TEMPLATE:
					WAVE/DF wGeneratorDFR = dgenWaves[%$dgen]
					DFREF dfr = wGeneratorDFR[index]

					switch(j)
						case 0:
							mData.dfr0 = dfr
							break
						case 1:
							mData.dfr1 = dfr
							break
						case 2:
							mData.dfr2 = dfr
							break
						case 3:
							mData.dfr3 = dfr
							break
						case 4:
							mData.dfr4 = dfr
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_WAVE_TEMPLATE:
					WAVE/WAVE wGeneratorWV = dgenWaves[%$dgen]
					WAVE wv = wGeneratorWV[index]

					switch(j)
						case 0:
							WAVE mData.w0 = wv
							break
						case 1:
							WAVE mData.w1 = wv
							break
						case 2:
							WAVE mData.w2 = wv
							break
						case 3:
							WAVE mData.w3 = wv
							break
						case 4:
							WAVE mData.w4 = wv
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
				case DGEN_CMPLX_TEMPLATE:
					WAVE/C wGeneratorC = dgenWaves[%$dgen]
					cplx = wGeneratorC[index]

					switch(j)
						case 0:
							mData.c0 = cplx
							break
						case 1:
							mData.c1 = cplx
							break
						case 2:
							mData.c2 = cplx
							break
						case 3:
							mData.c3 = cplx
							break
						case 4:
							mData.c4 = cplx
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
#if (IgorVersion() >= 7.0)
				case DGEN_INT64_TEMPLATE:
					WAVE wGeneratorI = dgenWaves[%$dgen]
					i64 = wGeneratorI[index]

					switch(j)
						case 0:
							mData.i0 = i64
							break
						case 1:
							mData.i1 = i64
							break
						case 2:
							mData.i2 = i64
							break
						case 3:
							mData.i3 = i64
							break
						case 4:
							mData.i4 = i64
							break
						default:
							UTF_Reporting#ReportErrorAndAbort("Encountered invalid index for mmd tc")
							break
					endswitch
					break
#endif
				default:
					UTF_Reporting#ReportErrorAndAbort("Encountered invalid type for mmd tc")
					break
			endswitch
		endfor
	endfor
End

/// @brief Structure for multi data function using multiple data generators
#if (IgorVersion() >= 7.0)
Structure IUTF_mData
	variable v0
	variable v1
	variable v2
	variable v3
	variable v4
	string s0
	string s1
	string s2
	string s3
	string s4
	DFREF dfr0
	DFREF dfr1
	DFREF dfr2
	DFREF dfr3
	DFREF dfr4
	WAVE/WAVE w0
	WAVE/WAVE w1
	WAVE/WAVE w2
	WAVE/WAVE w3
	WAVE/WAVE w4
	variable/C c0
	variable/C c1
	variable/C c2
	variable/C c3
	variable/C c4
	int64 i0
	int64 i1
	int64 i2
	int64 i3
	int64 i4
EndStructure
#else
Structure IUTF_mData
	variable v0
	variable v1
	variable v2
	variable v3
	variable v4
	string s0
	string s1
	string s2
	string s3
	string s4
	DFREF dfr0
	DFREF dfr1
	DFREF dfr2
	DFREF dfr3
	DFREF dfr4
	WAVE/WAVE w0
	WAVE/WAVE w1
	WAVE/WAVE w2
	WAVE/WAVE w3
	WAVE/WAVE w4
	variable/C c0
	variable/C c1
	variable/C c2
	variable/C c3
	variable/C c4
EndStructure
#endif

static Function/S GetMMDTCSuffix(tdIndex)
	variable tdIndex

	variable i, numVars, index
	string fullFuncName, dgen, lbl
	string tcSuffix = ""

	WAVE/T testRunData = UTF_Basics#GetTestRunData()
	WAVE/WAVE dgenWaves = UTF_Test_MD_Gen#GetDataGeneratorWaves()
	WAVE/WAVE mdState = GetMMDataState()

	fullFuncName = testRunData[tdIndex][%FULLFUNCNAME]
	WAVE/T mdFunState = mdState[%$fullFuncName]

	numVars = DimSize(mdFunState, UTF_ROW)
	for(i = 0; i < numVars; i += 1)
		dgen = mdFunState[i][%DATAGEN]
		index = str2num(mdFunState[i][%INDEX])
		WAVE wGenerator = dgenWaves[%$dgen]
		lbl = GetDimLabel(wGenerator, UTF_ROW, index)
		if(!UTF_Utils#IsEmpty(lbl))
			tcSuffix += IUTF_TC_SUFFIX_SEP + lbl
		else
			tcSuffix += IUTF_TC_SUFFIX_SEP + num2istr(index)
		endif
	endfor

	return tcSuffix
End
