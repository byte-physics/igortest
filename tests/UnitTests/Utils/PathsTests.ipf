#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.10
#pragma ModuleName = TEST_Utils_Paths

static Function Test_GetDirPathOfFile()
	string result, expect

	expect = "abc\\def\\"
	result = IUTF_Utils_Paths#GetDirPathOfFile("abc:def:ghi.exe")
	CHECK_EQUAL_STR(expect, result)

	expect = ""
	result = IUTF_Utils_Paths#GetDirPathOfFile("foo.txt")
	CHECK_EQUAL_STR(expect, result)
End
