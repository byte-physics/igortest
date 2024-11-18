#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma IndependentModule=ABCD
#pragma ModuleName=TAP1

#include "igortest"

static Function run_IGNORE()
	RunTest("IM_tap_example1b-warn_and_error.ipf;IM_tap_example1a-uncaught-aborts.ipf", enableTAP = 1)
End

// Showing the effect of uncaught aborts
// PASS() just increases the assertion counter
static Function CheckNumber(a)
	variable a

	PASS()

	if(numType(a) == 2)
		Abort
	endif

	return 1
End

// TAPDescription: Checking if '*' is the Answer to the Ultimate Question of Life, the Universe, and Everything
static Function TAPCheckNumber_not_nan()

	CheckNumber(char2num("*"))
End

// TAPDescription: Fails with an uncaught abort
static Function TAPCheckNumber_nan()

	CheckNumber(NaN)
End

// TAPDescription: Planned abort here
static Function Bail_Out()

	Abort
End
