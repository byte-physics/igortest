#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.10
#pragma ModuleName=Example8

#include "igortest"

Function TestWaveOp()

	Wave wv = $""
	print wv[0]
	print "This will be printed, even if a RTE occurs."

	WAVE/Z/SDFR=$"I dont exist" wv; AbortOnRTE
	print "This will not be printed, as AbortOnRTE aborts the test case."
End

Function CheckForRTEs()

	Wave wv = $""
	print wv[0]
	// Check if any RTE occurs. If no RTE exists at this point it will create an assertion error.
	CHECK_ANY_RTE()

	WAVE/SDFR=$"I dont exist" wv
	// Check for a specific error code. If a different RTE or no RTE exists at this point it will
	// create an assertion error.
	CHECK_RTE(394)

	print "This will always be printed and at this point there a no active RTE as all of them are handled."

	// If you want to test for RTEs and aborts at the same time you can do this doing this:
	try
		// info has to be set before the function call
		INFO("checks if CustomUserFunction returns with no RTE or aborts")
		CustomUserFunction()
		CHECK_NO_RTE()
	catch
		INFO("CustomUserFunction returned with an abort")
		FAIL()
	endtry

	// more tests ...
End
