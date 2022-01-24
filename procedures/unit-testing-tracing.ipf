#pragma rtGlobals=3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_Tracing

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 37700)

static StrConstant TRACING_AUTOGEN_PROCEDURE = "unit-testing-tracing-auto.ipf"
static StrConstant TRACING_AUTOGEN_FUNCTION = "GetTracedProcedureNames"
static StrConstant AUTOGEN_START = "// START OF AUTO GENERATED LINES"
static StrConstant AUTOGEN_END = "// END OF AUTO GENERATED LINES"
static StrConstant AUTODEL_START = "// AUTO DELETE AFTER THIS LINE"
static StrConstant PROC_BACKUP_ENDING = ".backup"
static StrConstant FUNCTION_TAG_PREFIX = "IUTF_TagFunc_"
static StrConstant GLOBAL_IPROCLIST = "instrumentedProcWins"
static StrConstant INSTRUDATA_FILENAME = "iutf_instrumentation_data.txt"
static Constant TABSIZE = 4

static Function SetupTracing(string procWinList, string traceOptions)

	variable instrumentOnly

	print "Setting up tracing..."

	SetupTraceProcedures(procWinList, traceOptions)

	DFREF dfr = GetPackageFolder()
	variable/G dfr:enableTracingAfterCompileHook = 1

	instrumentOnly = NumberByKey(UTF_KEY_INSTRUMENTATIONONLY, traceOptions)
	variable/G dfr:instrumentOnly = UTF_Utils#IsNaN(instrumentOnly) ? 0 : instrumentOnly

	print "Recompiling..."
	CompileAndRestart()
End

static Function CompileAndRestart()

	Execute/P "RELOAD CHANGED PROCS "
	Execute/P "COMPILEPROCEDURES "
End

static Function AfterCompiledHook()

	string cmd

	DFREF dfr = GetPackageFolder()
	NVAR/Z ACHookEnabled = dfr:enableTracingAfterCompileHook
	if(!NVAR_Exists(ACHookEnabled) || !ACHookEnabled)
		return 0
	endif

	if(!AllCompiled())
		CompileAndRestart()
		return 0
	endif

	ACHookEnabled = 0

	NVAR/Z instrumentOnly = dfr:instrumentOnly
	if(NVAR_Exists(instrumentOnly) && instrumentOnly)
		return 0
	endif

	sprintf cmd, "RunTest(\"\", traceWinList=\"%s\")", IUTF_TRACE_REENTRY_KEYWORD
	Execute/P/Q cmd
	return 0
End

static Function/S GetTaggedFunctionName(string procWin)

	return FUNCTION_TAG_PREFIX + Hash(procWin, 1) + "_IGNORE"
End

static Function AllCompiled()

	variable i, numProcs
	string fullProcText, procWin, funcName, funcList

	DFREF dfr = GetPackageFolder()
	SVAR procWinList = dfr:$GLOBAL_IPROCLIST

	procWinList = AddListItem(TRACING_AUTOGEN_PROCEDURE, procWinList, ";", Inf)
	numProcs = ItemsInList(procWinList)
	for(i = 0; i < numProcs; i += 1)
		procWin = StringFromList(i, procWinList)
		funcName = GetTaggedFunctionName(procWin)
		funcList = FunctionList(funcName, ";", "WIN:" + procWin)
		if(UTF_Utils#IsEmpty(funcList))
			return 0
		endif
	endfor

	return 1
End

static Function/S PreCheckProcedures(string procWinList)

	variable numProcs, i
	string procWin, infoStr, procText, outList, reservedProcWin

	outList = ""

	reservedProcWin = StringByKey("PROCWIN", FunctionInfo("Z_"))

	numProcs = ItemsInList(procWinList)
	for(i = 0; i < numProcs; i += 1)
		procWin = StringFromList(i, procWinList)
		infoStr = FunctionInfo(GetTaggedFunctionName(procWin), procWin)
		if(!UTF_Utils#IsEmpty(infoStr))
			printf "Tag function for procedure file %s is already present. (Is the procedure already instrumented?)\r", procWin
			Abort
		endif
		WAVE/T wProcText = ListToTextWave(ProcedureText("", NaN, procWin), "\r")
		if(DimSize(wProcText, UTF_ROW) >= UTF_MAX_PROC_LINES)
			printf "Procedure file %s has too many lines. (Current limit %d)\r", procWin, UTF_MAX_PROC_LINES
			Abort
		endif
		if(CmpStr(procWin, reservedProcWin))
			outList = AddListItem(procWin, outList, ";", Inf)
		endif
	endfor

	return outList
End

/// @brief Sets up procedure files for code coverage tracing and writes them back
static Function SetupTraceProcedures(string procWinList, string traceOptions)

	variable numProcs, i, fNum, enableRegExp
	string funcPath, output, input, compTag, endL, line, procWin, iProcList

	iProcList = ""

	enableRegExp = NumberByKey(UTF_KEY_REGEXP, traceOptions)
	enableRegExp = UTF_Utils#IsNaN(enableRegExp) ? 0 : enableRegExp

	procWinList = UTF_Basics#AdaptProcWinList(procWinList, enableRegExp)
	procWinList = UTF_Basics#FindProcedures(procWinList, enableRegExp)
	procWinList = PreCheckProcedures(procWinList)
	numProcs = ItemsInList(procWinList)

	Make/FREE/D/N=(UTF_MAX_PROC_LINES, numProcs) markLinesProc

	WAVE/Z/T procText
	WAVE/Z markLines
	for(i = 0; i < numProcs; i += 1)
		procWin = StringFromList(i, procWinList)
		[procText, funcPath, markLines] = AddTraceFunctions(procWin, i)
		if(!UTF_Utils#IsEmpty(funcPath))
			markLinesProc[0, DimSize(markLines, UTF_ROW) - 1][i] = markLines[p]

			Open/R/Z fNum as funcPath
			if(V_flag)
				printf "Open failed for file %s.\r", funcPath
				Abort
			endif
			FStatus fNum
			input = PadString("", V_logEOF, 0x20)
			FBinRead fnum, input
			Close fNum

			Open/Z fNum as (funcPath + PROC_BACKUP_ENDING)
			if(V_flag)
				printf "Open failed for file %s.\r", funcPath + PROC_BACKUP_ENDING
				Abort
			endif
			FBinWrite fnum, input
			Close fNum

			endL = GetLineEnding(input, defEndL = "\r")

			output = UTF_Utils#TextWaveToList(procText, endL)

			output += "Function " + GetTaggedFunctionName(procWin) + "()" + endL
			output += "End" + endL

			Open/Z fNum as funcPath
			if(V_flag)
				printf "Open failed for file %s.\r", funcPath
				Abort
			endif
			FBinWrite fNum, output
			Close fNum

			iProcList = AddListItem(procWin, iProcList)
		endif
	endfor

	Save/P=home/O/M="\n"/J markLinesProc as INSTRUDATA_FILENAME

	DFREF dfr = GetPackageFolder()
	string/G dfr:$GLOBAL_IPROCLIST = iProcList

	WriteProcList(procWinList)
End

/// @brief Generates code for GetTracedProcedureNames function to resolve procNum to procedure name on analysis.
static Function WriteProcList(string procWinList)

	string fullProcText, newCode, funcPath, fullFuncName, output
	variable i, numProcs, err, fNum

	fullFuncName = UTF_Basics#getFullFunctionName(err, TRACING_AUTOGEN_FUNCTION, TRACING_AUTOGEN_PROCEDURE)
	if(err)
		printf "Unable to retrieve full function name.\r"
		Abort
	endif
	funcPath = FunctionPath(fullFuncName)

	fullProcText = ProcedureText("", NaN, TRACING_AUTOGEN_PROCEDURE)
	WAVE/T wProcText = ListToTextWave(fullProcText, "\r")
	FindValue/TEXT=AUTOGEN_END/TXOP=4 wProcText
	if(V_Value < 0)
		printf "Autogen end marker not found.\r"
		Abort
	endif
	Duplicate/FREE/RMD=[V_Value, Inf] wProcText, fullTrailText
	FindValue/TEXT=AUTODEL_START/TXOP=4 fullTrailText
	Duplicate/FREE/RMD=[0 , V_Value] fullTrailText, trailText

	FindValue/TEXT=AUTOGEN_START/TXOP=4 wProcText
	if(V_Value < 0)
		printf "Autogen start marker not found.\r"
		Abort
	endif
	Duplicate/FREE/RMD=[0, V_Value] wProcText, headText

	numProcs = ItemsInList(procWinList)

	newCode = "Make/FREE/T wt = {\\\r"
	for(i = 0; i < numProcs - 1; i += 1)
		newCode += "\"" + StringFromList(i, procWinList) + "\",\\\r"
	endfor
	newCode += "\"" + StringFromList(numProcs - 1, procWinList) + "\"\\\r"
	newCode += "}\r"
	newCode += "return wt\r"
	WAVE/T wNewCode = ListToTextWave(newCode, "\r")

	Open/Z fNum as funcPath
	if(V_flag)
		printf "Open failed for file %s.\r", funcPath
		Abort
	endif
	wfprintf fNum, "%s\r", headText
	wfprintf fNum, "%s\r", wNewCode
	wfprintf fNum, "%s\r", trailText

	output = "Function " + GetTaggedFunctionName(TRACING_AUTOGEN_PROCEDURE) + "()\rEnd\r"
	fprintf fNum, "%s", output
	Close fNum
End

/// @brief Parses a function declaration and returns the list of declared variables
static Function/WAVE GetFunctionDeclarationList(string line)

	variable b1, b2, numDec, i, decSubCnt
	string decPart, decList, dec

	b1 = strsearch(line, "(", 0)
	if(b1 < 0)
		printf "Error parsing function declaration: %s.\r", line
		Abort
	endif
	b2 = strsearch(line, ")", b1 + 1)
	if(b2 < 0)
		printf "Error parsing function declaration: %s.\r", line
		Abort
	endif
	decPart = line[b1 + 1, b2 - 1]
	if(UTF_Utils#IsEmpty(decPart))
		Make/FREE/T/N=0 wt
		return wt
	endif
	decPart = StringFromList(0, decPart, "[") + StringFromList(1, decPart, "[")
	decPart = StringFromList(0, decPart, "]") + StringFromList(1, decPart, "]")

	decList = ""
	numDec = ItemsInList(decPart, ",")
	for(i = 0; i < numDec; i +=1)
		dec = StringFromList(i, decPart, ",")
		dec = TrimString(dec)
		decSubCnt = ItemsInList(dec, " ")
		if(decSubCnt > 1)
			dec = TrimString(StringFromList(decSubCnt - 1, dec, " "))
		endif
		decList = AddListItem(dec, decList, ";", Inf)
	endfor

	return ListToTextWave(decList, ";")
End

/// @brief returns the ascending function line numbers and sorts the function list accordingly
static Function/WAVE FindFunctionLocations(WAVE/T wFuncList, string procWin)

	Make/FREE/N=(DimSize(wFuncList, UTF_ROW)) wFuncLineStart
	wFuncLineStart[] = NumberByKey("PROCLINE", FunctionInfo(wFuncList[p], procWin))
	Sort wFuncLineStart, wFuncLineStart, wFuncList

	return wFuncLineStart
End

/// @brief Add code coverage tracing to all functions in procWin
static Function [WAVE/T w, string funcPath_, WAVE lineMark] AddTraceFunctions(string procWin, variable procNum)

	string allProcWins, errMsg
	string funcList, fullFuncName, funcName, funcPath
	string line, preLine, origLines, preFuncLines
	string newLine, newProcCode, sTmp

	variable numFunc, numProcLines, numKeyWords, i, j, k, err, lineCnt, inDeclLines, fNum
	variable numLineStartZAfterKeys, numLineStartZReplaceKeys, doNextLine
	variable funcLines, reqNumChars, currFuncLineNum, currProcLineNum, maxFuncLine
	variable functionLineCnt, vTmp

	// Z after keys get checked first
	Make/FREE/T lineStartZAfterKeys = { \
	"case ", \
	"default :", \
	"default:", \
	"endswitch ;", \
	"endswitch;", \
	"endswitch", \
	"endif", \
	"else" \
	}
	Make/FREE/T lineStartZReplaceKeys = { \
	"if(", \
	"if (", \
	"elseif(", \
	"elseif (" \
	}

	newProcCode = ""
	numLineStartZAfterKeys = DimSize(lineStartZAfterKeys, UTF_ROW)
	numLineStartZReplaceKeys = DimSize(lineStartZReplaceKeys, UTF_ROW)

	allProcWins = UTF_Basics#GetProcedureList()
	if(WhichListItem(procWin, allProcWins) == -1)
		sprintf errMsg, "Procedure window %s not found.", procWin
		print errMsg
		return [$"", "", $""]
	endif

	funcList = FunctionList("*", ";", "KIND:18,WIN:" + procWin)
	if(UTF_Utils#IsEmpty(funcList))
		return [$"", "", $""]
	endif

	WAVE/T wFuncList = ListToTextWave(funcList, ";")
	numFunc = DimSize(wFuncList, UTF_ROW)
	WAVE funcLineStart = FindFunctionLocations(wFuncList, procWin)
	Make/FREE/WAVE/N=(numFunc) funcTexts
	funcTexts[] = ListToTextWave(ProcedureText(wFuncList[p], 0, procWin), "\r")
	Make/FREE/D/N=(numFunc) funcExclusionFlag
	for(i = 0; i < numFunc; i += 1)
		fullFuncName = UTF_Basics#getFullFunctionName(err, wFuncList[i], procWin)
		if(err)
			printf "Unable to retrieve full function name for %s in procedure %s.\r", wFuncList[i], procWin
			printf "Is procedure file %s missing a #pragma ModuleName=<name> ?!?.\r", procWin
			continue
		endif
		funcExclusionFlag[i] = UTF_Utils#HasFunctionTag(fullFuncName, UTF_FTAG_NOINSTRUMENTATION)
		if(UTF_Utils#isEmpty(funcPath))
			funcPath = FunctionPath(fullFuncName)
		endif
	endfor
	if(UTF_Utils#isEmpty(funcPath))
		printf "Unable to retrieve path of procedure file %s as no function could be resolved.\r", procWin
		Abort
	endif

	WAVE/T wProcText = ListToTextWave(ProcedureText("", NaN, procWin), "\r")
	numProcLines = DimSize(wProcText, UTF_ROW)

	// Mark function lines
	Make/FREE/N=(numProcLines) betweenLineHelper
	for(i = 0; i < numFunc; i += 1)
		WAVE/T wFuncText = funcTexts[i]
		betweenLineHelper[funcLineStart[i], funcLineStart[i] + DimSize(wFuncText, UTF_ROW) - 1] = 1
	endfor

	for(i = 0; i < numFunc; i += 1)
		WAVE/T wFuncText = funcTexts[i]

		// Add lines before function
		preFuncLines = ""
		j = funcLineStart[i] - 1
		if(j >= 0)
			do
				if(!betweenLineHelper[j])
					preFuncLines = wProcText[j] + "\r" + preFuncLines
				else
					break
				endif
				j -= 1
			while(j >= 0)
		endif
		newProcCode += preFuncLines

		preLine = ""
		origLines = ""
		lineCnt = 1
		inDeclLines = 0
		funcLines = DimSize(wFuncText, UTF_ROW)
		maxFuncLine = max(maxFuncLine, funcLines + funcLineStart[i])
		for(j = 0; j < funcLines; j += 1)
			if(UTF_Utils#IsEmpty(preLine))
				currFuncLineNum = j
			endif
			line = preLine + wFuncText[j]
			origLines += wFuncText[j] + "\r"
			line = TokenizeStrings(line)
			// line continuation
			if(char2num(line[strlen(line) - 1]) == 92)
				preLine = line[0, strlen(line) - 2]
				lineCnt += 1
				continue
			endif

			preLine = ""
			doNextLine = 0
			currProcLineNum = currFuncLineNum + funcLineStart[i]

			if(funcExclusionFlag[i])
				newProcCode += AddNoZ(origLines, lineCnt)
				continue
			endif

			line = CutLineComment(line)
			line = TrimString(line, 1)
			if(UTF_Utils#IsEmpty(line))
				sTmp = wFuncText[j]
				if(UTF_Utils#IsEmpty(sTmp))
					newProcCode += AddNoZ(origLines, lineCnt)
				else
					newProcCode += AddZ(origLines, currProcLineNum, lineCnt, procNum)
				endif
				continue
			endif
			line = LowerStr(line)

			// Start line parsing
			if((strsearch(line, "function/", 0) == 0) || (strsearch(line, "macro ", 0) == 0) || (strsearch(line, "function ", 0) == 0) || (strsearch(line, " function ", 0) >= 0) || (strsearch(line, " function/", 0) >= 0) || (strsearch(line, " macro ", 0) >= 0))
				WAVE/T decList = GetFunctionDeclarationList(line)
				inDeclLines = !!DimSize(decList, UTF_ROW)
				newProcCode += AddNoZ(origLines, lineCnt)
				functionLineCnt = lineCnt

				if(!inDeclLines)
					newProcCode += AddZForFunctionLine(funcLineStart[i], funcLineStart[i] + funcLines - 1, functionLineCnt, procNum)
				endif

				continue
			endif

			if(inDeclLines)
				inDeclLines = CheckDeclarationLine(line, decList)
				if(inDeclLines)
					newProcCode += AddNoZ(origLines, lineCnt)
					continue
				endif
				newProcCode += AddZForFunctionLine(funcLineStart[i], funcLineStart[i] + funcLines - 1, functionLineCnt, procNum)
			endif

			if(j == funcLines - 1)
				newProcCode += AddNoZ(origLines, lineCnt)
				continue
			endif

			for(k = 0; k < numLineStartZAfterKeys; k += 1)
				if(strsearch(line, lineStartZAfterKeys[k], 0) == 0)
					newProcCode += AddZ(origLines, currProcLineNum, lineCnt, procNum, addAfter=1)
					doNextLine = 1
					break
				endif
			endfor
			if(doNextLine)
				continue
			endif
			for(k = 0; k < numLineStartZReplaceKeys; k += 1)
				if(strsearch(line, lineStartZReplaceKeys[k], 0) == 0)
					newProcCode += ReplaceWithZ(origLines, currProcLineNum, lineCnt, procNum)
					doNextLine = 1
					break
				endif
			endfor
			if(doNextLine)
				continue
			endif

			newProcCode += AddZ(origLines, currProcLineNum, lineCnt, procNum)
		endfor
	endfor

	// Add lines after last function
	DeletePoints 0, maxFuncLine, wProcText
	newProcCode += UTF_Utils#TextWaveToList(wProcText, "\r")

	return [ListToTextWave(newProcCode, "\r"), funcPath, betweenLineHelper]
End

/// @brief Adds the Z_ function for function line
static Function/T AddZForFunctionLine(variable funcLineNum, variable endLineNum, variable &lineCnt, variable procNum)

	string funcCall1, funcCall2

	if(lineCnt > 1)
		sprintf funcCall1, "Z_(%d, %d, l=%d)\r", procNum, funcLineNum, lineCnt
	else
		sprintf funcCall1, "Z_(%d, %d)\r", procNum, funcLineNum
	endif
	sprintf funcCall2, "Z_(%d, %d)\r", procNum, endLineNum

	lineCnt = 1

	return funcCall1 + funcCall2
End

/// @brief Replaces the condition in a code line with e.g. "if(...)" with a Z_ function call
Function/T ReplaceWithZ(string &origLines, variable currLineNum, variable &lineCnt, variable procNum)

	string tmpLine, cond, cmd, newcode
	variable b1, b2

	tmpLine = CutLineComment(origLines)
	b1 = strsearch(tmpLine, "(", 0)
	b2 = strsearch(tmpLine, ")", Inf, 1)
	if(b1 == -1 || b2 == -1)
		printf "Failed to parse condition; %s\r", origLines
		Abort
	endif

	cmd = tmpLine[0, b1 - 1]
	cond = tmpLine[b1 + 1, b2 - 1]

	newCode = cmd + "(Z_(" + num2istr(procNum) + ", " + num2istr(currLineNum)
	if(lineCnt > 1)
		newCode += ", l=" + num2istr(lineCnt)
	endif
	newCode += ", c=(" + cond + ")))\r"

	origLines = ""
	lineCnt = 1

	return newCode
End

/// @brief Takes over a original code line
static Function/T AddNoZ(string &origLines, variable &lineCnt)

	string newCode = origLines

	origLines = ""
	lineCnt = 1

	return newCode
End

/// @brief Adds the Z_ function before or after a code line
static Function/T AddZ(string &origLines, variable currLineNum, variable &lineCnt, variable procNum[, variable addAfter])

	string funcCall, newCode

	addAfter = ParamIsDefault(addAfter) ? 0 : !!addAfter

	if(lineCnt > 1)
		sprintf funcCall, "Z_(%d, %d, l=%d)\r", procNum, currLineNum, lineCnt
	else
		sprintf funcCall, "Z_(%d, %d)\r", procNum, currLineNum
	endif

	if(addAfter)
		newCode = origLines + funcCall
	else
		newCode = funcCall + origLines
	endif

	origLines = ""
	lineCnt = 1

	return newCode
End

/// @brief Parses a line after Function was encountered for declaration names and returns 1 if it is related to the function variable declaration
static Function CheckDeclarationLine(string line, WAVE/T decList)

	string decPart, dec, type
	variable i, numVars, decOffset, numParams, foundType

	if(strsearch(line, "=", 0) >= 0)
		return 0
	endif

	Make/FREE/T validParameters = { \
	"variable", \
	"string", \
	"wave", \
	"dfref", \
	"funcref", \
	"struct", \
	"int", \
	"int64", \
	"uint64", \
	"double", \
	"complex" \
	}
	numParams = DimSize(validParameters, UTF_ROW)

	type = StringFromList(0, line, " ")

	for(i = 0; i < numParams; i += 1)
		if(strsearch(type, validParameters[i], 0) >= 0)
			foundType = 1
			break
		endif
	endfor
	if(!foundType)
		return 0
	endif

	decOffset = !CmpStr(type, "struct") || !CmpStr(type, "funcref") ? 2 : 1

	decPart = StringFromList(decOffset, line, " ")
	numVars = ItemsInList(decPart, ",")
	for(i = 0; i < numVars; i += 1)
		dec = TrimString(StringFromList(i, decPart, ","))
		if(strsearch(dec, "&", 0) == 0)
			dec = dec[1, Inf]
		endif

		FindValue/TEXT=dec/TXOP=4 decList
		if(V_Value >= 0)
			return 1
		endif
	endfor

	return 0
End

/// @brief Cuts a comment off a code line
static Function/S CutLineComment(string s)

	variable pos

	pos = strsearch(s, "//", 0)
	if(pos >= 0)
		return s[0, pos - 1]
	endif

	return s
End

/// @brief Replaces all strings in a code line with a token. This helps easier later parsing.
static Function/S TokenizeStrings(string s)

	variable posBegin, posEnd, charBefore, searchStart
	string s2
	string stringToken = "s"

	do
		posBegin = strsearch(s, "\"", 0)
		if(posBegin >= 0)
			searchStart = posBegin + 1
				do
				posEnd = strsearch(s, "\"", searchStart)
				if(posEnd >= 0)
					charBefore = char2num(s[posEnd - 1, Inf])
					if(charBefore == 92)
						searchStart = posEnd + 1
						continue
					else
						s2 = s[0, posBegin - 1] + stringToken + s[posEnd + 1, Inf]
						s = s2
						break
					endif
				else
					return s
				endif
				while(1)
		endif
	while(posBegin >= 0)

	return s
End

/// @brief Determine first line ending found in given string
///        If a default defEndL is given then it is returned if line ending could not be determined from line
static Function/S GetLineEnding(string line[, string defEndL])

	string endL = ""
	variable len, i, c, e

	if(UTF_Utils#IsEmpty(line))
		if(!ParamIsDefault(defEndL))
			return defEndl
		endif
		printf "Can not determine line ending.\r"
		Abort
	endif

	len = strlen(line)
	for(i = 0; i < len && e < 2; i += 1)
		c = char2num(line[i])
		if(c == 0x0D || c == 0x0A)
			endL[Inf] = line[i]
			e += 1
		else
			if(e)
				break
			endif
		endif
	endfor

	if(UTF_Utils#IsEmpty(line))
		if(!ParamIsDefault(defEndL))
			return defEndl
		endif
		printf "Can not determine line ending.\r"
		Abort
	endif

	return endL
End

static Function AnalyzeTracingResult()

	variable numThreads, numProcs, i, j, err, fNum, numProcLines
	variable execC, branchC, nobranchC
	string funcList, fullFuncName, procWin, funcPath, procText, prefix, line, fName, wName, procLine, NBSpace, tabReplace
	string procLineFormat
	variable colR, colG, colB

	printf "Generating coverage output."

	TUFXOP_GetStorage/N="IUTF_Testrun" wv
	if(V_flag)
		printf "No gathered tracing data found for code coverage analysis.\r"
		Abort
	endif
	WAVE/WAVE wrefMain = wv
	numThreads = NumberByKey("Index", note(wrefMain))

	WAVE/T procNames = GetTracedProcedureNames()
	numProcs = DimSize(procNames, UTF_ROW)
	Make/FREE/D/N=(UTF_MAX_PROC_LINES, 3, numProcs) logData

	for(i = 0; i < numThreads; i += 1)
		WAVE/WAVE wrefThread = wrefMain[i]
		WAVE logdataThread = wrefThread[0]
		MultiThread logdata += logdataThread[p][q][r]
	endfor

	LoadWave/P=home/J/K=1/O/Q/M/N=iutf_instrumented_data INSTRUDATA_FILENAME
	if(V_flag != 1)
		printf "Error when loading instrumentation data.\r"
		Abort
	endif
	wName = StringFromList(0, S_waveNames)
	WAVE instrData = $wName
	if(DimSize(instrData, UTF_ROW) != UTF_MAX_PROC_LINES || DimSize(instrData, UTF_COLUMN) != numProcs)
		printf "Loaded instrumentation data has incompatible format for current gathered data.\r"
		Abort
	endif

	tabReplace = ""
	NBSpace = num2char(0x00A0)
	for(i = 0; i < TABSIZE; i += 1)
		tabReplace += NBSpace
	endfor

	for(i = 0; i < numProcs; i += 1)
		printf "."
		procWin = procNames[i]
		funcList = FunctionList("*", ";", "KIND:18,WIN:" + procWin)
		if(UTF_Utils#IsEmpty(funcList))
			continue
		endif
		fullFuncName = UTF_Basics#getFullFunctionName(err, StringFromList(0, funcList), procWin)
		if(err)
			printf "Unable to retrieve full function name.\r"
			Abort
		endif
		funcPath = FunctionPath(fullFuncName) + PROC_BACKUP_ENDING

		procText = ""
		Open/R/Z fNum as funcPath
		if(V_flag)
			printf "Open failed for file %s.", funcPath
			Abort
		endif

		do
			FReadLine fNum, line
			if(!strlen(line))
				break
			endif
			line = RemoveEnding(line, "\r\n")
			line = RemoveEnding(line, "\n\r")
			line = RemoveEnding(line, "\r")
			line = RemoveEnding(line, "\n")

			procText += line + "\r"
		while(1)
		Close fNum

		WAVE/T wProcText = ListToTextWave(procText, "\r")
		numProcLines = DimSize(wProcText, UTF_ROW)

		KillWindow/Z NBTracedData
		NewNotebook/F=1/N=NBTracedData as procWin
		DoWindow/HIDE=1 NBTracedData
		Notebook NBTracedData, ruler=Normal, margins={0,0,10000}, fStyle=1, font="Courier New"

		sprintf procLineFormat, "%%0%dd", strlen(num2istr(numProcLines))

		for(j = 0; j < numProcLines; j += 1)

			procLine = ReplaceString("\t", wProcText[j], tabReplace)

			execC = logData[j][0][i]
			nobranchC = logData[j][1][i]
			branchC = logData[j][2][i]
			if(!(execC + nobranchC + branchC))
				sprintf prefix, procLineFormat + "|________|________|________|", j
				prefix += procLine + "\r"
				Notebook NBTracedData selection={endOfFile, endOfFile}, text=prefix
				if(!instrData[j][i])
					colR = 0xc0
					colG = 0xc0
					colB = 0xc0
				else
					colR = 0x40
					colG = 0x40
					colB = 0x40
				endif
				Notebook NBTracedData selection={startOfPrevParagraph, endOfPrevParagraph}, textRGB=(colR * 0xff, colG * 0xff, colB * 0xff)
				continue
			endif

			if(!(noBranchC + branchC))
				sprintf prefix, procLineFormat + "|%.8#d|________|________|", j, execC
			else
				sprintf prefix, procLineFormat + "|%.8#d|%.8#d|%.8#d|", j, execC, branchC, nobranchC
			endif
			prefix +=  procLine + "\r"
			Notebook NBTracedData selection={endOfFile, endOfFile}, text=prefix
			Notebook NBTracedData selection={startOfPrevParagraph, endOfPrevParagraph}, textRGB=(0 * 0xff, 32  * 0xff, 128  * 0xff)
		endfor
		fName = procWin[0, strlen(procWin) - 5] + ".htm"
		SaveNotebook/O/P=home/S=5/H={"UTF-8", 0xFFFF, 0xFFFF, 0, 0, 32} NBTracedData as fName
	endfor
	printf "Done.\r"
End

#endif
