#pragma rtGlobals=3
#pragma ModuleName=Example6

#include "unit-testing"

// Command: Call "autorun-test.bat" without Igor Pro running

static Function CheckTrigonometricFunctions()
  CHECK_EQUAL_VAR(sin(0.0),0.0)
  CHECK_EQUAL_VAR(cos(0.0),1.0)
  CHECK_EQUAL_VAR(tan(0.0),0.0)
End

