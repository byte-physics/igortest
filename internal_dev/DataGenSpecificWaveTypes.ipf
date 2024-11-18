#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"

#include "igortest"

// RunTest("DataGenSpecificWaveTypes.ipf")

Function/WAVE myMDGeneratorMulti()

	Make/FREE/T wt = {"1"}
	Make/FREE/D wNum

	// Including the following line in favor to the next has to result in a type error report
	//	Make/FREE/WAVE wref = {wt, wt, wNum}
	Make/FREE/WAVE wref = {wt, wt}

	return wref
End

Function/WAVE myMDGeneratorText()

	Make/FREE/T wt = {"1"}
	Make/FREE/WAVE wref = {wt, wt, wt}

	return wref
End

Function/WAVE myMDGeneratorDFR()

	Make/FREE/DF wdfr = {NewFreeDataFolder()}
	Make/FREE/WAVE wref = {wdfr, wdfr, wdfr}

	return wref
End

Function/WAVE myMDGeneratorWAVE()

	Make/FREE w
	Make/FREE/WAVE wWave = {w}
	Make/FREE/WAVE wref = {wWave, wWave, wWave}

	return wref
End

// IUTF_TD_GENERATOR myMDGeneratorText
Function myMDTestText([textWave])
	WAVE/T textWave

	Make/FREE/T w1 = {"1"}

	CHECK_EQUAL_WAVES(w1, textWave, mode = WAVE_DATA)
End

// IUTF_TD_GENERATOR myMDGeneratorText
Function myMDTestGeneric([wv])
	WAVE wv

	WAVE/T textWave = wv
	Make/FREE/T w1 = {"1"}

	CHECK_EQUAL_WAVES(w1, textWave, mode = WAVE_DATA)
End

// IUTF_TD_GENERATOR myMDGeneratorDFR
Function myMDTestDFR([dfrWave])
	WAVE/DF dfrWave

	CHECK(DataFolderRefStatus(dfrWave[0]))
End

// IUTF_TD_GENERATOR myMDGeneratorMulti
Function myMDTestMulti([textWave])
	WAVE/T textWave

	Make/FREE/T w1 = {"1"}

	CHECK_EQUAL_WAVES(w1, textWave, mode = WAVE_DATA)
End

// IUTF_TD_GENERATOR myMDGeneratorWAVE
Function myMDTestWAVEGeneric([wv])
	WAVE wv

	WAVE/WAVE wref = wv

	CHECK(WaveExists(wref[0]))
End

// IUTF_TD_GENERATOR myMDGeneratorWAVE
Function myMDTestWAVE([wrefWave])
	WAVE/WAVE wrefWave

	CHECK(WaveExists(wrefWave[0]))
	RegisterIUTFMonitor("dummyTask", BACKGROUNDMONMODE_OR, "myMDTestWAVE1_REENTRY")
End

// IUTF_TD_GENERATOR myMDGeneratorWAVE
Function myMDTestWAVE1_REENTRY([wrefWave])
	WAVE/WAVE wrefWave

	CHECK(WaveExists(wrefWave[0]))
	RegisterIUTFMonitor("dummyTask", BACKGROUNDMONMODE_OR, "myMDTestWAVE2_REENTRY")
End

// IUTF_TD_GENERATOR myMDGeneratorWAVE
Function myMDTestWAVE2_REENTRY([wv])
	WAVE wv

	WAVE/WAVE wrefWave = wv
	CHECK(WaveExists(wrefWave[0]))
End
