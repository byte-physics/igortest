#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TestData_Cond

#ifdef TEST_COND_CHECK
static Function TestSum(a, b)
	variable a, b

	return a + b
End
#else
static Function/S TestSum(a, b)
	variable a, b

	return a + b
End
#endif
