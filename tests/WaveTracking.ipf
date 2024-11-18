#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access
#pragma DefaultTab={3, 20, 4} // Set default tab width in Igor Pro 9 and later
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=UTF_WaveTracking

Function TC_StoreWaveInDatafolder()

	Make/FREE wv
	Make/WAVE/N=1 container = wv
	PASS()
End
