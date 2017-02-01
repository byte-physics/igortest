#pragma rtGlobals=3
#pragma ModuleName=Example8

#include "unit-testing"

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
