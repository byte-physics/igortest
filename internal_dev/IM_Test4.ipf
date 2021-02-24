#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma IndependentModule=ABCD

#include "unit-testing"

Function run4_IGNORE()

	RunTest("IM_Test4.ipf", allowDebug=1, testCase="RequireTest", enableJU=1)
	RunTest("IM_Test4.ipf", allowDebug=1, enableJU=1)
End

// Command: RunTest("example3-plain.ipf")
// The error count of this test suite is 2

// WARN_* does not increment the error count
Function WarnTest()

	WARN_EQUAL_VAR(1.0,0.0)
End

// CHECK_* increments the error count
Function CheckTest()

	CHECK_EQUAL_VAR(1.0,0.0)
End

// REQUIRE_* increments the error count and will stop execution
// of the test case immediately.
// Nevertheless the test end hooks are still executed.
Function RequireTest()

	REQUIRE_EQUAL_VAR(1.0,2.0)
	print "I'm never reached :("
End

Function CheckTest2()
	print "CODERS FAIL: I should be never reached\r"
	CHECK_EQUAL_VAR(1.0,0.0)
End
