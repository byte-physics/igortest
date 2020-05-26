#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example8

#include "unit-testing"

Function TestWaveOp()

		Wave wv = $""
		print wv[0]
		print "This will be printed, even if a RTE occurs."

		WAVE/Z/SDFR=$"I dont exist" wv; AbortOnRTE
		print "This will not be printed, as AbortOnRTE aborts the test case."
End

Function TestWaveOpSelfCatch()

	try
		WAVE/Z/SDFR=$"I dont exist" wv; AbortOnRTE
		// If an RTE happens, the execution will jump to catch.
		PASS()
	catch
		print "Here you can print additional info to understand the RTE."
		// There is no need to clear the RTE (e.g. with GetRTError(1) )
		// RunTest will take care and print the error message.
		FAIL()
	endtry
	print "I only get printed when no RTE occurs"
End