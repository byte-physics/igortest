#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Utils_Paths

///@cond HIDDEN_SYMBOL

/// @brief Clears the current stored home path. The next call to GetHomePath() will return the
// current home path.
static Function ClearHomePath()
	DFREF dfr = GetPackageFolder()
	KillStrings/Z dfr:homePath
End

/// @brief Returns the home path at the start of the execution of RunTest. If this experiment wasn't
/// saved at this point it will return an empty string.
static Function/S GetHomePath()
	DFREF dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr homePath

	if(SVAR_Exists(homePath))
		return homePath
	endif

	PathInfo home
	if(V_flag)
		string/G dfr:homePath = S_path
		return S_path
	else
		string/G dfr:homePath = ""
		return ""
	endif
End

/// @brief Get the full path of a file at the cached home directory
///
/// @param fileName  The file name that need to be located in the home directory
/// @param unusedName  (optional, default 0=disabled) If set to 1 it will search for an unused file
///                    name in the home directory with the same pattern as fileName.
///                    If no unused file name could be found this function will abort the execution.
///
/// @returns The full file path
static Function/S AtHome(fileName, [unusedName])
	string fileName
	variable unusedName

	string result, msg

	unusedName = ParamIsDefault(unusedName) ? 0 : !!unusedName

	result = GetHomePath() + fileName

	if(unusedName)
		result = getUnusedFileName(result)
		if(IUTF_Utils#IsEmpty(result))
			sprintf msg, "Cannot determine unused file for %s at home directory", fileName
			IUTF_Reporting#ReportErrorAndAbort(msg)
		endif
	endif

	return result
End

/// Returns 0 if the file exists, !0 otherwise
static Function FileNotExists(fname)
	string fname

	GetFileFolderInfo/Q/Z fname
	return V_Flag
End

/// returns a non existing file name an empty string
static Function/S getUnusedFileName(fname)
	string fname

	variable count
	string fn, fnext, fnn

	if (FileNotExists(fname))
		return fname
	endif
	fname = ParseFilePath(5, fname, "\\", 0, 0)
	fnext = "." + ParseFilePath(4, fname, "\\", 0, 0)
	fnn = RemoveEnding(fname, fnext)

	count = -1
	do
		count += 1
		sprintf fn, "%s_%03d%s", fnn, count, fnext
	while(!FileNotExists(fn) && count < 999)
	if(!FileNotExists(fn))
		return ""
	endif
	return fn
End

// Get the directory part of a file with a trailing back-slash
//
// Examples:
// C:\foo\bar\baz.txt  ->  C:\foo\bar\
// C:\foo\bar\baz\     ->  C:\foo\bar\
static Function/S GetDirPathOfFile(path)
	string path

	path = ParseFilePath(5, path, "\\", 0, 0)
	path = ParseFilePath(1, path, "\\", 1, 0)

	return path
End

///@endcond // HIDDEN_SYMBOL
