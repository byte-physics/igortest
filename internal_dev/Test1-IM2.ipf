#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma IndependentModule=ABCD
#pragma ModuleName=EFGH

static Function TEST_BEGIN_OVERRIDE(testCase)
	string testCase

	print "TEST_BEGIN_OVERRIDE called"
End

static Function TEST_CASE_BEGIN_OVERRIDE(testCase)
	string testCase

	print "TEST_CASE_BEGIN_OVERRIDE called"
End

static Function run_IGNORE()

	RunTest("Test1-IM2.ipf", allowDebug=1)
	RunTest("Test1-IM2.ipf", allowDebug=1, enableJU = 1)
	RunTest("Test1-IM2.ipf", allowDebug=1, enableTAP = 1, testCase="TestMe2")
End

static Function TestMe1()
	CHECK_EQUAL_VAR(1, 1)
End

static Function TestMe2()
	CHECK_EQUAL_VAR(1, 1)
End

static Function TestMe3()
	CHECK_EQUAL_VAR(1, 2)
End
