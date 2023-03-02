#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = TEST_Exec
#pragma IndependentModule = IM_TEST

// This is just a test to showcase that Tracings works with IMs.

static Function Test()

	Print "==== TEST EXECUTED ===="
	PASS()

End
