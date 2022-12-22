#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_Various

// Licensed under 3-Clause BSD, see License.txt

static Constant MMD_COMBO_COUNT = 32

// this is used for checking warnings in the history
Function TriggerWarningToHistory()
	DoWindow/K HistoryCarbonCopy
	NewNotebook/V=0/F=0 /N=HistoryCarbonCopy
	INFO("This warning is intended to fail. The next testcase will search for it.")
	WARN(0)
End

Function CheckForWarningInHistory()
	Notebook HistoryCarbonCopy, findText={"Assertion \"WARN(0)\" failed in TriggerWarningToHistory", 19}
	CHECK_EQUAL_VAR(1, V_flag)

	Notebook HistoryCarbonCopy, findText={"This warning is intended to fail. The next testcase will search for it.", 2}
	CHECK_EQUAL_VAR(1, V_flag)
End

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

static Function/WAVE GeneratorSC()

	Make/FREE/N=10 data

	NVAR/Z cc = root:dgenCallCount
	if(!NVAR_Exists(cc))
		variable/G root:dgenCallCount = 1
	else
		cc += 1
	endif

	return data
End

// UTF_TD_GENERATOR GeneratorSC
static Function TestDGenSingleCall_A([var])
	variable var

	PASS()
End

static Function TestDGenSingleCall_B()

	NVAR/Z cc = root:dgenCallCount
	REQUIRE(NVAR_Exists(cc))
	CHECK_EQUAL_VAR(cc, 1)
End

Function/WAVE GeneratorVar()

	Make/FREE/N=2 data = p
	SetDimlabel UTF_ROW, 0, VAR0, data
	SetDimlabel UTF_ROW, 1, VAR1, data

	return data
End

Function/WAVE GeneratorStr()

	Make/FREE/N=2/T data

	return data
End

Function/WAVE GeneratorZeroSize()

	Make/FREE/N=0 data

	return data
End

// UTF_TD_GENERATOR v0:GeneratorVar
// UTF_TD_GENERATOR v1:GeneratorVar
// UTF_TD_GENERATOR v2:GeneratorVar
// UTF_TD_GENERATOR v3:GeneratorVar
// UTF_TD_GENERATOR v4:GeneratorVar
static Function TC_MMD_Part1([md])
	STRUCT IUTF_mData &md

	variable numVars = 5

	variable/G root:callCounter
	NVAR cc = root:callCounter

	if(!(md.v0 + md.v1 + md.v2 + md.v3 + md.v4))
		KillWaves/Z root:valueLog
		cc = 0
	endif

	WAVE/Z wv = root:valueLog
	if(!WaveExists(wv))
		Make/N=(MMD_COMBO_COUNT, numVars) root:valueLog/WAVE=wv
	endif

	wv[cc][0] = md.v0
	wv[cc][1] = md.v1
	wv[cc][2] = md.v2
	wv[cc][3] = md.v3
	wv[cc][4] = md.v4

	cc += 1
	if(cc == MMD_COMBO_COUNT)
		Make/FREE/N=(MMD_COMBO_COUNT, numVars) dataRef = mod(trunc(p / 2^q), 2)
		CHECK_EQUAL_WAVES(dataRef, wv, mode=WAVE_DATA)
	endif
	PASS()
End

static Function TC_MMD_Part2()

	NVAR cc = root:callCounter
	CHECK_EQUAL_VAR(MMD_COMBO_COUNT, cc)
	PASS()
End

// UTF_TD_GENERATOR s0:GeneratorStr
static Function TC_MMD_InitValues([md])
	STRUCT IUTF_mData &md

	CHECK_EQUAL_VAR(md.v0, 0)
	CHECK_EQUAL_VAR(strlen(md.s0), 0)
	CHECK_EQUAL_VAR(strlen(md.s1), NaN)

	CHECK_WAVE(md.w0, NULL_WAVE)
	CHECK_EQUAL_VAR(DataFolderRefStatus(md.dfr0), 0)
	CHECK_EQUAL_VAR(real(md.c0), 0)
	CHECK_EQUAL_VAR(imag(md.c0), 0)
	#if (IgorVersion() >= 7.0)
		CHECK_EQUAL_INT64(md.i0, 0)
	#endif

End

// UTF_TD_GENERATOR v0:GeneratorZeroSize
static Function TC_MMD_ZeroSize([md])
	STRUCT IUTF_mData &md

	FAIL()
End

// UTF_TD_GENERATOR GeneratorZeroSize
static Function TC_MD_ZeroSize([val])
	variable val

	FAIL()
End

static Function/WAVE GeneratorV()

	Make/FREE wv = {1}

	return wv
End

static Function/WAVE GeneratorS()

	Make/FREE/T wv = {"IUTF"}

	return wv
End

static Function/WAVE GeneratorC()

	Make/FREE/C wv = {cmplx(1,1)}

	return wv
End

static Function/WAVE GeneratorW()

	Make/FREE data = {1}
	Make/FREE/WAVE wv = {data}

	return wv
End

static Function/WAVE GeneratorDFR()

	Make/FREE/DF wv = {root:}

	return wv
End

// UTF_TD_GENERATOR v0:GeneratorV
// UTF_TD_GENERATOR v1:GeneratorV
// UTF_TD_GENERATOR v2:GeneratorV
// UTF_TD_GENERATOR v3:GeneratorV
// UTF_TD_GENERATOR v4:GeneratorV
// UTF_TD_GENERATOR s0:GeneratorS
// UTF_TD_GENERATOR s1:GeneratorS
// UTF_TD_GENERATOR s2:GeneratorS
// UTF_TD_GENERATOR s3:GeneratorS
// UTF_TD_GENERATOR s4:GeneratorS
// UTF_TD_GENERATOR c0:GeneratorC
// UTF_TD_GENERATOR c1:GeneratorC
// UTF_TD_GENERATOR c2:GeneratorC
// UTF_TD_GENERATOR c3:GeneratorC
// UTF_TD_GENERATOR c4:GeneratorC
// UTF_TD_GENERATOR w0:GeneratorW
// UTF_TD_GENERATOR w1:GeneratorW
// UTF_TD_GENERATOR w2:GeneratorW
// UTF_TD_GENERATOR w3:GeneratorW
// UTF_TD_GENERATOR w4:GeneratorW
// UTF_TD_GENERATOR dfr0:GeneratorDFR
// UTF_TD_GENERATOR dfr1:GeneratorDFR
// UTF_TD_GENERATOR dfr2:GeneratorDFR
// UTF_TD_GENERATOR dfr3:GeneratorDFR
// UTF_TD_GENERATOR dfr4:GeneratorDFR
static Function TC_MMD_Types([md])
	STRUCT IUTF_mData &md

	string str, strRef

	CHECK_EQUAL_VAR(md.v0, 1)
	CHECK_EQUAL_VAR(md.v1, 1)
	CHECK_EQUAL_VAR(md.v2, 1)
	CHECK_EQUAL_VAR(md.v3, 1)
	CHECK_EQUAL_VAR(md.v4, 1)
	strRef = "IUTF"
	str = md.s0
	CHECK_EQUAL_STR(str, strRef)
	str = md.s1
	CHECK_EQUAL_STR(str, strRef)
	str = md.s2
	CHECK_EQUAL_STR(str, strRef)
	str = md.s3
	CHECK_EQUAL_STR(str, strRef)
	str = md.s4
	CHECK_EQUAL_STR(str, strRef)

	CHECK_EQUAL_VAR(real(md.c0), 1)
	CHECK_EQUAL_VAR(imag(md.c0), 1)
	CHECK_EQUAL_VAR(real(md.c1), 1)
	CHECK_EQUAL_VAR(imag(md.c1), 1)
	CHECK_EQUAL_VAR(real(md.c2), 1)
	CHECK_EQUAL_VAR(imag(md.c2), 1)
	CHECK_EQUAL_VAR(real(md.c3), 1)
	CHECK_EQUAL_VAR(imag(md.c3), 1)
	CHECK_EQUAL_VAR(real(md.c4), 1)
	CHECK_EQUAL_VAR(imag(md.c4), 1)

	CHECK_EQUAL_VAR(md.w0[0], 1)
	CHECK_EQUAL_VAR(md.w1[0], 1)
	CHECK_EQUAL_VAR(md.w2[0], 1)
	CHECK_EQUAL_VAR(md.w3[0], 1)
	CHECK_EQUAL_VAR(md.w4[0], 1)

	DFREF dfrref = root:
	CHECK(DataFolderRefsEqual(md.dfr0, dfrref))
	CHECK(DataFolderRefsEqual(md.dfr1, dfrref))
	CHECK(DataFolderRefsEqual(md.dfr2, dfrref))
	CHECK(DataFolderRefsEqual(md.dfr3, dfrref))
	CHECK(DataFolderRefsEqual(md.dfr4, dfrref))
End

Function UserTask(s)
	STRUCT WMBackgroundStruct &s

	return !mod(trunc(datetime), 5)
End

Function/WAVE DataGeneratorFunction()
	Make/FREE data = {5, 1}
	SetDimLabel 0, 0, first, data
	SetDimLabel 0, 1, second, data
	return data
End

// UTF_TD_GENERATOR DataGeneratorFunction
Function TC_MD_bck([var])
	variable var

	CtrlNamedBackGround testtask, proc=UserTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "TC_MD_bck_REENTRY")
	CHECK(var == 1 || var == 5)
End

Function TC_MD_bck_REENTRY([var])
	variable var

	CHECK(var == 1 || var == 5)
	PASS()
End

// UTF_TD_GENERATOR v0:DataGeneratorFunction
Function TC_MMD_bck([md])
	STRUCT IUTF_mData &md

	CtrlNamedBackGround testtask, proc=UserTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "TC_MMD_bck_REENTRY")
	CHECK(md.v0 == 1 || md.v0 == 5)
End

Function TC_MMD_bck_REENTRY([md])
	STRUCT IUTF_mData &md

	CHECK(md.v0 == 1 || md.v0 == 5)
	PASS()
End

Function TC_UTILS_GetNiceStringForNumber()
	// no decimal point, short numbers
	TC_UTILS_GNSFN_Check_IGNORE("2", "2", 2)

	// small amount of digits behind decimal point
	TC_UTILS_GNSFN_Check_IGNORE("3.14", "3.14", 3.14)

	// medium amount of digits behind decimal point
	TC_UTILS_GNSFN_Check_IGNORE("3.141593", "3.141593", 3.141593)

	// big amount of digits behind decimal point
	TC_UTILS_GNSFN_Check_IGNORE("3.141593", "3.141592653589793", 3.141592653589793)

	// really large number
	TC_UTILS_GNSFN_Check_IGNORE("1e+30", "1e+30", 1e30)
	TC_UTILS_GNSFN_Check_IGNORE("3.141593e+07", "31415926.53589793", pi * 1e7)

	// all checks passed
	PASS()
End

Function TC_UTILS_GNSFN_Check_IGNORE(expect32, expect64, num)
	string expect32, expect64
	variable num

	string str

	str = UTF_UTILS#GetNiceStringForNumber(num, isDouble=0)
	REQUIRE_EQUAL_STR(expect32, str)

	str = UTF_UTILS#GetNiceStringForNumber(num, isDouble=1)
	REQUIRE_EQUAL_STR(expect64, str)
End

static Function TC_StringDiff()
	STRUCT IUTF_StringDiffResult result
	string str, res, expected

	// DIFF CHECKING

	// Case 1: text is different until line end
	TC_StringDiff_Check("abcfg", "abcde", "0:3:3> a b c f g", "0:3:3> a b c d e")
	TC_StringDiff_Check("foo\nabcfg\nbar", "foo\nabcde\nbar", "1:3:7> a b c f g", "1:3:7> a b c d e")

	// Case 2: one line is shorter than the other
	TC_StringDiff_Check("abc", "abcde", "0:3:3> a b c", "0:3:3> a b c d e")
	TC_StringDiff_Check("foo\nabc\nbar", "foo\nabcde\nbar", "1:3:7> a b c <LF>", "1:3:7> a b c d e <LF>")

	// Case 3: the line endings are different
	TC_StringDiff_Check("abc\ndef", "abc\rdef", "0:3:3> a b c <LF>", "0:3:3> a b c <CR>")
	TC_StringDiff_Check("abc\ndef", "abc\r\ndef", "0:3:3> a b c <LF>", "0:3:3> a b c <CR> <LF>")
	TC_StringDiff_Check("abc\r\ndef", "abc\rdef", "0:3:3> a b c <CR> <LF>", "0:3:3> a b c <CR>")

	// Case 4: one string is larger than the other one
	TC_StringDiff_Check("text\n", "text\nabc", "1:0:5>", "1:0:5> a b c")
	TC_StringDiff_Check("", "abc\ndef", "0:0:0>", "0:0:0> a b c <LF>")

	// CORE CHECKING

	// Case sensitivity
	TC_StringDiff_Check("a\nb", "A\nc", "0:0:0> a", "0:0:0> A")
	TC_StringDiff_Check("a\nb", "A\nc", "1:0:2> b", "1:0:2> c", case_sensitive=0)
	TC_StringDiff_Check("a\nb", "A\nc", "0:0:0> a", "0:0:0> A", case_sensitive=1)

	// Trim context
	TC_StringDiff_Check("0123456789abcdef.0123456789abcdef", "0123456789abcdef:0123456789abcdef", "0:16:16> 6 7 8 9 a b c d e f . 0 1 2 3 4 5 6 7 8 9", "0:16:16> 6 7 8 9 a b c d e f : 0 1 2 3 4 5 6 7 8 9")
	TC_StringDiff_Check(".0123456789abcdef", ":0123456789abcdef", "0:0:0> . 0 1 2 3 4 5 6 7 8 9", "0:0:0> : 0 1 2 3 4 5 6 7 8 9")
	TC_StringDiff_Check("0123456789abcdef\n.0123456789abcdef", "0123456789abcdef\n:0123456789abcdef", "1:0:17> . 0 1 2 3 4 5 6 7 8 9", "1:0:17> : 0 1 2 3 4 5 6 7 8 9")
	TC_StringDiff_Check("0123456789abcdef.", "0123456789abcdef:", "0:16:16> 6 7 8 9 a b c d e f .", "0:16:16> 6 7 8 9 a b c d e f :")
	TC_StringDiff_Check("0123456789abcdef.\n0123456789abcdef", "0123456789abcdef:\n0123456789abcdef", "0:16:16> 6 7 8 9 a b c d e f .", "0:16:16> 6 7 8 9 a b c d e f :")

	// Escaping
	res = UTF_UTILS#EscapeString("a\000\n\r\t\007")
	expected = " a <NUL> <LF> <CR> <TAB> <0x07>"
	CHECK_EQUAL_STR(expected, res)
End

static Function TC_StringDiff_Check(str1, str2, out1, out2, [case_sensitive])
	string str1, str2, out1, out2
	variable case_sensitive

	Struct IUTF_StringDiffResult result
	string str

	// forward check
	if(ParamIsDefault(case_sensitive))
		UTF_UTILS#DiffString(str1, str2, result)
	else
		UTF_UTILS#DiffString(str1, str2, result, case_sensitive=case_sensitive)
	endif
	str = result.v1
	CHECK_EQUAL_STR(out1, str)
	str = result.v2
	CHECK_EQUAL_STR(out2, str)

	// backward check (switched arguments)
	if(ParamIsDefault(case_sensitive))
		UTF_UTILS#DiffString(str2, str1, result)
	else
		UTF_UTILS#DiffString(str2, str1, result, case_sensitive=case_sensitive)
	endif
	str = result.v1
	CHECK_EQUAL_STR(out2, str)
	str = result.v2
	CHECK_EQUAL_STR(out1, str)
End

static Function TC_WaveMajorTypeString()
	// just the constants
	TC_WaveMajorTypeString_Check("NULL_WAVE", NULL_WAVE)
	TC_WaveMajorTypeString_Check("NUMERIC_WAVE", NUMERIC_WAVE)
	TC_WaveMajorTypeString_Check("TEXT_WAVE", TEXT_WAVE)
	TC_WaveMajorTypeString_Check("DATAFOLDER_WAVE", DATAFOLDER_WAVE)
	TC_WaveMajorTypeString_Check("WAVE_WAVE", WAVE_WAVE)
	TC_WaveMajorTypeString_Check("NORMAL_WAVE", NORMAL_WAVE)
	TC_WaveMajorTypeString_Check("FREE_WAVE", FREE_WAVE)

	// normal waves
	TC_WaveMajorTypeString_Check("NULL_WAVE", NORMAL_WAVE | NULL_WAVE)
	TC_WaveMajorTypeString_Check("NORMAL_WAVE, NUMERIC_WAVE", NORMAL_WAVE | NUMERIC_WAVE)
	TC_WaveMajorTypeString_Check("NORMAL_WAVE, TEXT_WAVE", NORMAL_WAVE | TEXT_WAVE)
	TC_WaveMajorTypeString_Check("NORMAL_WAVE, DATAFOLDER_WAVE", NORMAL_WAVE | DATAFOLDER_WAVE)
	TC_WaveMajorTypeString_Check("NORMAL_WAVE, WAVE_WAVE", NORMAL_WAVE | WAVE_WAVE)

	// free waves
	TC_WaveMajorTypeString_Check("NULL_WAVE", FREE_WAVE | NULL_WAVE)
	TC_WaveMajorTypeString_Check("FREE_WAVE, NUMERIC_WAVE", FREE_WAVE | NUMERIC_WAVE)
	TC_WaveMajorTypeString_Check("FREE_WAVE, TEXT_WAVE", FREE_WAVE | TEXT_WAVE)
	TC_WaveMajorTypeString_Check("FREE_WAVE, DATAFOLDER_WAVE", FREE_WAVE | DATAFOLDER_WAVE)
	TC_WaveMajorTypeString_Check("FREE_WAVE, WAVE_WAVE", FREE_WAVE | WAVE_WAVE)
End

static Function TC_WaveMajorTypeString_Check(expected, type)
	string expected
	variable type

	string str

	str = UTF_Checks#GetWaveMajorTypeString(type)
	CHECK_EQUAL_STR(expected, str)
End

static Function TC_WaveMinorTypeString()
	// just the constants
	TC_WaveMinorTypeString_Check("NON_NUMERIC_WAVE", NON_NUMERIC_WAVE)
	TC_WaveMinorTypeString_Check("COMPLEX_WAVE", COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("FLOAT_WAVE", FLOAT_WAVE)
	TC_WaveMinorTypeString_Check("DOUBLE_WAVE", DOUBLE_WAVE)
	TC_WaveMinorTypeString_Check("INT8_WAVE", INT8_WAVE)
	TC_WaveMinorTypeString_Check("INT16_WAVE", INT16_WAVE)
	TC_WaveMinorTypeString_Check("INT32_WAVE", INT32_WAVE)
	TC_WaveMinorTypeString_Check("INT64_WAVE", INT64_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE", UNSIGNED_WAVE)

	// unsigned waves
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT8_WAVE",  UNSIGNED_WAVE | INT8_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT16_WAVE", UNSIGNED_WAVE | INT16_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT32_WAVE", UNSIGNED_WAVE | INT32_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT64_WAVE", UNSIGNED_WAVE | INT64_WAVE)

	// complex waves
	TC_WaveMinorTypeString_Check("FLOAT_WAVE, COMPLEX_WAVE", FLOAT_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("DOUBLE_WAVE, COMPLEX_WAVE", DOUBLE_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("INT8_WAVE, COMPLEX_WAVE", INT8_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("INT16_WAVE, COMPLEX_WAVE", INT16_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("INT32_WAVE, COMPLEX_WAVE", INT32_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("INT64_WAVE, COMPLEX_WAVE", INT64_WAVE | COMPLEX_WAVE)

	// unsigned complex waves
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT8_WAVE, COMPLEX_WAVE", UNSIGNED_WAVE | INT8_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT16_WAVE, COMPLEX_WAVE", UNSIGNED_WAVE | INT16_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT32_WAVE, COMPLEX_WAVE", UNSIGNED_WAVE | INT32_WAVE | COMPLEX_WAVE)
	TC_WaveMinorTypeString_Check("UNSIGNED_WAVE, INT64_WAVE, COMPLEX_WAVE", UNSIGNED_WAVE | INT64_WAVE | COMPLEX_WAVE)
End

static Function TC_WaveMinorTypeString_Check(expected, type)
	string expected
	variable type

	string str

	str = UTF_Checks#GetWaveMinorTypeString(type)
	CHECK_EQUAL_STR(expected, str)
End

// UTF_EXPECTED_FAILURE
static Function TC_BreaksHard()

	Make/FREE/T wv1 = {"a"}
	Make/FREE/T wv2 = {"A"}

	CHECK_EQUAL_WAVES(wv1, wv2)
End

static Function TC_WaveName()
	string dfr, str, expect

	dfr = GetDataFolder(1)

	str = UTF_Utils#GetWaveNameInDFStr($"")
	expect = "_null_"
	CHECK_EQUAL_STR(expect, str)

	Make namedDFWave
	str = UTF_Utils#GetWaveNameInDFStr(namedDFWave)
	expect = "namedDFWave in " + dfr
	CHECK_EQUAL_STR(expect, str)

	Make/FREE unnamedFreeWave
	str = UTF_UTILS#GetWaveNameInDFStr(unnamedFreeWave)
	CHECK(GrepString(str, "^_free_ \\(0x[0-9a-f]+\\)$"))

#if IgorVersion() >= 9.0
	Make/FREE=1 namedFreeWave
	str = UTF_Utils#GetWaveNameInDFStr(namedFreeWave)
	CHECK(GrepString(str, "^namedFreeWave \\(0x[0-9a-f]+\\)$"))
#endif

End

static Function TC_WaveCapacity()
	variable size

	INFO("test small waves")
	Make/FREE/N=50 wv
	UTF_Basics#EnsureLargeEnoughWaveSimple(wv, 100)
	size = DimSize(wv, UTF_ROW)
	CHECK_EQUAL_VAR(IUTF_WAVECHUNK_SIZE, size)

	INFO("test small increment")
	MAKE/FREE/N=(IUTF_WAVECHUNK_SIZE * 2) wv
	UTF_Basics#EnsureLargeEnoughWaveSimple(wv, IUTF_WAVECHUNK_SIZE * 2)
	size = DimSize(wv, UTF_ROW)
	CHECK_EQUAL_VAR(IUTF_WAVECHUNK_SIZE * 4, size)

	INFO("test big jump")
	MAKE/FREE/N=(IUTF_WAVECHUNK_SIZE) wv
	UTF_Basics#EnsureLargeEnoughWaveSimple(wv, IUTF_WAVECHUNK_SIZE * 16 - 1)
	size = DimSize(wv, UTF_ROW)
	CHECK_EQUAL_VAR(IUTF_WAVECHUNK_SIZE * 16, size)

	// I am sorry for breaking your test setup
	INFO("test heavy load")
	MAKE/FREE/N=(IUTF_BIGWAVECHUNK_SIZE) wv
	UTF_Basics#EnsureLargeEnoughWaveSimple(wv, IUTF_BIGWAVECHUNK_SIZE * 2 + 1)
	size = DimSize(wv, UTF_ROW)
	CHECK_EQUAL_VAR(IUTF_BIGWAVECHUNK_SIZE * 3, size)
End

static Function TEST_SUITE_END_OVERRIDE(name)
	string name

	NVAR/Z cc = root:dgenCallCount
	KillVariables/Z cc
End
