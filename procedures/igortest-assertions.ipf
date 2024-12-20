#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Assertion

/// Steps for adding new test assertions:
/// - Add the test you want to perform to `igortest-assertion-checks.ipf`, these
///   functions must return 0/1 from their input parameters. No access of globals
///   is allowed here.
/// - Add a wrapper function which also handles error
///   reporting to igortest-assertion-wrappers.ipf
/// - Document the `*_WRAPPER` function using "@class *_DOCU" without the flags parameter
/// - Add WARN/CHECK/REQUIRE variants in this file
/// - Use `copydoc *_DOCU` for copying the documentation to the test assertions
/// - Write tests for the check function in `igortest-assertion-checks.ipf`
///   and the `CHECK_*` assertion in `VTTE.ipf`

/// @addtogroup Assertions
/// @{

/// Increase the assertion counter only
Function PASS()
	IUTF_Wrapper#TRUE_WRAPPER(1, REQUIRE_MODE)
End

/// Force the test case to fail
Function FAIL()
	IUTF_Wrapper#TRUE_WRAPPER(0, REQUIRE_MODE)
End

/// Skips current test case
///
/// The test case is aborted.
/// Already failed assertions are treated as expected failure.
/// Any registered reentry is automatically unregistered.
Function SKIP_TESTCASE_EXPECT_FAILS()
	IUTF_Basics#SetExpectedFailure(1)
	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_SKIP
	SKIP_TESTCASE()
End

/// Skips current test case
///
/// The test case is aborted.
/// Any registered reentry is automatically unregistered.
Function SKIP_TESTCASE()
	IUTF_Reporting#IUTF_PrintStatusMessage("Skipping test case")
	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	if(!CmpStr(wvTestCase[%CURRENT][%STATUS], IUTF_STATUS_RUNNING))
		wvTestCase[%CURRENT][%STATUS] = IUTF_STATUS_SKIP
	endif

	IUTF_Reporting#incrAssert()

	IUTF_Reporting#ShowInfoMsg()
	IUTF_Reporting#CleanupInfoMsg()

	UnRegisterIUTFMonitor()

	IUTF_Basics#SetAbortFromSkipFlag()
	Abort
End

/// Append information to the next assertion to print if failed
Function INFO(format, [s, n, s0, s1, s2, s3, s4, n0, n1, n2, n3, n4])
	string format
	WAVE/T s
	WAVE   n
	string s0, s1, s2, s3, s4
	variable n0, n1, n2, n3, n4

	variable stringLength = 0
	variable numberLength = 0

	if(ParamIsDefault(s))
		Make/FREE/T/N=5 wv
		WAVE/T s = wv
		if(!ParamIsDefault(s0))
			s[stringLength] = s0
			stringLength   += 1
		endif
		if(!ParamIsDefault(s1))
			s[stringLength] = s1
			stringLength   += 1
		endif
		if(!ParamIsDefault(s2))
			s[stringLength] = s2
			stringLength   += 1
		endif
		if(!ParamIsDefault(s3))
			s[stringLength] = s3
			stringLength   += 1
		endif
		if(!ParamIsDefault(s4))
			s[stringLength] = s4
			stringLength   += 1
		endif
		Redimension/N=(stringLength) s
	elseif(!ParamIsDefault(s0) || !ParamIsDefault(s1) || !ParamIsDefault(s2) || !ParamIsDefault(s3) || !ParamIsDefault(s4))
		EvaluateResults(0, "Cannot mix single string with wave parameter", REQUIRE_MODE)
	endif

	if(ParamIsDefault(n))
		Make/FREE/N=5 numbers
		WAVE n = numbers
		if(!ParamIsDefault(n0))
			numbers[numberLength] = n0
			numberLength         += 1
		endif
		if(!ParamIsDefault(n1))
			numbers[numberLength] = n1
			numberLength         += 1
		endif
		if(!ParamIsDefault(n2))
			numbers[numberLength] = n2
			numberLength         += 1
		endif
		if(!ParamIsDefault(n3))
			numbers[numberLength] = n3
			numberLength         += 1
		endif
		if(!ParamIsDefault(n4))
			numbers[numberLength] = n4
			numberLength         += 1
		endif
		Redimension/N=(numberLength) numbers
	elseif(!ParamIsDefault(n0) || !ParamIsDefault(n1) || !ParamIsDefault(n2) || !ParamIsDefault(n3) || !ParamIsDefault(n4))
		EvaluateResults(0, "Cannot mix single number with wave parameter", REQUIRE_MODE)
	endif

	IUTF_WRAPPER#INFO_WRAPPER(format, s, n, CHECK_MODE)
End

/// @copydoc TRUE_DOCU
Function WARN(var)
	variable var

	IUTF_Wrapper#TRUE_WRAPPER(var, WARN_MODE)
End

/// @copydoc TRUE_DOCU
Function CHECK(var)
	variable var

	IUTF_Wrapper#TRUE_WRAPPER(var, CHECK_MODE)
End

/// @copydoc TRUE_DOCU
Function REQUIRE(var)
	variable var

	IUTF_Wrapper#TRUE_WRAPPER(var, REQUIRE_MODE)
End

/// @copydoc EQUAL_VAR_DOCU
Function WARN_EQUAL_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#EQUAL_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc EQUAL_VAR_DOCU
Function CHECK_EQUAL_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#EQUAL_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc EQUAL_VAR_DOCU
Function REQUIRE_EQUAL_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#EQUAL_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.0
/// @endcond

/// @copydoc EQUAL_INT64_DOCU
Function WARN_EQUAL_INT64(int64 var1, int64 var2)
	IUTF_Wrapper#EQUAL_INT64_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc EQUAL_INT64_DOCU
Function CHECK_EQUAL_INT64(int64 var1, int64 var2)
	IUTF_Wrapper#EQUAL_INT64_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc EQUAL_INT64_DOCU
Function REQUIRE_EQUAL_INT64(int64 var1, int64 var2)
	IUTF_Wrapper#EQUAL_INT64_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc EQUAL_UINT64_DOCU
Function WARN_EQUAL_UINT64(uint64 var1, uint64 var2)
	IUTF_Wrapper#EQUAL_UINT64_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc EQUAL_UINT64_DOCU
Function CHECK_EQUAL_UINT64(uint64 var1, uint64 var2)
	IUTF_Wrapper#EQUAL_UINT64_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc EQUAL_UINT64_DOCU
Function REQUIRE_EQUAL_UINT64(uint64 var1, uint64 var2)
	IUTF_Wrapper#EQUAL_UINT64_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @copydoc LESS_EQUAL_VAR_DOCU
Function WARN_LE_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#LESS_EQUAL_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc LESS_EQUAL_VAR_DOCU
Function CHECK_LE_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#LESS_EQUAL_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc LESS_EQUAL_VAR_DOCU
Function REQUIRE_LE_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#LESS_EQUAL_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc LESS_THAN_VAR_DOCU
Function WARN_LT_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#LESS_THAN_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc LESS_THAN_VAR_DOCU
Function CHECK_LT_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#LESS_THAN_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc LESS_THAN_VAR_DOCU
Function REQUIRE_LT_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#LESS_THAN_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc GREATER_EQUAL_VAR_DOCU
Function WARN_GE_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#GREATER_EQUAL_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc GREATER_EQUAL_VAR_DOCU
Function CHECK_GE_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#GREATER_EQUAL_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc GREATER_EQUAL_VAR_DOCU
Function REQUIRE_GE_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#GREATER_EQUAL_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc GREATER_THAN_VAR_DOCU
Function WARN_GT_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#GREATER_THAN_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc GREATER_THAN_VAR_DOCU
Function CHECK_GT_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#GREATER_THAN_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc GREATER_THAN_VAR_DOCU
Function REQUIRE_GT_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#GREATER_THAN_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc NEQ_VAR_DOCU
Function WARN_NEQ_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#NEQ_VAR_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc NEQ_VAR_DOCU
Function CHECK_NEQ_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#NEQ_VAR_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc NEQ_VAR_DOCU
Function REQUIRE_NEQ_VAR(var1, var2)
	variable var1, var2

	IUTF_Wrapper#NEQ_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.0
/// @endcond

/// @copydoc NEQ_INT64_DOCU
Function WARN_NEQ_INT64(int64 var1, int64 var2)
	IUTF_Wrapper#NEQ_INT64_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc NEQ_INT64_DOCU
Function CHECK_NEQ_INT64(int64 var1, int64 var2)
	IUTF_Wrapper#NEQ_INT64_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc NEQ_INT64_DOCU
Function REQUIRE_NEQ_INT64(int64 var1, int64 var2)
	IUTF_Wrapper#NEQ_INT64_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @copydoc NEQ_UINT64_DOCU
Function WARN_NEQ_UINT64(uint64 var1, uint64 var2)
	IUTF_Wrapper#NEQ_UINT64_WRAPPER(var1, var2, WARN_MODE)
End

/// @copydoc NEQ_UINT64_DOCU
Function CHECK_NEQ_UINT64(uint64 var1, uint64 var2)
	IUTF_Wrapper#NEQ_UINT64_WRAPPER(var1, var2, CHECK_MODE)
End

/// @copydoc NEQ_UINT64_DOCU
Function REQUIRE_NEQ_UINT64(uint64 var1, uint64 var2)
	IUTF_Wrapper#NEQ_UINT64_WRAPPER(var1, var2, REQUIRE_MODE)
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @copydoc CLOSE_VAR_DOCU
Function WARN_CLOSE_VAR(var1, var2, [tol, strong])
	variable var1, var2
	variable tol
	variable strong

	if(ParamIsDefault(tol) && ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, strong = strong)
	elseif(ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, tol = tol)
	else
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, WARN_MODE, tol = tol, strong = strong)
	endif
End

/// @copydoc CLOSE_VAR_DOCU
Function CHECK_CLOSE_VAR(var1, var2, [tol, strong])
	variable var1, var2
	variable tol
	variable strong

	if(ParamIsDefault(tol) && ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, strong = strong)
	elseif(ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, tol = tol)
	else
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, CHECK_MODE, tol = tol, strong = strong)
	endif
End

/// @copydoc CLOSE_VAR_DOCU
Function REQUIRE_CLOSE_VAR(var1, var2, [tol, strong])
	variable var1, var2
	variable tol
	variable strong

	if(ParamIsDefault(tol) && ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE, strong = strong)
	elseif(ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE, tol = tol)
	else
		IUTF_Wrapper#CLOSE_VAR_WRAPPER(var1, var2, REQUIRE_MODE, tol = tol, strong = strong)
	endif
End

/// @copydoc CLOSE_CMPLX_DOCU
Function WARN_CLOSE_CMPLX(var1, var2, [tol, strong])
	variable/C var1, var2
	variable tol, strong

	if(ParamIsDefault(tol) && ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE, strong = strong)
	elseif(ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE, tol = tol)
	else
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, WARN_MODE, tol = tol, strong = strong)
	endif
End

/// @copydoc CLOSE_CMPLX_DOCU
Function CHECK_CLOSE_CMPLX(var1, var2, [tol, strong])
	variable/C var1, var2
	variable tol, strong

	if(ParamIsDefault(tol) && ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE, strong = strong)
	elseif(ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE, tol = tol)
	else
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, CHECK_MODE, tol = tol, strong = strong)
	endif
End

/// @copydoc CLOSE_CMPLX_DOCU
Function REQUIRE_CLOSE_CMPLX(var1, var2, [tol, strong])
	variable/C var1, var2
	variable tol, strong

	if(ParamIsDefault(tol) && ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE, strong = strong)
	elseif(ParamIsDefault(strong))
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE, tol = tol)
	else
		IUTF_Wrapper#CLOSE_CMPLX_WRAPPER(var1, var2, REQUIRE_MODE, tol = tol, strong = strong)
	endif
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.0
/// @endcond

/// @copydoc CLOSE_INT64_DOCU
Function WARN_CLOSE_INT64(int64 var1, int64 var2, [int64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_INT64_WRAPPER(var1, var2, WARN_MODE)
	else
		IUTF_Wrapper#CLOSE_INT64_WRAPPER(var1, var2, WARN_MODE, tol = tol)
	endif
End

/// @copydoc CLOSE_INT64_DOCU
Function CHECK_CLOSE_INT64(int64 var1, int64 var2, [int64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_INT64_WRAPPER(var1, var2, CHECK_MODE)
	else
		IUTF_Wrapper#CLOSE_INT64_WRAPPER(var1, var2, CHECK_MODE, tol = tol)
	endif
End

/// @copydoc CLOSE_INT64_DOCU
Function REQUIRE_CLOSE_INT64(int64 var1, int64 var2, [int64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_INT64_WRAPPER(var1, var2, REQUIRE_MODE)
	else
		IUTF_Wrapper#CLOSE_INT64_WRAPPER(var1, var2, REQUIRE_MODE, tol = tol)
	endif
End

/// @copydoc CLOSE_UINT64_DOCU
Function WARN_CLOSE_UINT64(uint64 var1, uint64 var2, [uint64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_UINT64_WRAPPER(var1, var2, WARN_MODE)
	else
		IUTF_Wrapper#CLOSE_UINT64_WRAPPER(var1, var2, WARN_MODE, tol = tol)
	endif
End

/// @copydoc CLOSE_UINT64_DOCU
Function CHECK_CLOSE_UINT64(uint64 var1, uint64 var2, [uint64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_UINT64_WRAPPER(var1, var2, CHECK_MODE)
	else
		IUTF_Wrapper#CLOSE_UINT64_WRAPPER(var1, var2, CHECK_MODE, tol = tol)
	endif
End

/// @copydoc CLOSE_UINT64_DOCU
Function REQUIRE_CLOSE_UINT64(uint64 var1, uint64 var2, [uint64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#CLOSE_UINT64_WRAPPER(var1, var2, REQUIRE_MODE)
	else
		IUTF_Wrapper#CLOSE_UINT64_WRAPPER(var1, var2, REQUIRE_MODE, tol = tol)
	endif
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @copydoc SMALL_VAR_DOCU
Function WARN_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_VAR_WRAPPER(var, WARN_MODE)
	else
		IUTF_Wrapper#SMALL_VAR_WRAPPER(var, WARN_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_VAR_DOCU
Function CHECK_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_VAR_WRAPPER(var, CHECK_MODE)
	else
		IUTF_Wrapper#SMALL_VAR_WRAPPER(var, CHECK_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_VAR_DOCU
Function REQUIRE_SMALL_VAR(var, [tol])
	variable var
	variable tol

	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_VAR_WRAPPER(var, REQUIRE_MODE)
	else
		IUTF_Wrapper#SMALL_VAR_WRAPPER(var, REQUIRE_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_CMPLX_DOCU
Function WARN_SMALL_CMPLX(var, [tol])
	variable/C var
	variable   tol

	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_CMPLX_WRAPPER(var, WARN_MODE)
	else
		IUTF_Wrapper#SMALL_CMPLX_WRAPPER(var, WARN_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_CMPLX_DOCU
Function CHECK_SMALL_CMPLX(var, [tol])
	variable/C var
	variable   tol

	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_CMPLX_WRAPPER(var, CHECK_MODE)
	else
		IUTF_Wrapper#SMALL_CMPLX_WRAPPER(var, CHECK_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_CMPLX_DOCU
Function REQUIRE_SMALL_CMPLX(var, [tol])
	variable/C var
	variable   tol

	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_CMPLX_WRAPPER(var, REQUIRE_MODE)
	else
		IUTF_Wrapper#SMALL_CMPLX_WRAPPER(var, REQUIRE_MODE, tol = tol)
	endif
End

/// @cond HIDDEN_SYMBOL
#if IgorVersion() >= 7.0
/// @endcond

/// @copydoc SMALL_INT64_DOCU
Function WARN_SMALL_INT64(int64 var, [int64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_INT64_WRAPPER(var, WARN_MODE)
	else
		IUTF_Wrapper#SMALL_INT64_WRAPPER(var, WARN_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_INT64_DOCU
Function CHECK_SMALL_INT64(int64 var, [int64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_INT64_WRAPPER(var, CHECK_MODE)
	else
		IUTF_Wrapper#SMALL_INT64_WRAPPER(var, CHECK_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_INT64_DOCU
Function REQUIRE_SMALL_INT64(int64 var, [int64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_INT64_WRAPPER(var, REQUIRE_MODE)
	else
		IUTF_Wrapper#SMALL_INT64_WRAPPER(var, REQUIRE_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_UINT64_DOCU
Function WARN_SMALL_UINT64(uint64 var, [uint64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_UINT64_WRAPPER(var, WARN_MODE)
	else
		IUTF_Wrapper#SMALL_UINT64_WRAPPER(var, WARN_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_UINT64_DOCU
Function CHECK_SMALL_UINT64(uint64 var, [uint64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_UINT64_WRAPPER(var, CHECK_MODE)
	else
		IUTF_Wrapper#SMALL_UINT64_WRAPPER(var, CHECK_MODE, tol = tol)
	endif
End

/// @copydoc SMALL_UINT64_DOCU
Function REQUIRE_SMALL_UINT64(uint64 var, [uint64 tol])
	if(ParamIsDefault(tol))
		IUTF_Wrapper#SMALL_UINT64_WRAPPER(var, REQUIRE_MODE)
	else
		IUTF_Wrapper#SMALL_UINT64_WRAPPER(var, REQUIRE_MODE, tol = tol)
	endif
End

/// @cond HIDDEN_SYMBOL
#endif
/// @endcond

/// @copydoc EMPTY_STR_DOCU
Function WARN_EMPTY_STR(str)
	string &str

	IUTF_Wrapper#EMPTY_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc EMPTY_STR_DOCU
Function CHECK_EMPTY_STR(str)
	string &str

	IUTF_Wrapper#EMPTY_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc EMPTY_STR_DOCU
Function REQUIRE_EMPTY_STR(str)
	string &str

	IUTF_Wrapper#EMPTY_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc NON_EMPTY_STR_DOCU
Function WARN_NON_EMPTY_STR(str)
	string &str

	IUTF_Wrapper#NON_EMPTY_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc NON_EMPTY_STR_DOCU
Function CHECK_NON_EMPTY_STR(str)
	string &str

	IUTF_Wrapper#NON_EMPTY_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc NON_EMPTY_STR_DOCU
Function REQUIRE_NON_EMPTY_STR(str)
	string &str

	IUTF_Wrapper#NON_EMPTY_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc PROPER_STR_DOCU
Function WARN_PROPER_STR(str)
	string &str

	IUTF_Wrapper#PROPER_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc PROPER_STR_DOCU
Function CHECK_PROPER_STR(str)
	string &str

	IUTF_Wrapper#PROPER_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc PROPER_STR_DOCU
Function REQUIRE_PROPER_STR(str)
	string &str

	IUTF_Wrapper#PROPER_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc NULL_STR_DOCU
Function WARN_NULL_STR(str)
	string &str

	IUTF_Wrapper#NULL_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc NULL_STR_DOCU
Function CHECK_NULL_STR(str)
	string &str

	IUTF_Wrapper#NULL_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc NULL_STR_DOCU
Function REQUIRE_NULL_STR(str)
	string &str

	IUTF_Wrapper#NULL_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc NON_NULL_STR_DOCU
Function WARN_NON_NULL_STR(str)
	string &str

	IUTF_Wrapper#NON_NULL_STR_WRAPPER(str, WARN_MODE)
End

/// @copydoc NON_NULL_STR_DOCU
Function CHECK_NON_NULL_STR(str)
	string &str

	IUTF_Wrapper#NON_NULL_STR_WRAPPER(str, CHECK_MODE)
End

/// @copydoc NON_NULL_STR_DOCU
Function REQUIRE_NON_NULL_STR(str)
	string &str

	IUTF_Wrapper#NON_NULL_STR_WRAPPER(str, REQUIRE_MODE)
End

/// @copydoc EQUAL_STR_DOCU
Function WARN_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		IUTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, WARN_MODE)
	else
		IUTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, WARN_MODE, case_sensitive = case_sensitive)
	endif
End

/// @copydoc EQUAL_STR_DOCU
Function CHECK_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		IUTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, CHECK_MODE)
	else
		IUTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, CHECK_MODE, case_sensitive = case_sensitive)
	endif
End

/// @copydoc EQUAL_STR_DOCU
Function REQUIRE_EQUAL_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		IUTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, REQUIRE_MODE)
	else
		IUTF_Wrapper#EQUAL_STR_WRAPPER(str1, str2, REQUIRE_MODE, case_sensitive = case_sensitive)
	endif
End

/// @copydoc NEQ_STR_DOCU
Function WARN_NEQ_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		IUTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, WARN_MODE)
	else
		IUTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, WARN_MODE, case_sensitive = case_sensitive)
	endif
End

/// @copydoc NEQ_STR_DOCU
Function CHECK_NEQ_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		IUTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, CHECK_MODE)
	else
		IUTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, CHECK_MODE, case_sensitive = case_sensitive)
	endif
End

/// @copydoc NEQ_STR_DOCU
Function REQUIRE_NEQ_STR(str1, str2, [case_sensitive])
	string str1, str2
	variable case_sensitive

	if(ParamIsDefault(case_sensitive))
		IUTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, REQUIRE_MODE)
	else
		IUTF_Wrapper#NEQ_STR_WRAPPER(str1, str2, REQUIRE_MODE, case_sensitive = case_sensitive)
	endif
End

/// @copydoc WAVE_DOCU
Function WARN_WAVE(wv, majorType, [minorType])
	WAVE/Z wv
	variable majorType, minorType

	if(ParamIsDefault(minorType))
		IUTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, WARN_MODE)
	else
		IUTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, WARN_MODE, minorType = minorType)
	endif
End

/// @copydoc WAVE_DOCU
Function CHECK_WAVE(wv, majorType, [minorType])
	WAVE/Z wv
	variable majorType, minorType

	if(ParamIsDefault(minorType))
		IUTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, CHECK_MODE)
	else
		IUTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, CHECK_MODE, minorType = minorType)
	endif
End

/// @copydoc WAVE_DOCU
Function REQUIRE_WAVE(wv, majorType, [minorType])
	WAVE/Z wv
	variable majorType, minorType

	if(ParamIsDefault(minorType))
		IUTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, REQUIRE_MODE)
	else
		IUTF_Wrapper#TEST_WAVE_WRAPPER(wv, majorType, REQUIRE_MODE, minorType = minorType)
	endif
End

/// @copydoc EQUAL_WAVE_DOCU
Function WARN_EQUAL_WAVES(wv1, wv2, [mode, tol])
	WAVE/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode = mode)
	elseif(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, tol = tol)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, tol = tol, mode = mode)
	endif
End

/// @copydoc EQUAL_WAVE_DOCU
Function CHECK_EQUAL_WAVES(wv1, wv2, [mode, tol])
	WAVE/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode = mode)
	elseif(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, tol = tol)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, tol = tol, mode = mode)
	endif
End

/// @copydoc EQUAL_WAVE_DOCU
Function REQUIRE_EQUAL_WAVES(wv1, wv2, [mode, tol])
	WAVE/Z wv1, wv2
	variable mode, tol

	if(ParamIsDefault(mode) && ParamIsDefault(tol))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE)
	elseif(ParamIsDefault(tol))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, mode = mode)
	elseif(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, tol = tol)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, tol = tol, mode = mode)
	endif
End

#if (IgorVersion() >= 7.00)

Function WARN_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	WAVE/Z/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode = mode)
	endif
End

Function CHECK_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	WAVE/Z/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode = mode)
	endif
End

Function REQUIRE_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	WAVE/Z/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, mode = mode)
	endif
End

#else

/// @class TEXT_WAVE_EQUAL_DOCU
/// Tests two text waves for equality
///
/// @param wv1    first text wave, can be invalid for Igor Pro 7 or later
/// @param wv2    second text wave, can be invalid for Igor Pro 7 or later
/// @param mode   (optional) features of the waves to compare, defaults to all modes
///
/// @verbatim embed:rst:leading-slashes
/// See also :ref:`flags_testwave`.
/// @endverbatim
///

/// @copydoc TEXT_WAVE_EQUAL_DOCU
Function WARN_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	WAVE/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, WARN_MODE, mode = mode)
	endif
End

/// @copydoc TEXT_WAVE_EQUAL_DOCU
Function CHECK_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	WAVE/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, CHECK_MODE, mode = mode)
	endif
End

/// @copydoc TEXT_WAVE_EQUAL_DOCU
Function REQUIRE_EQUAL_TEXTWAVES(wv1, wv2, [mode])
	WAVE/T wv1, wv2
	variable mode

	if(ParamIsDefault(mode))
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE)
	else
		IUTF_Wrapper#EQUAL_WAVE_WRAPPER(wv1, wv2, REQUIRE_MODE, mode = mode)
	endif
End

#endif

/// @copydoc CDF_EMPTY_DOCU
Function WARN_EMPTY_FOLDER()
	IUTF_Wrapper#CDF_EMPTY_WRAPPER(WARN_MODE)
End

/// @copydoc CDF_EMPTY_DOCU
Function CHECK_EMPTY_FOLDER()
	IUTF_Wrapper#CDF_EMPTY_WRAPPER(CHECK_MODE)
End

/// @copydoc CDF_EMPTY_DOCU
Function REQUIRE_EMPTY_FOLDER()
	IUTF_Wrapper#CDF_EMPTY_WRAPPER(REQUIRE_MODE)
End

/// @copydoc RTE_DOCU
Function WARN_RTE(code)
	variable code
	IUTF_Wrapper#RTE_WRAPPER(code, WARN_MODE)
End

/// @copydoc RTE_DOCU
Function CHECK_RTE(code)
	variable code
	IUTF_Wrapper#RTE_WRAPPER(code, CHECK_MODE)
End

/// @copydoc RTE_DOCU
Function REQUIRE_RTE(code)
	variable code
	IUTF_Wrapper#RTE_WRAPPER(code, REQUIRE_MODE)
End

/// @copydoc ANY_RTE_DOCU
Function WARN_ANY_RTE()
	IUTF_Wrapper#ANY_RTE_WRAPPER(WARN_MODE)
End

/// @copydoc ANY_RTE_DOCU
Function CHECK_ANY_RTE()
	IUTF_Wrapper#ANY_RTE_WRAPPER(CHECK_MODE)
End

/// @copydoc ANY_RTE_DOCU
Function REQUIRE_ANY_RTE()
	IUTF_Wrapper#ANY_RTE_WRAPPER(REQUIRE_MODE)
End

/// @copydoc NO_RTE_DOCU
Function WARN_NO_RTE()
	IUTF_Wrapper#NO_RTE_WRAPPER(WARN_MODE)
End

/// @copydoc NO_RTE_DOCU
Function CHECK_NO_RTE()
	IUTF_Wrapper#NO_RTE_WRAPPER(CHECK_MODE)
End

/// @copydoc NO_RTE_DOCU
Function REQUIRE_NO_RTE()
	IUTF_Wrapper#NO_RTE_WRAPPER(REQUIRE_MODE)
End

/// @copydoc COMPILATION_DOCU
Function WARN_COMPILATION(file, [defines, reentry])
	string file, reentry
	WAVE/Z/T defines

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#COMPILATION_WRAPPER(file, WARN_MODE)
		else
			IUTF_Wrapper#COMPILATION_WRAPPER(file, WARN_MODE, reentry = reentry)
		endif
	else
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#COMPILATION_WRAPPER(file, WARN_MODE, defines = defines)
		else
			IUTF_Wrapper#COMPILATION_WRAPPER(file, WARN_MODE, defines = defines, reentry = reentry)
		endif
	endif
End

/// @copydoc COMPILATION_DOCU
Function CHECK_COMPILATION(file, [defines, reentry])
	string file, reentry
	WAVE/Z/T defines

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#COMPILATION_WRAPPER(file, CHECK_MODE)
		else
			IUTF_Wrapper#COMPILATION_WRAPPER(file, CHECK_MODE, reentry = reentry)
		endif
	else
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#COMPILATION_WRAPPER(file, CHECK_MODE, defines = defines)
		else
			IUTF_Wrapper#COMPILATION_WRAPPER(file, CHECK_MODE, defines = defines, reentry = reentry)
		endif
	endif
End

/// @copydoc COMPILATION_DOCU
Function REQUIRE_COMPILATION(file, [defines, reentry])
	string file, reentry
	WAVE/Z/T defines

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#COMPILATION_WRAPPER(file, REQUIRE_MODE)
		else
			IUTF_Wrapper#COMPILATION_WRAPPER(file, REQUIRE_MODE, reentry = reentry)
		endif
	else
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#COMPILATION_WRAPPER(file, REQUIRE_MODE, defines = defines)
		else
			IUTF_Wrapper#COMPILATION_WRAPPER(file, REQUIRE_MODE, defines = defines, reentry = reentry)
		endif
	endif
End

/// @copydoc NO_COMPILATION_DOCU
Function WARN_NO_COMPILATION(file, [defines, reentry])
	string file, reentry
	WAVE/Z/T defines

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, WARN_MODE)
		else
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, WARN_MODE, reentry = reentry)
		endif
	else
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, WARN_MODE, defines = defines)
		else
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, WARN_MODE, defines = defines, reentry = reentry)
		endif
	endif
End

/// @copydoc NO_COMPILATION_DOCU
Function CHECK_NO_COMPILATION(file, [defines, reentry])
	string file, reentry
	WAVE/Z/T defines

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, CHECK_MODE)
		else
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, CHECK_MODE, reentry = reentry)
		endif
	else
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, CHECK_MODE, defines = defines)
		else
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, CHECK_MODE, defines = defines, reentry = reentry)
		endif
	endif
End

/// @copydoc NO_COMPILATION_DOCU
Function REQUIRE_NO_COMPILATION(file, [defines, reentry])
	string file, reentry
	WAVE/Z/T defines

	if(ParamIsDefault(defines))
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, REQUIRE_MODE)
		else
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, REQUIRE_MODE, reentry = reentry)
		endif
	else
		if(ParamIsDefault(reentry))
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, REQUIRE_MODE, defines = defines)
		else
			IUTF_Wrapper#NO_COMPILATION_WRAPPER(file, REQUIRE_MODE, defines = defines, reentry = reentry)
		endif
	endif
End

///@}
