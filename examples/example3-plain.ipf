#pragma rtGlobals=3
#pragma ModuleName=Example3

#include "unit-testing"

// Command: RunTest("example3-plain.ipf")
// The error count of this test suite is 1

// WARN_* does not increment the error count
Function WarnTestComplexSqrt()

  variable/C c1 = cmplx(0,0) 
  WARN_EQUAL_VAR(sqrt(c1),c1)   
End

// CHECK_* increments the error count
Function CheckTestComplexSqrt()

  variable/C c1 = cmplx(0,0) 
  WARN_EQUAL_VAR(sqrt(c1),c1)   
End

// REQUIRE_* increments the error count and will stop execution after this test case
Function RequireTestComplexSqrt()

  variable/C c1 = cmplx(0,0) 
  REQUIRE_EQUAL_VAR(sqrt(c1),c1)   

  // a failing require test will stop execution immediatley
  REQUIRE_EQUAL_VAR(0,1)
  print "I'm never reached :("
End
