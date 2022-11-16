#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma ModuleName = UTF_Tracing_Analytics

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)


static Structure CollectionResult
	WAVE/T functions
	WAVE lines
	WAVE calls
	WAVE sums
	variable count
EndStructure

static Function GetMaxFuncCount()
	WAVE/WAVE funcLocations = UTF_Tracing#GetFuncLocations()
	variable size = DimSize(funcLocations, UTF_ROW)

	Make/FREE=1/N=(size) helper = DimSize(funcLocations[p][%FUNCLIST], UTF_ROW)
	return WaveMax(helper)
End

static Function GetMaxProcLineCount()
	WAVE wv = UTF_Tracing#GetProcSizes()

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
	WAVE/WAVE funcLocations = UTF_Tracing#GetFuncLocations()
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
	WAVE/WAVE funcLocations = UTF_Tracing#GetFuncLocations()
	variable lbFuncList = FindDimLabel(funcLocations, UTF_COLUMN, "FUNCLIST")
	variable lbFuncStart = FindDimLabel(funcLocations, UTF_COLUMN, "FUNCSTART")

	Make/FREE=1/N=(procCount, lineCount)/T result.functions = ""
	Make/FREE=1/N=(procCount, lineCount) result.lines = q
	Make/FREE=1/N=(procCount, lineCount) result.calls = totals[q][0][p]

	WAVE procSizes = UTF_Tracing#GetProcSizes()
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
#endif
