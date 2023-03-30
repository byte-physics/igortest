#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.10
#pragma ModuleName = TEST_Test_Compilation
#pragma IndependentModule = IM_TEST

static Function CheckValidFile()
	CHECK_COMPILATION("TestData-Valid")
End

static Function CheckInvalidFile()
	CHECK_NO_COMPILATION("TestData-Invalid", reentry = "TEST_Test_Compilation#CheckInvalidFile_REENTRY")
End

static Function CheckInvalidFile_REENTRY()
	CHECK_NO_COMPILATION("TestData-Cond")
End

static Function CheckCondFile()
	Make/T/FREE defines = { "TEST_COND_CHECK" }

	CHECK_COMPILATION("TestData-Cond", defines = defines)
End
