#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"

#include "unit-testing"

// As this procedure file is in ProcGlobal context
// the test hook extensions are global.

Function TEST_BEGIN_OVERRIDE(name)
	string name

	print ">> The global Test Begin is extended by this output <<"
End

// note: At the point where TEST_END_OVERRIDE is called the Igor Debugger is
// already reset to the state before the Test Run
Function TEST_END_OVERRIDE(name)
	string name

	print ">> The global Test End is extended by this output <<"
End

Function TEST_CASE_END_OVERRIDE(name)
	string name

	print ">> This is the global extension for the End of Test Cases <<"
End

Function TEST_SUITE_BEGIN_OVERRIDE(name)
	string name

	print ">> The Test Suite Begin is globally extended by this output <<"
End

Function TEST_SUITE_END_OVERRIDE(name)
	string name

	print ">> The Test Suite End is globally extended by this output <<"
End

Function CheckBasicMath()

	CHECK_EQUAL_VAR(1+2,3)
End
