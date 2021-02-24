#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma IndependentModule=ABCD

#include "unit-testing"

Function TEST_BEGIN_OVERRIDE(testCase)
	string testCase

	print "TEST_BEGIN_OVERRIDE called"
End

Function TEST_CASE_BEGIN_OVERRIDE(testCase)
	string testCase

	print "TEST_CASE_BEGIN_OVERRIDE called"
End

Function run_IGNORE()

	RunTest("Test1-IM1.ipf", allowDebug=1)
	RunTest("Test1-IM1.ipf", allowDebug=1, testCase="TestMe1")
End

Function TestMe1()
	CHECK_EQUAL_VAR(1, 1)
End

Function TestMe2()
	CHECK_EQUAL_VAR(1, 1)
End

Function TestMe3()
	CHECK_EQUAL_VAR(1, 2)
End
