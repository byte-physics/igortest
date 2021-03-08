#pragma rtGlobals=3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors=1

#include "unit-testing"

// All tests here should fail and give an detailed message
// from CHECK_EQUAL_WAVES in WAVE_DATA mode

Function EqualWavesTol()

	CHECK_EQUAL_WAVES({1}, {1}, mode=WAVE_DATA, tol=NaN)
End

Function EqualWavesNull()

	WAVE/Z wv1 = $""
	CHECK_EQUAL_WAVES(wv1, {1}, mode=WAVE_DATA)
End

Function EqualWavesSize()

	CHECK_EQUAL_WAVES({1}, {2, 3}, mode=WAVE_DATA)
End

Function EqualWavesType1()

	Make/FREE/N=0/D wv1
	Make/FREE/N=0/I wv2
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWavesType1_1()

	Make/FREE/N=0/D wv1
	Make/FREE/N=1/I wv2
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWavesType2()

	Make/FREE/N=1/D wv1
	Make/FREE/N=1/T wv2
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWavesType3()

	Make/FREE/N=1/D wv1
	Make/FREE/N=1/D/C wv2
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWaves1()

	CHECK_EQUAL_WAVES({1}, {2}, mode=WAVE_DATA)
End

Function EqualWaves2()

	Make/FREE/T wv1 = {"1"}
	Make/FREE/T wv2 = {"2"}
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWaves3()

	Make/FREE wTest1, wTest2
	Make/FREE/WAVE wv1 = {wTest1, wTest2}
	Make/FREE/WAVE wv2 = {wTest2, wTest1}
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWaves3_1()

	Make/FREE wTest1, wTest2
	Make/FREE/WAVE wv1 = {wTest1, wTest2}
	Make/FREE wv2 = {0, 0}
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWaves3_2()

	Make/FREE wTest1, wTest2
	Make/FREE/WAVE wv1 = {wTest1, wTest2}
	Make/FREE/DF wv2 = {NewFreeDataFolder(), NewFreeDataFolder()}
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWaves4()

	Make/FREE/DF wv1 = {NewFreeDataFolder()}
	Make/FREE/DF wv2 = {NewFreeDataFolder()}
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWaves5()

	Make/FREE/C/D wv1 = {cmplx(Inf, NaN)}
	Make/FREE/C/D wv2 = {cmplx(NaN, Inf)}
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

// expect 8 errors in table from 20 to 27, [1][0][2][0] to [2][2][2][0]
// this also proves the correct indexing order in checking
Function EqualWaves6()

	Make/FREE/N=(3, 3, 3) wv1
	Make/FREE/N=(3, 3, 3) wv2
	wv1 = p + 3 * q
	wv1 = wv2 + 1
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA, tol = 20)
End

Function SetDimLabelImpl(w, row, col, layer)
	WAVE w
	variable row, col, layer

	SetDimLabel 0, row, $("ROW" + num2str(row)), w
	SetDimLabel 1, col, $("COL" + num2str(col)), w
	SetDimLabel 2, layer, $("LAYER" + num2str(layer)), w
End

Function EqualWaves7()

	Make/FREE/N=(3, 3, 3) wv1
	Make/FREE/N=(3, 3, 3) wv2
	wv2 = SetDimLabelImpl(wv2, p, q, r)
	wv1 = p + 3 * q
	wv2 = wv1 + 1
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA, tol = 20)
End

Function EqualWaves8()

	NewDataFolder there
	DFREF dfr1 = there
	NewDataFolder here
	DFREF dfr2 = here
	Make/T dfr1:there = {"must be here"}
	Make/T dfr2:here = {"should be there"}
	WAVE wv1 = dfr1:there
	WAVE wv2 = dfr2:here
	CHECK_EQUAL_WAVES(wv1, wv2, mode=WAVE_DATA)
End

Function EqualWavesTextWithNulls()

	string str1, str2

	str1 = "abcd"
	str2 = PadString(str1, strlen(str1) + 1, 0x0)

	CHECK_EQUAL_TEXTWAVES({str1}, {str2}, mode=WAVE_DATA)
End

#if IgorVersion() >= 7.00
Function EqualWavesTextWithUTF8()

	string str1, str2

	str1 = "AΔ♣∑B" + U+2022 + U+061C
	str2 = PadString(str1, strlen(str1) + 1, 0x0)

	CHECK_EQUAL_TEXTWAVES({str1}, {str2}, mode=WAVE_DATA)
End

Function EqualWavesUINT64()

	Make/FREE/L/U/N=1 wInt1, wInt2
	wInt1[0] = 0xFFFFFFFFFFFFFFFF
	wInt2[0] = wInt1[0] - 1

	CHECK_EQUAL_WAVES(wInt1, wInt2, mode=WAVE_DATA, tol = 0.99)
End

Function EqualWavesINT64()

	Make/FREE/L/N=1 wInt1, wInt2
	wInt1[0] = 0x7FFFFFFFFFFFFFFF
	wInt2[0] = wInt1[0] - 1

	CHECK_EQUAL_WAVES(wInt1, wInt2, mode=WAVE_DATA, tol = 0.99)
End

Function EqualWavesComplexINT64()

	Make/FREE/C/L/N=1 wInt1, wInt2
	INT64 vi = 0x7FFFFFFFFFFFFFFF
	wInt1[0] += vi
	wInt2[0] += vi
	wInt2[0] -= 1

	CHECK_EQUAL_WAVES(wInt1, wInt2, mode=WAVE_DATA, tol = 0.99)
End

Function EqualWavesComplexUINT64()

	Make/FREE/C/L/U/N=1 wInt1, wInt2
	INT64 vi = 0xFFFFFFFFFFFFFFFF
	wInt1[0] += vi
	wInt2[0] += vi
	wInt2[0] -= 1

	CHECK_EQUAL_WAVES(wInt1, wInt2, mode=WAVE_DATA, tol = 0.99)
End
#endif
