#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma ModuleName = IM_RUN
#pragma IndependentModule = IM_RUN

#include "igortest"

Function run()
	RunTest("IM_run.ipf", testCase = "TestCase", enableJU = 1)
End

static Function TestCase()
	CHECK_EQUAL_STR("IM_RUN", GetIndependentModuleName())
End
