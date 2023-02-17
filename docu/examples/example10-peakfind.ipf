#pragma TextEncoding = "UTF-8"
#pragma version=1.09
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "igortest"

// https://github.com/ukos-git/igor-common-utilities.git
#include "common-utilities"

Function testSinglePeakFit()

	// define a peak
	variable peak_position = 570
	variable peak_fwhm = 50

	// create the peak
	Make/O root:spectrum/WAVE=peak
	SetScale x, 0, 1000, "nm", peak
	peak = Gauss(x, peak_position, peak_fwhm) + gnoise(1e-3)

	// do the fit
	wave/Z/WAVE peakParam = Utilities#FitGauss(peak)

	// check that our input wave was good
	REQUIRE_WAVE(peak, NUMERIC_WAVE, minorType = FLOAT_WAVE)
	// check that the returned function is a valid wave
	REQUIRE_WAVE(peakParam, FREE_WAVE | WAVE_WAVE)
	// require at least one peak
	REQUIRE_EQUAL_VAR(1, DimSize(peakParam, 0) > 0)
	// warn if more than one peak was found
	WARN_EQUAL_VAR(1.0, DimSize(peakParam, 0))

	// convert to human readable result
	wave/Z peakInfo = Utilities#peakParamToResult(peakParam)

	// again, check that the function returned a valid wave
	CHECK_WAVE(peakInfo, FREE_WAVE | NUMERIC_WAVE)
	// check the found peak against the peak definition
	REQUIRE_CLOSE_VAR(peakInfo[0][%position], peak_position, tol=peakInfo[0][%position_err])
	REQUIRE_CLOSE_VAR(peakInfo[0][%fwhm], peak_fwhm, tol=peakInfo[0][%fwhm_err])
End
