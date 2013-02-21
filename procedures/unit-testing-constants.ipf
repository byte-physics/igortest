#pragma rtGlobals=3
#pragma version=0.1

/// Settings folder
StrConstant PKG_FOLDER = "root:Packages:UnitTesting"

/// Action flags
///@{
Constant OUTPUT_MESSAGE = 0x01
Constant INCREASE_ERROR = 0x02
Constant ABORT_FUNCTION = 0x04
Constant WARN_MODE      = 0x01 // == OUTPUT_MESSAGE
Constant CHECK_MODE     = 0x03 // == OUTPUT_MESSAGE | INCREASE_ERROR
Constant REQUIRE_MODE   = 0x07 // == OUTPUT_MESSAGE | INCREASE_ERROR | ABORT_FUNCTION
///@}

///@addtogroup PublicApi
///@{

///@defgroup mainWaveTypes Major wave types
/// Possible values of the parameter mainType in @ref WARN_WAVE, @ref CHECK_WAVE, @ref REQUIRE_WAVE
///@{
Constant TEXT_WAVE    = 2
Constant NUMERIC_WAVE = 1
///@}

///@defgroup minorWaveTypes Minor wave types
///
/// Possible values of the parameter minorType in @ref WARN_WAVE, @ref CHECK_WAVE, @ref REQUIRE_WAVE
///@{
Constant COMPLEX_WAVE = 0x01
Constant FLOAT_WAVE   = 0x02
Constant DOUBLE_WAVE  = 0x04
Constant INT8_WAVE    = 0x08
Constant INT16_WAVE   = 0x16
Constant INT32_WAVE   = 0x20
Constant UNSIGNED_WAVE= 0x40
///@}

///@defgroup CheckWaveModes Equal wave modes
/// Possible values of the mode parameter in @ref WARN_EQUAL_WAVES, @ref CHECK_EQUAL_WAVES, @ref REQUIRE_EQUAL_WAVES
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

