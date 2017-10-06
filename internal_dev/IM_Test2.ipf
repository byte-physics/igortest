#pragma rtGlobals=3
#pragma IndependentModule=ABCD

#include "unit-testing"

// Execute the test suite, same named as this procedure file
// with RunTest("example1-plain.ipf")

Function TestModulo()

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
