#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.10
#pragma rtFunctionErrors=1

#include "igortest"

// RunTest("TestCaseAssertionCounterCheck.ipf")

// If this test fails then everything works correct,
// as the assertions in the hooks must not count as test case assertions.

Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name

	print "Hook TC Begin called"
	PASS()
End

Function TEST_CASE_END_OVERRIDE(name)
	string name

	print "Hook TC End called"
	PASS()
End

Function myTestCase()
	// no Assertion here
End
