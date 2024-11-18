#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Main

#include "igortest"
#include ":Reporting:WarnTests"
#include ":Tracing:CoberturaTests"
#include ":Tracing:ComplexityTests"
#include ":Utils:PathsTests"
#include ":Utils:StringsTests"

Function run()
	variable allowDebug = 0
	string   procedures = ".*Tests\\.ipf"

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
	string traceProcedures = "(?:" + procedures + "|igortest-(?(?=tracing\\.ipf)|.*))"
#else
	string traceProcedures = ""
#endif

#if IgorVersion() >= 9.00
	variable waveTrackingMode = UTF_WAVE_TRACKING_ALL
#else
	variable waveTrackingMode = UTF_WAVE_TRACKING_NONE
#endif

	string tracingOp = ""
	tracingOp = ReplaceNumberByKey(UTF_KEY_HTMLCREATION, tracingOp, 0)
	tracingOp = ReplaceNumberByKey(UTF_KEY_COBERTURA, tracingOp, 1)
	tracingOp = ReplaceNumberByKey(UTF_KEY_REGEXP, tracingOp, 1)

	string testVars = ReadTestVars()
	tracingOp = ReplaceStringByKey(UTF_KEY_COBERTURA_SOURCES, tracingOp, TrimString(StringByKey("COBERTURA_SOURCES", testVars, "=", "\n")))
	tracingOp = ReplaceStringByKey(UTF_KEY_COBERTURA_OUT, tracingOp, TrimString(StringByKey("COBERTURA_OUT", testVars, "=", "\n")))

	// traceProcedures = ""

	RunTest(procedures, name = "Unit Tests", enableJU = 1, enableRegExp = 1, allowDebug = allowDebug, traceWinList = traceProcedures, traceOptions = tracingOp, waveTrackingMode = waveTrackingMode)
End

Function TEST_END_OVERRIDE(name)
	string name

	Execute/P "cleanup()"
End

Function cleanup()

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
	IUTF_RestoreTracing()
#endif

End

static Function/S ReadTestVars()
	string path, input
	variable fNum

	path = IUTF_Utils_Paths#AtHome("TEST_VARS.TXT")
	GetFileFolderInfo/Z/Q path
	if(V_flag || !V_IsFile)
		return ""
	endif

	Open/R/Z fNum as path
	if(V_flag)
		return ""
	endif
	FStatus fNum
	input = PadString("", V_logEOF, 0x20)
	FBinRead fnum, input
	Close fNum

	return input
End
