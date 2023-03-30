#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.10
#pragma ModuleName=Example7

#include "igortest"

Function CheckNumber(a)
	variable a

	PASS()
	if(numType(a) == 2)
		Abort
	endif
	AbortOnValue a == 5, 100
	return 1
End

static Function CheckNumber_correct()

	CheckNumber(1.0)
End

static Function CheckNumber_nan()

	CheckNumber(NaN)
End

static Function CheckNumber_wrong_value()

	CheckNumber(5)
End
