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

// REQUIRE_* stops execution of the current test case
Function RequireTest()

	REQUIRE_EQUAL_VAR(1.0, 0.0)
	print "If I'm reached math is wrong !"
End

// The test run continues with the next test case
Function AfterRequireTest()
	CHECK_EQUAL_VAR(1.0, 1.0)
End
