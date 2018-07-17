#pragma rtGlobals=3
#pragma version=1.06
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt
//
// @defgroup TestRunnerAndHelper Helper functions
// Runner and helper functions
//
// @defgroup Assertions Test Assertions
// Test assertions for variables, strings, waves and helper functions
//
// @defgroup assertionFlags Assertions flags
// Constants for assertion test tuning
//
// @defgroup testWaveFlags Wave existence flags
// Values for @c majorType / @c minorType of @ref WARN_WAVE, @ref CHECK_WAVE and @ref REQUIRE_WAVE
//
// @defgroup equalWaveFlags Wave equality flags
// Values for @c mode in @ref WARN_EQUAL_WAVES, @ref CHECK_EQUAL_WAVES and @ref REQUIRE_EQUAL_WAVES
//
//
// @example example1-plain.ipf
// @example example2-plain.ipf
// @example example3-plain.ipf
// @example example4-wavechecking.ipf
// @example example5-extensionhooks.ipf
// @example example5-extensionhooks-otherSuite.ipf
// @example example7-uncaught-aborts.ipf
// @example example8-uncaught-runtime-errors.ipf
// @example example9-IM.ipf
//
//

#include "unit-testing-constants"
#include "unit-testing-basics"
#include "unit-testing-comparators"
#include "unit-testing-hooks"
#include "unit-testing-autorun"
#include "unit-testing-junit"
#include "unit-testing-tap"
