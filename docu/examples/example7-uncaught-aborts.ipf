#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example7

#include "unit-testing"

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
