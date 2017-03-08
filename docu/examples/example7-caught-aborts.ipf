#pragma rtGlobals=3
#pragma ModuleName=Example7

#include "unit-testing"

// Command: RunTest("example7-caught-aborts.ipf")
// Showing the error message from caught aborts
// works with: Abort, AbortOnValue
// PASS() just increases the assertion counter
Function CheckNumber(a)
	variable a

	PASS()

	if(numType(a) == 2)
		Abort
	endif

	return 1
End

static Function CheckNumber_not_nan()

	CheckNumber(1.0)
End

static Function CheckNumber_nan()

	CheckNumber(NaN)
End
