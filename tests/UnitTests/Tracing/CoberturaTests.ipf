#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Tracing_Cobertura

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)

static Function Test_FilePathToXml()
	string result, expect

	expect = "abc/def/ghi"
	result = IUTF_Tracing_Cobertura#FilePathToXml("abc\\def\\ghi")
	CHECK_EQUAL_STR(expect, result)
End

static Function Test_GetClassName()
	string result, expect

	expect = "abc.def.ghi.jkl"
	result = IUTF_Tracing_Cobertura#GetClassName("abc\\def\\ghi\\jkl.txt")
	CHECK_EQUAL_STR(expect, result)

	expect = "abc"
	result = IUTF_Tracing_Cobertura#GetClassName("abc.txt")
	CHECK_EQUAL_STR(expect, result)

	expect = "abc.def.ghi.jkl"
	result = IUTF_Tracing_Cobertura#GetClassName("abc\\def\\ghi\\jkl")
	CHECK_EQUAL_STR(expect, result)

	expect = ""
	result = IUTF_Tracing_Cobertura#GetClassName("")
	CHECK_EQUAL_STR(expect, result)
End

static Function CheckProcInfo(string infoStr, STRUCT IUTF_Cobertura_ProcInfo &procInfo, string sourcePath, string packageName, string classFileName, string className)
	string value

	value = procInfo.sourcePath
	INFO(infoStr)
	INFO("Source Path")
	CHECK_EQUAL_STR(sourcePath, value)

	value = procInfo.packageName
	INFO(infoStr)
	INFO("Package Name")
	CHECK_EQUAL_STR(packageName, value)

	value = procInfo.classFileName
	INFO(infoStr)
	INFO("Class File Name")
	CHECK_EQUAL_STR(classFileName, value)

	value = procInfo.className
	INFO(infoStr)
	INFO("Class Name")
	CHECK_EQUAL_STR(className, value)
End

static Function Test_GetProcInfo()
	string                         infoStr
	STRUCT IUTF_Cobertura_ProcInfo procInfo

	infoStr = "path is directly inside first path"
	Make/FREE=1/T sources = {"foo\\bar\\"}
	[procInfo] = IUTF_Tracing_Cobertura#GetProcInfo("foo\\bar\\baz.txt", sources)
	CheckProcInfo(infoStr, procInfo, "foo\\bar", "", "baz.txt", "baz")

	infoStr = "path is directly inside second path"
	Make/FREE=1/T sources = {"abc\\", "foo\\bar\\"}
	[procInfo] = IUTF_Tracing_Cobertura#GetProcInfo("foo\\bar\\baz.txt", sources)
	CheckProcInfo(infoStr, procInfo, "foo\\bar", "", "baz.txt", "baz")

	infoStr = "path is somewhere in a subdirectory of a path"
	Make/FREE=1/T sources = {"abc\\", "foo\\bar\\"}
	[procInfo] = IUTF_Tracing_Cobertura#GetProcInfo("foo\\bar\\abc\\def\\baz.txt", sources)
	CheckProcInfo(infoStr, procInfo, "foo\\bar", "abc\\def", "abc\\def\\baz.txt", "abc.def.baz")

	infoStr = "path is not included in sources"
	Make/FREE=1/T sources = {"abc\\"}
	[procInfo] = IUTF_Tracing_Cobertura#GetProcInfo("foo\\bar\\baz.txt", sources)
	CheckProcInfo(infoStr, procInfo, "foo\\bar", "", "baz.txt", "baz")
End

static Function Test_GetLinesReport_NoBranch()
	STRUCT IUTF_Cobertura_Metrics metrics
	string                        result

	string   indent    = ""
	variable lineStart = 0
	variable lineEnd   = 2
	variable procIndex = 1
	string   expected  = "<lines>\n"                                            + \
	                     "\t<line number=\"1\" hits=\"1\" branch=\"false\"/>\n" + \
	                     "\t<line number=\"2\" hits=\"2\" branch=\"false\"/>\n" + \
	                     "</lines>\n"

	Make/FREE=1/N=(3, 3, 2) totals
	totals[][0][procIndex] = p + 1

	WAVE marker = IUTF_Tracing#GetNewMarkerWave(3)
	marker[][%INSTR] = 1

	[result, metrics] = IUTF_Tracing_Cobertura#GetLinesReport(indent, lineStart, lineEnd, procIndex, totals, marker)

	INFO("xml output")
	CHECK_EQUAL_STR(expected, result)

	CHECK_EQUAL_VAR(1, metrics.lineRate)
	CHECK_EQUAL_VAR(2, metrics.lineCovered)
	CHECK_EQUAL_VAR(2, metrics.lineValid)
	CHECK_EQUAL_VAR(1, metrics.branchRate)
	CHECK_EQUAL_VAR(0, metrics.branchCovered)
	CHECK_EQUAL_VAR(0, metrics.branchValid)
End

static Function Test_GetLinesReport_SingleBranch()
	STRUCT IUTF_Cobertura_Metrics metrics
	string                        result

	string   indent    = ""
	variable lineStart = 0
	variable lineEnd   = 4
	variable procIndex = 1
	string   expected  = "<lines>\n"                                                                           + \
	                     "\t<line number=\"1\" hits=\"1\" branch=\"false\"/>\n"                                + \
	                     "\t<line number=\"2\" hits=\"1\" branch=\"true\" condition-coverage=\"50% (1/2)\">\n" + \
	                     "\t\t<conditions>\n"                                                                  + \
	                     "\t\t\t<condition number=\"0\" type=\"jump\" coverage=\"50%\"/>\n"                    + \
	                     "\t\t</conditions>\n"                                                                 + \
	                     "\t</line>\n"                                                                         + \
	                     "\t<line number=\"3\" hits=\"0\" branch=\"false\"/>\n"                                + \
	                     "\t<line number=\"4\" hits=\"1\" branch=\"false\"/>\n"                                + \
	                     "</lines>\n"

	Make/FREE=1/N=(5, 3, 2) totals
	totals[][0][procIndex]  = 1
	totals[2][0][procIndex] = 0
	totals[1][1][procIndex] = 1

	WAVE marker = IUTF_Tracing#GetNewMarkerWave(5)
	marker[][%INSTR] = 1

	[result, metrics] = IUTF_Tracing_Cobertura#GetLinesReport(indent, lineStart, lineEnd, procIndex, totals, marker)

	INFO("xml output")
	CHECK_EQUAL_STR(expected, result)

	CHECK_EQUAL_VAR(0.75, metrics.lineRate)
	CHECK_EQUAL_VAR(3, metrics.lineCovered)
	CHECK_EQUAL_VAR(4, metrics.lineValid)
	CHECK_EQUAL_VAR(0.5, metrics.branchRate)
	CHECK_EQUAL_VAR(1, metrics.branchCovered)
	CHECK_EQUAL_VAR(2, metrics.branchValid)
End

static Function Test_GetLinesReport_Empty()
	STRUCT IUTF_Cobertura_Metrics metrics
	string                        result

	string   indent    = ""
	variable lineStart = 0
	variable lineEnd   = 2
	variable procIndex = 1
	string   expected  = "<lines>\n" + \
	                     "</lines>\n"

	Make/FREE=1/N=(3, 3, 2) totals
	totals[][0][procIndex] = p + 1

	WAVE marker = IUTF_Tracing#GetNewMarkerWave(3)
	marker[][%INSTR] = 0

	[result, metrics] = IUTF_Tracing_Cobertura#GetLinesReport(indent, lineStart, lineEnd, procIndex, totals, marker)

	INFO("xml output")
	CHECK_EQUAL_STR(expected, result)

	CHECK_EQUAL_VAR(1, metrics.lineRate)
	CHECK_EQUAL_VAR(0, metrics.lineCovered)
	CHECK_EQUAL_VAR(0, metrics.lineValid)
	CHECK_EQUAL_VAR(1, metrics.branchRate)
	CHECK_EQUAL_VAR(0, metrics.branchCovered)
	CHECK_EQUAL_VAR(0, metrics.branchValid)
End

#endif
