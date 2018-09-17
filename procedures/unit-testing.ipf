#pragma rtGlobals=3
#pragma version=1.06
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt
//
// @defgroup Helpers Helper functions
// Helper functions
//
// @defgroup Assertions Test Assertions
// Test assertions for variables, strings, waves and helper functions
//
// @defgroup assertionFlags Assertions flags
// Constants for assertion test tuning
//
// @defgroup testWaveFlagsGeneral Wave existence flags
// Values for both, @p majorType / @p minorType of @ref WARN_WAVE, @ref CHECK_WAVE and @ref REQUIRE_WAVE
//
// @defgroup testWaveFlagsMinor Wave existence flags
// Values for @p minorType of @ref WARN_WAVE, @ref CHECK_WAVE and @ref REQUIRE_WAVE
//
// @defgroup testWaveFlagsMajor Wave existence flags
// Values for @p majorType of @ref WARN_WAVE, @ref CHECK_WAVE and @ref REQUIRE_WAVE
//
// @defgroup equalWaveFlags Wave equality flags
// Values for @c mode in @ref WARN_EQUAL_WAVES, @ref CHECK_EQUAL_WAVES and @ref REQUIRE_EQUAL_WAVES
//

#include "unit-testing-constants"
#include "unit-testing-basics"
#include "unit-testing-comparators"
#include "unit-testing-hooks"
#include "unit-testing-autorun"
#include "unit-testing-junit"
#include "unit-testing-tap"
