#pragma rtGlobals=3
#pragma ModuleName=TAPExample1a

#include "unit-testing"

// RunTest("tap_example1a-uncaught-aborts.ipf", enableTAP = 1)

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

// #TAPDescription: Checking if '*' is the Answer to the Ultimate Question of Life, the Universe, and Everything
static Function TAPCheckNumber_not_nan()

	CheckNumber(char2num("*"))
End

// #TAPDescription: Fails with an uncaught abort
static Function TAPCheckNumber_nan()

	CheckNumber(NaN)
End

// #TAPDescription: Planned abort here
static Function Bail_Out()

	AbortNow()
End
