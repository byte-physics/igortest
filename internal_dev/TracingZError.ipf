#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma version=1.09
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma ModuleName=TracingZError

#include "unit-testing"

static Function CorruptXOPDatabase()
	TUFXOP_Clear/A/Z
	PASS()
End
