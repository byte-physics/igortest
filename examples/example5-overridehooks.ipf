#pragma rtGlobals=3
#pragma ModuleName=CheckSquareRoot

#include "unit-testing"

// Command: RunTest("example5-overridehooks.ipf;example5-overridehooks-otherSuite.ipf")

static Function TEST_CASE_BEGIN_OVERRIDE(name)
  string name

  print "I'm for all test cases in this test suite overriding the test case begin"
End

static Function TEST_CASE_END_OVERRIDE(name)
  string name

  printf "I'm overriding test case end for (%s) in this test suite only but still call the default hook\r", name
  TEST_CASE_END(name)
End

static Function CheckSquareRoot()

  CHECK_EQUAL_VAR(sqrt(4.0),2.0)
  CHECK_CLOSE_VAR(sqrt(2.0),1.4142,tol=1e-4)
End

