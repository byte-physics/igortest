#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_Various

// Licensed under 3-Clause BSD, see License.txt

Function DoesNotBugOutOnLongString()

	string a = PadString("a", 10e4, 0x20)
	string b = PadString("b", 10e4, 0x20)
	WARN_EQUAL_STR(a, b)
	WARN_NULL_STR(a)
	WARN_PROPER_STR(a)
	REQUIRE_EQUAL_VAR(GetRTError(0), 0)
End

Function GetWavePointerWorks()
	variable pointer, err

	Make/FREE content

	pointer = str2num(UTF_Utils#GetWavePointer(content))
	CHECK_GT_VAR(pointer, 0)

	Make/N=(inf) data

	// check that lingering RTE's are not changed
	err = GetRTError(0)
	CHECK_GT_VAR(err, 0)
	pointer = str2num(UTF_Utils#GetWavePointer(content))
	CHECK_EQUAL_VAR(err, GetRTError(0))

	// clear RTE to make the testing framework happy
	err = GetRTError(1)
End

static Function CompareZeroSizedWaves()

	Make/FREE/N=0 wvSP
	Make/FREE/D/N=0 wvDP

	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = WAVE_SCALING)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = DATA_UNITS)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = DIMENSION_UNITS)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = DIMENSION_LABELS)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = WAVE_NOTE)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = WAVE_LOCK_STATE)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = DATA_FULL_SCALE)
	CHECK_EQUAL_WAVES(wvSP, wvDP, mode = DIMENSION_SIZES)

	Make/FREE/N=0 wvSP
	Make/FREE/T/N=0 wvT

	CHECK_EQUAL_WAVES(wvSP, wvT, mode = WAVE_DATA)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = WAVE_SCALING)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = DATA_UNITS)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = DIMENSION_UNITS)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = DIMENSION_LABELS)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = WAVE_NOTE)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = WAVE_LOCK_STATE)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = DATA_FULL_SCALE)
	CHECK_EQUAL_WAVES(wvSP, wvT, mode = DIMENSION_SIZES)
End
