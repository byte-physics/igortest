#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"

///@cond HIDDEN_SYMBOL

// Package Version
Constant PKG_VERSION = 1.10

/// Settings folder
StrConstant PKG_FOLDER      = "root:Packages:igortest"
StrConstant PKG_FOLDER_SAVE = "root:Packages:igortest:SaveState"

Constant CLOSE_COMPARE_STRONG  = 1
Constant DEFAULT_TOLERANCE     = 1e-8
Constant DEFAULT_TOLERANCE_INT = 16

// This RegEx matches all procedure names that do not end with "_reentry" (non case sensitive)
StrConstant PROCNAME_NOT_REENTRY = "^(?!(?i).*_REENTRY$).*$"

// special RunTest return codes (negativ)
Constant RUNTEST_RET_BCKG = -1

/// Action flags
///@{
Constant OUTPUT_MESSAGE = 0x01
Constant INCREASE_ERROR = 0x02
Constant ABORT_FUNCTION = 0x04
Constant WARN_MODE      = 0x01 // == OUTPUT_MESSAGE
Constant CHECK_MODE     = 0x03 // == OUTPUT_MESSAGE | INCREASE_ERROR
Constant REQUIRE_MODE   = 0x07 // == OUTPUT_MESSAGE | INCREASE_ERROR | ABORT_FUNCTION
///@}

Constant IUTF_WAVECHUNK_SIZE = 1024
// The size when a wave is considered as really big. After this point the sizes of chunks are
// handled differently because of the large impact to system memory.
// This number is 512 * 1024 * 1024 (= 512 MiB)
Constant IUTF_BIGWAVECHUNK_SIZE = 536870912

/// Text case status flags
///@{
// test case was never run
StrConstant IUTF_STATUS_UNKNOWN = ""
// test case is running
StrConstant IUTF_STATUS_RUNNING = "RUNNING"
// An errored test had an unanticipated problem. Like an RTE or no assertions at all.
StrConstant IUTF_STATUS_ERROR = "ERROR"
// A failed assertion
StrConstant IUTF_STATUS_FAIL = "FAIL"
// Test is skipped
StrConstant IUTF_STATUS_SKIP = "SKIP"
// Test is finished without any problem
StrConstant IUTF_STATUS_SUCCESS = "SUCCESS"
// Test is retried
StrConstant IUTF_STATUS_RETRY = "RETRY"
///@}

/// Test assertion severity flags
///@{
// This assertion is just a informational warning and has no influence to the test result
StrConstant IUTF_SEVERITY_WARN = "WARN"
// This assertion is an error and should fail the test case in some way.
StrConstant IUTF_SEVERITY_ERROR = "ERROR"
///@}

Constant IUTF_MICRO_TO_ONE = 1e-06

/// @name Constants for WaveTypes
/// @anchor WaveTypes
/// @{
Constant IUTF_WAVETYPE0_CMPL  = 0x01
Constant IUTF_WAVETYPE0_FP32  = 0x02
Constant IUTF_WAVETYPE0_FP64  = 0x04
Constant IUTF_WAVETYPE0_INT8  = 0x08
Constant IUTF_WAVETYPE0_INT16 = 0x10
Constant IUTF_WAVETYPE0_INT32 = 0x20
Constant IUTF_WAVETYPE0_INT64 = 0x80
Constant IUTF_WAVETYPE0_USGN  = 0x40

Constant IUTF_WAVETYPE1_NULL = 0x00
Constant IUTF_WAVETYPE1_NUM  = 0x01
Constant IUTF_WAVETYPE1_TEXT = 0x02
Constant IUTF_WAVETYPE1_DFR  = 0x03
Constant IUTF_WAVETYPE1_WREF = 0x04

Constant IUTF_WAVETYPE2_NULL   = 0x00
Constant IUTF_WAVETYPE2_GLOBAL = 0x01
Constant IUTF_WAVETYPE2_FREE   = 0x02
/// @}

/// @name Constants for Debugger mode
/// @anchor DebugConstants
/// @{
Constant IUTF_DEBUG_DISABLE          = 0x00
Constant IUTF_DEBUG_ENABLE           = 0x01
Constant IUTF_DEBUG_ON_ERROR         = 0x02
Constant IUTF_DEBUG_NVAR_SVAR_WAVE   = 0x04
Constant IUTF_DEBUG_FAILED_ASSERTION = 0x08
/// @}

StrConstant IUTF_TRACE_REENTRY_KEYWORD = " *** REENTRY ***"

#if IgorVersion() >= 7.00
// right arrow
StrConstant TC_ASSERTION_MLINE_INDICATOR = "\342\236\224"
// right filled triangle
StrConstant TC_ASSERTION_LIST_INDICATOR = "\342\226\266"
// info icon
StrConstant TC_ASSERTION_INFO_INDICATOR = "\xE2\x93\x98"
#else
StrConstant TC_ASSERTION_MLINE_INDICATOR = "->"
StrConstant TC_ASSERTION_LIST_INDICATOR  = "-"
StrConstant TC_ASSERTION_INFO_INDICATOR  = "(i)"
#endif

/// @name Constants for IUTF_Hooks#ExecuteHooks
/// @anchor HookTypes
/// @{
Constant IUTF_TEST_BEGIN_CONST       = 0x01
Constant IUTF_TEST_END_CONST         = 0x02
Constant IUTF_TEST_SUITE_BEGIN_CONST = 0x04
Constant IUTF_TEST_SUITE_END_CONST   = 0x08
Constant IUTF_TEST_CASE_BEGIN_CONST  = 0x10
Constant IUTF_TEST_CASE_END_CONST    = 0x20
/// @}

Constant IUTF_TEST_CASE_TYPE = 0x01
Constant IUTF_USER_HOOK_TYPE = 0x02
Constant IUTF_DATA_GEN_TYPE  = 0x04

Constant IUTF_WVTRACK_INACTIVE_MODE = 0
Constant IUTF_WVTRACK_COUNT_MODE    = 1
Constant IUTF_WVTRACK_TRACKER_MODE  = 2

Constant    IUTF_DGEN_NUM_VARS = 5
StrConstant IUTF_TC_SUFFIX_SEP = ":"

///@endcond // HIDDEN_SYMBOL

/// @addtogroup AssertionFlags
///@{

/// @addtogroup TestWaveFlagsMinor
///@{
Constant NON_NUMERIC_WAVE = 0x100
Constant COMPLEX_WAVE     = 0x01
Constant FLOAT_WAVE       = 0x02
Constant DOUBLE_WAVE      = 0x04
Constant INT8_WAVE        = 0x08
Constant INT16_WAVE       = 0x10
Constant INT32_WAVE       = 0x20
Constant INT64_WAVE       = 0x80
Constant UNSIGNED_WAVE    = 0x40
///@}

/// @addtogroup TestWaveFlagsMajor
///@{
Constant NULL_WAVE       = 0x1000
Constant NUMERIC_WAVE    = 0x01
Constant TEXT_WAVE       = 0x02
Constant DATAFOLDER_WAVE = 0x04
Constant WAVE_WAVE       = 0x08

Constant NORMAL_WAVE = 0x10
Constant FREE_WAVE   = 0x20
///@}

/// @addtogroup EqualWaveFlags
///@{
Constant WAVE_DATA        = 1
Constant WAVE_DATA_TYPE   = 2
Constant WAVE_SCALING     = 4
Constant DATA_UNITS       = 8
Constant DIMENSION_UNITS  = 16
Constant DIMENSION_LABELS = 32
Constant WAVE_NOTE        = 64
Constant WAVE_LOCK_STATE  = 128
Constant DATA_FULL_SCALE  = 256
Constant DIMENSION_SIZES  = 512
///@}
///@}

/// @anchor AutorunModes
/// @{
Constant AUTORUN_OFF   = 0x0
Constant AUTORUN_FULL  = 0x1
Constant AUTORUN_PLAIN = 0x2
/// @}

/// @addtogroup IUTFBackgroundMonModes
/// @{
Constant BACKGROUNDMONMODE_AND = 0
Constant BACKGROUNDMONMODE_OR  = 1
/// @}

/// @anchor dimensionIndices
/// @{
Constant UTF_ROW    = 0
Constant UTF_COLUMN = 1
Constant UTF_LAYER  = 2
Constant UTF_CHUNK  = 3
/// @}

/// @name error codes for function tags
/// @anchor FunctionTagErrors
/// @{
Constant UTF_TAG_OK        = 0x00
Constant UTF_TAG_NOT_FOUND = 0x01
Constant UTF_TAG_EMPTY     = 0x02
Constant UTF_TAG_ABORTED   = 0x04
/// @}

/// @name String constants for function tags
/// Need to be added to IUTF_FunctionTags#GetTagConstants!
///
/// @anchor FunctionTagStrings
/// @{
StrConstant UTF_FTAG_NOINSTRUMENTATION = "IUTF_NOINSTRUMENTATION"
StrConstant UTF_FTAG_TD_GENERATOR      = "IUTF_TD_GENERATOR"
StrConstant UTF_FTAG_EXPECTED_FAILURE  = "IUTF_EXPECTED_FAILURE"
StrConstant UTF_FTAG_SKIP              = "IUTF_SKIP"
StrConstant UTF_FTAG_TAP_DIRECTIVE     = "TAPDirective"
StrConstant UTF_FTAG_TAP_DESCRIPTION   = "TAPDescription"
StrConstant UTF_FTAG_NO_WAVE_TRACKING  = "IUTF_NO_WAVE_TRACKING"
StrConstant UTF_FTAG_RETRY_FAILED      = "IUTF_RETRY_FAILED"
/// @}

/// @name Keys for traceOptions parameter
///
/// @anchor TraceOptionKeyStrings
/// @{
StrConstant UTF_KEY_INSTRUMENTATIONONLY = "INSTRUMENTONLY"
StrConstant UTF_KEY_HTMLCREATION        = "HTMLCREATION"
StrConstant UTF_KEY_REGEXP              = "REGEXP"
StrConstant UTF_KEY_COBERTURA           = "COBERTURA"
StrConstant UTF_KEY_COBERTURA_SOURCES   = "COBERTURA_SOURCES"
StrConstant UTF_KEY_COBERTURA_OUT       = "COBERTURA_OUT"
/// @}

/// @name Maximum number of procedure lines allowed for code coverage tracing
///
/// @anchor TraceMaxProcLines
/// @{
Constant UTF_MAX_PROC_LINES = 10000
/// @}

/// @name Wave tracking modes. These are in a bit pattern, which can be combined.
///
/// @anchor WaveTrackingModes
/// @{
Constant UTF_WAVE_TRACKING_NONE  = 0x00
Constant UTF_WAVE_TRACKING_FREE  = 0x01
Constant UTF_WAVE_TRACKING_LOCAL = 0x02
Constant UTF_WAVE_TRACKING_ALL   = 0x03
/// @}

/// @name IUTF Analytic output modes
/// @anchor AnalyticModes
/// @{
Constant UTF_ANALYTICS_FUNCTIONS = 0x00
Constant UTF_ANALYTICS_LINES     = 0x01
/// @}

/// @name IUTF Analytics sorting modes
/// @anchor AnalyticSorting
/// @{
Constant UTF_ANALYTICS_CALLS = 0x00
Constant UTF_ANALYTICS_SUM   = 0x01
/// @}

/// @name IUTF Retry modes
/// @anchor RetryModes
/// @{
// no functions will be retried at all
Constant IUTF_RETRY_NORETRY = 0x00
// retry all failed functions until they pass their execution once.
Constant IUTF_RETRY_FAILED_UNTIL_PASS = 0x01
// Allow all tests to be retried. The default is that only test cases with the function
// tag UTF_FTAG_RETRY_FAILED are retried.
Constant IUTF_RETRY_MARK_ALL_AS_RETRY = 0x10
// Allow failed REQUIREs to be retried which would normally abort the whole test run. This flag has
// only an effect if IUTF_RETRY_FAILED_UNTIL_PASS is set.
Constant IUTF_RETRY_REQUIRES = 0x20
/// @}

/// @name Maximum number a single test case can be retried. The user can set a lower limit but this
/// is the maximum supported by IUTF.
Constant IUTF_MAX_SUPPORTED_RETRY = 10

/// @name IUTF Test shuffle modes
/// @anchor TestShuffleModes
/// @{
Constant IUTF_SHUFFLE_NONE        = 0x00
Constant IUTF_SHUFFLE_TEST_SUITES = 0x01
Constant IUTF_SHUFFLE_TEST_CASES  = 0x02
Constant IUTF_SHUFFLE_ALL         = 0x03 // IUTF_SHUFFLE_TEST_SUITES | IUTF_SHUFFLE_TEST_CASES
/// @}

StrConstant IUTF_NO_SHUFFLE_TEST_CASE = "IUTF_NO_SHUFFLE_TEST_CASE"
