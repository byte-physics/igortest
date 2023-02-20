#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = TEST_Main

#include "igortest"
#include "Tracing-CoberturaTests"
#include "Utils-PathsTests"
#include "Utils-StringsTests"

Function run()
	variable debugMode = 0
	string procedures = ".*-.*Tests\\.ipf"
	string traceProcedures = "(?:" + procedures + "|igortest-(?(?=tracing\\.ipf)|.*))"
	variable waveTracking = UTF_WAVE_TRACKING_ALL

	string tracingOp = ""
	tracingOp = ReplaceNumberByKey(UTF_KEY_HTMLCREATION, tracingOp, 0)
	tracingOp = ReplaceNumberByKey(UTF_KEY_COBERTURA, tracingOp, 1)
	tracingOp = ReplaceNumberByKey(UTF_KEY_REGEXP, tracingOp, 1)

	// traceProcedures = ""

	RunTest(procedures, name = "Unit Tests", enableJU = 1, enableRegExp = 1, debugMode = debugMode, traceWinList = traceProcedures, traceOptions = tracingOp, waveTrackingMode = waveTracking)
End

Function cleanup()

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
	IUTF_RestoreTracing()
#endif

End
