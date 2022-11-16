#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma ModuleName = UTF_Tracing_Analytics

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)


static Function/WAVE GetTotals()
	variable i, numWaves

	TUFXOP_GetStorage/N="IUTF_TestRun" storage
	numWaves = DimSize(storage, UTF_ROW)
	WAVE/ZZ totals
	for(i = 0; i < numWaves; i++)
		WAVE/WAVE/Z entryOuter = storage[i]
		if(!WaveExists(entryOuter))
			continue
		endif
		WAVE entry = entryOuter[0]
		if(WaveExists(totals))
			totals += entry
		else
			Duplicate/FREE=1 entry, totals
		endif
	endfor

	if(!WaveExists(totals))
		Make/N=0/FREE=1 totals
	endif

	return totals
End

#endif
