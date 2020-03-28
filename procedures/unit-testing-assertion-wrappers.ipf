#pragma rtGlobals=3
#pragma version=1.08
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Wrapper

// Licensed under 3-Clause BSD, see License.txt

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

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif

	SetTestStatusAndDebug("Assumption that the current data folder is empty is", result)
End

/// @class TRUE_DOCU
/// Tests if var is true (1).
/// @param var    variable to test
static Function TRUE_WRAPPER(var, flags)
	variable var
	variable flags

	variable result

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#IsTrue(var)
	SetTestStatusAndDebug(num2istr(var), result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
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
	SetTestStatusAndDebug("Assumption of str being null is ", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
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
	SetTestStatusAndDebug("Assumption that the string is empty is", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
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
	SetTestStatusAndDebug("Assumption that the string is not null is", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
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
	SetTestStatusAndDebug("Assumption that the string is non empty is", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
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
	SetTestStatusAndDebug("Assumption that the string is a proper string is", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class NEQ_VAR_DOCU
/// Tests two variables for inequality
/// @param var1    first variable
/// @param var2    second variable
static Function NEQ_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(UTF_Checks#EQUAL_VAR(var1, var2))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class NEQ_STR_DOCU
/// Compares two strings for unequality
/// @param str1            first string
/// @param str2            second string
/// @param case_sensitive  (optional) should the comparison be done case sensitive (1) or case insensitive (0, the default)
static Function NEQ_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string &str1, &str2
	variable case_sensitive
	variable flags

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif

	if(UTF_Checks#EQUAL_STR(str1, str2, case_sensitive))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
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
/// @param var1            first variable
/// @param var2            second variable
/// @param tol             (optional) tolerance, defaults to 1e-8
/// @param strong_or_weak  (optional) type of condition, can be 0 for weak or 1 for strong (default)
static Function CLOSE_VAR_WRAPPER(var1, var2, flags, [tol, strong_or_weak])
	variable var1, var2
	variable flags
	variable tol
	variable strong_or_weak

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(strong_or_weak))
		strong_or_weak  = CLOSE_COMPARE_STRONG_OR_WEAK
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	if(!UTF_Checks#CLOSE_VAR(var1, var2, tol, strong_or_weak))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class CLOSE_CMPLX_DOCU
/// @copydoc CLOSE_VAR_DOCU
///
/// Variant for complex numbers.
static Function CLOSE_CMPLX_WRAPPER(var1, var2, flags, [tol, strong_or_weak])
	variable/C var1, var2
	variable flags
	variable tol
	variable strong_or_weak

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(strong_or_weak))
		strong_or_weak  = CLOSE_COMPARE_STRONG_OR_WEAK
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	if(!UTF_Checks#CLOSE_VAR(real(var1), real(var2), tol, strong_or_weak) || !UTF_Checks#CLOSE_VAR(imag(var1), imag(var2), tol, strong_or_weak))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class SMALL_VAR_DOCU
/// Tests if a variable is small using the inequality @f$  | var | < | tol |  @f$
/// @param var        variable
/// @param tol        (optional) tolerance, defaults to 1e-8
static Function SMALL_VAR_WRAPPER(var, flags, [tol])
	variable var
	variable flags
	variable tol

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	if(!UTF_Checks#SMALL_VAR(var, tol))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class SMALL_CMPLX_DOCU
/// @copydoc SMALL_VAR_DOCU
///
/// Variant for complex numbers
static Function SMALL_CMPLX_WRAPPER(var, flags, [tol])
	variable/C var
	variable flags
	variable tol

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	if(!UTF_Checks#SMALL_VAR(cabs(var), tol))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class EQUAL_STR_DOCU
/// Compares two strings for equality.
/// @param str1           first string
/// @param str2           second string
/// @param case_sensitive (optional) should the comparison be done case sensitive (1) or case insensitive (0, the default)
static Function EQUAL_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string &str1, &str2
	variable case_sensitive
	variable flags

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif

	if(!UTF_Checks#EQUAL_STR(str1, str2, case_sensitive))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class WAVE_DOCU
/// Tests a wave for existence and its type
/// @param wv         wave reference
/// @param majorType  major wave type
/// @param minorType  (optional) minor wave type
/// @see testWaveFlags
static Function TEST_WAVE_WRAPPER(wv, majorType, flags, [minorType])
	Wave/Z wv
	variable majorType, minorType
	variable flags

	variable result, type, type1, type2
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	type2 = WaveType(wv, 2)
	type1 = WaveType(wv, 1)
	if(type1 > 0 && type1 <= 4)
		type = type | 2^(type1 - 1)
	endif
	if(type2 > 0 && type2 <= 2)
		type = type | 2^(type2 + 3)
	endif

	if((type1 == 0 && type2 == 0) || !WaveExists(wv))
		type = NULL_WAVE
	endif

	result = (type & majorType) == majorType

	sprintf str, "Assumption that the wave's main type is %d", majorType
	SetTestStatusAndDebug(str, result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif

	if(!ParamIsDefault(minorType))
		type = WaveExists(wv) ? WaveType(wv, 0) : NULL_WAVE

		result = (type & minorType) == minorType
		sprintf str, "Assumption that the wave's sub type is %d", minorType
		SetTestStatusAndDebug(str, result)

		if(!result)
			if(flags & OUTPUT_MESSAGE)
				printFailInfo()
			endif
			if(flags & INCREASE_ERROR)
				incrError()
			endif
			if(flags & ABORT_FUNCTION)
				abortNow()
			endif
		endif
	endif
End

/// @class EQUAL_VAR_DOCU
/// Tests two variables for equality.
///
/// For variables holding floating point values it is often more desirable use CHECK_CLOSE_VAR instead. To fullfill semantic correctness this assertion treats two variables with both holding NaN as equal.
/// @param var1   first variable
/// @param var2   second variable
static Function EQUAL_VAR_WRAPPER(var1, var2, flags)
	variable var1, var2
	variable flags

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(!UTF_Checks#EQUAL_VAR(var1, var2))
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
	endif
End

/// @class EQUAL_WAVE_DOCU
/// Tests two waves for equality
/// @param wv1    first wave
/// @param wv2    second wave
/// @param mode   (optional) features of the waves to compare, defaults to all modes, defined at @ref equalWaveFlags
/// @param tol    (optional) tolerance for comparison, by default 0.0 which does byte-by-byte comparison (relevant only for mode=WAVE_DATA)
static Function EQUAL_WAVE_WRAPPER(wv1, wv2, flags, [mode, tol])
	Wave/Z wv1, wv2
	variable flags
	variable mode, tol

	variable i
	string str, detailedMsg

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	variable result = WaveExists(wv1)
	SetTestStatusAndDebug("Assumption that the first wave (wv1) exists", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
		return NaN
	endif

	result = WaveExists(wv2)
	SetTestStatusAndDebug("Assumption that the second wave (wv2) exists", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
		return NaN
	endif

	result = !WaveRefsEqual(wv1, wv2)
	SetTestStatusAndDebug("Assumption that both waves are distinct", result)

	if(!result)
		if(flags & OUTPUT_MESSAGE)
			printFailInfo()
		endif
		if(flags & INCREASE_ERROR)
			incrError()
		endif
		if(flags & ABORT_FUNCTION)
			abortNow()
		endif
		return NaN
	endif

	if(ParamIsDefault(mode))
		Make/I/FREE modes = { WAVE_DATA, WAVE_DATA_TYPE, WAVE_SCALING, DATA_UNITS, DIMENSION_UNITS, DIMENSION_LABELS, WAVE_NOTE, WAVE_LOCK_STATE, DATA_FULL_SCALE, DIMENSION_SIZES}
	else
		Make/I/FREE modes = { mode }
	endif

	if(ParamIsDefault(tol))
		tol = 0.0
	endif

	for(i = 0; i < DimSize(modes, 0); i += 1)
		mode = modes[i]

		// handle NaN return values from EqualWaves for unknown modes
		result = EqualWaves(wv1, wv2, mode, tol) == 1

		detailedMsg = ""

		// work around buggy EqualWaves versions which detect some
		// waves as differing but they are not in reality
		if(!result && mode == DIMENSION_LABELS)
#if IgorVersion() >= 9.0
			GenerateDimLabelDifference(wv1, wv2, detailedMsg)
#elif IgorVersion() >= 8.0
#if NumberByKey("BUILD", IgorInfo(0)) >= 33425
			GenerateDimLabelDifference(wv1, wv2, detailedMsg)
#else // old IP8
			result = GenerateDimLabelDifference(wv1, wv2, detailedMsg)
#endif
#else // IP7 and older
			result = GenerateDimLabelDifference(wv1, wv2, detailedMsg)
#endif
		endif

		sprintf str, "Assuming equality using mode %s for waves %s and %s", EqualWavesModeToString(mode), NameOfWave(wv1), NameOfWave(wv2)

		if(!UTF_Utils#IsEmpty(detailedMsg))
			str += "; detailed: " + detailedMsg
		endif

		SetTestStatusAndDebug(str, result)

		if(!result)
			if(flags & OUTPUT_MESSAGE)
				printFailInfo()
			endif
			if(flags & INCREASE_ERROR)
				incrError()
			endif
			if(flags & ABORT_FUNCTION)
				abortNow()
			endif
		endif
	endfor
End
