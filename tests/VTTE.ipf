#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=UTF_Tests


/// VTTE is short for "Very Tiny Test Environment" and is a testing framework
/// for our testing framework. It has only one assertion, and aborts if the
/// first argument is false.

static Constant STRONG_CLOSENESS = 1
static Constant WEAK_CLOSENESS   = 0

static Constant ALL_MODES = 0xFFFF

static Function Ensure(var, [quiet])
	variable var, quiet

	quiet = ParamIsDefault(quiet) ? 0 : quiet

	if(!(abs(var) > 0))
		if(!quiet)
			printf "Ensure failed with stacktrace: %s\r", GetRTStackInfo(3)
		endif
		Abort
	endif
End

// One test case for everyting
// This is done so that we don't rely on the IUTF test case discovery logic to work.
static Function TestIUTF()
	variable err
	string str

	PASS()

	// test VTEE's Ensure
	Ensure(1)
	Ensure(1e-14)
	Ensure(inf)
	Ensure(-1)
	Ensure(-1e-14)
	Ensure(-inf)

	try
		Ensure(NaN, quiet = 1); AbortOnRTE
		FAIL()
	catch
		PASS()
	endtry

	try
		Ensure(0, quiet = 1); AbortOnRTE
		FAIL()
	catch
		PASS()
	endtry

	// IsDataFolderEmpty
	// @{

	// empty CDF
	Ensure(IUTF_Checks#IsDataFolderEmpty(""))
	Ensure(IUTF_Checks#IsDataFolderEmpty(":"))

	// empty
	NewDataFolder test1
	Ensure(IUTF_Checks#IsDataFolderEmpty("test1"))

	// wave
	NewDataFolder/O test2
	DFREF dfr = test2
	Make dfr:data
	Ensure(!IUTF_Checks#IsDataFolderEmpty("test2"))

	// datafolder
	NewDataFolder/O test3
	DFREF dfr = test3
	NewDataFolder/O dfr:data
	Ensure(!IUTF_Checks#IsDataFolderEmpty("test3"))

	// variable
	NewDataFolder/O test4
	DFREF dfr = test4
	variable/G dfr:var
	Ensure(!IUTF_Checks#IsDataFolderEmpty("test4"))

	// string
	NewDataFolder/O test5
	DFREF dfr = test5
	string/G dfr:globalstr
	Ensure(!IUTF_Checks#IsDataFolderEmpty("test5"))
	// @}

	NewDataFolder/O/S test6

	CHECK_EMPTY_FOLDER()

	// IsTrue
	// @{
	Ensure(IUTF_Checks#IsTrue(1))
	Ensure(IUTF_Checks#IsTrue(-1))
	Ensure(IUTF_Checks#IsTrue(1e-15))
	Ensure(IUTF_Checks#IsTrue(inf))
	Ensure(IUTF_Checks#IsTrue(-inf))
	Ensure(!IUTF_Checks#IsTrue(NaN))
	Ensure(!IUTF_Checks#IsTrue(0))
	// @}

	CHECK(1)

	// IsNullString
	// @{
	string properstr = "abcd"
	string nullstr, randomstr, anotherrandomstr
	string emptystr = ""
	Ensure(IUTF_Checks#IsNullString(nullstr))
	Ensure(!IUTF_Checks#IsNullString(emptystr))
	Ensure(!IUTF_Checks#IsNullString(properstr))
	randomstr = PadString("", 1, 0) // string with only \0
	Ensure(!IUTF_Checks#IsNullString(randomstr))
	// @}

	CHECK_NULL_STR(nullstr)

	CHECK_NON_NULL_STR(emptystr)

	// IsEmptyString
	// @{
	Ensure(!IUTF_Checks#IsEmptyString(nullstr))
	Ensure(IUTF_Checks#IsEmptyString(emptystr))
	Ensure(!IUTF_Checks#IsEmptyString(properstr))
	randomstr = PadString("", 1, 0) // string with only \0
	// even only a \0 char does not make the string empty
	Ensure(!IUTF_Checks#IsEmptyString(randomstr))
	// @}

	CHECK_EMPTY_STR(emptystr)

	CHECK_NON_EMPTY_STR(properstr)
	CHECK_NON_EMPTY_STR(nullstr)

	// IsProperString
	// @{
	Ensure(IUTF_Checks#IsProperString(properstr))
	Ensure(!IUTF_Checks#IsProperString(emptystr))
	Ensure(!IUTF_Checks#IsProperString(nullstr))
	// @}

	CHECK_PROPER_STR(properstr)

	// AreStringsEqual
	// @{
	Ensure(!IUTF_Checks#AreStringsEqual(properstr, emptystr, 0))
	Ensure(!IUTF_Checks#AreStringsEqual(properstr, emptystr, 1))
	Ensure(!IUTF_Checks#AreStringsEqual(properstr, emptystr, NaN))
	Ensure(!IUTF_Checks#AreStringsEqual(properstr, nullstr, 0))
	Ensure(!IUTF_Checks#AreStringsEqual(properstr, nullstr, 1))
	Ensure(!IUTF_Checks#AreStringsEqual(properstr, nullstr, NaN))
	Ensure(IUTF_Checks#AreStringsEqual(emptystr, emptystr, 0))
	Ensure(IUTF_Checks#AreStringsEqual(emptystr, emptystr, 1))
	Ensure(IUTF_Checks#AreStringsEqual(emptystr, emptystr, NaN))
	Ensure(IUTF_Checks#AreStringsEqual(nullstr, nullstr, 0))
	Ensure(IUTF_Checks#AreStringsEqual(nullstr, nullstr, 1))
	Ensure(IUTF_Checks#AreStringsEqual(nullstr, nullstr, NaN))

	Ensure(IUTF_Checks#AreStringsEqual(properstr, properstr, 0))
	Ensure(IUTF_Checks#AreStringsEqual(properstr, properstr, 1))
	Ensure(IUTF_Checks#AreStringsEqual(properstr, properstr, NaN))

	randomstr = "abcd"
	anotherrandomstr = "ABCD"
	Ensure(IUTF_Checks#AreStringsEqual(randomstr, anotherrandomstr, 0))
	Ensure(!IUTF_Checks#AreStringsEqual(randomstr, anotherrandomstr, 1))
	Ensure(!IUTF_Checks#AreStringsEqual(randomstr, anotherrandomstr, NaN))
	// @}

	CHECK_EQUAL_STR(randomstr, randomstr)
	CHECK_EQUAL_STR(randomstr, randomstr, case_sensitive = 1)

	// AreVariablesEqual
	// @{
	Ensure(IUTF_Checks#AreVariablesEqual(0, 0))
	Ensure(IUTF_Checks#AreVariablesEqual(0, -0))
	Ensure(IUTF_Checks#AreVariablesEqual(1, 1))
	Ensure(IUTF_Checks#AreVariablesEqual(inf, inf))
	Ensure(IUTF_Checks#AreVariablesEqual(-inf, -inf))
	Ensure(!IUTF_Checks#AreVariablesEqual(-inf, inf))
	Ensure(IUTF_Checks#AreVariablesEqual(NaN, NaN))
	Ensure(IUTF_Checks#AreVariablesEqual(1, 1 + 1e-16))
	Ensure(!IUTF_Checks#AreVariablesEqual(1, 1 + 1e-15))
	// @}

	CHECK_EQUAL_VAR(1, 1)
	CHECK_NEQ_VAR(1, 0)

	// IsLessOrEqual
	// @{
	Ensure(IUTF_Checks#IsLessOrEqual(0, 0))
	Ensure(IUTF_Checks#IsLessOrEqual(0, -0))
	Ensure(IUTF_Checks#IsLessOrEqual(0, 0.1))
	Ensure(IUTF_Checks#IsLessOrEqual(inf, inf))
	Ensure(IUTF_Checks#IsLessOrEqual(-inf, -inf))
	Ensure(IUTF_Checks#IsLessOrEqual(-inf, inf))
	Ensure(!IUTF_Checks#IsLessOrEqual(inf, -inf))
	Ensure(IUTF_Checks#IsLessOrEqual(NaN, NaN))
	Ensure(IUTF_Checks#IsLessOrEqual(1, 1 + 1e-16))
	Ensure(IUTF_Checks#IsLessOrEqual(1, 1 + 1e-15))
	// @}

	CHECK_LE_VAR(0, 1)
	CHECK_LE_VAR(0, 0)

	// Uses IsLessOrEqual internally
	CHECK_GE_VAR(1, 0)
	CHECK_GE_VAR(1, 1)

	// IsLess
	// @{
	Ensure(IUTF_Checks#IsLess(0, 1))
	Ensure(!IUTF_Checks#IsLess(0, 0))
	Ensure(IUTF_Checks#IsLess(-1, 0))
	Ensure(!IUTF_Checks#IsLess(inf, inf))
	Ensure(!IUTF_Checks#IsLess(-inf, -inf))
	Ensure(IUTF_Checks#IsLess(-inf, inf))
	Ensure(!IUTF_Checks#IsLess(inf, -inf))
	Ensure(!IUTF_Checks#IsLess(NaN, NaN))
	Ensure(!IUTF_Checks#IsLess(1, 1 + 1e-16))
	Ensure(IUTF_Checks#IsLess(1, 1 + 1e-15))
	// @}

	CHECK_LT_VAR(0, 1)
	CHECK_LT_VAR(-1, 0)

	// Uses IsLess internally
	CHECK_GT_VAR(1, 0)
	CHECK_GT_VAR(0, -1)

	// IsVariableSmall
	// @{
	Ensure(IUTF_Checks#IsVariableSmall(0, DEFAULT_TOLERANCE))
	Ensure(!IUTF_Checks#IsVariableSmall(Inf, DEFAULT_TOLERANCE))
	Ensure(!IUTF_Checks#IsVariableSmall(-Inf, DEFAULT_TOLERANCE))
	Ensure(!IUTF_Checks#IsVariableSmall(NaN, DEFAULT_TOLERANCE))
	Ensure(IUTF_Checks#IsVariableSmall(DEFAULT_TOLERANCE - 1e-15, DEFAULT_TOLERANCE))
	Ensure(!IUTF_Checks#IsVariableSmall(-(DEFAULT_TOLERANCE + 1e-15), DEFAULT_TOLERANCE))
	Ensure(!IUTF_Checks#IsVariableSmall(DEFAULT_TOLERANCE + 1e-15, DEFAULT_TOLERANCE))
	Ensure(!IUTF_Checks#IsVariableSmall(-(DEFAULT_TOLERANCE + 1e-15), DEFAULT_TOLERANCE))
	Ensure(IUTF_Checks#IsVariableSmall(0, 0))
	Ensure(IUTF_Checks#IsVariableSmall(1, 1))
	// @}

	CHECK_SMALL_VAR(DEFAULT_TOLERANCE - 1e-15)
	CHECK_SMALL_CMPLX(cmplx(0, DEFAULT_TOLERANCE - 1e-15))
	CHECK_SMALL_CMPLX(cmplx(DEFAULT_TOLERANCE - 1e-15, 0))

	// AreVariablesClose
	// @{

	// equal
	Ensure(IUTF_Checks#AreVariablesClose(1, 1, 0, STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(1, 1, 0, WEAK_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(-1, -1, 0, STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(-1, -1, 0, WEAK_CLOSENESS))

	// not equal
	Ensure(!IUTF_Checks#AreVariablesClose(-1, 1, 0, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(-1, 1, 0, WEAK_CLOSENESS))

	// strong vs weak, custom tolerance
	Ensure(!IUTF_Checks#AreVariablesClose(1, 2, 0.5, STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(1, 2, 0.5, WEAK_CLOSENESS))

	// and it is symmetric
	Ensure(!IUTF_Checks#AreVariablesClose(2, 1, 0.5, STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(2, 1, 0.5, WEAK_CLOSENESS))

	// strong vs weak, default tolerance
	Ensure(IUTF_Checks#AreVariablesClose(1e-8, 1e-8 + 1e-16, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1e-8, 1e-8 + 1e-16, DEFAULT_TOLERANCE, STRONG_CLOSENESS))

	Ensure(!IUTF_Checks#AreVariablesClose(NaN, 1, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(NaN, 1, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1, NaN, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1, NaN, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(Inf, 1, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(Inf, 1, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1, Inf, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1, Inf, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(-Inf, 1, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(-Inf, 1, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1, -Inf, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1, -Inf, DEFAULT_TOLERANCE, WEAK_CLOSENESS))

	// singularity (one of both sides is zero)
	Ensure(IUTF_Checks#AreVariablesClose( 0,   0.5, 1,    STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose( 0,   0.5, 1,    WEAK_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose( 0.5, 0,   1,    STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose( 0.5, 0,   1,    WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0,   0.5, 0.25, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0,   0.5, 0.25, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0.5, 0,   0.25, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0.5, 0,   0.25, WEAK_CLOSENESS))

	Ensure(!IUTF_Checks#AreVariablesClose(NaN, 0, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(NaN, 0, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, NaN, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, NaN, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(Inf, 0, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(Inf, 0, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, Inf, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, Inf, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(-Inf, 0, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(-Inf, 0, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, -Inf, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, -Inf, DEFAULT_TOLERANCE, STRONG_CLOSENESS))

	Ensure(IUTF_Checks#AreVariablesClose(0, 0, 0, WEAK_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(0, 0, 0, STRONG_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(0, 1e-308, 0, WEAK_CLOSENESS))
	Ensure(!IUTF_Checks#AreVariablesClose(1e-308, 0, 0, STRONG_CLOSENESS))

	Ensure(IUTF_Checks#AreVariablesClose(0, 1, 1, WEAK_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(0, 1, 1, STRONG_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(1, 0, 1, WEAK_CLOSENESS))
	Ensure(IUTF_Checks#AreVariablesClose(1, 0, 1, STRONG_CLOSENESS))
	// @}

	// CHECK_CLOSE
	// @{
	CHECK_CLOSE_VAR(1e-8, 1e-8 + 1e-17, strong=1)
	CHECK_CLOSE_VAR(1e-8, 1e-8 + 1e-17, strong=0)

	CHECK_CLOSE_VAR(1, 2, tol = 1, strong=1)
	CHECK_CLOSE_VAR(1, 2, tol = 1, strong=0)
	// @}

	// CHECK_CLOSE_CMPLX
	// @{

	CHECK_CLOSE_CMPLX(cmplx(1e-8, 1e-8), cmplx(1e-8 + 1e-17, 1e-8 + 1e-17), strong=STRONG_CLOSENESS)
	CHECK_CLOSE_CMPLX(cmplx(1e-8, 1e-8), cmplx(1e-8 + 1e-17, 1e-8 + 1e-17), strong=WEAK_CLOSENESS)

	CHECK_CLOSE_CMPLX(cmplx(1, 1), cmplx(2, 2), tol = 1, strong=STRONG_CLOSENESS)
	CHECK_CLOSE_CMPLX(cmplx(1, 1), cmplx(2, 2), tol = 1, strong=WEAK_CLOSENESS)
	// @}

	// AreWavesEqual
	// @{
	string detailedMsg
	Make/FREE numData1, numData2
	// Null Waves are checked in the wrapper, call to test that no RTE comes up
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER($"", $"", !OUTPUT_MESSAGE)
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(numData1, $"", !OUTPUT_MESSAGE)
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER($"", numData2, !OUTPUT_MESSAGE)
	// equal waves
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(numData1, numData1, !OUTPUT_MESSAGE)
	// different type zero sized waves
	Make/FREE/N=0/D wNumType1
	Make/FREE/N=0/I wNumType2
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wNumType1, wNumType2, !OUTPUT_MESSAGE)
	// different basic type waves
	Make/FREE/N=1/D wNumType1
	Make/FREE/WAVE wWRrefType = {wNumType1}
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wNumType1, wWRrefType, !OUTPUT_MESSAGE)

	Ensure(IUTF_Checks#AreWavesEqual(numData1, numData2, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)
	Ensure(IUTF_Checks#AreWavesEqual(numData1, numData2, ALL_MODES, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)

	Make/FREE/T textData1, textData2
	Ensure(IUTF_Checks#AreWavesEqual(textData1, textData2, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)
	// all modes
	Ensure(IUTF_Checks#AreWavesEqual(textData1, textData2, ALL_MODES, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)
	// If the following invalid tol or mode is improperly checked the function fails with an uncaught RTE
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, !OUTPUT_MESSAGE, mode = WAVE_DATA, tol = NaN)
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, !OUTPUT_MESSAGE, mode = WAVE_DATA, tol = -1)
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, !OUTPUT_MESSAGE, mode = NaN, tol = DEFAULT_TOLERANCE)
	IUTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, !OUTPUT_MESSAGE, mode = 0x10000000, tol = DEFAULT_TOLERANCE)
	// @}

	// AreWavesEqual
	// @{
	CHECK_EQUAL_WAVES(numData1, numData2, mode = ALL_MODES, tol = 0)
	CHECK_EQUAL_TEXTWAVES(textData1, textData2, mode = ALL_MODES)
	// @}

	// AreWavesEqual
	// @{
	Make/FREE/N=0 wvSP
	Make/FREE/D/N=0 wvDP
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_DATA_TYPE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_SCALING, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DATA_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DIMENSION_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DIMENSION_LABELS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_NOTE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_LOCK_STATE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DATA_FULL_SCALE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DIMENSION_SIZES, DEFAULT_TOLERANCE, detailedMsg))

	Make/FREE/N=0 wvSP
	Make/FREE/D/N=1 wvDP
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_DATA_TYPE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_SCALING, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DATA_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, DIMENSION_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, DIMENSION_LABELS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_NOTE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, WAVE_LOCK_STATE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvDP, DATA_FULL_SCALE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvDP, DIMENSION_SIZES, DEFAULT_TOLERANCE, detailedMsg))

	Make/FREE/N=0 wvSP
	Make/FREE/N=0/T wvTEXT
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_DATA_TYPE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_SCALING, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DATA_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DIMENSION_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DIMENSION_LABELS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_NOTE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_LOCK_STATE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DATA_FULL_SCALE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DIMENSION_SIZES, DEFAULT_TOLERANCE, detailedMsg))

	Make/FREE/N=(4,3,2,1) wvSP
	Make/FREE/N=(4,3,2,1)/T wvTEXT
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_DATA_TYPE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_SCALING, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DATA_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DIMENSION_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DIMENSION_LABELS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_NOTE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, WAVE_LOCK_STATE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DATA_FULL_SCALE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(IUTF_Checks#AreWavesEqual(wvSP, wvTEXT, DIMENSION_SIZES, DEFAULT_TOLERANCE, detailedMsg))

	SetScale d, 1, 2, "dataUnitSP", wvSP
	SetScale d, 3, 4, "dataUnitDP", wvDP
	Note/K wvSP, "waveNoteSP"
	Note/K wvDP, "waveNoteDP"
	SetWaveLock 1, wvSP
	SetWaveLock 0, wvDP
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, WAVE_DATA_TYPE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, WAVE_SCALING, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, DATA_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, DIMENSION_UNITS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, DIMENSION_LABELS, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, WAVE_NOTE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, WAVE_LOCK_STATE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, DATA_FULL_SCALE, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!IUTF_Checks#AreWavesEqual(wvDP, wvSP, DIMENSION_SIZES, DEFAULT_TOLERANCE, detailedMsg))
	// @}

	// HasWaveMajorType
	// @{

	Ensure(IUTF_Checks#HasWaveMajorType($"", NULL_WAVE))

	Make/FREE wv
	Ensure(IUTF_Checks#HasWaveMajorType(wv, FREE_WAVE | NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wv, NORMAL_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wv, TEXT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wv, DATAFOLDER_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wv, WAVE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wv, NULL_WAVE))

	Make/O/T wvText
	Ensure(!IUTF_Checks#HasWaveMajorType(wvText, FREE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvText, NUMERIC_WAVE))
	Ensure(IUTF_Checks#HasWaveMajorType(wvText, NORMAL_WAVE | TEXT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvText, DATAFOLDER_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvText, WAVE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvText, NULL_WAVE))

	Make/FREE/DF wvDFR
	Ensure(IUTF_Checks#HasWaveMajorType(wvDFR, FREE_WAVE | DATAFOLDER_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvDFR, NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvDFR, NORMAL_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvDFR, TEXT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvDFR, WAVE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvDFR, NULL_WAVE))

	Make/FREE/Wave wvWave
	Ensure(IUTF_Checks#HasWaveMajorType(wvWave, FREE_WAVE | WAVE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvWave, NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvWave, NORMAL_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvWave, TEXT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvWave, DATAFOLDER_WAVE))
	Ensure(!IUTF_Checks#HasWaveMajorType(wvWave, NULL_WAVE))

	// @}

	// HasWaveMinorType
	// @{

	Ensure(IUTF_Checks#HasWaveMinorType($"", NULL_WAVE))

	Make/FREE/D wvDouble
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, NON_NUMERIC_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvDouble,  DOUBLE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, FLOAT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

	Make/FREE/W wvInt16
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, NON_NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16,  DOUBLE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, FLOAT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

	Make/FREE/W/U wvUInt16
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, NON_NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16,  DOUBLE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, FLOAT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

	Make/FREE/W/U/C wvUInt16Complex
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, NON_NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, DOUBLE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, FLOAT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE   | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

#if IgorVersion() >= 7.0

	Make/FREE/L/U wvUint64
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, NON_NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, DOUBLE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, FLOAT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(IUTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

#endif

	Make/FREE/T wvText
	Ensure(IUTF_CHECKS#HasWaveMinorType(wvText, NON_NUMERIC_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, DOUBLE_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, FLOAT_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT8_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT16_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT32_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT64_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT64_WAVE   | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!IUTF_Checks#HasWaveMinorType(wvText, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

#if IgorVersion() >= 7.0

	int64 i64zero     = 0
	int64 i64one      = 1
	int64 i64big      = 0x7FFFFFFFFFFFFFFE
	int64 i64biggest  = 0x7FFFFFFFFFFFFFFF
	int64 i64minustwo = 0xFFFFFFFFFFFFFFFE
	int64 i64minusone = 0xFFFFFFFFFFFFFFFF
	Ensure(IUTF_Checks#AreINT64Equal(i64zero, i64zero))
	Ensure(IUTF_Checks#AreINT64Equal(i64big, i64big))
	Ensure(IUTF_Checks#AreINT64Equal(i64minusone, i64minusone))
	Ensure(!IUTF_Checks#AreINT64Equal(i64minusone, i64minustwo))
	Ensure(!IUTF_Checks#AreINT64Equal(i64zero, i64one))
	Ensure(!IUTF_Checks#AreINT64Equal(i64big, i64biggest))
	Ensure(!IUTF_Checks#AreINT64Equal(i64one, i64biggest))
	Ensure(IUTF_Checks#AreINT64Close(i64zero, i64one, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#AreINT64Close(i64big, i64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(!IUTF_Checks#AreINT64Close(i64one, i64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#AreINT64Close(i64zero, i64minusone, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#AreINT64Close(i64minustwo, i64minusone, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#AreINT64Close(i64one, i64biggest, i64biggest))
	Ensure(!IUTF_Checks#AreINT64Close(i64big, i64biggest, i64zero))
	Ensure(IUTF_Checks#IsINT64Small(i64zero, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#IsINT64Small(i64one, DEFAULT_TOLERANCE_INT))
	Ensure(!IUTF_Checks#IsINT64Small(i64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#IsINT64Small(i64minustwo, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#IsINT64Small(i64big, i64Biggest))
	Ensure(!IUTF_Checks#IsINT64Small(i64one, i64zero))
	Ensure(IUTF_Checks#IsINT64Small(i64one, i64minustwo))

	uint64 ui64zero     = 0
	uint64 ui64one      = 1
	uint64 ui64big      = 0xFFFFFFFFFFFFFFFE
	uint64 ui64biggest  = 0xFFFFFFFFFFFFFFFF
	Ensure(IUTF_Checks#AreUINT64Equal(ui64zero, ui64zero))
	Ensure(IUTF_Checks#AreUINT64Equal(ui64big, ui64big))
	Ensure(!IUTF_Checks#AreUINT64Equal(ui64zero, ui64one))
	Ensure(!IUTF_Checks#AreUINT64Equal(ui64big, ui64biggest))
	Ensure(!IUTF_Checks#AreUINT64Equal(ui64one, ui64biggest))
	Ensure(IUTF_Checks#AreUINT64Close(ui64zero, ui64one, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#AreUINT64Close(ui64big, ui64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(!IUTF_Checks#AreUINT64Close(ui64one, ui64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#AreUINT64Close(ui64one, ui64biggest, ui64biggest))
	Ensure(!IUTF_Checks#AreUINT64Close(ui64big, ui64biggest, ui64zero))
	Ensure(IUTF_Checks#IsUINT64Small(ui64zero, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#IsUINT64Small(ui64one, DEFAULT_TOLERANCE_INT))
	Ensure(!IUTF_Checks#IsUINT64Small(ui64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(IUTF_Checks#IsUINT64Small(ui64big, ui64Biggest))
	Ensure(!IUTF_Checks#IsUINT64Small(ui64one, ui64zero))

#endif

	// @}

	// CHECK_WAVE
	// @{

	CHECK_WAVE($"", NULL_WAVE)
	CHECK_WAVE({0}, NUMERIC_WAVE, minorType = FLOAT_WAVE)

	// @}

	// HasRTE/HasAnyRTE
	// @{
	WAVE/Z nullWave = $""
	nullWave[0] = 0
	Ensure(!IUTF_Checks#HasRTE(0))
	Ensure(IUTF_Checks#HasRTE(330))
	Ensure(!IUTF_Checks#HasRTE(185))
	Ensure(IUTF_Checks#HasAnyRTE())
	err = GetRTError(1)

	str = nullstr[0]
	Ensure(!IUTF_Checks#HasRTE(0))
	Ensure(!IUTF_Checks#HasRTE(330))
	Ensure(IUTF_Checks#HasRTE(185))
	Ensure(IUTF_Checks#HasAnyRTE())
	err = GetRTError(1)

	Ensure(IUTF_Checks#HasRTE(0))
	Ensure(!IUTF_Checks#HasRTE(330))
	Ensure(!IUTF_Checks#HasRTE(185))
	Ensure(!IUTF_Checks#HasAnyRTE())
	// @}

	// CHECK_RTE, CHECK_ANY_RTE, CHECK_NO_RTE
	// @{
	CHECK_NO_RTE()

	nullWave[0] = 0
	CHECK_RTE(330)
	Ensure(!GetRTError(1))

	str = nullstr[0]
	CHECK_RTE(185)
	Ensure(!GetRTError(1))

	nullWave[0] = 0
	CHECK_ANY_RTE()
	Ensure(!GetRTError(1))

	str = nullstr[0]
	CHECK_ANY_RTE()
	Ensure(!GetRTError(1))

	CHECK_NO_RTE()
	// @}

	// UserPrintF
	// @{

	Make/FREE/N=0/T emptyText
	Make/FREE/N=0 emptyVars
	Ensure(CheckUserPrintF("", "", emptyText, emptyVars))
	Ensure(CheckUserPrintF("abc", "abc", emptyText, emptyVars))
	Ensure(CheckUserPrintF("a%f", "a%%f", emptyText, emptyVars))
	Ensure(!CheckUserPrintF("", "%s", emptyText, emptyVars, onlyErr=1))
	Ensure(!CheckUserPrintF("", "%d", emptyText, emptyVars, onlyErr=1))

	Ensure(CheckUserPrintF("a foo b", "a %s b", { "foo" }, emptyVars))
	Ensure(CheckUserPrintF("a foo bbarc", "a %s b%sc", { "foo", "bar" }, emptyVars))
	Ensure(CheckUserPrintF("a {foo, bar} b", "a @%s b", { "foo", "bar" }, emptyVars))
	Ensure(CheckUserPrintF("a @{foo} b", "a @@%s b", { "foo" }, emptyVars))
	Ensure(CheckUserPrintF("a @@ foo b", "a @@ %s b", { "foo" }, emptyVars))
	Ensure(!CheckUserPrintF("", "%s %s", { "foo" }, emptyVars, onlyErr=1))

	Ensure(CheckUserPrintF("a 1 b", "a %d b", emptyText, { 1 }))
	Ensure(CheckUserPrintF("a 1 b2c", "a %d b%dc", emptyText, { 1, 2 }))
	Ensure(CheckUserPrintF("a {1, 2} b", "a @%d b", emptyText, { 1, 2 }))
	Ensure(CheckUserPrintF("a @{1} b", "a @@%d b", emptyText, { 1 }))
	Ensure(CheckUserPrintF("a @@ 1 b", "a @@ %d b", emptyText, { 1 }))
	Ensure(!CheckUserPrintF("", "%d %d", emptyText, { 1 }, onlyErr=1))

	Ensure(CheckUserPrintF("foo 2", "%s %d", { "foo" }, { 2 }))
	Ensure(CheckUserPrintF("2 foo", "%d %s", { "foo" }, { 2 }))
	Ensure(CheckUserPrintF("foo bar 2", "%s %s %d", { "foo", "bar" }, { 2 }))
	Ensure(CheckUserPrintF("foo 2 bar", "%s %d %s", { "foo", "bar" }, { 2 }))
	Ensure(CheckUserPrintF("2 foo bar", "%d %s %s", { "foo", "bar" }, { 2 }))
	Ensure(CheckUserPrintF("2 3 foo", "%d %d %s", { "foo" }, { 2, 3 }))
	Ensure(CheckUserPrintF("2 foo 3", "%d %s %d", { "foo" }, { 2, 3 }))
	Ensure(CheckUserPrintF("foo 2 3", "%s %d %d", { "foo" }, { 2, 3 }))

	Ensure(CheckUserPrintF("foo {2}", "%s @%d", { "foo" }, { 2 }))
	Ensure(CheckUserPrintF("{foo} 2", "@%s %d", { "foo" }, { 2 }))
	Ensure(CheckUserPrintF("{foo} {2}", "@%s @%d", { "foo" }, { 2 }))

	Ensure(CheckUserPrintF("1.235", "%.3f", emptyText, { 1.23456789 }))
	Ensure(CheckUserPrintF("1.234568", "%.6f", emptyText, { 1.23456789 }))
	Ensure(CheckUserPrintF("1.0MHz", "%.1W0PHz", emptyText, { 1e6 }))

#if IgorVersion() > 8.00
	Ensure(!CheckUserPrintF("", "%~d", emptyText, { 1 }, onlyErr=1))
	Ensure(!CheckUserPrintF("", "%~", emptyText, emptyVars, onlyErr=1))
#else
	Ensure(CheckUserPrintF("~lld", "%~d", emptyText, { 1 }))
#endif
	Ensure(!CheckUserPrintF("", "@%%d", emptyText, { 1 }, onlyErr=1))

	WAVE/Z nullWave = $""
	variable val = nullWave[0]
	Ensure(!CheckUserPrintF("", "", emptyText, emptyVars, onlyErr=1))
	err = GetRTError(1)

	// @}

End

static Function TestIUTFSetup()

	// TestCaseNameNotation
	// @{

	variable tmpVar1
	string thisProcName, tmpStr
	thisProcName = ParseFilePath(0, FunctionPath("TestCaseNameTest2"), ":", 1, 0)
	Ensure(IUTF_Basics#CreateTestRunSetup(thisProcName, ".*", 1, tmpStr, 0, IUTF_DEBUG_DISABLE, 0) == 0)
	WAVE/T testRunData = IUTF_Basics#GetTestRunData()
	tmpVar1 = FindDimLabel(testRunData, UTF_COLUMN, "TESTCASE")
	Duplicate/FREE/R=[][tmpVar1, tmpVar1] testRunData, tcCol
	FindValue/TXOP=4/TEXT="UTF_Tests#TestCaseNameTest1" tcCol
	Ensure(V_value >= 0)
	FindValue/TXOP=4/TEXT="TestCaseNameTest2" tcCol
	Ensure(V_value >= 0)

	// @}

	PASS()
End

static Function CheckUserPrintF(expected, format, strings, numbers, [onlyErr])
	string expected, format
	WAVE/T strings
	WAVE numbers
	variable onlyErr

	string result
	variable err

	onlyErr = ParamIsDefault(onlyErr) ? 0 : !!onlyErr

	result = IUTF_Utils_Strings#UserPrintF(format, strings, numbers, err)
	if(onlyErr)
		return !err
	else
		return !err && !CmpStr(expected, result)
	endif
End

static Function TestCaseNameTest1()

	PASS()
End

Function TestCaseNameTest2()

	PASS()
End
