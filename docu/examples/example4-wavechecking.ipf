#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=Example4

#include "unit-testing"

// Command: RunTest("example4-wavechecking.ipf")
// Helper functions to check wave types and compare with
// reference waves are also provided

static Function CheckMakeDouble()
	CHECK_EMPTY_FOLDER() // checks that the cdf is completely empty

	Make/D myWave
	CHECK_WAVE(myWave,NUMERIC_WAVE,minorType=DOUBLE_WAVE)
	CHECK_EQUAL_VAR(DimSize(myWave,0),128)

	// as this test case is always executed in a fresh datafolder
	// we don't have to use the overwrite /O option for Duplicate
	Duplicate myWave, myWaveCopy
	CHECK_EQUAL_WAVES(myWave,myWaveCopy)

End

static Function CheckMakeText()
	CHECK_EMPTY_FOLDER()

	Make/T myWave
	CHECK_WAVE(myWave,TEXT_WAVE)
	CHECK_EQUAL_VAR(DimSize(myWave,0),128)

	Duplicate/T myWave, myWaveCopy
	CHECK_EQUAL_WAVES(myWave,myWaveCopy)
End

static Function CheckWaveTypes()
	WAVE/Z wv
	CHECK_WAVE(wv, NULL_WAVE)

	Make/FREE/U/I wv0
	CHECK_WAVE(wv0, FREE_WAVE | NUMERIC_WAVE, minorType = UNSIGNED_WAVE | INT32_WAVE)

	Make/FREE/T wv1
	CHECK_WAVE(wv1, FREE_WAVE | TEXT_WAVE)

	Make/O/U/I root:wv2/WAVE=wv2
	CHECK_WAVE(wv2, NORMAL_WAVE | NUMERIC_WAVE, minorType = UNSIGNED_WAVE | INT32_WAVE)
	print "The following check for free wave is intended to fail"
	CHECK_WAVE(wv2, FREE_WAVE | NUMERIC_WAVE, minorType = UNSIGNED_WAVE | INT32_WAVE) // ! not a free wave
End
