#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma ModuleName=FreeWaveLeaks

#include "unit-testing"

static Function TestProduceWaveLeaks()
	variable max = WaveMax(GiveMeWave_IGNORE())

	CHECK_EQUAL_VAR(2.0, max)
End

// UTF_NO_WAVE_TRACKING
static Function TestWaveLeaksIgnored()
	variable max = WaveMax(GiveMeWave_IGNORE())

	CHECK_EQUAL_VAR(2.0, max)
End

static Function TestNoWaveLeaks()
	WAVE wv = GiveMeWave_IGNORE()
	variable max = WaveMax(wv)

	CHECK_EQUAL_VAR(2.0, max)
End

static Function/WAVE GiveMeWave_IGNORE()
	Make/FREE wv = { 1.0, 2.0, 1.5 }

	return wv
End