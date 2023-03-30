#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.10
#pragma ModuleName = IUTF_Tracing_Cobertura

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)

// file size limit to show a warning banner. Some Cobertura consumers like Gitlab have a hardcoded
// limit after which no cobertura files can no longer be read. The limit for Gitlab is at 10 MB but
// this will show the warning a bit early to leave the user some room to take some preparation.
static Constant FILESIZE_WARNING_LIMIT = 8000000

// Empty function signature without any arguments.
static StrConstant EMPTY_FUNC_SIGNATURE = "()"

/// @brief The Cobertura information for one procedure file. This is needed to generate a valid
/// Cobertura file.
///
/// sourcePath: The source path where the procedure file can be found. The source path can be any
///     directory, the procedure file just have to be in any sub-directory in it. This is usually
///     one of theuser defined values.
/// packageName: A package name is a part of the directory path from the source path to the
///     procedure file. The package name doesn't contain the name of the procedure file itself. If
///     the procedure file is located directly in the source path the package name is an empty
///     string.
/// classFileName: The class file name is the relative path from the source path to the procedure
///     file.
/// className: The class name is like the class file name. The file extension is removed and all
///     directory delimiters are replaced with dots.
Structure IUTF_Cobertura_ProcInfo
	string sourcePath
	string packageName
	string classFileName
	string className
EndStructure

/// @brief Contains the coverage metrics about a section of the code (this could be a function/macro
/// or the whole file).
///
/// lineRate: The result of lineCovered/lineValid. If lineValid is 0 lineRate is set to 1.
/// lineCovered: The number of valid lines that has at least one hit.
/// lineValid: The number of lines that are marked as instrumented and therefore user code.
/// branchRate: The result of branchCovered/branchValid. If branchValid is 0 branchRate is set to 1.
/// branchCovered: The number of valid branches that has at least one hit.
/// branchValid: The number of branches that could be instrumented. A branch is a point where the
///     user code branches and can execute different parts depending on a condition (like an
///     if-statement).
Structure IUTF_Cobertura_Metrics
	variable lineRate
	variable lineCovered
	variable lineValid
	variable branchRate
	variable branchCovered
	variable branchValid
EndStructure

// Convert a file path suitable for Cobertura XML. This will replace all back-slash with a
// forward-slash.
// This is similar to ParseFilePath(5, path, "/", 0, 0) which isn't supported in Igor 9.
static Function/S FilePathToXml(string path)
	path = ReplaceString("\\", path, "/")
	path = IUTF_Utils_Xml#ToXmlToken(path)

	return path
End

// Returns the Cobertura class name of a relative file name. This will trim the file extension and
// replace directory delimiter with a dots.
static Function/S GetClassName(string fileName)
	string className

	string dir = ParseFilePath(1, fileName, "\\", 1, 0)
	string rawName = ParseFilePath(3, fileName, "\\", 0, 0)
	sprintf className, "%s%s", ReplaceString("\\", dir, "."), rawName

	return className
End

/// @brief Fill info with the required path information of a procedure file for the cobertura output
///
/// @param procPath   The full path of the procedure file
/// @param sources    A wave with valid source paths. It will use the first entry which contains
///                   procPath. If no source contains procPath the parent directory of procPath will
///                   be used as source.
///
/// @retval info      The information that can be used for the Cobertura output.
static Function [STRUCT IUTF_Cobertura_ProcInfo info] GetProcInfo(string procPath, WAVE/T sources)
	variable i, length

	string dirPath = IUTF_Utils_Paths#GetDirPathOfFile(procPath)
	variable size = DimSize(sources, UTF_ROW)

	procPath = ParseFilePath(5, procPath, "\\", 0, 0)

	for(i = 0; i < size; i += 1)
		if(!IUTF_Utils_Strings#IsPrefix(dirPath, sources[i]))
			continue
		endif

		info.sourcePath = RemoveEnding(sources[i], "\\")
		info.packageName = RemoveEnding(dirPath[strlen(sources[i]), Inf], "\\")
		info.classFileName = procPath[strlen(sources[i]), Inf]
		info.className = GetClassName(info.classFileName)

		return
	endfor

	info.sourcePath = RemoveEnding(dirPath, "\\")
	info.packageName = ""
	info.classFileName = procPath[strlen(dirPath), Inf]
	info.className = GetClassName(info.classFileName)
End

/// @brief Creates the lines report for the Cobertura output. At the same time it will generate some
/// metrics which can be used at other places in the Cobertura output.
///
/// @param indent     The indent string that is prefixed for each output line.
/// @param lineStart  the inclusive line index where the report should start
/// @param lineEnd    the exclusive line index where the report should end
/// @param procIndex  The index of the procedure file
/// @param totals     The totals wave with the data from the instrumentation run
/// @param marker     The wave with can tell which line in the source file was instrumented
///
/// @retval report    The report XML
/// @retval metrics   The collected metrics for the specified lines section and procedure file
static Function [string report, STRUCT IUTF_Cobertura_Metrics metrics] GetLinesReport(string indent, variable lineStart, variable lineEnd, variable procIndex, WAVE totals, WAVE marker)
	string line, coverage
	variable i, execC, nobranchC, branchC, sum

	variable totalLines, coveredLines, totalBranches, coveredBranches

	report = indent + "<lines>\n"

	for(i = lineStart; i < lineEnd; i += 1)
		if(!marker[i][%INSTR])
			continue
		endif

		execC = totals[i][0][procIndex]
		nobranchC = totals[i][1][procIndex]
		branchC = totals[i][2][procIndex]

		totalLines += 1
		coveredLines += execC > 0

		if(noBranchC + branchC)
			sum = (nobranchC > 0) + (branchC > 0)
			sprintf coverage, "%g%% (%d/2)", sum * 50, sum
			totalBranches += 2
			coveredBranches += sum

			sprintf line, "%s\t<line number=\"%d\" hits=\"%d\" branch=\"true\" condition-coverage=\"%s\">\n", indent, i + 1, execC, coverage
			report += line
			report += indent + "\t\t<conditions>\n"

			sprintf line, "%s\t\t\t<condition number=\"0\" type=\"jump\" coverage=\"%g%%\"/>\n", indent, sum * 50
			report += line

			report += indent + "\t\t</conditions>\n"
			report += indent + "\t</line>\n"
		else
			sprintf line, "%s\t<line number=\"%d\" hits=\"%d\" branch=\"false\"/>\n", indent, i + 1, execC
			report += line
		endif
	endfor

	report += indent + "</lines>\n"

	metrics.lineCovered = coveredLines
	metrics.lineValid = totalLines
	metrics.lineRate = totalLines == 0 ? 1 : coveredLines / totalLines
	metrics.branchCovered = coveredBranches
	metrics.branchValid = totalBranches
	metrics.branchRate = totalBranches == 0 ? 1 : coveredBranches / totalBranches
End

/// @brief Creates a report of a specific function inside a procedure file.
///
/// @param funcName   The name of the function
/// @param funcStart  The inclusive line index where the function starts
/// @param funcEnd    The exclusive line index where the function ends
/// @param procName   The name of the procedure file
/// @param procIndex  The index of the procedure file
/// @param totals     The totals wave with the data from the instrumentation run
/// @param marker     The wave with can tell which line in the source file was instrumented
///
/// @returns The report XML
static Function/S GetFunctionReport(string funcName, variable funcStart, variable funcEnd, string procName, variable procIndex, WAVE totals, WAVE marker)
	string report, linesReport, line, fullFuncName, msg
	STRUCT IUTF_Cobertura_Metrics metrics
	variable err, complexity, complexIndex

	complexIndex = FindDimLabel(marker, UTF_COLUMN, "COMPLEX")
	WaveStats/M=0/Q/Z/RMD=[funcStart, funcEnd - 1][complexIndex, complexIndex] marker
	complexity = V_sum

	[linesReport, metrics] = GetLinesReport("\t\t\t\t\t\t\t", funcStart, funcEnd, procIndex, totals, marker)

	fullFuncName = IUTF_Basics#getFullFunctionName(err, funcName, procName)
	if(err)
		// possibly a macro which has no full function name
		fullFuncName = funcName
	endif

	sprintf line, "\t\t\t\t\t\t<method name=\"%s\" signature=\"%s\" line-rate=\"%f\" branch-rate=\"%f\" complexity=\"%d\">\n", IUTF_Utils_Xml#ToXmlToken(fullFuncName), EMPTY_FUNC_SIGNATURE, metrics.lineRate, metrics.branchRate, complexity
	report = line

	report += linesReport

	report += "\t\t\t\t\t\t</method>\n"
	return report
End

/// @brief Creates a report of a procedure file
///
/// @brief procName   The name of the procedure file
/// @brief procPath   The path to the procedure file
/// @brief procIndex  The index of the procedure file
/// @param totals     The totals wave with the data from the instrumentation run
/// @param marker     The wave with can tell which line in the source file was instrumented
/// @param sources    The source wave which contains all valid source paths
///
/// @returns The report XML
static Function/S GetProcedureReport(string procName, string procPath, variable procIndex, WAVE totals, WAVE marker, WAVE/T sources)
	string msg, report, line
	variable i, funcCount, funcEnd, epochTime, complexity, complexIndex
	STRUCT IUTF_Cobertura_ProcInfo info
	STRUCT IUTF_Cobertura_Metrics metrics
	string linesReport

	[info] = GetProcInfo(procPath, sources)
	WAVE/WAVE funcLocations = IUTF_Tracing#GetFuncLocations()
	WAVE/T procFuncNames = funcLocations[procIndex][%FUNCLIST]
	WAVE procFuncLines = funcLocations[procIndex][%FUNCSTART]
	funcCount = DimSize(procFuncNames, UTF_ROW)

	complexIndex = FindDimLabel(marker, UTF_COLUMN, "COMPLEX")
	WaveStats/M=0/Q/Z/RMD=[][complexIndex, complexIndex] marker
	complexity = V_sum

	[linesReport, metrics] = GetLinesReport("\t\t\t\t\t", 0, DimSize(marker, UTF_ROW), procIndex, totals, marker)

	// DateTime since unix epoch and in UTC. This is the short version of:
	// (<current datetime> - <utc offset>) - (<epoch datetime> - <utc offset>)
	epochTime = DateTime - Date2Secs(1970, 1, 1)

	report = "<?xml version=\"1.0\"?>\n"
	report += "<!DOCTYPE coverage SYSTEM \"https://cobertura.sourceforge.net/xml/coverage-04.dtd\">\n"
	report += "<!--Cobertura coverage report generated by the Igor Pro package \"igortest\"-->\n"
	sprintf line, "<coverage line-rate=\"%f\" branch-rate=\"%f\" lines-covered=\"%d\" lines-valid=\"%d\" branches-covered=\"%d\" branches-valid=\"%d\" complexity=\"%d\" version=\"0.0\" timestamp=\"%d000\">\n", \
		metrics.lineRate, metrics.branchRate, metrics.lineCovered, metrics.lineValid, metrics.branchCovered, metrics.branchValid, complexity, epochTime
	report += line

	report += "\t<sources>\n"
	sprintf line, "\t\t<source>%s</source>\n", FilePathToXml(info.sourcePath)
	report += line
	report += "\t</sources>\n"

	report += "\t<packages>\n"
	sprintf line, "\t\t<package name=\"%s\" line-rate=\"%f\" branch-rate=\"%f\" complexity=\"%d\">\n", FilePathToXml(info.packageName), metrics.lineRate, metrics.branchRate, complexity
	report += line

	report += "\t\t\t<classes>\n"
	sprintf line, "\t\t\t\t<class name=\"%s\" filename=\"%s\" line-rate=\"%f\" branch-rate=\"%f\" complexity=\"%d\">\n", IUTF_Utils_Xml#ToXmlToken(info.className), FilePathToXml(info.classFileName), metrics.lineRate, metrics.branchRate, complexity
	report += line

	report += "\t\t\t\t\t<methods>\n"
	for(i = 0; i < funcCount; i += 1)
		if(i < funcCount - 1)
			funcEnd = procFuncLines[i + 1]
		else
			funcEnd = DimSize(marker, UTF_ROW)
		endif
		report += GetFunctionReport(procFuncNames[i], procFuncLines[i], funcEnd, procName, procIndex, totals, marker)
	endfor
	report += "\t\t\t\t\t</methods>\n"

	report += linesReport

	report += "\t\t\t\t</class>\n"
	report += "\t\t\t</classes>\n"

	report += "\t\t</package>\n"
	report += "\t</packages>\n"

	report += "</coverage>\n"
	return report
End

/// @brief Generate the cobertura report for each instrumented procedure file and write each report
/// to the home directory of the experiment.
///
/// @param sources A comma delimited list of source paths that should be used for the cobertura
///                generation. If this string is empty it will use the current home directory as
///                source path.
/// @param outDir  The output path for the generated files. If this string is empty it will use the
///                current home directory.
static Function PrintReport(string sources, string outDir)
	variable i, procCount, nameIndex, pathIndex
	string name, path, report, msg

	WAVE/T procs = IUTF_Tracing#GetTracedProcedureInfos()
	procCount = IUTF_Utils_Vector#GetLength(procs)
	nameIndex = FindDimLabel(procs, UTF_COLUMN, "NAME")
	pathIndex = FindDimLabel(procs, UTF_COLUMN, "PATH")

	if(!IUTF_Tracing_Analytics#HasTracingData())
		IUTF_Reporting#ReportErrorAndAbort("Bug: No tracing data exists")
		return NaN
	endif

	WAVE totals = IUTF_Tracing_Analytics#GetTotals()
	if(!DimSize(totals, UTF_ROW))
		// this can happen after stored Experiment is loaded to a fresh instance of Igor
		IUTF_Reporting#ReportErrorAndAbort("Bug: TUFXOP has no data. Try to rerun tracing to get new data.")
		return NaN
	endif

	Wave/WAVE instrMarker = IUTF_Tracing#GetInstrumentedMarker()

	if(IUTF_Utils#IsEmpty(sources))
		Make/T/N=1/FREE=1 wvSources
		wvSources[0] = IUTF_Utils_Paths#GetHomePath()
	else
		WAVE/T wvSources = ListToTextWave(sources, ",")
	endif
	wvSources[] = ParseFilePath(2, ParseFilePath(5, wvSources[p], "\\", 0, 0), "\\", 0, 0)

	printf "Generate Cobertura reports"

	for(i = 0; i < procCount; i += 1)
		name = procs[i][nameIndex]
		path = procs[i][pathIndex]
		WAVE/Z marker = instrMarker[i]

		if(IUTF_Utils#IsEmpty(path) || !WaveExists(marker))
			continue
		endif

		printf "."

		report = GetProcedureReport(name, path, i, totals, marker, wvSources)

		if(strlen(report) >= FILESIZE_WARNING_LIMIT)
			sprintf msg, "WARNING! The report size of \"%s\" (%.2W1PB) exceed suggested maximum file size of %.2W1PB.", name, strlen(report), FILESIZE_WARNING_LIMIT
			IUTF_Reporting#IUTF_PrintStatusMessage(msg)
			sprintf msg, "WARNING! Some Cobertura consumer like Gitlab could have issues reading such large files."
			IUTF_Reporting#IUTF_PrintStatusMessage(msg)
			sprintf msg, "WARNING! Try to split your procedure file into multiple smaller ones."
			IUTF_Reporting#IUTF_PrintStatusMessage(msg)
		endif

		IUTF_Utils_XML#WriteXML("Cobertura_", report, outDir = outDir)
	endfor

	printf "\n"
	IUTF_Reporting#IUTF_PrintStatusMessage("Cobertura export finished.")
End

#endif
