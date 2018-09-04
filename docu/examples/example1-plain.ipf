#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"

#include "unit-testing"

Function TestAbs()

	CHECK_EQUAL_VAR(abs(1.5), 1.5)
	CHECK_EQUAL_VAR(abs(-1.5), 1.5)
	CHECK_EQUAL_VAR(abs(NaN), NaN)
	WARN(abs(NaN) == NaN)
	CHECK_EQUAL_VAR(abs(INF), INF)
	CHECK_EQUAL_VAR(abs(-INF), INF)
End
