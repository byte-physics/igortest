#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma IndependentModule=ABCD
#pragma ModuleName=test8
#include "unit-testing"

// Command: RunTest("example7-uncaught-aborts.ipf")
// Showing the effect of uncaught aborts
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
