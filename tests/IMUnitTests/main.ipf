#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Main

#include "igortest"

// The setup for Instrumentation in IM are a bit complex because Igor creates a copy of the igortest
// procedure files when launching an IM and no instrumentation does work after that. It is also a
// bit tricky to jump right after the instrumentation only process as we need to know that all
// procedure files are compiled before starting the IM.
//
// This experiment uses the following steps to test:
//   1. Instrument ProcGlobal igortest-* files
//   2. Use a test case to call run2 as the next command
//   3. run2 loads further settings and includes im-main.ipf which starts the IM. Including
//      im-main.ipf does also create a copy of all instrumented igortest procedure files
//   4. im-main.ipf launches the real test with JUnit output
//   5. The test run end hook creates the cobertura output we want

Function run()

	string msg

#if (exists("TUFXOP_Version") && ((IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812) || (IgorVersion() >= 10.00)))

	// Instrument igortest files and use CallRun2 as test case
	string traceProcedures = "igortest-(?(?=tracing\\.ipf)|.*)"

	string tracingOp = ""
	tracingOp = ReplaceNumberByKey(UTF_KEY_HTMLCREATION, tracingOp, 0)
	tracingOp = ReplaceNumberByKey(UTF_KEY_COBERTURA, tracingOp, 0)
	tracingOp = ReplaceNumberByKey(UTF_KEY_REGEXP, tracingOp, 1)

#else
	string traceProcedures = ""
	string tracingOp       = ""
#endif

	// backup and clear autorun state to prevent the first RunTest closing Igor
	if(GetAutorunMode() == AUTORUN_FULL)
		variable/G root:autorun = 1

		GetFileFolderInfo/Q/Z/P=home "DO_AUTORUN.TXT"
		string/G root:autorunPath = S_Path

		MoveFile/O/Z=1 S_Path as (S_Path + ".BAK")
		if(V_flag)
			msg = GetErrMessage(V_flag)
			sprintf msg, "Cannot backup autorun file: %s", msg
			print msg
		endif
	else
		variable/G root:autorun = 0
	endif

	RunTest("main.ipf", name = "Instrumentation Run", testCase = "CallRun2", traceWinList = traceProcedures, traceOptions = tracingOp)
End

static Function CallRun2()
	PASS()
	// run2() must be executed after the current RunTest. Otherwise they are some problems with the
	// autorun feature.
	Execute/P/Q "TEST_Main#run2()"
End

static Function run2()
	variable allowDebug = 0
	string   procedures = ".*-.*Tests(?:\\.ipf)?"

#if IgorVersion() >= 9.00
	variable waveTrackingMode = UTF_WAVE_TRACKING_ALL
#else
	variable waveTrackingMode = UTF_WAVE_TRACKING_NONE
#endif

	// restore autorun state
	NVAR autorun = root:autorun
	if(autorun)
		SVAR autorunPath = root:autorunPath
		MoveFile/O/Z=1 (autorunPath + ".BAK") as autorunPath
		if(V_flag)
			string msg = GetErrMessage(V_flag)
			sprintf msg, "Cannot restore autorun file: %s", msg
			print msg
		endif
	endif

	string   testVars       = ReadTestVars()
	string/G root:cobSource = TrimString(StringByKey("COBERTURA_SOURCES", testVars, "=", "\n"))
	string/G root:cobOut    = TrimString(StringByKey("COBERTURA_OUT", testVars, "=", "\n"))

	Execute/P/Q "INSERTINCLUDE \"im-main\""
	Execute/P/Q "SetIgorOption IndependentModuleDev=1"
	Execute/P/Q "COMPILEPROCEDURES "

	// Command: IM_TEST#run(".*-.*Tests(?:\\.ipf)?", 1, 1)
	string command = "IM_TEST#run(\""
	command += ReplaceString("\\", procedures, "\\\\")
	command += "\", " + num2istr(allowDebug) + ", " + num2istr(waveTrackingMode) + ")"

	Execute/P/Q command
End

Function cleanup()

#if (exists("TUFXOP_Version") && ((IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812) || (IgorVersion() >= 10.00)))
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
