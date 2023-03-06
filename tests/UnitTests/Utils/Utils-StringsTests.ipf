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

static Function Test_ReplaceAllRegex()
	// empty text
	CHECK_EQUAL_STR("", IUTF_Utils_Strings#ReplaceAllRegex("", "", ""))
	CHECK_EQUAL_STR("", IUTF_Utils_Strings#ReplaceAllRegex(".*", "", "abc"))

	// replaces simple patterns
	CHECK_EQUAL_STR("b", IUTF_Utils_Strings#ReplaceAllRegex("a", "a", "b"))
	CHECK_EQUAL_STR("b b", IUTF_Utils_Strings#ReplaceAllRegex("a", "a a", "b"))
	CHECK_EQUAL_STR("b b ", IUTF_Utils_Strings#ReplaceAllRegex("a", "a a ", "b"))

	// replaces more complex patterns
	CHECK_EQUAL_STR("cbacba", IUTF_Utils_Strings#ReplaceAllRegex("(?<!b)a", "abaaba", "c"))
End

static Function Test_CountRegex()
	// empty text
	CHECK_EQUAL_VAR(0, IUTF_Utils_Strings#CountRegex("", ""))
	CHECK_EQUAL_VAR(0, IUTF_Utils_Strings#CountRegex(".*", ""))

	// replaces simple patterns
	CHECK_EQUAL_VAR(1, IUTF_Utils_Strings#CountRegex("a", "a"))
	CHECK_EQUAL_VAR(2, IUTF_Utils_Strings#CountRegex("a", "a a"))
	CHECK_EQUAL_VAR(2, IUTF_Utils_Strings#CountRegex("a", "a a "))

	// replaces more complex patterns
	CHECK_EQUAL_VAR(2, IUTF_Utils_Strings#CountRegex("(?<!b)a", "abaaba"))
End
