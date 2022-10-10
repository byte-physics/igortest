#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_Various

// Licensed under 3-Clause BSD, see License.txt

static Constant MMD_COMBO_COUNT = 32

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

static Function TEST_SUITE_END_OVERRIDE(name)
	string name

	NVAR/Z cc = root:dgenCallCount
	KillVariables/Z cc
End
