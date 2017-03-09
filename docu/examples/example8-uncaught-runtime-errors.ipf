#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example8

#include "unit-testing"

// Command: RunTest("example8-uncaught-runtime-errors.ipf")
// Shows when User code generates an uncaught Runtime Error.
// The test environment catches this condition and gives
// a detailed error message in the history
// The Runtime Error is of course treated as FAIL

Function TestWaveOp()
		WAVE/Z/SDFR=$"I dont exist" wv;
End

// There might be situations where the user wants to catch a runtime error (RTE) himself
// This function shows how to catch the RTE before the test environment handles it.
// The test environment is controlled manually by PASS() and FAIL()
// PASS() increases the assertion counter and FAIL() treats this assertion as fail when a RTE was caught.
// note: As this code can hide critical errors from the test environment it may render test runs unreliable.
Function TestWaveOpSelfCatch()
	try
		PASS()
		WAVE/Z/SDFR=$"I dont exist" wv;AbortOnRTE
	catch
		// Do not forget to clear the RTE
		variable err = getRTError(1)
		FAIL()
	endtry
End
