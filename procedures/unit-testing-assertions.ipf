#pragma rtGlobals=3
#pragma version=1.08
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt

/// Steps for adding new test assertions:
/// - Add the test you want to perform to `unit-testing-assertion-checks.ipf`, these
///   functions must return 0/1 from their input parameters. No access of globals
///   is allowed here.
/// - Add a wrapper function which also handles error
///   reporting to unit-testing-assertion-wrappers.ipf
/// - Document the `*_WRAPPER` function using "@class *_DOCU" without the flags parameter
/// - Add WARN/CHECK/REQUIRE variants in this file
/// - Use `copydoc *_DOCU` for copying the documentation to the test assertions
/// - Write tests for the check function in `unit-testing-assertion-checks.ipf`
///   and the `CHECK_*` assertion in `VTTE.ipf`

/// @addtogroup Assertions
/// @{

/// Increase the assertion counter only
Function PASS()
	UTF_Wrapper#TRUE_WRAPPER(1, REQUIRE_MODE)
End

/// Force the test case to fail
Function FAIL()
	UTF_Wrapper#TRUE_WRAPPER(0, REQUIRE_MODE)
End

/// @copydoc TRUE_DOCU
Function WARN(var)
	variable var

	UTF_Wrapper#TRUE_WRAPPER(var, WARN_MODE)
End

/// @copydoc TRUE_DOCU
Function CHECK(var)
	variable var

	UTF_Wrapper#TRUE_WRAPPER(var, CHECK_MODE)
End

/// @copydoc TRUE_DOCU
Function REQUIRE(var)
	variable var

	UTF_Wrapper#TRUE_WRAPPER(var, REQUIRE_MODE)
End

/// @copydoc EQUAL_VAR_DOCU
Function WARN_EQUAL_VAR(var1, var2)
	variable var1, var2

	UTF_Wrapper#EQUAL_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc EQUAL_VAR_DOCU
Function CHECK_EQUAL_VAR(var1, var2)
	variable var1, var2

	UTF_Wrapper#EQUAL_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc EQUAL_VAR_DOCU
Function REQUIRE_EQUAL_VAR(var1, var2)
	variable var1, var2

	UTF_Wrapper#EQUAL_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc NEQ_VAR_DOCU
Function WARN_NEQ_VAR(var1, var2)
	variable var1, var2

	UTF_Wrapper#NEQ_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc NEQ_VAR_DOCU
Function CHECK_NEQ_VAR(var1, var2)
	variable var1, var2

	UTF_Wrapper#NEQ_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc NEQ_VAR_DOCU
Function REQUIRE_NEQ_VAR(var1, var2)
	variable var1, var2

	UTF_Wrapper#NEQ_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc CLOSE_VAR_DOCU
Function WARN_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
	variable tol
	variable strong_or_weak

	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, tol=tol)
	else
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// @copydoc CLOSE_VAR_DOCU
Function CHECK_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
	variable tol
	variable strong_or_weak

	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, tol=tol)
	else
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// @copydoc CLOSE_VAR_DOCU
Function REQUIRE_CLOSE_VAR(var1, var2, [tol, strong_or_weak])
	variable var1, var2
	variable tol
	variable strong_or_weak

	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE, tol=tol)
	else
		UTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// @copydoc CLOSE_CMPLX_DOCU
Function WARN_CLOSE_CMPLX(var1, var2 [tol, strong_or_weak])
	variable/C var1, var2
	variable tol, strong_or_weak

	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE, tol=tol)
	else
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// @copydoc CLOSE_CMPLX_DOCU
Function CHECK_CLOSE_CMPLX(var1, var2 [tol, strong_or_weak])
	variable/C var1, var2
	variable tol, strong_or_weak

	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE, tol=tol)
	else
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// @copydoc CLOSE_CMPLX_DOCU
Function REQUIRE_CLOSE_CMPLX(var1, var2 [tol, strong_or_weak])
	variable/C var1, var2
	variable tol, strong_or_weak

	if(ParamIsDefault(tol) && ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE, strong_or_weak=strong_or_weak)
	elseif(ParamIsDefault(strong_or_weak))
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE, tol=tol)
	else
		UTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE, tol=tol, strong_or_weak=strong_or_weak)
	endif
End

/// @copydoc SMALL_VAR_DOCU
Function WARN_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		UTF_Wrapper#SMALL_VAR_WRAPPER(var, WARN_MODE)
	else
		UTF_Wrapper#SMALL_VAR_WRAPPER(var, WARN_MODE, tol=tol)
	endif
End

/// @copydoc SMALL_VAR_DOCU
Function CHECK_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		UTF_Wrapper#SMALL_VAR_WRAPPER(var, CHECK_MODE)
	else
		UTF_Wrapper#SMALL_VAR_WRAPPER(var, CHECK_MODE, tol=tol)
	endif
End

/// @copydoc SMALL_VAR_DOCU
Function REQUIRE_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		UTF_Wrapper#SMALL_VAR_WRAPPER(var, REQUIRE_MODE)
	else
		UTF_Wrapper#SMALL_VAR_WRAPPER(var, REQUIRE_MODE, tol=tol)
	endif
End

/// @copydoc SMALL_CMPLX_DOCU
Function WARN_SMALL_CMPLX(var, [tol])
	variable/C var
	variable tol

	if(ParamIsDefault(tol))
		UTF_Wrapper#SMALL_CMPLX_WRAPPER(var, WARN_MODE)
	else
		UTF_Wrapper#SMALL_CMPLX_WRAPPER(var, WARN_MODE, tol=tol)
	endif
End

/// @copydoc SMALL_CMPLX_DOCU
Function CHECK_SMALL_CMPLX(var, [tol])
	variable/C var
	variable tol

	if(ParamIsDefault(tol))
		UTF_Wrapper#SMALL_CMPLX_WRAPPER(var, CHECK_MODE)
	else
		UTF_Wrapper#SMALL_CMPLX_WRAPPER(var, CHECK_MODE, tol=tol)
	endif
End

/// @copydoc SMALL_CMPLX_DOCU
Function REQUIRE_SMALL_CMPLX(var, [tol])
	variable/C var
	variable tol

	if(ParamIsDefault(tol))
		UTF_Wrapper#SMALL_CMPLX_WRAPPER(var, REQUIRE_MODE)
	else
		UTF_Wrapper#SMALL_CMPLX_WRAPPER(var, REQUIRE_MODE, tol=tol)
	endif
End

/// @copydoc EMPTY_STR_DOCU
Function WARN_EMPTY_STR(str)
	string &str

	UTF_Wrapper#EMPTY_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc EMPTY_STR_DOCU
Function CHECK_EMPTY_STR(str)
	string &str

	UTF_Wrapper#EMPTY_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc EMPTY_STR_DOCU
Function REQUIRE_EMPTY_STR(str)
	string &str

	UTF_Wrapper#EMPTY_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc NON_EMPTY_STR_DOCU
Function WARN_NON_EMPTY_STR(str)
	string &str

	UTF_Wrapper#NON_EMPTY_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc NON_EMPTY_STR_DOCU
Function CHECK_NON_EMPTY_STR(str)
	string &str

	UTF_Wrapper#NON_EMPTY_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc NON_EMPTY_STR_DOCU
Function REQUIRE_NON_EMPTY_STR(str)
	string &str

	UTF_Wrapper#NON_EMPTY_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc PROPER_STR_DOCU
Function WARN_PROPER_STR(str)
	string &str

	UTF_Wrapper#PROPER_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc PROPER_STR_DOCU
Function CHECK_PROPER_STR(str)
	string &str

	UTF_Wrapper#PROPER_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc PROPER_STR_DOCU
Function REQUIRE_PROPER_STR(str)
	string &str

	UTF_Wrapper#PROPER_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc NULL_STR_DOCU
Function WARN_NULL_STR(str)
	string &str

	UTF_Wrapper#NULL_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc NULL_STR_DOCU
Function CHECK_NULL_STR(str)
	string &str

	UTF_Wrapper#NULL_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc NULL_STR_DOCU
Function REQUIRE_NULL_STR(str)
	string &str

	UTF_Wrapper#NULL_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc NON_NULL_STR_DOCU
Function WARN_NON_NULL_STR(str)
	string &str

	UTF_Wrapper#NON_NULL_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc NON_NULL_STR_DOCU
Function CHECK_NON_NULL_STR(str)
	string &str

	UTF_Wrapper#NON_NULL_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc NON_NULL_STR_DOCU
Function REQUIRE_NON_NULL_STR(str)
	string &str

	UTF_Wrapper#NON_NULL_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc EQUAL_STR_DOCU
Function WARN_EQUAL_STR(str1, str2, [case_sensitive])
	string &str1, &str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		UTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, WARN_MODE)
	else
		UTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, WARN_MODE, case_sensitive=case_sensitive)
	endif
End

/// @copydoc EQUAL_STR_DOCU
Function CHECK_EQUAL_STR(str1, str2, [case_sensitive])
	string &str1, &str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		UTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, CHECK_MODE)
	else
		UTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, CHECK_MODE, case_sensitive=case_sensitive)
	endif
End

/// @copydoc EQUAL_STR_DOCU
Function REQUIRE_EQUAL_STR(str1, str2, [case_sensitive])
	string &str1, &str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		UTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, REQUIRE_MODE)
	else
		UTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, REQUIRE_MODE, case_sensitive=case_sensitive)
	endif
End

/// @copydoc NEQ_STR_DOCU
Function WARN_NEQ_STR(str1, str2, [case_sensitive])
	string &str1, &str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		UTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, WARN_MODE)
	else
		UTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, WARN_MODE, case_sensitive=case_sensitive)
	endif
End

/// @copydoc NEQ_STR_DOCU
Function CHECK_NEQ_STR(str1, str2, [case_sensitive])
	string &str1, &str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		UTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, CHECK_MODE)
	else
		UTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, CHECK_MODE, case_sensitive=case_sensitive)
	endif
End

/// @copydoc NEQ_STR_DOCU
Function REQUIRE_NEQ_STR(str1, str2, [case_sensitive])
	string &str1, &str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		UTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, REQUIRE_MODE)
	else
		UTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, REQUIRE_MODE, case_sensitive=case_sensitive)
	endif
End

/// @copydoc WAVE_DOCU
Function WARN_WAVE(wv, majorType, [minorType])
	Wave/Z wv
	variable majorType, minorType

	if(ParamIsDefault(minorType))
		UTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, WARN_MODE)
	else
		UTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, WARN_MODE, minorType=minorType)
	endif
End

/// @copydoc WAVE_DOCU
Function CHECK_WAVE(wv, majorType, [minorType])
	Wave/Z wv
	variable majorType, minorType

	if(ParamIsDefault(minorType))
		UTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, CHECK_MODE)
	else
		UTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, CHECK_MODE, minorType=minorType)
	endif
End

/// @copydoc WAVE_DOCU
Function REQUIRE_WAVE(wv, majorType, [minorType])
	Wave/Z wv
	variable majorType, minorType

	if(ParamIsDefault(minorType))
		UTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, REQUIRE_MODE)
	else
		UTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, REQUIRE_MODE, minorType=minorType)
	endif
End

/// @copydoc EQUAL_WAVE_DOCU
Function WARN_EQUAL_WAVES(wv1, wv2, [mode, tol])
	Wave/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
			UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode=mode)
	elseif(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, tol=tol)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, tol=tol, mode=mode)
	endif
End

/// @copydoc EQUAL_WAVE_DOCU
Function CHECK_EQUAL_WAVES(wv1, wv2, [mode, tol])
	Wave/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode=mode)
	elseif(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, tol=tol)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, tol=tol, mode=mode)
	endif
End

/// @copydoc EQUAL_WAVE_DOCU
Function REQUIRE_EQUAL_WAVES(wv1, wv2, [mode, tol])
	Wave/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE)
	elseif(ParamIsDefault(tol))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, mode=mode)
	elseif(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, tol=tol)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, tol=tol, mode=mode)
	endif
End

#if (IgorVersion() >= 7.00)

Function WARN_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	Wave/Z/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode=mode)
	endif
End

Function CHECK_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	Wave/Z/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode=mode)
	endif
End

Function REQUIRE_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	Wave/Z/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, mode=mode)
	endif
End

#else

/// @class TEXT_WAVE_EQUAL_DOCU
/// Tests two text waves for equality
///
/// @param wv1    first text wave, can be invalid for Igor Pro 7 or later
/// @param wv2    second text wave, can be invalid for Igor Pro 7 or later
/// @param mode   (optional) features of the waves to compare, defaults to all modes, defined at @ref equalWaveFlags

/// @copydoc TEXT_WAVE_EQUAL_DOCU
Function WARN_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	Wave/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode=mode)
	endif
End

/// @copydoc TEXT_WAVE_EQUAL_DOCU
Function CHECK_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	Wave/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode=mode)
	endif
End

/// @copydoc TEXT_WAVE_EQUAL_DOCU
Function REQUIRE_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	Wave/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE)
	else
		UTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, mode=mode)
	endif
End

#endif

/// @copydoc CDF_EMPTY_DOCU
Function WARN_EMPTY_FOLDER()
	UTF_Wrapper#CDF_EMPTY_WRAPPER(WARN_MODE)
End

/// @copydoc CDF_EMPTY_DOCU
Function CHECK_EMPTY_FOLDER()
	UTF_Wrapper#CDF_EMPTY_WRAPPER(CHECK_MODE)
End

/// @copydoc CDF_EMPTY_DOCU
Function REQUIRE_EMPTY_FOLDER()
	UTF_Wrapper#CDF_EMPTY_WRAPPER(REQUIRE_MODE)
End

///@}
