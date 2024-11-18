#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.10

#include "igortest"

Function TEST_BEGIN_OVERRIDE(name)
	string name

	print ">> The global Test Begin is extended by this output <<"
End

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

	CHECK_EQUAL_VAR(1 + 2, 3)
End
