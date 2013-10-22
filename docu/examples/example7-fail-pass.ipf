#pragma rtGlobals=3
#pragma ModuleName=Example7

#include "unit-testing"

// Function to add two numbers which aborts on NaN in either a or b
Function AddNormalNumbers(a, b)
	variable a, b

	if(numType(a) == 2 || numType(b) == 2)
		Abort
	endif

	return a + b
End

// Command: RunTest("example7-fail-pass.ipf")
// Helper functions to use with try/catch
static Function CheckAddNormalNumbers_a_nan()
	
	variable a = NaN
	variable b = 1.0
	try
		AddNormalNumbers(a,b)
	catch
		PASS()
		return 0
	endtry
	FAIL()
End

static Function CheckAddNormalNumbers_b_nan()
	
	variable a = 1.0
	variable b = NaN
	try
		AddNormalNumbers(a,b)
	catch
		PASS()
		return 0
	endtry
	FAIL()
End

static Function CheckAddNormalNumbers_both_nan()
	
	variable a = NaN
	variable b = NaN
	try
		AddNormalNumbers(a,b)
	catch
		PASS()
		return 0
	endtry
	FAIL()
End
