#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=UTF_TestTracing

#undef UTF_ALLOW_TRACING
#if Exists("TUFXOP_Version")

#if IgorVersion() >= 10.00
#define UTF_ALLOW_TRACING
#elif (IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
#define UTF_ALLOW_TRACING
#endif

#endif

#ifdef UTF_ALLOW_TRACING

static Function/S TracingTestLoadFile(string fName)
	variable fNum
	string   data

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

	funcPath  = FunctionPath(GetIndependentModuleName() + "#TracingTest")
	basePath  = ParseFilePath(1, funcPath, ":", 1, 0)
	proc1Text = TracingTestLoadFile(basePath + "test-tracing.ipf")
	proc2Text = TracingTestLoadFile(basePath + "test-tracing_instrumented.ipf")

	CHECK_EQUAL_STR(proc1Text, proc2Text)
End

static Function TracingTest2()

	variable numThreads, numProcs, i
	variable max_proc_lines = 10000

	TestTracing2#TracingTest()

	TUFXOP_GetStorage/N="IUTF_Testrun" wrefMain
	numThreads = NumberByKey("Index", note(wrefMain))

	WAVE/T procNames = IUTF_Tracing#GetTracedProcedureNames()
	numProcs = DimSize(procNames, UTF_ROW)
	CHECK_EQUAL_TEXTWAVES(procNames, {"test-tracing2.ipf"})

	Make/FREE=1/D/N=(max_proc_lines, 3, numProcs) logData

	for(i = 0; i < numThreads; i += 1)
		WAVE/WAVE wrefThread    = wrefMain[i]
		WAVE      logdataThread = wrefThread[0]
		logdata += logdataThread[p][q][r]
	endfor

	Make/FREE=1/N=(max_proc_lines) logSimple
	logSimple = logData[p][0][0] != 0

	WAVE logRef = MarkerFromLines(max_proc_lines,                                                  \
	                              {25, 27, 29, 30, 32, 34, 35, 37, 39, 41, 42, 44, 46, 47, 48, 50, \
	                               51, 52, 53, 55, 58, 59, 60, 65})

	CHECK_EQUAL_WAVES(logSimple, logRef)

	WAVE/WAVE instrMarker = IUTF_Tracing#GetInstrumentedMarker()
	WAVE      marker      = instrMarker[0]

	// verify instrumentation marker
	Make/FREE=1/N=(DimSize(marker, UTF_ROW)) markerValues = marker[p][%INSTR]

	WAVE/Z markerRef = MarkerFromLines(DimSize(marker, UTF_ROW),                                \
	                                   {25, 27, 29, 30, 32, 34, 35, 37, 38, 39, 41, 42, 43, 44, \
	                                    46, 47, 48, 50, 51, 52, 53, 55, 56, 57, 58, 59, 60, 65})
	CHECK_EQUAL_WAVES(markerValues, markerRef)

	// verify complexity marker
	Make/FREE=1/N=(DimSize(marker, UTF_ROW)) markerValues = marker[p][%COMPLEX]

	WAVE/Z markerRef = MarkerFromLines(DimSize(marker, UTF_ROW), {25, 32, 37, 41, 42, 46, 51, 56})
	CHECK_EQUAL_WAVES(markerValues, markerRef)
End

static Function/WAVE MarkerFromLines(variable numLines, WAVE/Z lines)

	variable i
	variable size = DimSize(lines, UTF_ROW)
	Make/FREE/N=(numLines) marker

	for(i = 0; i < size; i++)
		marker[lines] = 1
	endfor

	return marker
End
#endif // UTF_ALLOW_TRACING
