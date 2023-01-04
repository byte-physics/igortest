#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.09
#pragma ModuleName=Example2

#include "unit-testing"

Function run_IGNORE()

	// executes all test cases of this file
	RunTest("example2-plain.ipf")
	// execute only one test case at a time
	RunTest("example2-plain.ipf", testCase="VerifyStringComparison")
	// explicitly specify both tests
	RunTest("example2-plain.ipf", testCase="VerifyStringComparison;VerfifyEmptyString")
	// specify with regular expression
	RunTest("example2-plain.ipf", testCase="Verify.*", enableRegExp = 1)
	// Give the test a descriptive name
	RunTest("example2-plain.ipf", name="My first test")
End

static Function VerifyStringComparison()

	string strLow      = "123abc"
	string strUP       = "123ABC"

	// by default string comparison is done case sensitive
	// so the following would fail with CHECK/REQUIRE
	WARN_EQUAL_STR(strLow, strUP)
	// It can be specificylly enabled or disabled.
	CHECK_EQUAL_STR(strLow, strUP, case_sensitive = 0)
	// Now we use WARN because the two strings are not equal.
	WARN_EQUAL_STR(strLow, strUP, case_sensitive = 1)
	// other comparisons are also possible
	CHECK_EQUAL_VAR(strlen(strLow), 6)
End

static Function VerfifyEmptyString()

	string nullString
	string emptyString = ""
	string filledString = "filled"

	// an uninitialized string is not equal to an empty string.
	CHECK_NEQ_STR(emptyString, nullString)
	// same as for a filled string
	CHECK_NEQ_STR(filledString, nullString)
	// there is an explicit function for empty strings
	CHECK_EMPTY_STR(emptyString)
	// and also for null strings.
	CHECK_NULL_STR(nullString)
End
