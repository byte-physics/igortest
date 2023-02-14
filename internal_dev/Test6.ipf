#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=Example5

#include "igortest"

// RunTest("example5-overridehooks.ipf;example5-overridehooks-otherSuite.ipf")

static Function TEST_CASE_BEGIN_EXT(name)
	string name

	print "I'm for all test cases in *this* test suite"
End

static Function TEST_CASE_END_EXT(name)
	string name

	printf "I'm overriding test case end for (%s) in this test suite only\r", name
End

static Function CheckSquareRoot()

	CHECK_EQUAL_VAR(sqrt(4.0),2.0)
	CHECK_CLOSE_VAR(sqrt(2.0),1.4142,tol=1e-4)
End
