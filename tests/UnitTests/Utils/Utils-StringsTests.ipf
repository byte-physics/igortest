#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = TEST_Utils_Strings

static Function Test_IsPrefix()
	INFO("Expect \"%s\" is prefix of \"%s\"", s2 = "abcde", s1 = "abcde")
	CHECK(IUTF_Utils_Strings#IsPrefix("abcde", "abcde"))
	INFO("Expect \"%s\" is prefix of \"%s\"", s2 = "abcde", s1 = "abc")
	CHECK(IUTF_Utils_Strings#IsPrefix("abcde", "abc"))
	INFO("Expect \"%s\" is no prefix of \"%s\"", s2 = "abcde", s1 = "cde")
	CHECK(!IUTF_Utils_Strings#IsPrefix("abcde", "cde"))
End
