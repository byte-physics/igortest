#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.08
#pragma TextEncoding="UTF-8"

// Licensed under 3-Clause BSD, see License.txt

/// Creates a notebook with the special name "HistoryCarbonCopy"
/// which will hold a copy of the history
Function CreateHistoryLog()

	DoWindow/K HistoryCarbonCopy
	NewNotebook/V=0/F=0 /N=HistoryCarbonCopy
End

/// Return the type of autorun mode we are in
///
/// @returns one of @ref AutorunModes
Function GetAutorunMode()
	GetFileFolderInfo/Q/Z/P=home "DO_AUTORUN.TXT"

	if(!V_flag)
		return AUTORUN_FULL
	endif

	GetFileFolderInfo/Q/Z/P=home "DO_AUTORUN_PLAIN.TXT"

	if(!V_flag)
		return AUTORUN_PLAIN
	endif

	return AUTORUN_OFF
End

/// Hook function which is executed after opening a file
///
/// This function calls the user supplied run routine if
/// - the opened file is an igor experiment
/// - the file DO_AUTORUN.TXT exists in the igor home path
static Function AfterFileOpenHook(refNum, file, pathName, type, creator, kind)
	variable refNum, kind
	string file, pathName, type, creator

	string funcList, cmd
	variable autorunMode, err

	// do nothing if the opened file was not an Igor packed/unpacked experiment
	if(kind != 1 && kind != 2)
		return 0
	endif

	autorunMode = GetAutorunMode()

	if(autorunMode == AUTORUN_OFF)
		return 0
	endif

	if(autorunMode == AUTORUN_FULL)
		CreateHistoryLog()
	endif

	funcList = FunctionList("run", ";", "KIND:2,NPARAMS:0,WIN:[ProcGlobal]")
	if(ItemsInList(funcList) >= 1)
		FuncRef AUTORUN_MODE_PROTO f = $StringFromList(0, funcList)

		if(UTF_FuncRefIsAssigned(FuncRefInfo(f)))
			try
				err = GetRTError(1)
				f(); AbortOnRTE
			catch
				err = GetRTError(1)
				print "The run() function aborted with an RTE and this can not be handled."
				QuitOnAutoRunFull()
			endtry
		else
			print "The run() function has an invalid signature."
		endif
	else
		print "The requested autorun mode is not possible because the function run() does not exist in ProcGlobal context."
	endif
End

Function QuitOnAutoRunFull()

	string tmpStr

	if(GetAutorunMode() == AUTORUN_FULL)
		sprintf tmpStr, "%s#SaveHistoryLog(); Quit/N", GetIndependentModuleName()
		Execute/P tmpStr
	endif
End

/// resets a global filename template string for output
Function ClearBaseFilename()
	dfref dfr = GetPackageFolder()
	string/G dfr:baseFilename = ""
End

/// creates a new filename template, if template already present return current
Function/S GetBaseFilename()
	dfref dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr baseFilename
	SVAR/Z/SDFR=dfr baseFilenameOverwrite

	if(!SVAR_Exists(baseFilename))
		string/G dfr:baseFilename = ""
		SVAR/SDFR=dfr baseFilename
	endif

	if(strlen(baseFilename))
		return baseFilename
	endif

	if(SVAR_Exists(baseFilenameOverwrite) && strlen(baseFilenameOverwrite))
		baseFilename = baseFilenameOverwrite
	else
		sprintf baseFilename, "%s_%s_%s", IgorInfo(1), Secs2Date(DateTime, -2), ReplaceString(":", Secs2Time(DateTime, 3), "-")
	endif

	return baseFilename
End

/// Save the contents of the history notebook on disk
/// in the same folder as this experiment as timestamped file "run_*_*.log"
Function SaveHistoryLog()

	string historyLog
	historyLog = GetBaseFilename() + ".log"

	DoWindow HistoryCarbonCopy
	if(V_flag == 0)
		print "No log notebook found, please call CreateHistoryLog() before."
		return NaN
	endif

	PathInfo home
	historyLog = getUnusedFileName(S_path + historyLog)
	if(UTF_Utils#IsEmpty(historyLog))
		printf "Error: Unable to determine unused file name for History Log output in path %s !", S_path
		return NaN
	endif

	SaveNoteBook/S=3/P=home HistoryCarbonCopy as historyLog
End
