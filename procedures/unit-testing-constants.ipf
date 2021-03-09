#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.08
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt

///@cond HIDDEN_SYMBOL

// Package Version
Constant PKG_VERSION = 1.08

/// Settings folder
StrConstant PKG_FOLDER = "root:Packages:UnitTesting"
StrConstant PKG_FOLDER_SAVE = "root:Packages:UnitTesting:SaveState"

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

///@endcond // HIDDEN_SYMBOL

/// @addtogroup assertionFlags
///@{

/// @addtogroup testWaveFlagsMinor
///@{
Constant COMPLEX_WAVE    = 0x01
Constant FLOAT_WAVE      = 0x02
Constant DOUBLE_WAVE     = 0x04
Constant INT8_WAVE       = 0x08
Constant INT16_WAVE      = 0x10
Constant INT32_WAVE      = 0x20
Constant INT64_WAVE      = 0x80
Constant UNSIGNED_WAVE   = 0x40
///@}

/// @addtogroup testWaveFlagsMajor
///@{
Constant NULL_WAVE       = 0x1000
Constant NUMERIC_WAVE    = 0x01
Constant TEXT_WAVE       = 0x02
Constant DATAFOLDER_WAVE = 0x04
Constant WAVE_WAVE       = 0x08

Constant NORMAL_WAVE     = 0x10
Constant FREE_WAVE       = 0x20
///@}

/// @addtogroup equalWaveFlags
///@{
Constant WAVE_DATA        =   1
Constant WAVE_DATA_TYPE   =   2
Constant WAVE_SCALING     =   4
Constant DATA_UNITS       =   8
Constant DIMENSION_UNITS  =  16
Constant DIMENSION_LABELS =  32
Constant WAVE_NOTE        =  64
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

/// @addtogroup UTFBackgroundMonModes
/// @{
Constant BACKGROUNDMONMODE_AND  = 0
Constant BACKGROUNDMONMODE_OR   = 1
/// @}

/// @anchor dimensionIndices
/// @{
Constant UTF_ROW = 0
Constant UTF_COLUMN = 1
Constant UTF_LAYER = 2
Constant UTF_CHUNK = 3
/// @}

/// @name error codes for function tags
/// @anchor FunctionTagErrors
/// @{
Constant UTF_TAG_OK        = 0x00
Constant UTF_TAG_NOT_FOUND = 0x01
Constant UTF_TAG_EMPTY     = 0x02
Constant UTF_TAG_ABORTED   = 0x04
///@}

/// @name String constants for function tags
/// Need to be added to UTF_Utils#GetTagConstants!
///
/// @anchor FunctionTagStrings
/// @{
StrConstant UTF_FTAG_TD_GENERATOR      = "UTF_TD_GENERATOR"
StrConstant UTF_FTAG_EXPECTED_FAILURE  = "UTF_EXPECTED_FAILURE"
StrConstant UTF_FTAG_TAP_DIRECTIVE     = "#TAPDirective:"
StrConstant UTF_FTAG_TAP_DESCRIPTION   = "#TAPDescription:"
///@}