#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_Tests

// Licensed under 3-Clause BSD, see License.txt

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
// This is done so that we don't rely on the UTF test case discovery logic to work.
static Function TestUTF()
	variable err

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
	Ensure(UTF_Checks#IsDataFolderEmpty(""))
	Ensure(UTF_Checks#IsDataFolderEmpty(":"))

	// empty
	NewDataFolder test1
	Ensure(UTF_Checks#IsDataFolderEmpty("test1"))

	// wave
	NewDataFolder/O test2
	DFREF dfr = test2
	Make dfr:data
	Ensure(!UTF_Checks#IsDataFolderEmpty("test2"))

	// datafolder
	NewDataFolder/O test3
	DFREF dfr = test3
	NewDataFolder/O dfr:data
	Ensure(!UTF_Checks#IsDataFolderEmpty("test3"))

	// variable
	NewDataFolder/O test4
	DFREF dfr = test4
	variable/G dfr:var
	Ensure(!UTF_Checks#IsDataFolderEmpty("test4"))

	// string
	NewDataFolder/O test5
	DFREF dfr = test5
	string/G dfr:globalstr
	Ensure(!UTF_Checks#IsDataFolderEmpty("test5"))
	// @}

	NewDataFolder/O/S test6

	CHECK_EMPTY_FOLDER()

	// IsTrue
	// @{
	Ensure(UTF_Checks#IsTrue(1))
	Ensure(UTF_Checks#IsTrue(-1))
	Ensure(UTF_Checks#IsTrue(1e-15))
	Ensure(UTF_Checks#IsTrue(inf))
	Ensure(UTF_Checks#IsTrue(-inf))
	Ensure(!UTF_Checks#IsTrue(NaN))
	Ensure(!UTF_Checks#IsTrue(0))
	// @}

	CHECK(1)

	// IsNullString
	// @{
	string properstr = "abcd"
	string nullstr, randomstr, anotherrandomstr
	string emptystr = ""
	Ensure(UTF_Checks#IsNullString(nullstr))
	Ensure(!UTF_Checks#IsNullString(emptystr))
	Ensure(!UTF_Checks#IsNullString(properstr))
	randomstr = PadString("", 1, 0) // string with only \0
	Ensure(!UTF_Checks#IsNullString(randomstr))
	// @}

	CHECK_NULL_STR(nullstr)

	CHECK_NON_NULL_STR(emptystr)

	// IsEmptyString
	// @{
	Ensure(!UTF_Checks#IsEmptyString(nullstr))
	Ensure(UTF_Checks#IsEmptyString(emptystr))
	Ensure(!UTF_Checks#IsEmptyString(properstr))
	randomstr = PadString("", 1, 0) // string with only \0
	// even only a \0 char does not make the string empty
	Ensure(!UTF_Checks#IsEmptyString(randomstr))
	// @}

	CHECK_EMPTY_STR(emptystr)

	CHECK_NON_EMPTY_STR(properstr)
	CHECK_NON_EMPTY_STR(nullstr)

	// IsProperString
	// @{
	Ensure(UTF_Checks#IsProperString(properstr))
	Ensure(!UTF_Checks#IsProperString(emptystr))
	Ensure(!UTF_Checks#IsProperString(nullstr))
	// @}

	CHECK_PROPER_STR(properstr)

	// AreStringsEqual
	// @{
	Ensure(!UTF_Checks#AreStringsEqual(properstr, emptystr, 0))
	Ensure(!UTF_Checks#AreStringsEqual(properstr, emptystr, 1))
	Ensure(!UTF_Checks#AreStringsEqual(properstr, emptystr, NaN))
	Ensure(!UTF_Checks#AreStringsEqual(properstr, nullstr, 0))
	Ensure(!UTF_Checks#AreStringsEqual(properstr, nullstr, 1))
	Ensure(!UTF_Checks#AreStringsEqual(properstr, nullstr, NaN))
	Ensure(UTF_Checks#AreStringsEqual(emptystr, emptystr, 0))
	Ensure(UTF_Checks#AreStringsEqual(emptystr, emptystr, 1))
	Ensure(UTF_Checks#AreStringsEqual(emptystr, emptystr, NaN))
	Ensure(UTF_Checks#AreStringsEqual(nullstr, nullstr, 0))
	Ensure(UTF_Checks#AreStringsEqual(nullstr, nullstr, 1))
	Ensure(UTF_Checks#AreStringsEqual(nullstr, nullstr, NaN))

	Ensure(UTF_Checks#AreStringsEqual(properstr, properstr, 0))
	Ensure(UTF_Checks#AreStringsEqual(properstr, properstr, 1))
	Ensure(UTF_Checks#AreStringsEqual(properstr, properstr, NaN))

	randomstr = "abcd"
	anotherrandomstr = "ABCD"
	Ensure(UTF_Checks#AreStringsEqual(randomstr, anotherrandomstr, 0))
	Ensure(!UTF_Checks#AreStringsEqual(randomstr, anotherrandomstr, 1))
	Ensure(!UTF_Checks#AreStringsEqual(randomstr, anotherrandomstr, NaN))
	// @}

	CHECK_NEQ_STR(properstr, nullstr)

	CHECK_EQUAL_STR(randomstr, anotherrandomstr, case_sensitive = 0)
	CHECK_EQUAL_STR(randomstr, randomstr, case_sensitive = 1)

	// AreVariablesEqual
	// @{
	Ensure(UTF_Checks#AreVariablesEqual(0, 0))
	Ensure(UTF_Checks#AreVariablesEqual(1, 1))
	Ensure(UTF_Checks#AreVariablesEqual(inf, inf))
	Ensure(UTF_Checks#AreVariablesEqual(-inf, -inf))
	Ensure(!UTF_Checks#AreVariablesEqual(-inf, inf))
	Ensure(UTF_Checks#AreVariablesEqual(NaN, NaN))
	Ensure(UTF_Checks#AreVariablesEqual(1, 1 + 1e-16))
	Ensure(!UTF_Checks#AreVariablesEqual(1, 1 + 1e-15))
	// @}

	CHECK_EQUAL_VAR(1, 1)
	CHECK_NEQ_VAR(1, 0)

	// IsVariableSmall
	// @{
	Ensure(UTF_Checks#IsVariableSmall(0, DEFAULT_TOLERANCE))
	Ensure(!UTF_Checks#IsVariableSmall(Inf, DEFAULT_TOLERANCE))
	Ensure(!UTF_Checks#IsVariableSmall(-Inf, DEFAULT_TOLERANCE))
	Ensure(!UTF_Checks#IsVariableSmall(NaN, DEFAULT_TOLERANCE))
	Ensure(UTF_Checks#IsVariableSmall(DEFAULT_TOLERANCE - 1e-15, DEFAULT_TOLERANCE))
	Ensure(!UTF_Checks#IsVariableSmall(-(DEFAULT_TOLERANCE + 1e-15), DEFAULT_TOLERANCE))
	Ensure(!UTF_Checks#IsVariableSmall(DEFAULT_TOLERANCE + 1e-15, DEFAULT_TOLERANCE))
	Ensure(!UTF_Checks#IsVariableSmall(-(DEFAULT_TOLERANCE + 1e-15), DEFAULT_TOLERANCE))
	// @}

	CHECK_SMALL_VAR(DEFAULT_TOLERANCE - 1e-15)
	CHECK_SMALL_CMPLX(cmplx(0, DEFAULT_TOLERANCE - 1e-15))
	CHECK_SMALL_CMPLX(cmplx(DEFAULT_TOLERANCE - 1e-15, 0))

	// AreVariablesClose
	// @{

	// equal
	Ensure(UTF_Checks#AreVariablesClose(1, 1, 0, STRONG_CLOSENESS))
	Ensure(UTF_Checks#AreVariablesClose(1, 1, 0, WEAK_CLOSENESS))
	Ensure(UTF_Checks#AreVariablesClose(-1, -1, 0, STRONG_CLOSENESS))
	Ensure(UTF_Checks#AreVariablesClose(-1, -1, 0, WEAK_CLOSENESS))

	// not equal
	Ensure(!UTF_Checks#AreVariablesClose(-1, 1, 0, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(-1, 1, 0, WEAK_CLOSENESS))

	// strong vs weak, custom tolerance
	Ensure(!UTF_Checks#AreVariablesClose(1, 2, 0.5, STRONG_CLOSENESS))
	Ensure(UTF_Checks#AreVariablesClose(1, 2, 0.5, WEAK_CLOSENESS))

	// and it is symmetric
	Ensure(!UTF_Checks#AreVariablesClose(2, 1, 0.5, STRONG_CLOSENESS))
	Ensure(UTF_Checks#AreVariablesClose(2, 1, 0.5, WEAK_CLOSENESS))

	// strong vs weak, default tolerance
	Ensure(UTF_Checks#AreVariablesClose(1e-8, 1e-8 + 1e-16, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1e-8, 1e-8 + 1e-16, DEFAULT_TOLERANCE, STRONG_CLOSENESS))

	Ensure(!UTF_Checks#AreVariablesClose(NaN, 1, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(NaN, 1, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1, NaN, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1, NaN, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(Inf, 1, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(Inf, 1, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1, Inf, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1, Inf, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(-Inf, 1, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(-Inf, 1, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1, -Inf, DEFAULT_TOLERANCE, STRONG_CLOSENESS))
	Ensure(!UTF_Checks#AreVariablesClose(1, -Inf, DEFAULT_TOLERANCE, WEAK_CLOSENESS))
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
	Ensure(!UTF_Checks#AreWavesEqual($"", $"", WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!UTF_Checks#AreWavesEqual(numData1, $"", WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(!UTF_Checks#AreWavesEqual($"", numData2, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(UTF_Checks#AreWavesEqual(numData1, numData2, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)
	Ensure(UTF_Checks#AreWavesEqual(numData1, numData2, ALL_MODES, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)

	Make/FREE/T textData1, textData2
	Ensure(UTF_Checks#AreWavesEqual(textData1, textData2, WAVE_DATA, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)
	// all modes
	Ensure(UTF_Checks#AreWavesEqual(textData1, textData2, ALL_MODES, DEFAULT_TOLERANCE, detailedMsg))
	Ensure(strlen(detailedMsg) == 0)
	// If the following invalid tol or mode is improperly checked the function fails with an uncaught RTE
	UTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, 0, mode = WAVE_DATA, tol = NaN)
	UTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, 0, mode = WAVE_DATA, tol = -1)
	UTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, 0, mode = NaN, tol = DEFAULT_TOLERANCE)
	UTF_Wrapper#EQUAL_WAVE_WRAPPER(textData1, textData2, 0, mode = 0x10000000, tol = DEFAULT_TOLERANCE)
	// @}

	// AreWavesEqual
	// @{
	CHECK_EQUAL_WAVES(numData1, numData2, mode = ALL_MODES, tol = 0)
	CHECK_EQUAL_TEXTWAVES(textData1, textData2, mode = ALL_MODES)
	// @}

	// HasWaveMajorType
	// @{

	Ensure(UTF_Checks#HasWaveMajorType($"", NULL_WAVE))

	Make/FREE wv
	Ensure(UTF_Checks#HasWaveMajorType(wv, FREE_WAVE | NUMERIC_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wv, NORMAL_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wv, TEXT_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wv, DATAFOLDER_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wv, WAVE_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wv, NULL_WAVE))

	Make/O/T wvText
	Ensure(!UTF_Checks#HasWaveMajorType(wvText, FREE_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvText, NUMERIC_WAVE))
	Ensure(UTF_Checks#HasWaveMajorType(wvText, NORMAL_WAVE | TEXT_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvText, DATAFOLDER_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvText, WAVE_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvText, NULL_WAVE))

	Make/FREE/DF wvDFR
	Ensure(UTF_Checks#HasWaveMajorType(wvDFR, FREE_WAVE | DATAFOLDER_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvDFR, NUMERIC_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvDFR, NORMAL_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvDFR, TEXT_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvDFR, WAVE_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvDFR, NULL_WAVE))

	Make/FREE/Wave wvWave
	Ensure(UTF_Checks#HasWaveMajorType(wvWave, FREE_WAVE | WAVE_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvWave, NUMERIC_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvWave, NORMAL_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvWave, TEXT_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvWave, DATAFOLDER_WAVE))
	Ensure(!UTF_Checks#HasWaveMajorType(wvWave, NULL_WAVE))

	// @}

	// HasWaveMinorType
	// @{

	Ensure(UTF_Checks#HasWaveMinorType($"", NULL_WAVE))

	Make/FREE/D wvDouble
	Ensure(UTF_Checks#HasWaveMinorType(wvDouble,  DOUBLE_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, FLOAT_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvDouble, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

	Make/FREE/W wvInt16
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16,  DOUBLE_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, FLOAT_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvInt16, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

	Make/FREE/W/U wvUInt16
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16,  DOUBLE_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, FLOAT_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE   | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

	Make/FREE/W/U/C wvUInt16Complex
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, DOUBLE_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, FLOAT_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE   | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE   | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT16_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUInt16Complex, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

#if IgorVersion() >= 7.0

	Make/FREE/L/U wvUint64
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, DOUBLE_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, FLOAT_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, DOUBLE_WAVE | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, FLOAT_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE   | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE  | COMPLEX_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE   | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE  | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE  | UNSIGNED_WAVE))
	Ensure(UTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE   | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT8_WAVE   | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT16_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT32_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))
	Ensure(!UTF_Checks#HasWaveMinorType(wvUint64, INT64_WAVE  | COMPLEX_WAVE | UNSIGNED_WAVE))

#endif

#if IgorVersion() >= 7.0

	int64 i64zero     = 0
	int64 i64one      = 1
	int64 i64big      = 0x7FFFFFFFFFFFFFFE
	int64 i64biggest  = 0x7FFFFFFFFFFFFFFF
	int64 i64minustwo = 0xFFFFFFFFFFFFFFFE
	int64 i64minusone = 0xFFFFFFFFFFFFFFFF
	Ensure(UTF_Checks#AreINT64Equal(i64zero, i64zero))
	Ensure(UTF_Checks#AreINT64Equal(i64big, i64big))
	Ensure(UTF_Checks#AreINT64Equal(i64minusone, i64minusone))
	Ensure(!UTF_Checks#AreINT64Equal(i64minusone, i64minustwo))
	Ensure(!UTF_Checks#AreINT64Equal(i64zero, i64one))
	Ensure(!UTF_Checks#AreINT64Equal(i64big, i64biggest))
	Ensure(!UTF_Checks#AreINT64Equal(i64one, i64biggest))
	Ensure(UTF_Checks#AreINT64Close(i64zero, i64one, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#AreINT64Close(i64big, i64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(!UTF_Checks#AreINT64Close(i64one, i64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#AreINT64Close(i64zero, i64minusone, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#AreINT64Close(i64minustwo, i64minusone, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#AreINT64Close(i64one, i64biggest, i64biggest))
	Ensure(!UTF_Checks#AreINT64Close(i64big, i64biggest, i64zero))
	Ensure(UTF_Checks#IsINT64Small(i64zero, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#IsINT64Small(i64one, DEFAULT_TOLERANCE_INT))
	Ensure(!UTF_Checks#IsINT64Small(i64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#IsINT64Small(i64minustwo, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#IsINT64Small(i64big, i64Biggest))
	Ensure(!UTF_Checks#IsINT64Small(i64one, i64zero))
	Ensure(UTF_Checks#IsINT64Small(i64one, i64minustwo))

	uint64 ui64zero     = 0
	uint64 ui64one      = 1
	uint64 ui64big      = 0xFFFFFFFFFFFFFFFE
	uint64 ui64biggest  = 0xFFFFFFFFFFFFFFFF
	Ensure(UTF_Checks#AreUINT64Equal(ui64zero, ui64zero))
	Ensure(UTF_Checks#AreUINT64Equal(ui64big, ui64big))
	Ensure(!UTF_Checks#AreUINT64Equal(ui64zero, ui64one))
	Ensure(!UTF_Checks#AreUINT64Equal(ui64big, ui64biggest))
	Ensure(!UTF_Checks#AreUINT64Equal(ui64one, ui64biggest))
	Ensure(UTF_Checks#AreUINT64Close(ui64zero, ui64one, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#AreUINT64Close(ui64big, ui64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(!UTF_Checks#AreUINT64Close(ui64one, ui64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#AreUINT64Close(ui64one, ui64biggest, ui64biggest))
	Ensure(!UTF_Checks#AreUINT64Close(ui64big, ui64biggest, ui64zero))
	Ensure(UTF_Checks#IsUINT64Small(ui64zero, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#IsUINT64Small(ui64one, DEFAULT_TOLERANCE_INT))
	Ensure(!UTF_Checks#IsUINT64Small(ui64biggest, DEFAULT_TOLERANCE_INT))
	Ensure(UTF_Checks#IsUINT64Small(ui64big, ui64Biggest))
	Ensure(!UTF_Checks#IsUINT64Small(ui64one, ui64zero))

#endif

	// @}

	// CHECK_WAVE
	// @{

	CHECK_WAVE($"", NULL_WAVE)
	CHECK_WAVE({0}, NUMERIC_WAVE, minorType = FLOAT_WAVE)

	// @}
End
