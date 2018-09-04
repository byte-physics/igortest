#pragma rtGlobals=3
#pragma version=1.06
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt

///@cond HIDDEN_SYMBOL

// Package Version
Constant PKG_VERSION = 1.06

/// Settings folder
StrConstant PKG_FOLDER = "root:Packages:UnitTesting"

Constant CLOSE_COMPARE_STRONG_OR_WEAK = 1
Constant DEFAULT_TOLERANCE            = 1e-8

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

/// @addtogroup testWaveFlagsGeneral
///@{
Constant NULL_WAVE       = 0x00
///@}

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
