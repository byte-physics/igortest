#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.10
#pragma ModuleName=Example3

#include "igortest"

// WARN_* does not increment the error count
Function WarnTest()

	WARN_EQUAL_VAR(1.0, 0.0)
End

// CHECK_* increments the error count
Function CheckTest()

	CHECK_EQUAL_VAR(1.0, 0.0)
End

// REQUIRE_* will stop execution of the test run immediately
Function RequireTest()

	REQUIRE_EQUAL_VAR(1.0, 0.0)
	print "If I'm reached math is wrong !"
End

Function AfterRequireTest()
	print "I will never be reached. Just like all the subsequent test suites."
End
