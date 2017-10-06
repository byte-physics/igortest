#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3
#pragma IndependentModule=Example9

#include "unit-testing"

// Command: Example9#RunTest("example9-IM.ipf")
// Please note that the procedure window name does *not*
// include any independent module specification.

Function TestMe()
	CHECK_EQUAL_VAR(1, 1)
End
