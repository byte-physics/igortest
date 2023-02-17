#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.09
#pragma ModuleName=Example5

#include "igortest"

static Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name

	printf ">> Begin of Test Case %s was extended in this test suite only <<\r", name
End

static Function TEST_CASE_END_OVERRIDE(name)
	string name

	printf ">> End of Test Case %s was extended in this test suite only <<\r", name
End

static Function CheckSquareRoot()

	CHECK_EQUAL_VAR(sqrt(4.0), 2.0)
	CHECK_CLOSE_VAR(sqrt(2.0), 1.4142, tol = 1e-4)
End
