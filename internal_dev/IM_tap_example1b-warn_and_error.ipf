#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma IndependentModule=ABCD
#pragma ModuleName=TAP2

#include "igortest"

// RunTest("tap_example1b-warn_and_error.ipf;tap_example1a-uncaught-aborts.ipf",tapEnable=1)

// TAPDirective: ### Double Cross Enclosed Text ###
// TAPDescription: 123_Description_starts_with_digit_and_ends_with_double_cross_###
Function TAPTestModulo()

	CHECK_EQUAL_VAR(abs(1.5),1.5)
	CHECK_EQUAL_VAR(abs(-1.5),1.5)
	CHECK_EQUAL_VAR(abs(NaN),NaN)
	// remember that NaN is not equal to NaN
	// this check will generate a warning message but due
	// to the usage of WARN instead of CHECK not increment the error count
	WARN(abs(NaN) == NaN)
	CHECK_EQUAL_VAR(abs(INF),INF)
	CHECK_EQUAL_VAR(abs(-INF),INF)
End

// TAPDirective: Look Left
Function TAPTestModulo1()

	CHECK_EQUAL_VAR(abs(1.5),1.5)
	CHECK_EQUAL_VAR(abs(-1.5),1.5)
	CHECK_EQUAL_VAR(abs(NaN),NaN)
	// The following line fails
	CHECK_EQUAL_VAR(1, 2)
	CHECK_EQUAL_VAR(abs(INF),INF)
	CHECK_EQUAL_VAR(abs(-INF),INF)
End

// TAPDirective: SKIP with TAP enabled this Test Case is not executed (skipped) and reported 'ok', when executed it fails
Function TAPTestSkip()
	CHECK_EQUAL_VAR(1,2)
End
