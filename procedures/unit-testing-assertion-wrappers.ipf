#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Wrapper

// Licensed under 3-Clause BSD, see License.txt

/// @class INFO_DOCU
/// Append information to the next assertion to print if failed
static Function INFO_WRAPPER(format, strings, numbers, flags)
	string format
	WAVE/T strings
	WAVE numbers
	variable flags

	variable err
	string msg
	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr AssertionInfo

	if(!SVAR_Exists(AssertionInfo))
		string/G dfr:AssertionInfo = ""
		SVAR/SDFR=dfr AssertionInfo
	endif

	msg = UTF_Utils_Strings#UserPrintF(format, strings, numbers, err)
	if(err)
		sprintf msg, "PrintF error \"%s\"", msg
		EvaluateResults(0, msg, flags, cleanupInfo = 0)
		return NaN
	endif

	if(strlen(AssertionInfo))
		AssertionInfo += "\r  "
	endif
	AssertionInfo += "  " + TC_ASSERTION_INFO_INDICATOR + " " + msg
End

/// @class CDF_EMPTY_DOCU
/// Tests if the current data folder is empty
///
/// Counted are objects with type waves, strings, variables and folders
static Function CDF_EMPTY_WRAPPER(flags)
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsDataFolderEmpty(":")
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsTrue(var)
	EvaluateResults(result, num2istr(var), flags)
End

/// @class NULL_STR_DOCU
/// Tests if str is null.
///
/// An empty string is never null.
/// @param str    string to test
static Function NULL_STR_WRAPPER(str, flags)
	string &str
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsNullString(str)
	EvaluateResults(result, "Assumption that str is null is", flags)
End

/// @class EMPTY_STR_DOCU
/// Tests if str is empty.
///
/// A null string is never empty.
/// @param str  string to test
static Function EMPTY_STR_WRAPPER(str, flags)
	string &str
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsEmptyString(str)
	EvaluateResults(result, "Assumption that the string is empty is", flags)
End

/// @class NON_NULL_STR_DOCU
/// Tests if str is not null.
///
/// An empty string is always non null.
/// @param str    string to test
static Function NON_NULL_STR_WRAPPER(str, flags)
	string &str
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !UTF_Checks#IsNullString(str)
	EvaluateResults(result, "Assumption of the string being non null is", flags)
End

/// @class NON_EMPTY_STR_DOCU
/// Tests if str is not empty.
///
/// A null string is a non empty string too.
/// @param str  string to test
static Function NON_EMPTY_STR_WRAPPER(str, flags)
	string &str
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !UTF_Checks#IsEmptyString(str)
	EvaluateResults(result, "Assumption that the string is non empty is", flags)
End

/// @class PROPER_STR_DOCU
/// Tests if str is a "proper" string, i.e. a string with a length larger than
/// zero.
///
/// Neither null strings nor empty strings are proper strings.
/// @param str  string to test
static Function PROPER_STR_WRAPPER(str, flags)
	string &str
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsProperString(str)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !UTF_Checks#AreVariablesEqual(var1, var2)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s != %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class NEQ_STR_DOCU
/// Compares two strings for unequality
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 1
	endif

	result = !UTF_Checks#AreStringsEqual(str1, str2, case_sensitive)
	tmpStr1 = UTF_Utils#PrepareStringForOut(str1)
	tmpStr2 = UTF_Utils#PrepareStringForOut(str2)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(strong))
		strong  = CLOSE_COMPARE_STRONG
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result = UTF_Checks#AreVariablesClose(var1, var2, tol, strong)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	tmpStr3 = UTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(strong))
		strong  = CLOSE_COMPARE_STRONG
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result = UTF_Checks#AreVariablesClose(real(var1), real(var2), tol, strong) && UTF_Checks#AreVariablesClose(imag(var1), imag(var2), tol, strong)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(real(var1), isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(imag(var1), isDouble = 1)
	tmpStr3 = UTF_Utils#GetNiceStringForNumber(real(var2), isDouble = 1)
	tmpStr4 = UTF_Utils#GetNiceStringForNumber(imag(var2), isDouble = 1)
	tmpStr5 = UTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = UTF_Checks#AreINT64Close(var1, var2, tol)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = UTF_Checks#AreUINT64Close(var1, var2, tol)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result = UTF_Checks#IsVariableSmall(var, tol)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)

	sprintf str, "%s ~ 0 with tol %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End

/// @class SMALL_CMPLX_DOCU
/// @copydoc SMALL_VAR_DOCU
///
/// Variant for complex numbers
static Function SMALL_CMPLX_WRAPPER(var, flags, [tol])
	variable/C var
	variable flags
	variable tol

	variable result
	string str, tmpStr1, tmpStr2, tmpStr3

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result = UTF_Checks#IsVariableSmall(cabs(var), tol)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(real(var), isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(imag(var), isDouble = 1)
	tmpStr3 = UTF_Utils#GetNiceStringForNumber(tol, isDouble = 1)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = UTF_Checks#IsINT64Small(var, tol)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE_INT
	endif

	result = UTF_Checks#IsUINT64Small(var, tol)
	sprintf str, "%d ~ 0 with tol %g", var, tol
	EvaluateResults(result, str, flags)
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @class EQUAL_STR_DOCU
/// Compares two strings for byte-wise equality. (no encoding considered, no unicode normalization)
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
	Struct IUTF_StringDiffResult diffResult

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 1
	endif

	result = UTF_Checks#AreStringsEqual(str1, str2, case_sensitive)
	if(!result)
		UTF_Utils#DiffString(str1, str2, diffResult, case_sensitive=case_sensitive)
		sprintf str, "String mismatch (case %ssensitive):\rstr1: %s\rstr2: %s\r", SelectString(case_sensitive, "in", ""), diffResult.v1, diffResult.v2
		EvaluateResults(result, str, flags)
	endif
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
	Wave/Z wv
	variable majorType, minorType
	variable flags

	variable result, type
	string str, str1, str2

	incrAssert()

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

	result = UTF_Checks#HasWaveMajorType(wv, majorType)
	type = UTF_Checks#GetWaveMajorType(wv)
	str1 = UTF_Checks#GetWaveMajorTypeString(majorType)
	str2 = UTF_Checks#GetWaveMajorTypeString(type)
	sprintf str, "Expect wave's main type to be '%s' but got '%s'", str1, str2
	EvaluateResults(result, str, flags, cleanupInfo = 0)

	if(!ParamIsDefault(minorType))
		result = UTF_Checks#HasWaveMinorType(wv, minorType)
		type = UTF_Checks#GetWaveMinorType(wv)
		str1 = UTF_Checks#GetWaveMinorTypeString(minorType)
		str2 = UTF_Checks#GetWaveMinorTypeString(type)
		sprintf str, "Expect wave's sub type to be '%s' but got '%s'", str1, str2
		EvaluateResults(result, str, flags, cleanupInfo = 0)
	endif

	UTF_Basics#CleanupInfoMsg()
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#AreVariablesEqual(var1, var2)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#AreInt64Equal(var1, var2)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#AreUInt64Equal(var1, var2)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !UTF_Checks#AreInt64Equal(var1, var2)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !UTF_Checks#AreUInt64Equal(var1, var2)
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
	Wave/Z wv1, wv2
	variable flags
	variable mode, tol

	variable i, result
	string str, detailedMsg, name1, name2

	incrAssert()

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

	Make/FREE validModes = { WAVE_DATA, WAVE_DATA_TYPE, WAVE_SCALING, DATA_UNITS, DIMENSION_UNITS, DIMENSION_LABELS, WAVE_NOTE, WAVE_LOCK_STATE, DATA_FULL_SCALE, DIMENSION_SIZES}

	if(ParamIsDefault(mode))
		WAVE modes = validModes
	else
		if(!UTF_Utils#IsFinite(mode))
			EvaluateResults(0, "Valid mode for EQUAL_WAVE check.", flags)
			return NaN
		elseif(!(mode & (WAVE_DATA | WAVE_DATA_TYPE | WAVE_SCALING | DATA_UNITS | DIMENSION_UNITS | DIMENSION_LABELS | WAVE_NOTE | WAVE_LOCK_STATE | DATA_FULL_SCALE | DIMENSION_SIZES)))
			EvaluateResults(0, "Valid mode for EQUAL_WAVE check.", flags)
			return NaN
		endif

		// mode can be a bit pattern, split into separate entities for better debugging
		Duplicate/FREE validModes, modes

		modes[] = (validModes[p] == (validModes[p] & mode)) ? validModes[p] : NaN
		WaveTransform/O zapNaNs modes

		if(!DimSize(modes, 0))
			EvaluateResults(0, "Valid mode for EQUAL_WAVE check.", flags)
			return NaN
		endif
	endif

	if(ParamIsDefault(tol))
		tol = 0.0
	elseif(UTF_Utils#IsNaN(tol))
		EvaluateResults(0, "Valid tolerance for EQUAL_WAVE check.", flags)
		return NaN
	elseif(tol < 0)
		EvaluateResults(0, "Valid tolerance for EQUAL_WAVE check.", flags)
		return NaN
	endif

	for(i = 0; i < DimSize(modes, 0); i += 1)
		mode = modes[i]
		result = UTF_Checks#AreWavesEqual(wv1, wv2, mode, tol, detailedMsg)

		name1 = UTF_Utils#GetWaveNameInDFStr(wv1)
		name2 = UTF_Utils#GetWaveNameInDFStr(wv2)
		sprintf str, "Assuming equality using mode %s for waves %s and %s", EqualWavesModeToString(mode), name1, name2

		if(!UTF_Utils#IsEmpty(detailedMsg))
			str += "; detailed: " + detailedMsg
		endif

		EvaluateResults(result, str, flags, cleanupInfo = 0)
	endfor

	UTF_Basics#CleanupInfoMsg()
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsLessOrEqual(var1, var2)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsLess(var1, var2)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsLessOrEqual(var2, var1)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
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

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsLess(var2, var1)
	tmpStr1 = UTF_Utils#GetNiceStringForNumber(var1, isDouble = 1)
	tmpStr2 = UTF_Utils#GetNiceStringForNumber(var2, isDouble = 1)
	sprintf str, "%s > %s", tmpStr1, tmpStr2
	EvaluateResults(result, str, flags)
End
