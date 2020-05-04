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
	ReportResults(result, "Assumption that the current data folder is empty is", flags)
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
	ReportResults(result, num2istr(var), flags)
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
	ReportResults(result, "Assumption that str is null is", flags)
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
	ReportResults(result, "Assumption that the string is empty is", flags)
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
	ReportResults(result, "Assumption of the string being non null is", flags)
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
	ReportResults(result, "Assumption that the string is non empty is", flags)
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
	ReportResults(result, "Assumption that the string is a proper string is", flags)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = !UTF_Checks#AreVariablesEqual(var1, var2)
	sprintf str, "%g != %g", var1, var2
	ReportResults(result, str, flags)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif

	result = !UTF_Checks#AreStringsEqual(str1, str2, case_sensitive)
	sprintf str, "\"%s\" != \"%s\" %s case", SelectString(UTF_Checks#IsNullString(str1), str1, "(null)"), SelectString(UTF_Checks#IsNullString(str2), str2, "(null)"), SelectString(case_sensitive, "not respecting", "respecting")

	ReportResults(result, str, flags)
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
	string str

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
	sprintf str, "%g ~ %g with %s check and tol %g", var1, var2, SelectString(strong, "weak", "strong"), tol
	ReportResults(result, str, flags)
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
	string str

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
	sprintf str, "(%g, %g) ~ (%g, %g) with %s check and tol %g", real(var1), imag(var1), real(var2), imag(var2), SelectString(strong, "weak", "strong"), tol
	ReportResults(result, str, flags)
End

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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result = UTF_Checks#IsVariableSmall(var, tol)
	sprintf str, "%g ~ 0 with tol %g", var, tol
	ReportResults(result, str, flags)
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(tol))
		tol = DEFAULT_TOLERANCE
	endif

	result = UTF_Checks#IsVariableSmall(cabs(var), tol)
	sprintf str, "(%g, %g) ~ 0 with tol %g", real(var), imag(var), tol
	ReportResults(result, str, flags)
End

/// @class EQUAL_STR_DOCU
/// Compares two strings for equality.
///
/// @param str1           first string
/// @param str2           second string
/// @param case_sensitive (optional) should the comparison be done case sensitive (1) or case insensitive (0, the default)
static Function EQUAL_STR_WRAPPER(str1, str2, flags, [case_sensitive])
	string &str1, &str2
	variable case_sensitive
	variable flags

	variable result
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	if(ParamIsDefault(case_sensitive))
		case_sensitive = 0
	endif

	result = UTF_Checks#AreStringsEqual(str1, str2, case_sensitive)
	sprintf str, "\"%s\" == \"%s\" %s case", SelectString(UTF_Checks#IsNullString(str1), str1, "(null)"), SelectString(UTF_Checks#IsNullString(str2), str2, "(null)"), SelectString(case_sensitive, "not respecting", "respecting")
	ReportResults(result, str, flags)
End

/// @class WAVE_DOCU
/// Tests a wave for existence and its type
///
/// @param wv         wave reference
/// @param majorType  major wave type
/// @param minorType  (optional) minor wave type
/// @see testWaveFlags
static Function TEST_WAVE_WRAPPER(wv, majorType, flags, [minorType])
	Wave/Z wv
	variable majorType, minorType
	variable flags

	variable result
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#HasWaveMajorType(wv, majorType)
	sprintf str, "Assumption that the wave's main type is %d", majorType
	ReportResults(result, str, flags)

	if(!ParamIsDefault(minorType))
		result = UTF_Checks#HasWaveMinorType(wv, minorType)
		sprintf str, "Assumption that the wave's sub type is %d", minorType
		ReportResults(result, str, flags)
	endif
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
	string str

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = UTF_Checks#AreVariablesEqual(var1, var2)
	sprintf str, "%g == %g", var1, var2
	ReportResults(result, str, flags)
End

/// @class EQUAL_WAVE_DOCU
/// Tests two waves for equality
///
/// @param wv1    first wave
/// @param wv2    second wave
/// @param mode   (optional) features of the waves to compare, defaults to all modes, defined at @ref equalWaveFlags
/// @param tol    (optional) tolerance for comparison, by default 0.0 which does byte-by-byte comparison (relevant only for mode=WAVE_DATA)
static Function EQUAL_WAVE_WRAPPER(wv1, wv2, flags, [mode, tol])
	Wave/Z wv1, wv2
	variable flags
	variable mode, tol

	variable i, result
	string str, detailedMsg

	incrAssert()

	if(shouldDoAbort())
		return NaN
	endif

	result = WaveExists(wv1)
	ReportResults(result, "Assumption that the first wave (wv1) exists", flags)

	if(!result)
		return NaN
	endif

	result = WaveExists(wv2)
	ReportResults(result, "Assumption that the second wave (wv2) exists", flags)

	if(!result)
		return NaN
	endif

	result = !WaveRefsEqual(wv1, wv2)
	ReportResults(result, "Assumption that both waves are distinct", flags)

	if(!result)
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
		result = UTF_Checks#AreWavesEqual(wv1, wv2, mode, tol, detailedMsg)

		sprintf str, "Assuming equality using mode %s for waves %s and %s", EqualWavesModeToString(mode), NameOfWave(wv1), NameOfWave(wv2)

		if(!UTF_Utils#IsEmpty(detailedMsg))
			str += "; detailed: " + detailedMsg
		endif

		ReportResults(result, str, flags)
	endfor
End
