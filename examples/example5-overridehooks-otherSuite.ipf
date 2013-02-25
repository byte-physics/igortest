#pragma rtGlobals=3

#include "unit-testing"

// Command: RunTest("example5-overridehooks.ipf;example5-overridehooks-otherSuite.ipf")
// As this procedure file is in ProcGlobal context, the test hook overrides are globally.

Function TEST_BEGIN_OVERRIDE(name)
  string name

  print "I can only be overriden globally"
End

Function TEST_END_OVERRIDE(name)
  string name

  print "I can only be overriden globally, too"
End

Function TEST_CASE_END_OVERRIDE(name)
  string name

  print "I'm for all test suites overriding the test case end but still call the default hook"
  TEST_CASE_END(name)
End

Function TEST_SUITE_BEGIN_OVERRIDE(name)
  string name

  print "Global test suite begin override"
End

Function TEST_SUITE_END_OVERRIDE(name)
  string name

  print "Global test suite end override"
  TEST_SUITE_END(name)
End

Function CheckBasicMath()

  CHECK_EQUAL_VAR(1+2,3)
End
