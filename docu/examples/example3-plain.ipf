#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example3

#include "unit-testing"

// Command: RunTest("example3-plain.ipf")

// Shows the differences between WARN, CHECK and REQUIRE
// The error count this test suite returns is 2
// This can be shown by: print RunTest("example3-plain.ipf")

// WARN_* does not increment the error count
Function WarnTest()

	WARN_EQUAL_VAR(1.0,0.0)
End

// CHECK_* increments the error count
Function CheckTest()

	CHECK_EQUAL_VAR(1.0,0.0)
End

// REQUIRE_* increments the error count and will stop execution
// of the test case immediately.
// Nevertheless the test end hooks are still executed.
Function RequireTest()

	REQUIRE_EQUAL_VAR(1.0,0.0)
	print "If I'm reached math is wrong !"
End
