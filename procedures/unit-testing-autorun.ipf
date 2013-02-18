#pragma rtGlobals=3		// Use modern global access method and strict wave access.

/// Creates a notebook with the special name "HistoryCarbonCopy"
/// which will hold a copy of the history
static Function CreateHistoryLog()
	DoWindow/K HistoryCarbonCopy
	NewNotebook/V=0/F=0 /N=HistoryCarbonCopy
End

/// This hook is executed after an Igor experiment is loaded
static Function AfterFileOpenHook(refNum,file,pathName,type,creator,kind)
Variable refNum,kind
String file,pathName,type,creator

	// do nothing if the opened file was not an Igor packed/unpacked experiment
	if(kind != 1 && kind != 2)
		return 0
	endif

	string stateFile = "DO_AUTORUN.TXT"
	// return if the state file does exist
	GetFileFolderInfo/Q/Z/P=home stateFile
	if(V_flag != 0)
		return 0
	endif
	
	// state file exists, call the run routine and quit Igor afterwards
	CreateHistoryLog()
	run()
	SaveHistoryLog()
	Execute/P "Quit/N"
End

/// Save the contents of the history notebook on disk
/// in the same folder as this experiment as timestamped file "run_*_*.log"
static Function SaveHistoryLog()
	
	string historyLog
	sprintf historyLog, "run_%s_%s.log", Secs2Date(DateTime,-2), ReplaceString(":",Secs2Time(DateTime,1),"-")
	
	DoWindow HistoryCarbonCopy
	if(V_flag == 0)
		print "No log notebook found, please call CreateHistoryLog() before."
		return NaN
	endif

	SaveNoteBook/S=3/P=home HistoryCarbonCopy as historyLog
End
