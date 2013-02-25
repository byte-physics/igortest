#pragma rtGlobals=3
#pragma ModuleName=Example4

#include "unit-testing"

// Command: RunTest("example4-wavechecking.ipf")
// Helper functions to check wave types and compare with reference waves are also provided

static Function CheckMake()
  CHECK_EMPTY_FOLDER() // checks that the current data folder is empty and has no variables etc
  
  Make/D myWave
  CHECK_WAVE(myWave,NUMERIC_WAVE,minorType=DOUBLE_WAVE)
  CHECK_EQUAL_VAR(DimSize(myWave,0),128)

  // as this test case is always executed in a fresh datafolder we don't have to use the overwrite
  // /O option for Duplicate
  Duplicate myWave, myWaveCopy
  CHECK_EQUAL_WAVES(myWave,myWaveCopy)
 
End

