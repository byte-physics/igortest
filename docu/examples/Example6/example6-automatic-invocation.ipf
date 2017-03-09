#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example6

#include "unit-testing"

// Shows automatic execution of Test Runs
// Command: Call "autorun-test-xxx.bat" from the helper folder
// Details:
// the autorun command script executes Test Runs for all pxp experiment files in the current folder
// open a command line in the example6 folder
// execute "..\..\..\helper\autorun-test-IP7-64bit.bat"
// for e.g. Igor Pro 7 64 bit. Igor Pro is expected to be in the default installation folder.
// After the run a log file in the example6 folder with the history can be found.

static Function CheckTrigonometricFunctions()
	CHECK_EQUAL_VAR(sin(0.0),0.0)
	CHECK_EQUAL_VAR(cos(0.0),1.0)
	CHECK_EQUAL_VAR(tan(0.0),0.0)
End
