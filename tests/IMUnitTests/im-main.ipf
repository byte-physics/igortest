#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=IM_TEST_Main
#pragma IndependentModule=IM_TEST

#include "igortest"
#include "Test-ExecTests"
#include "Test-CompilationTests"

Function run(procedures, allowDebug, waveTrackingMode)
	string procedures
	variable allowDebug, waveTrackingMode

	RunTest(procedures, name = "IM Unit Tests", enableJU = 1, enableRegExp = 1, allowDebug = allowDebug, waveTrackingMode = waveTrackingMode)
End

#undef UTF_ALLOW_TRACING
#if Exists("TUFXOP_Version")

#if IgorVersion() >= 10.00
#define UTF_ALLOW_TRACING
#elif (IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
#define UTF_ALLOW_TRACING
#endif

#endif

#ifdef UTF_ALLOW_TRACING

Function TEST_END_OVERRIDE(name)
	string name

	printf "IM END: %s\n", name

	SVAR cobSource = root:cobSource
	SVAR cobOut    = root:cobOut

	IUTF_Tracing_Cobertura#PrintReport(cobSource, cobOut)

	Execute "ProcGlobal#cleanup()"
End

#endif // UTF_ALLOW_TRACING
