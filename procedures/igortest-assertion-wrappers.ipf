#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Wrapper

static Constant RTE_NULL_STRING = 185

/// @class INFO_DOCU
/// Append information to the next assertion to print if failed
static Function INFO_WRAPPER(format, strings, numbers, flags)
	string   format
	WAVE/T   strings
	WAVE     numbers
	variable flags

	variable err, index
	string msg
	WAVE/T wvInfoMsg = IUTF_Reporting#GetInfoMsg()

	msg = IUTF_Utils_Strings#UserPrintF(format, strings, numbers, err)
	if(err)
		sprintf msg, "PrintF error \"%s\"", msg
		EvaluateResults(0, msg, flags, cleanupInfo = 0)
		return NaN
	endif

	index            = IUTF_Utils_Vector#AddRow(wvInfoMsg)
	wvInfoMsg[index] = msg
End

/// @class CDF_EMPTY_DOCU
/// Tests if the current data folder is empty
///
/// Counted are objects with type waves, strings, variables and folders
static Function CDF_EMPTY_WRAPPER(flags)
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#IsDataFolderEmpty(":")
	EvaluateResults(result, "Assumption that the current data folder is empty is", flags)
End

/// @class TRUE_DOCU
/// Tests if var is non-zero and not "Not a Number" (NaN).
///
/// @param var variable to test
static Function TRUE_WRAPPER(var, flags)
	variable var
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#IsTrue(var)
	EvaluateResults(result, num2istr(var), flags)
End

/// @class NULL_STR_DOCU
/// Tests if str is null.
///
/// An empty string is never null.
/// @param str    string to test
static Function NULL_STR_WRAPPER(str, flags)
	string  &str
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#IsNullString(str)
	EvaluateResults(result, "Assumption that str is null is", flags)
End

/// @class EMPTY_STR_DOCU
/// Tests if str is empty.
///
/// A null string is never empty.
/// @param str  string to test
static Function EMPTY_STR_WRAPPER(str, flags)
	string  &str
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#IsEmptyString(str)
	EvaluateResults(result, "Assumption that the string is empty is", flags)
End

/// @class NON_NULL_STR_DOCU
/// Tests if str is not null.
///
/// An empty string is always non null.
/// @param str    string to test
static Function NON_NULL_STR_WRAPPER(str, flags)
	string  &str
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !IUTF_Checks#IsNullString(str)
	EvaluateResults(result, "Assumption of the string being non null is", flags)
End

/// @class NON_EMPTY_STR_DOCU
/// Tests if str is not empty.
///
/// A null string is a non empty string too.
/// @param str  string to test
static Function NON_EMPTY_STR_WRAPPER(str, flags)
	string  &str
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !IUTF_Checks#IsEmptyString(str)
	EvaluateResults(result, "Assumption that the string is non empty is", flags)
End

/// @class PROPER_STR_DOCU
/// Tests if str is a "proper" string, i.e. a string with a length larger than
/// zero.
///
/// Neither null strings nor empty strings are proper strings.
/// @param str  string to test
static Function PROPER_STR_WRAPPER(str, flags)
	string  &str
	variable flags

	variable result

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#IsProperString(str)
	EvaluateResults(result, "Assumption that the string is a proper string is", flags)
End

/// @class NEQ_VAR_DOCU
/// Tests two variables for inequality
///
/// @param var1    first variable
/// @param var2    second variable
static Function NEQ_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result  = !IUTF_Checks#AreVariablesEqual(var1, var2)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s != %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class NEQ_STR_DOCU
/// Compares two strings for unequality
///
/// This doesn't check if one of the two string are null. If this function is called with a null
/// string this will throw a check assertion error. The same will happen if you call this function
/// and there is a pending code 185 runtime error.
///
/// @param str1            first string
/// @param str2            second string
/// @param case_sensitive  (optional) should the comparison be done case sensitive (1) or case insensitive (0, the default)
static Function NEQ_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string &str1, &str2
	variable case_sensitive
	variable flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 1
	endif

	if(GetRTError(0) == RTE_NULL_STRING)
		IUTF_Basics#ClearRTError()
		str = "Null string error: One of the provided arguments could be an unsupported null string."
		EvaluateResults(0, str, CHECK_MODE)
		return NaN
	endif

	result  = !IUTF_Checks#AreStringsEqual(str1, str2, case_sensitive)
	tmpStr1 = IUTF_Utils#IUTF_PrepareStringForOut(str1)
	tmpStr2 = IUTF_Utils#IUTF_PrepareStringForOut(str2)
	sprintf str, "\"%s\" != \"%s\" %s case", tmpStr1, tmpStr2, SelectString(case_sensitive, "not respecting", "respecting")

	EvaluateResults(result, str, flags)
End

/// @class CLOSE_VAR_DOCU
/// Compares two variables and determines if they are close.
///
/// Based on the implementation of "Floating-point comparison algorithms" in the C++ Boost unit testing framework.
///
/// Literature:<br>
/// The art of computer programming (Vol II). Donald. E. Knuth. 0-201-89684-2. Addison-Wesley Professional;
/// 3 edition, page 234 equation (34) and (35).
///
/// @param var1   first variable
/// @param var2   second variable
/// @param tol    (optional) tolerance, defaults to 1e-8
/// @param strong (optional) type of condition, can be 0 for weak or 1 for strong (default)
static Function CLOSE_VAR_WRAPPER(var1, var2, flags, [tol, strong])
	variable var1, var2
	variable flags
	variable tol
	variable strong

	variable result
	string str, tmpStr1, tmpStr2, tmpStr3

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(strong))
		strong = CLOSE_COMPARE_STRONG
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result  = IUTF_Checks#AreVariablesClose(var1, var2, tol, strong)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	tmpStr3 = IUTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)
	sprintf str, "%s ~ %s with %s check and tol %s", tmpStr1, tmpStr2, SelectString(strong, "weak", "strong"), tmpStr3
	EvaluateResults(result, str, flags)
End

/// @class CLOSE_CMPLX_DOCU
/// @copydoc CLOSE_VAR_DOCU
///
/// Variant for complex numbers.
static Function CLOSE_CMPLX_WRAPPER(var1, var2, flags, [tol, strong])
	variable/C var1, var2
	variable flags
	variable tol
	variable strong

	variable result
	string str, tmpStr1, tmpStr2, tmpStr3, tmpStr4, tmpStr5

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(strong))
		strong = CLOSE_COMPARE_STRONG
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result  = IUTF_Checks#AreVariablesClose(real(var1), real(var2), tol, strong) && IUTF_Checks#AreVariablesClose(imag(var1), imag(var2), tol, strong)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(real(var1), isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(imag(var1), isDouble = 1)
	tmpStr3 = IUTF_Utils#GetNiceStringForNumber(real(var2), isDouble = 1)
	tmpStr4 = IUTF_Utils#GetNiceStringForNumber(imag(var2), isDouble = 1)
	tmpStr5 = IUTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)
	sprintf str, "(%s, %s) ~ (%s, %s) with %s check and tol %s", tmpStr1, tmpStr2, tmpStr3, tmpStr4, SelectString(strong, "weak", "strong"), tmpStr5
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.0
/// @endcond

/// @class CLOSE_INT64_DOCU
/// Compares two int64 and determines if they are close.
///
/// @param var1   first int64 variable
/// @param var2   second int64 variable
/// @param tol    (optional) int64 tolerance, defaults to 16
static Function CLOSE_INT64_WRAPPER(int64 var1, int64 var2, variable flags, [int64 tol])
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = IUTF_Checks#AreINT64Close(var1, var2, tol)
	sprintf str, "%d ~ %d with tol %d", var1, var2, tol
	EvaluateResults(result, str, flags)
End

/// @class CLOSE_UINT64_DOCU
/// Compares two uint64 and determines if they are close.
///
/// @param var1   first uint64 variable
/// @param var2   second uint64 variable
/// @param tol    (optional) uint64 tolerance, defaults to 16
static Function CLOSE_UINT64_WRAPPER(uint64 var1, uint64 var2, variable flags, [uint64 tol])
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = IUTF_Checks#AreUINT64Close(var1, var2, tol)
	sprintf str, "%d ~ %d with tol %d", var1, var2, tol
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @class SMALL_VAR_DOCU
/// Tests if a variable is small using the inequality @f$  | var | < | tol |  @f$
///
/// @param var        variable
/// @param tol        (optional) tolerance, defaults to 1e-8
static Function SMALL_VAR_WRAPPER(var, flags, [tol])
	variable var
	variable flags
	variable tol

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result  = IUTF_Checks#IsVariableSmall(var, tol)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)

	sprintf str, "%s ~ 0 with tol %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class SMALL_CMPLX_DOCU
/// @copydoc SMALL_VAR_DOCU
///
/// Variant for complex numbers
static Function SMALL_CMPLX_WRAPPER(var, flags, [tol])
	variable/C var
	variable   flags
	variable   tol

	variable result
	string str, tmpStr1, tmpStr2, tmpStr3

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result  = IUTF_Checks#IsVariableSmall(cabs(var), tol)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(real(var), isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(imag(var), isDouble = 1)
	tmpStr3 = IUTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)
	sprintf str, "(%s, %s) ~ 0 with tol %s", tmpStr1, tmpStr2, tmpStr3
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.0
/// @endcond

/// @class SMALL_INT64_DOCU
/// Tests if a int64 variable is small using the inequality @f$  | var | < | tol |  @f$
///
/// @param var        int64 variable
/// @param tol        (optional) int64 tolerance, defaults to 16
static Function SMALL_INT64_WRAPPER(int64 var, variable flags, [int64 tol])
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = IUTF_Checks#IsINT64Small(var, tol)
	sprintf str, "%d ~ 0 with tol %g", var, tol
	EvaluateResults(result, str, flags)
End

/// @class SMALL_UINT64_DOCU
/// Tests if a uint64 variable is small using the inequality @f$  var < tol  @f$
///
/// @param var        uint64 variable
/// @param tol        (optional) uint64 tolerance, defaults to 16
static Function SMALL_UINT64_WRAPPER(uint64 var, variable flags, [uint64 tol])
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = IUTF_Checks#IsUINT64Small(var, tol)
	sprintf str, "%d ~ 0 with tol %g", var, tol
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @class EQUAL_STR_DOCU
/// Compares two strings for byte-wise equality. (no encoding considered, no unicode normalization).
///
/// This doesn't check if one of the two string are null. If this function is called with a null
/// string this will throw a check assertion error. The same will happen if you call this function
/// and there is a pending code 185 runtime error.
///
/// @param str1           first string
/// @param str2           second string
/// @param case_sensitive (optional) should the comparison be done case sensitive (1) or case insensitive (1, the default)
static Function EQUAL_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string &str1, &str2
	variable case_sensitive
	variable flags

	variable result
	string str, tmpStr1, tmpStr2
	STRUCT IUTF_StringDiffResult diffResult

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 1
	endif

	if(GetRTError(0) == RTE_NULL_STRING)
		IUTF_Basics#ClearRTError()
		str = "Null string error: One of the provided arguments could be an unsupported null string."
		EvaluateResults(0, str, CHECK_MODE)
		IUTF_Reporting#CleanupInfoMsg()
		return NaN
	endif

	result = IUTF_Checks#AreStringsEqual(str1, str2, case_sensitive)
	if(!result)
		IUTF_Utils#DiffString(str1, str2, diffResult, case_sensitive = case_sensitive)
		sprintf str, "String mismatch (case %ssensitive):\rstr1: %s\rstr2: %s\r", SelectString(case_sensitive, "in", ""), diffResult.v1, diffResult.v2
		EvaluateResults(result, str, flags)
	endif

	IUTF_Reporting#CleanupInfoMsg()
End

/// @class WAVE_DOCU
/// Tests a wave for existence and its type
///
/// @param wv         wave reference
/// @param majorType  major wave type
/// @param minorType  (optional) minor wave type
///
/// @verbatim embed:rst:leading-slashes
/// See also :ref:`flags_testwave`.
/// @endverbatim
///
static Function TEST_WAVE_WRAPPER(wv, majorType, flags, [minorType])
	WAVE/Z wv
	variable majorType, minorType
	variable flags

	variable result, type
	string str, str1, str2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(!(majorType & (NULL_WAVE | NUMERIC_WAVE | TEXT_WAVE | DATAFOLDER_WAVE | WAVE_WAVE | NORMAL_WAVE | FREE_WAVE)))
		EvaluateResults(0, "Valid major type check", flags)
		return NaN
	elseif(!ParamIsDefault(minorType) && !(minorType & (NULL_WAVE | NON_NUMERIC_WAVE | COMPLEX_WAVE | FLOAT_WAVE | DOUBLE_WAVE | INT8_WAVE | INT16_WAVE | INT32_WAVE | INT64_WAVE | UNSIGNED_WAVE)))
		EvaluateResults(0, "Valid minor type check", flags)
		return NaN
	endif

	result = IUTF_Checks#HasWaveMajorType(wv, majorType)
	type   = IUTF_Checks#GetWaveMajorType(wv)
	str1   = IUTF_Checks#GetWaveMajorTypeString(majorType)
	str2   = IUTF_Checks#GetWaveMajorTypeString(type)
	sprintf str, "Expect wave's main type to be '%s' but got '%s'", str1, str2
	EvaluateResults(result, str, flags, cleanupInfo = 0)

	if(!ParamIsDefault(minorType))
		result = IUTF_Checks#HasWaveMinorType(wv, minorType)
		type   = IUTF_Checks#GetWaveMinorType(wv)
		str1   = IUTF_Checks#GetWaveMinorTypeString(minorType)
		str2   = IUTF_Checks#GetWaveMinorTypeString(type)
		sprintf str, "Expect wave's sub type to be '%s' but got '%s'", str1, str2
		EvaluateResults(result, str, flags, cleanupInfo = 0)
	endif

	IUTF_Reporting#CleanupInfoMsg()
End

/// @class EQUAL_VAR_DOCU
/// Tests two variables for equality.
///
/// For variables holding floating point values it is often more desirable use
/// CHECK_CLOSE_VAR instead. To fullfill semantic correctness this assertion
/// treats two variables with both holding NaN as equal.
///
/// @param var1   first variable
/// @param var2   second variable
static Function EQUAL_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result  = IUTF_Checks#AreVariablesEqual(var1, var2)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s == %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.00
/// @endcond

/// @class EQUAL_INT64_DOCU
/// Tests two int64 for equality.
///
/// @param var1   first variable
/// @param var2   second variable
static Function EQUAL_INT64_WRAPPER(int64 var1, int64 var2, variable flags)
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#AreInt64Equal(var1, var2)
	sprintf str, "%d == %d", var1, var2
	EvaluateResults(result, str, flags)
End

/// @class EQUAL_UINT64_DOCU
/// Tests two uint64 for equality.
///
/// @param var1   first variable
/// @param var2   second variable
static Function EQUAL_UINT64_WRAPPER(uint64 var1, uint64 var2, variable flags)
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#AreUInt64Equal(var1, var2)
	sprintf str, "%u == %u", var1, var2
	EvaluateResults(result, str, flags)
End

/// @class NEQ_INT64_DOCU
/// Tests two int64 for unequality.
///
/// @param var1   first variable
/// @param var2   second variable
static Function NEQ_INT64_WRAPPER(int64 var1, int64 var2, variable flags)
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !IUTF_Checks#AreInt64Equal(var1, var2)
	sprintf str, "%d == %d", var1, var2
	EvaluateResults(result, str, flags)
End

/// @class NEQ_UINT64_DOCU
/// Tests two uint64 for unequality.
///
/// @param var1   first variable
/// @param var2   second variable
static Function NEQ_UINT64_WRAPPER(uint64 var1, uint64 var2, variable flags)
	variable result
	string   str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !IUTF_Checks#AreUInt64Equal(var1, var2)
	sprintf str, "%u == %u", var1, var2
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @class EQUAL_WAVE_DOCU
/// Tests two waves for equality.
/// If one wave has a zero size and the other one does not then properties like DIMENSION_UNITS are compared to unequal as a property for a
/// non-existing dimension is always unequal to a property of an existing dimension.
/// This function won't throw an assert if both waves have the same reference, because they are considered as equal.
///
/// @param wv1    first wave
/// @param wv2    second wave
/// @param mode   (optional) features of the waves to compare, defaults to all modes
/// @param tol    (optional) tolerance for comparison, by default 0.0 which does byte-by-byte comparison (relevant only for mode=WAVE_DATA)
///
/// @verbatim embed:rst:leading-slashes
/// See also :ref:`flags_equalwave`.
/// @endverbatim
///
static Function EQUAL_WAVE_WRAPPER(wv1, wv2, flags, [mode, tol])
	WAVE/Z wv1, wv2
	variable flags
	variable mode, tol

	variable i, result
	string detailedMsg, name1, name2
	string str = ""

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = WaveExists(wv1)

	if(!result)
		EvaluateResults(0, "Assumption that the first wave (wv1) exists", flags)
		return NaN
	endif

	result = WaveExists(wv2)

	if(!result)
		EvaluateResults(0, "Assumption that the second wave (wv2) exists", flags)
		return NaN
	endif

	Make/FREE validModes = {WAVE_DATA, WAVE_DATA_TYPE, WAVE_SCALING, DATA_UNITS, DIMENSION_UNITS, DIMENSION_LABELS, WAVE_NOTE, WAVE_LOCK_STATE, DATA_FULL_SCALE, DIMENSION_SIZES}

	if(ParamIsDefault(mode))
		WAVE modes = validModes
	else
		if(!IUTF_Utils#IsFinite(mode))
			EvaluateResults(0, "Valid mode for EQUAL_WAVE check.", flags)
			return NaN
		elseif(!(mode & (WAVE_DATA | WAVE_DATA_TYPE | WAVE_SCALING | DATA_UNITS | DIMENSION_UNITS | DIMENSION_LABELS | WAVE_NOTE | WAVE_LOCK_STATE | DATA_FULL_SCALE | DIMENSION_SIZES)))
			EvaluateResults(0, "Valid mode for EQUAL_WAVE check.", flags)
			return NaN
		endif

		// mode can be a bit pattern, split into separate entities for better debugging
		Duplicate/FREE validModes, modes

		modes[] = (validModes[p] == (validModes[p] & mode)) ? validModes[p] : NaN
		WaveTransform/O zapNaNs, modes

		if(!DimSize(modes, 0))
			EvaluateResults(0, "Valid mode for EQUAL_WAVE check.", flags)
			return NaN
		endif
	endif

	if(ParamIsDefault(tol))
		tol = 0.0
	elseif(IUTF_Utils#IsNaN(tol))
		EvaluateResults(0, "Valid tolerance for EQUAL_WAVE check.", flags)
		return NaN
	elseif(tol < 0)
		EvaluateResults(0, "Valid tolerance for EQUAL_WAVE check.", flags)
		return NaN
	endif

	for(i = 0; i < DimSize(modes, 0); i += 1)
		mode   = modes[i]
		result = IUTF_Checks#AreWavesEqual(wv1, wv2, mode, tol, detailedMsg)

		if(!result)
			name1 = IUTF_Utils#GetWaveNameInDFStr(wv1)
			name2 = IUTF_Utils#GetWaveNameInDFStr(wv2)
			sprintf str, "Assuming equality using mode %s for waves %s and %s", EqualWavesModeToString(mode), name1, name2

			if(!IUTF_Utils#IsEmpty(detailedMsg))
				str += "; detailed: " + detailedMsg
			endif
		endif

		EvaluateResults(result, str, flags, cleanupInfo = 0)
	endfor

	IUTF_Reporting#CleanupInfoMsg()
End

/// @class LESS_EQUAL_VAR_DOCU
/// Tests that var1 is less or equal than var2
///
/// @param var1 first variable
/// @param var2 second variable
static Function LESS_EQUAL_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2, flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result  = IUTF_Checks#IsLessOrEqual(var1, var2)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s <= %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class LESS_THAN_VAR_DOCU
/// Tests that var1 is less than var2
///
/// @param var1 first variable
/// @param var2 second variable
static Function LESS_THAN_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2, flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result  = IUTF_Checks#IsLess(var1, var2)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s < %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class GREATER_EQUAL_VAR_DOCU
/// Tests that var1 is greather or equal than var2
///
/// @param var1 first variable
/// @param var2 second variable
static Function GREATER_EQUAL_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2, flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result  = IUTF_Checks#IsLessOrEqual(var2, var1)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s >= %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class GREATER_THAN_VAR_DOCU
/// Tests that var1 is greather than var2
///
/// @param var1 first variable
/// @param var2 second variable
static Function GREATER_THAN_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2, flags

	variable result
	string str, tmpStr1, tmpStr2

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result  = IUTF_Checks#IsLess(var2, var1)
	tmpStr1 = IUTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = IUTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s > %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

static Function/S RTE2String(code, [msg])
	variable code
	string   msg

	string result

	if(code)
		if(ParamIsDefault(msg))
			sprintf result, "RTE %d", code
		else
			sprintf result, "RTE %d \"%s\"", code, msg
		endif
		return result
	else
		return "no RTE"
	endif
End

/// @class RTE_DOCU
/// Tests if a RTE with the specified code was thrown. This assertion will clear any pending RTEs.
///
/// Hint: You have to add INFO() statements before the statement that is tested. INFO() won't do
/// something if a pending RTE exists.
///
/// @param code the code that is expected to be thrown
static Function RTE_WRAPPER(code, flags)
	variable code, flags

	variable result, err
	string str, msg

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#HasRTE(code)
	msg    = GetRTErrMessage()
	err    = GetRTError(1)

	sprintf str, "Expecting %s but got %s", RTE2String(code), RTE2String(err, msg = msg)
	EvaluateResults(result, str, flags)
End

/// @class ANY_RTE_DOCU
/// Tests if any RTE was thrown. This assertion will clear any pending RTEs.
///
/// Hint: You have to add INFO() statements before the statement that is tested. INFO() won't do
/// something if a pending RTE exists.
static Function ANY_RTE_WRAPPER(flags)
	variable flags

	variable result, err
	string str

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = IUTF_Checks#HasAnyRTE()
	err    = GetRTError(1)

	sprintf str, "Expecting any RTE but got nothing"
	EvaluateResults(result, str, flags)
End

/// @class NO_RTE_DOCU
/// Tests if no RTEs are thrown. This assertion will clear any pending RTEs.
///
/// Hint: You have to add INFO() statements before the statement that is tested. INFO() won't do
/// something if a pending RTE exists.
static Function NO_RTE_WRAPPER(flags)
	variable flags

	RTE_WRAPPER(0, flags)
End

/// @class COMPILATION_DOCU
/// Tests if the specified Igor Pro file can be compiled with the list of defines. This assertion
/// can only be used if IUTF is located inside an independent module. This assertion needs to be the
/// last assertion of the current test case. If you want to continue your test case after this
/// assertion try to split your test case into multiple functions and specify the next part in the
/// optional parameter reentry.
///
/// It is recommended to start Igor with the <tt>/CompErrNoDialog</tt> (alternatively
/// <tt>/UNATTENDED</tt> since Igor 9) command line argument to prevent error pop-ups when a single
/// compilation failed.
///
/// @param file     The Igor Pro procedure file that should be tested. This must be a valid path
///                 that can be used in the <tt>\#include "file"</tt> syntax.
/// @param defines  (optional) A text wave which contains globally defined flags that are
///                 used for conditional compilation. If this parameter is not set it will be
///                 treated as if an empty wave was provided and won't set any flags.
/// @param reentry  (optional) The full function name of the reentry function that will be executed
///                 after this assertion finished. If this parameter is not used the test case will
//                  be finished after this assertion.
static Function COMPILATION_WRAPPER(file, flags, [defines, reentry, noCompile])
	string   file
	variable flags
	WAVE/Z/T defines
	string   reentry
	variable noCompile

	variable tmpVar

	noCompile = ParamIsDefault(noCompile) ? 0 : !!noCompile

	IUTF_Reporting#incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(!CmpStr(GetIndependentModuleName(), "ProcGlobal"))
		IUTF_Reporting#ReportErrorAndAbort("This assertion is only allowed to be called in an independent module")
	endif

	if(!ParamIsDefault(reentry))
		if(IUTF_Utils#IsEmpty(reentry))
			IUTF_Reporting#ReportErrorAndAbort("Reentry parameter is an empty string")
		endif

		if(GrepString(reentry, PROCNAME_NOT_REENTRY))
			IUTF_Reporting#ReportErrorAndAbort("Name of Reentry function must end with _REENTRY")
		endif
		FUNCREF TEST_CASE_PROTO    rFuncRef    = $reentry
		FUNCREF TEST_CASE_PROTO_MD rFuncRefMMD = $reentry
		if(!IUTF_FuncRefIsAssigned(FuncRefInfo(rFuncRef)) && !IUTF_FuncRefIsAssigned(FuncRefInfo(rFuncRefMMD)) && !IUTF_Test_MD#GetFunctionSignatureTCMD(reentry, tmpVar, tmpVar, tmpVar))
			IUTF_Reporting#ReportErrorAndAbort("Specified reentry procedure has wrong format. The format must be function_REENTRY() or for multi data function_REENTRY([type]).")
		endif
	else
		reentry = ""
	endif

	if(ParamIsDefault(defines) || !WaveExists(defines))
		Make/FREE/N=0/T defines
	endif

	IUTF_Test_Compilation#TestCompilation(file, flags, defines, reentry, noCompile)
End

/// @class NO_COMPILATION_DOCU
/// Tests if the specified Igor Pro file cannot be compiled with the list of defines. This assertion
/// can only be used if IUTF is located inside an independent module. This assertion needs to be the
/// last assertion of the current test case. If you want to continue your test case after this
/// assertion try to split your test case into multiple functions and specify the next part in the
/// optional parameter reentry.
///
/// It is recommended to start Igor with the <tt>/CompErrNoDialog</tt> (alternatively
/// <tt>/UNATTENDED</tt> since Igor 9) command line argument to prevent error pop-ups when a single
/// compilation failed.
///
/// @param file     The Igor Pro procedure file that should be tested. This must be a valid path
///                 that can be used in the <tt>\#include "file"</tt> syntax.
/// @param defines  (optional) A text wave which contains globally defined flags that are
///                 used for conditional compilation. If this parameter is not set it will be
///                 treated as if an empty wave was provided and won't set any flags.
/// @param reentry  (optional) The full function name of the reentry function that will be executed
///                 after this assertion finished. If this parameter is not used the test case will
//                  be finished after this assertion.
static Function NO_COMPILATION_WRAPPER(file, flags, [defines, reentry])
	string   file
	variable flags
	WAVE/Z/T defines
	string   reentry

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			COMPILATION_WRAPPER(file, flags, noCompile = 1)
		else
			COMPILATION_WRAPPER(file, flags, reentry = reentry, noCompile = 1)
		endif
	else
		if(ParamIsDefault(reentry))
			COMPILATION_WRAPPER(file, flags, defines = defines, noCompile = 1)
		else
			COMPILATION_WRAPPER(file, flags, defines = defines, reentry = reentry, noCompile = 1)
		endif
	endif
End
