#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Reporting_Warn

static Function WarnTest()
	INFO("this warning should not fail this test case")
	WARN(0)
End
