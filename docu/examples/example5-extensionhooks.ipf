#pragma rtGlobals=3
#pragma ModuleName=Example5

#include "unit-testing"

// To run this example:
// RunTest("example5-extensionhooks.ipf;example5-extensionhooks-otherSuite.ipf")

// Here is shown how own code can be added to the Test Run at certain points.
// In this Test Suite additional code can be executed
// at the beginning and end of Test Cases defined in this procedure aka Test Suite
// This is done by declaring the TEST_CASE_BEGIN_OVERRIDE / TEST_CASE_END_OVERRIDE function 'static'

// Be aware that this overrides any global TEST_CASE_BEGIN_OVERRIDE functions for this Test Suite
// If you want to execute the global TEST_CASE_BEGIN_OVERRIDE as well add this code:
//	FUNCREF USER_HOOK_PROTO tcbegin_global = $"ProcGlobal#TEST_CASE_BEGIN_OVERRIDE"
//	tcbegin_global(name)

// Each hook will output a message starting with >>
// After the Test Run you can see at which points the additional User code was executed.

static Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name

	printf ">> The begin of Test Case %s was extended in this test suite only <<\r", name
End

static Function TEST_CASE_END_OVERRIDE(name)
	string name

	printf ">> The end of Test Case %s was extended in this test suite only <<\r", name
End

static Function CheckSquareRoot()

	CHECK_EQUAL_VAR(sqrt(4.0),2.0)
	CHECK_CLOSE_VAR(sqrt(2.0),1.4142,tol=1e-4)
End
