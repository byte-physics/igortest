#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "unit-testing"

Function run_IGNORE()
	RunTest("TestWaveType.ipf", name="Test different Wave Types", testCase="testWaveTypes")
End

Function testWaveTypes()
	WAVE/Z wv
	CHECK_WAVE(wv, NULL_WAVE)

	Make/FREE/U/I wv0
	CHECK_WAVE(wv0, FREE_WAVE, minorType = UNSIGNED_WAVE)
	CHECK_WAVE(wv0, NUMERIC_WAVE, minorType = INT32_WAVE)

	Make/FREE/T wv1
	CHECK_WAVE(wv1, FREE_WAVE)
	CHECK_WAVE(wv1, TEXT_WAVE)

	Make/O/U/I root:wv2/WAVE=wv2
	CHECK_WAVE(wv2, NORMAL_WAVE, minorType = UNSIGNED_WAVE)
	CHECK_WAVE(wv2, NUMERIC_WAVE, minorType = INT32_WAVE)
End

Function checkWaveType()
	WAVE/Z wv
	printWaveType(wv)

	Make/FREE/U/I wv0
	printWaveType(wv0)

	Make/FREE/T wv1
	printWaveType(wv1)

	Make/O/U/I root:wv2/WAVE=wv2
	printWaveType(wv2)
End

Function printWaveType(wv)
	WAVE/Z wv

	Variable type2 = WaveType(wv, 2)
	Variable type1 = WaveType(wv, 1)
	Variable type0 = WaveExists(wv) ? WaveType(wv, 0) : NULL_WAVE

	Variable myType = type0
	myType = myType | (type1 == NULL_WAVE ? NULL_WAVE : 2^(type1 + 7))
	myType = myType | (type2 == NULL_WAVE ? NULL_WAVE : 2^(type2 + 11))

	print "current Wave Type"
	printf "%016b\r", myType

	print "Wave Type Definitions"
	printf "%016b\r", myType & NULL_WAVE

	print "WaveType(wv, 0)"
	printf "%016b  compl\r", myType & COMPLEX_WAVE
	printf "%016b  float\r", myType & FLOAT_WAVE
	printf "%016b double\r", myType & DOUBLE_WAVE
	printf "%016b   int8\r", myType & INT8_WAVE
	printf "%016b  int16\r", myType & INT16_WAVE
	printf "%016b  int32\r", myType & INT32_WAVE
	printf "%016b  int64\r", myType & INT64_WAVE
	printf "%016b   uint\r", myType & UNSIGNED_WAVE

	print "WaveType(wv, 1)"
	printf "%016b    num\r", myType & NUMERIC_WAVE
	printf "%016b   text\r", myType & TEXT_WAVE
	printf "%016b    dfr\r", myType & DATAFOLDER_WAVE
	printf "%016b   wave\r", myType & WAVE_WAVE

	print "WaveType(wv, 2)"
	printf "%016b normal\r", myType & NORMAL_WAVE
	printf "%016b   free\r", myType & FREE_WAVE

	print myType & NUMERIC_WAVE && myType & FREE_WAVE, "free and numeric"
	print myType & NUMERIC_WAVE && myType & NORMAL_WAVE, "normal and numeric"
	print myType & TEXT_WAVE && myType & FREE_WAVE, "free and text"
End
