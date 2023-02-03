#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Tracing_Analytics

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)

static Structure CollectionResult
	WAVE/T functions
	WAVE lines
	WAVE calls
	WAVE sums
	variable count
EndStructure

static Function GetMaxFuncCount()
	WAVE/WAVE funcLocations = IUTF_Tracing#GetFuncLocations()
	variable size = DimSize(funcLocations, UTF_ROW)

	Make/FREE=1/N=(size) helper = DimSize(funcLocations[p][%FUNCLIST], UTF_ROW)
	return WaveMax(helper)
End

static Function GetMaxProcLineCount()
	WAVE wv = IUTF_Tracing#GetProcSizes()

	return WaveMax(wv)
End

static Function/WAVE GetTotals()
	variable i, numWaves

	TUFXOP_GetStorage/N="IUTF_TestRun" storage
	numWaves = DimSize(storage, UTF_ROW)
	WAVE/ZZ totals
	for(i = 0; i < numWaves; i++)
		WAVE/WAVE/Z entryOuter = storage[i]
		if(!WaveExists(entryOuter))
			continue
		endif
		WAVE entry = entryOuter[0]
		if(WaveExists(totals))
			totals += entry
		else
			Duplicate/FREE=1 entry, totals
		endif
	endfor

	if(!WaveExists(totals))
		Make/N=0/FREE=1 totals
	endif

	return totals
End

static Function CollectFunctions(WAVE totals, WAVE/T procs, STRUCT CollectionResult &result)
	variable i, j, startIndex, endIndex, funcCount
	variable procCount = DimSize(procs, UTF_ROW)
	variable maxFuncCount = GetMaxFuncCount()
	DFREF dfr = GetPackageFolder()
	WAVE/WAVE funcLocations = IUTF_Tracing#GetFuncLocations()
	variable lbFuncList = FindDimLabel(funcLocations, UTF_COLUMN, "FUNCLIST")
	variable lbFuncStart = FindDimLabel(funcLocations, UTF_COLUMN, "FUNCSTART")

	Make/FREE=1/N=(procCount, maxFuncCount)/T result.functions
	Make/FREE=1/N=(procCount, maxFuncCount) result.lines, result.calls, result.sums

	for(i = 0; i < procCount; i++)
		WAVE/T procFuncNames = funcLocations[i][lbFuncList]
		WAVE procFuncLines = funcLocations[i][lbFuncStart]
		funcCount = DimSize(procFuncNames, UTF_ROW)
		if(!funcCount)
			continue
		endif
		result.count += funcCount

		result.functions[i][0, funcCount - 1] = procFuncNames[q]
		result.lines[i][0, funcCount - 1] = procFuncLines[q]
		result.calls[i][0, funcCount - 1] = totals[procFuncLines[q]][0][i]
		for(j = 0; j < funcCount; j++)
			startIndex = procFuncLines[j]
			endIndex = j + 1 < funcCount ? procFuncLines[j + 1] : DimSize(totals, UTF_ROW)
			WaveStats/M=1/Q/RMD=[startIndex, endIndex - 1][0, 0][i, i] totals
			result.sums[i][j] = V_sum
		endfor
	endfor
End

static Function CollectLines(WAVE totals, WAVE/T procs, STRUCT CollectionResult &result)
	variable i, j, funcCount
	string name
	variable procCount = DimSize(procs, UTF_ROW)
	variable lineCount = GetMaxProcLineCount()
	DFREF dfr = GetPackageFolder()
	WAVE/WAVE funcLocations = IUTF_Tracing#GetFuncLocations()
	variable lbFuncList = FindDimLabel(funcLocations, UTF_COLUMN, "FUNCLIST")
	variable lbFuncStart = FindDimLabel(funcLocations, UTF_COLUMN, "FUNCSTART")

	Make/FREE=1/N=(procCount, lineCount)/T result.functions = ""
	Make/FREE=1/N=(procCount, lineCount) result.lines = q
	Make/FREE=1/N=(procCount, lineCount) result.calls = totals[q][0][p]

	WAVE procSizes = IUTF_Tracing#GetProcSizes()
	for(i = 0; i < procCount; i++)
		WAVE/T procFuncNames = funcLocations[i][lbFuncList]
		WAVE procFuncLines = funcLocations[i][lbFuncStart]
		lineCount = procSizes[i]
		result.count += lineCount

		// insert the function names at the lines of their declaration.
		funcCount = DimSize(procFuncNames, UTF_ROW)
		for(j = 0; j < funcCount; j++)
			result.functions[i][procFuncLines[j]] = procFuncNames[j]
		endfor

		// fill in the gaps between the function declaration with the name
		// of the previous function declaration
		name = ""
		for(j = 0; j < lineCount; j++)
			if(!strlen(result.functions[i][j]))
				result.functions[i][j] = name
			else
				name = result.functions[i][j]
			endif
		endfor
	endfor
End

static Function/WAVE SearchHighestWithMeta(WAVE/T procs, STRUCT CollectionResult &collectionResult, variable sorting)
	variable i, searchIndex, metaIndex
	string msg

	Make/FREE=1/N=(collectionResult.count, 5)/T result
	SetDimLabel UTF_COLUMN, 0, 'Function Calls', result
	SetDimLabel UTF_COLUMN, 1, 'Sum of called Lines', result
	SetDimLabel UTF_COLUMN, 2, Procedure, result
	SetDimLabel UTF_COLUMN, 3, Function, result
	SetDimLabel UTF_COLUMN, 4, Line, result

	if(sorting == UTF_ANALYTICS_CALLS)
		WAVE searchWave = collectionResult.calls
		searchIndex = 0
		WAVE metaWave = collectionResult.sums
		metaIndex = 1
	elseif(sorting == UTF_ANALYTICS_SUM)
		WAVE searchWave = collectionResult.sums
		searchIndex = 1
		WAVE metaWave = collectionResult.calls
		metaIndex = 0
	else
		sprintf msg, "Bug: Sorting %d is not supported", sorting
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
		return result
	endif

	for(i = 0; i < collectionResult.count; i++)
		WaveStats/M=1/Q searchWave
		if(V_max <= 0)
			Redimension/N=(i, -1) result
			return result
		endif
		result[i][searchIndex] = num2istr(V_max)
		result[i][metaIndex] = num2istr(metaWave[V_maxRowLoc][V_maxColLoc])
		result[i][2] = procs[V_maxRowLoc]
		result[i][3] = collectionResult.functions[V_maxRowLoc][V_maxColLoc]
		result[i][4] = num2istr(collectionResult.lines[V_maxRowLoc][V_maxColLoc])
		searchWave[V_maxRowLoc][V_maxColLoc] = NaN
	endfor

	return result
End

static Function/WAVE SearchHighest(WAVE/T procs, STRUCT CollectionResult &collectionResult, variable sorting)
	variable i
	string msg

	Make/FREE=1/N=(collectionResult.count, 4)/T result
	SetDimLabel UTF_COLUMN, 0, Calls, result
	SetDimLabel UTF_COLUMN, 1, Procedure, result
	SetDimLabel UTF_COLUMN, 2, Function, result
	SetDimLabel UTF_COLUMN, 3, Line, result

	if(sorting == UTF_ANALYTICS_CALLS)
		WAVE searchWave = collectionResult.calls
	else
		sprintf msg, "Bug: Sorting %d is not supported", sorting
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
		return result
	endif

	for(i = 0; i < collectionResult.count; i++)
		WaveStats/M=1/Q searchWave
		if(V_max <= 0)
			Redimension/N=(i, -1) result
			return result
		endif
		result[i][0] = num2istr(V_max)
		result[i][1] = procs[V_maxRowLoc]
		result[i][2] = collectionResult.functions[V_maxRowLoc][V_maxColLoc]
		result[i][3] = num2istr(collectionResult.lines[V_maxRowLoc][V_maxColLoc])
		searchWave[V_maxRowLoc][V_maxColLoc] = NaN
	endfor

	return result
End

static Function/S GetWaveHeader(WAVE wv)
	variable i
	string header = ""
	variable size = DimSize(wv, UTF_COLUMN)

	for(i = size - 1; i >= 0; i--)
		header = AddListItem(GetDimLabel(wv, UTF_COLUMN, i), header)
	endfor

	return header
End

static Function HasTracingData()
	DFREF dfr = GetPackageFolder()

	WAVE/Z/SDFR=dfr FuncLocations
	WAVE/Z/SDFR=dfr ProcSizes
	if(!WaveExists(FuncLocations) || !WaveExists(ProcSizes))
		return 0
	endif

	TUFXOP_GetStorage/Z/N="IUTF_TestRun" storage
	if(V_flag)
		return 0
	endif

	return 1
End

/// @brief Show the top functions after a tracing run in the history area
/// @param count   The maximum number of items that should be output.
/// @param mode    (optional, default UTF_ANALYTICS_FUNCTIONS) defines the data selection.
///                Can be UTF_ANALYTICS_FUNCTIONS or UTF_ANALYTICS_LINES.
/// @param sorting (optional, default UTF_ANALYTICS_CALLS) defines the metric for sorting.
///                Can be UTF_ANALYTICS_CALLS or UTF_ANALYTICS_SUM. UTF_ANALYTICS_SUM is only
///                supported for the mode UTF_ANALYTICS_FUNCTIONS.
Function ShowTopFunctions(variable count, [variable mode, variable sorting])
	STRUCT CollectionResult collectionResult
	string msg, header
	WAVE/T procs = IUTF_Tracing#GetTracedProcedureNames()
	DFREF dfr = GetPackageFolder()

	mode = ParamIsDefault(mode) ? UTF_ANALYTICS_FUNCTIONS : mode
	sorting = ParamIsDefault(sorting) ? UTF_ANALYTICS_CALLS : sorting

	if(mode != UTF_ANALYTICS_FUNCTIONS && mode != UTF_ANALYTICS_LINES)
		sprintf msg, "Mode %d is an unsupported mode", mode
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
		return NaN
	endif
	if(sorting != UTF_ANALYTICS_CALLS && sorting != UTF_ANALYTICS_SUM)
		sprintf msg, "Sorting %d is an unsupported sorting", sorting
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
		return NaN
	endif
	if(sorting == UTF_ANALYTICS_SUM && mode != UTF_ANALYTICS_FUNCTIONS)
		IUTF_Reporting#UTF_PrintStatusMessage("Sum sorting is only available for the functions mode")
		return NaN
	endif
	if(count < 0 || IUTF_Utils#IsNaN(count))
		sprintf msg, "Invalid count: %d", count
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
		return NaN
	endif
	if(!HasTracingData())
		IUTF_Reporting#UTF_PrintStatusMessage("No Tracing data exists. Try to run tracing first.")
		return NaN
	endif

	WAVE totals = GetTotals()
	if(!DimSize(totals, UTF_ROW))
		// this can happen after stored Experiment is loaded to a fresh instance of Igor
		IUTF_Reporting#UTF_PrintStatusMessage("TUFXOP has no data. Try to rerun tracing to get new data.")
		return NaN
	endif

	if(mode == UTF_ANALYTICS_FUNCTIONS)
		CollectFunctions(totals, procs, collectionResult)
	elseif(mode == UTF_ANALYTICS_LINES)
		CollectLines(totals, procs, collectionResult)
	else
		sprintf msg, "Bug: Unknown mode %d for collection", mode
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
		return NaN
	endif

	if(count < collectionResult.count)
		collectionResult.count = count
	endif

	if(mode == UTF_ANALYTICS_FUNCTIONS)
		WAVE/T result = SearchHighestWithMeta(procs, collectionResult, sorting)
	elseif(mode == UTF_ANALYTICS_LINES)
		WAVE/T result = SearchHighest(procs, collectionResult, sorting)
	else
		sprintf msg, "Bug: Unknown mode %d for sorting", mode
		IUTF_Reporting#UTF_PrintStatusMessage(msg)
	endif

	Duplicate/O result, dfr:TracingAnalyticResult

	header = GetWaveHeader(result)
	msg = IUTF_Utils#NicifyTableText(result, header)
	IUTF_Reporting#UTF_PrintStatusMessage(msg)
End

#endif
