#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.09
#pragma ModuleName=Example4

#include "unit-testing"


static Function CheckMakeDouble()

	CHECK_EMPTY_FOLDER()

	Make/D myWave
	CHECK_WAVE(myWave, NUMERIC_WAVE, minorType = DOUBLE_WAVE)
	CHECK_EQUAL_VAR(DimSize(myWave, 0), 128)

	Duplicate myWave, myWaveCopy
	CHECK_EQUAL_WAVES(myWave, myWaveCopy)

End

static Function CheckMakeText()

	CHECK_EMPTY_FOLDER()

	Make/T myWave
	CHECK_WAVE(myWave, TEXT_WAVE)
	CHECK_EQUAL_VAR(DimSize(myWave, 0), 128)

	Duplicate/T myWave, myWaveCopy
	CHECK_EQUAL_WAVES(myWave, myWaveCopy)
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
	//The following check for a free wave is intended to fail
	WARN_WAVE(wv2, FREE_WAVE | NUMERIC_WAVE, minorType = UNSIGNED_WAVE | INT32_WAVE)
End
