#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_TestTracing

// Licensed under 3-Clause BSD, see License.txt

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
static Function/S TracingTestLoadFile(string fName)
	variable fNum
	string data

	Open/R/Z fNum as fName
	REQUIRE(!V_flag)
	FStatus fNum
	data = PadString("", V_logEOF, 0x20)
	FBinRead fNum, data
	Close fNum

	return data
End

static Function TracingTest()

	string funcPath, procFileName, basePath
	string proc1Text, proc2Text
	variable fNum

	SaveExperiment/P=home as "TestTracing.pxp"

	funcPath = FunctionPath(GetIndependentModuleName() + "#TracingTest")
	basePath = ParseFilePath(1, funcPath, ":", 1, 0)
	proc1Text = TracingTestLoadFile(basePath + "test-tracing.ipf")
	proc2Text = TracingTestLoadFile(basePath + "test-tracing_instrumented.ipf")

	CHECK_EQUAL_STR(proc1Text, proc2Text)
End

static Function TracingTest2()

	variable numThreads, numProcs, i, numRefLines
	variable max_proc_lines = 10000

	TestTracing2#TracingTest()

	TUFXOP_GetStorage/N="IUTF_Testrun" wrefMain
	numThreads = NumberByKey("Index", note(wrefMain))

	WAVE/T procNames = GetTracedProcedureNames()
	numProcs = DimSize(procNames, UTF_ROW)
	CHECK_EQUAL_TEXTWAVES(procNames, {"test-tracing2.ipf"})

	Make/FREE/D/N=(max_proc_lines, 3, numProcs) logData

	for(i = 0; i < numThreads; i += 1)
		WAVE/WAVE wrefThread = wrefMain[i]
		WAVE logdataThread = wrefThread[0]
		logdata += logdataThread[p][q][r]
	endfor

	Make/FREE/D/N=(max_proc_lines) logSimple, logRef
	logSimple = logData[p][0][0] != 0

	Make/FREE/D logRefGen = {11, 13, 15, 16, 18, 51, 20, 21, 23, 25, 27, 28, 30, 32, 33, 34, 36 ,37, 38, 39, 41, 44, 45, 46, 48, 49, 50}
	numRefLines = DimSize(logRefGen, UTF_ROW)
	for(i = 0; i < numrefLines; i += 1)
		logRef[logRefGen[i]] = 1
	endfor

	CHECK_EQUAL_WAVES(logSimple, logRef)
End
#endif
