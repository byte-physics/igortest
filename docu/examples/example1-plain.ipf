#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.10

#include "igortest"

Function TestAbs()

	CHECK_EQUAL_VAR(abs(1.5), 1.5)
	CHECK_EQUAL_VAR(abs(-1.5), 1.5)
	CHECK_EQUAL_VAR(abs(NaN), NaN)
	WARN(abs(NaN) == NaN)
	CHECK_EQUAL_VAR(abs(Inf), Inf)
	CHECK_EQUAL_VAR(abs(-Inf), Inf)
End
