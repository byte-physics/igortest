#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma IndependentModule=ABCD

#include "igortest"

// Command: RunTest("example8-pass-fail.ipf")
// Shows how to use PASS() and FAIL() together with try/catch

Function TestWaveOp()
	try
		WAVE/Z/SDFR=$"I dont exist" wv; AbortOnRTE
		FAIL()
	catch
		PASS()
	endtry
End
