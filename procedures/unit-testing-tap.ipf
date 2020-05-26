#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.08

// Licensed under 3-Clause BSD, see License.txt

static StrConstant TAP_DIRECTIVE_STR   = "#TAPDirective:"
static StrConstant TAP_DESCRIPTION_STR = "#TAPDescription:"
static StrConstant TAP_LINEEND_STR     = "\n"

/// Creates the variable tap_output in PKG_FOLDER and initializes and empty TAP output file with a unique name
Function TAP_EnableOutput()

	dfref dfr = GetPackageFolder()
	variable/G dfr:tap_output
	NVAR/SDFR=dfr tap_output

	tap_output = 1
End

/// Creates a fresh TAP output file
Function TAP_CreateFile()

	variable fnum
	dfref dfr = GetPackageFolder()
	string/G dfr:tap_filename
	SVAR/SDFR=dfr tap_filename

	tap_filename = "tap_" + GetBaseFilename() + ".log"
	PathInfo home
	tap_filename = getUnusedFileName(S_path + tap_filename)
	if(!strlen(tap_filename))
		printf "Error: Unable to determine unused file name for TAP output in path %s !", S_path
		return NaN
	endif

	open/Z/P=home fnum as tap_filename
	if(!V_flag)
		fprintf fnum,"%s","TAP version 13" + TAP_LINEEND_STR
		close fnum
	else
		PathInfo home
		printf "Error: Could not create TAP output file at %s\r", S_path + tap_filename
	endif
End

/// Checks if tap_output variable exists in PKG_FOLDER, which indicates that TAP Output is enabled
Function TAP_IsOutputEnabled()
	dfref dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr tap_output

	if(NVAR_Exists(tap_output))
		return tap_output
	endif
	return 0
End

/// Writes Case result to TAP File only if TAP is enabled
Function TAP_WriteCaseIfReq(tap_caseCount, tap_skipCase)
	variable tap_caseCount, tap_skipCase

	if(!TAP_IsOutputEnabled())
		return NaN
	endif

	TAP_WriteCase(tap_caseCount, tap_skipCase)
End

/// Writes to TAP File only if TAP is enabled
Function TAP_WriteOutputIfReq(str)
	string str

	if(!TAP_IsOutputEnabled())
		return NaN
	endif

	TAP_WriteOutput(RemoveEnding(str,TAP_LINEEND_STR) + TAP_LINEEND_STR)
End

/// Writes string str to the TAP file, the file is opened/closed on each write for flushes to disk
static Function TAP_WriteOutput(str)
	string str

	SVAR/SDFR=GetPackageFolder() tap_filename
	variable fnum

	open/A/Z/P=home fnum as tap_filename
	if(!V_flag)
		fprintf fnum, "%s", str
		close fnum
	else
		PathInfo home
		printf "Error: Could not write to TAP output file at %s\r", S_path + tap_filename
	endif
End

/// Resets TAP Directive/Description to empty strings
static Function TAP_ClearNotes()
	dfref dfr = GetPackageFolder()
	string/G dfr:tap_directive = ""
	string/G dfr:tap_description = ""
End

/// If a TAP Description starts with a digit (which is invalid), add a '_' at the front
static Function/S TAP_GetValidDescription(str)
	string str

	string str_notAllowedStart
	variable i

	str_notAllowedStart = "0123456789"

	for(i = 0; i < strlen(str_notAllowedStart); i += 1)
		if(strsearch(str, str_notAllowedStart[i], 0) == 0)
			return ("_" + str)
		endif
	endfor
	return str
end

/// Parses a string for TAP Description/Directives keys, converts to valid ones for TAP output, key char '#' is replaced by '_'
static Function TAP_ValidNote(str)
	string str

	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr tap_directive
	SVAR/SDFR=dfr tap_description
	variable s_key_pos

	s_key_pos = strsearch(str, TAP_DIRECTIVE_STR, 0)
	if(s_key_pos > 0)
		tap_directive = str[s_key_pos + strlen(TAP_DIRECTIVE_STR), Inf]
		tap_directive = TrimString(tap_directive)
		if(strlen(tap_directive) > 0)
			tap_directive = ReplaceString("#", tap_directive, "_")
			tap_directive = "# " + tap_directive
		endif
	endif

	s_key_pos = strsearch(str, TAP_DESCRIPTION_STR, 0)
	if(s_key_pos > 0)
		tap_description	= str[s_key_pos + strlen(TAP_DESCRIPTION_STR), Inf]
		tap_description = TrimString(tap_description)
		tap_description = ReplaceString("#", tap_description, "_")
		tap_description = TAP_GetValidDescription(tap_description)

	endif
End

/// Reads the preceding two lines of a function, finds optional TAP Directive/Description, Checks the TAP Directive for the SKIP keyword, returns 1 if present
Function TAP_GetNotes(s_funcName)
	string s_funcName

	string s_funcText

	TAP_ClearNotes()
	SVAR/SDFR=GetPackageFolder() tap_directive

	s_funcText = ProcedureText(s_funcName, 2, "[" + GetIndependentModuleName() + "]")
	TAP_ValidNote(StringFromList(0, s_funcText, "\r"))
	TAP_ValidNote(StringFromList(1, s_funcText, "\r"))
	return (strsearch(tap_directive, "# SKIP", 0) >= 0)
End

/// Checks optional TAP Directives of all Test Case functions for the SKIP keyword, returns 1 if all is SKIPped
Function TAP_CheckAllSkip(testCaseList)
	string testCaseList

	TAP_ClearNotes()

	string funcName
	variable i, numItems

	numItems = ItemsInList(testCaseList)
	for(i = 0; i < numItems; i += 1)
		funcName = StringFromList(i, testCaseList)
		if(!TAP_GetNotes(funcName))
			return 0
		endif
	endfor
	return 1
End

/// @brief returns 1 if all test cases are marked as SKIP and TAP is enabled, zero otherwise
///
/// @param testCaseList list of function names
/// @returns 1 if all test cases are marked as SKIP and TAP is enabled, zero otherwise
Function TAP_AreAllFunctionsSkip(testCaseList)
	string testCaseList

	string funcName
	variable i, numItems

	numItems = ItemsInList(testCaseList)
	for(i = 0; i < numItems; i += 1)
		funcName = StringFromList(i, testCaseList)
		if(!TAP_IsFunctionSkip(funcName))
			return 0
		endif
	endfor
	return 1
End

/// @brief returns 1 if function is marked as TODO, zero otherwise
///
/// @param funcName name of function
/// @returns 1 if function is marked as TODO, zero otherwise
Function TAP_IsFunctionTodo(funcName)
	string funcName

	variable err
	string str
	
	str = UTF_Utils#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
	if(!err)
		return strsearch(str, "TODO", 0, 2) == 0
	endif

	return 0
End

/// @brief returns 1 if current function is marked as TODO, zero otherwise.
///        Faster because it only reads out a string, needs to be called after TAP_TestCaseBegin.
///
/// @returns 1 if current function is marked as TODO, zero otherwise
Function TAP_IsFunctionTodo_Fast()
	string funcName

	variable result, err
	DFREF dfr = GetPackageFolder()
	SVAR/SDFR=dfr tap_directive
	
	return strsearch(tap_directive, "# TODO", 0, 2) == 0
End

/// @brief returns 1 if function is marked as SKIP, zero otherwise
///
/// @param funcName name of function
/// @returns 1 if function is marked as SKIP, zero otherwise
Function TAP_IsFunctionSkip(funcName)
	string funcName

	variable err
	string str

	str = UTF_Utils#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
	if(!err)
		return strsearch(str, "SKIP", 0, 2) == 0
	endif

	return 0
End

/// If a TAP Description starts with a digit (which is invalid), add a '_' at the front
static Function/S TAP_GetValidDescription(str)
	string str

	string str_notAllowedStart
	variable i

	str_notAllowedStart = "0123456789"

	for(i = 0; i < strlen(str_notAllowedStart); i += 1)
		if(strsearch(str, str_notAllowedStart[i], 0) == 0)
			return ("_" + str)
		endif
	endfor
	return str
end

/// @brief writes string to either tap_directive or tap_description in correct format
///
/// @param str         string to write
/// @param isDirective unequal zero if directive, zero if description
static Function TAP_WriteValidTag(str, isDirective)
	string str
	variable isDirective

	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr tap_directive
	SVAR/SDFR=dfr tap_description

	str = ReplaceString("#", str, "_")

	if(isDirective)
		tap_directive = "# " + str
	else
		tap_description = TAP_GetValidDescription(str)
	endif
End

/// @brief writes the tag information on directive and description in the according global strings
///
/// @param funcName name of function
Function TAP_SetDirectiveAndDescription(funcName)
	string funcName

	variable err
	string directive, description
	
	directive = UTF_Utils#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DIRECTIVE, err)
	if(err == UTF_TAG_OK)
		TAP_WriteValidTag(directive, 1)
	endif

	description = UTF_Utils#GetFunctionTagValue(funcName, UTF_FTAG_TAP_DESCRIPTION, err)
	if(err == UTF_TAG_OK)
		TAP_WriteValidTag(description, 0)
	endif
End

/// @brief if the current test case is marked as expected failure, TAP will treat it as TODO
static Function TAP_treatExpectedFailureAsTodo()
	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr tap_directive

	string buf = tap_directive

	if(UTF_Utils#IsEmpty(buf))
		if(IsExpectedFailure())
			tap_directive = "# TODO due to function tag EXPECTED_FAILURE"
		endif
	endif
End

Function TAP_TestCaseBegin(funcNameWithSuffix)
	string funcNameWithSuffix

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr error_count

	string/G dfr:tap_diagnostic = ""
	variable/G dfr:tap_caseErr = error_count

	TAP_ClearNotes()
	SplitString/E="[^:]*" funcNameWithSuffix
	TAP_SetDirectiveAndDescription(S_Value)
End

Function TAP_TestCaseEnd()
	DFREF dfr = GetPackageFolder()

	NVAR/SDFR=dfr error_count
	NVAR/SDFR=dfr tap_caseErr

	tap_caseErr -= error_count

	TAP_treatExpectedFailureAsTodo()

	if(shouldDoAbort())
		TAP_WriteOutputIfReq("Bail out!")
	endif
End

/// Converts generic diagnostic text to a valid TAP diagnostic text
static Function/S TAP_ValidDiagnostic(diag)
	string diag

	if(UTF_Utils#IsEmpty(diag))
		return diag
	endif
	// Add a newline on demand to tap_diagnostic, both functions return byte position (and not char position)
	// The check works only if tap_diagnostic is not ""
	if(strsearch(diag, "\r", Inf, 1) != (strlen(diag) - 1) )
		diag += "\r"
	endif
	// diagnostic message may start with 'ok' or 'not ok' in a line which are TAP keywords
	// so we add a "#" to each line
	diag = "# " + diag
	diag = ReplaceString("\r", diag, TAP_LINEEND_STR + "#")
	diag = diag[0, strlen(diag) - strlen(TAP_LINEEND_STR) - 1]
	return diag
End

/// Writes collected TAP Output for a single Test Case to file
static Function TAP_WriteCase(case_cnt, skipcase)
	variable case_cnt, skipcase

	dfref dfr = GetPackageFolder()
	SVAR/SDFR=dfr tap_diagnostic
	SVAR/SDFR=dfr tap_description
	SVAR/SDFR=dfr tap_directive
	NVAR/SDFR=dfr tap_caseErr

	string str_out
	string str_ok

	if(skipcase)
		str_ok = "ok"
		tap_diagnostic = ""
	else
		str_ok = SelectString(tap_caseErr == 0, "not ok", "ok")
		tap_diagnostic = TAP_ValidDiagnostic(tap_diagnostic)
	endif

	// Write Out Test Case Result, TAP counts starting with 1
	sprintf str_out, "%s %d %s %s" + TAP_LINEEND_STR, str_ok, case_cnt, tap_description, tap_directive
	TAP_WriteOutput(str_out)

	// Write out Diagnostic
	TAP_WriteOutput(tap_diagnostic)
End
