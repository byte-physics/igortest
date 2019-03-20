#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma ModuleName=AbortingUserHooks

#include "unit-testing"

Function run()
	RunTest("aborting-user-hooks.ipf", allowDebug=0, enableJU=0, enableTAP=0)
End

Function TEST_BEGIN_OVERRIDE(str)
	string str

	Abort
End

Function TEST_SUITE_BEGIN_OVERRIDE(str)
	string str

	Abort
End

Function TEST_CASE_BEGIN_OVERRIDE(str)
	string str

	Abort
End

Function TEST_CASE_END_OVERRIDE(str)
	string str

	Abort
End

Function TEST_SUITE_END_OVERRIDE(str)
	string str

	Abort
End

Function TEST_END_OVERRIDE(str)
	string str

	Abort
End

Function Dostuff()

	PASS()
End
