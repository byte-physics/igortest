#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example8

#include "unit-testing"

Function TestWaveOp()

		WAVE/Z/SDFR=$"I dont exist" wv;
End

Function TestWaveOpSelfCatch()

	try
		WAVE/Z/SDFR=$"I dont exist" wv; AbortOnRTE
		PASS()
	catch
		// Do not forget to clear the RTE
		variable err = getRTError(1)
		FAIL()
	endtry
End
