#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_FunctionTags

/// @brief Returns a global wave that stores the Function Tag Waves of this testrun
static Function/WAVE GetFunctionTagWaves()

	string name = "FunctionTagWaves"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=(IUTF_WAVECHUNK_SIZE) dfr:$name/WAVE=wv
	IUTF_Utils_Vector#SetLength(wv, 0)

	return wv
End

/// @brief Returns a global wave that stores the full function names at the same position as their
/// tag waves. This is used to find the references easier.
static Function/WAVE GetFunctionTagRefs()
	string name = "FunctionTagRefs"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/T wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/T/N=(IUTF_WAVECHUNK_SIZE) dfr:$name/WAVE=wv
	IUTF_Utils_Vector#SetLength(wv, 0)

	return wv
End

static Function AddFunctionTagWave(fullFuncName)
	string fullFuncName

	variable index

	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	WAVE/T ftagRefs = GetFunctionTagRefs()
	WAVE/T tags = GetFunctionTagWave(fullFuncName)
	if(!DimSize(tags, UTF_ROW))
		return NaN
	endif

	index = IUTF_Utils_Vector#AddRow(ftagRefs)
	ftagRefs[index] = fullFuncName
	IUTF_Utils_Vector#EnsureCapacity(ftagWaves, index)
	ftagWaves[index] = tags
End

/// @brief Find the current index in the global function tag wave reference wave.
///
/// @param fullFuncName  the full function name
///
/// @returns The index inside the function tag wave reference wave. -1 if not found.
static Function GetFunctionTagRef(fullFuncName)
	string fullFuncName

	WAVE/T ftagRefs = GetFunctionTagRefs()

	return IUTF_Utils_Vector#FindText(ftagRefs, fullFuncName)
End

/// @brief returns 1 if the comments above a function contain a certain tag, zero otherwise
///
/// @param funcName function name
/// @param tagName  tag that is searched (see FunctionTagStrings for possible tags)
/// @returns        1 if the comments above a function contain a certain tag, zero otherwise
static Function HasFunctionTag(funcName, tagName)
	string funcName, tagName

	variable funcPos = GetFunctionTagRef(funcName)

	if(funcPos == -1)
		return 0
	endif

	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	WAVE tagValues = ftagWaves[funcPos]

	return (FindDimLabel(tagValues, UTF_ROW, tagName) != -2)
End

/// @brief returns the value belonging to a certain tag in the comments above a function.
/// In case of an error, returns a detailed error message instead.
///
/// @param[in]  funcName function name
/// @param[in]  tagName  tag that is searched (see FunctionTagStrings for possible tags)
/// @param[out] err      error code (see constants UTF_TAG*)
/// @returns             value belonging to a certain tag in the comments above a function, error message if not found
static Function/S GetFunctionTagValue(funcName, tagName, err)
	string funcName, tagName
	variable &err

	variable tagPosition
	string tagValue, msg
	variable funcPos = GetFunctionTagRef(funcName)

	err = UTF_TAG_ABORTED
	if(funcPos == -1)
		err = UTF_TAG_NOT_FOUND
		sprintf msg, "The tag %s was not found.", tagName
		return msg
	endif

	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	WAVE/T tagValueWave = ftagWaves[funcPos]
	tagPosition = FindDimLabel(tagValueWave, UTF_ROW, tagName)
	if(tagPosition == -2)
		err = UTF_TAG_NOT_FOUND
		sprintf msg, "The tag %s was not found.", tagName
		return msg
	endif

	tagValue = tagValueWave[tagPosition]
	if(IUTF_Utils#IsEmpty(tagValue))
		err = UTF_TAG_EMPTY
		sprintf msg, "The tag %s has no value.", tagName
		return msg
	endif

	err = UTF_TAG_OK

	return tagValue
End

/// @brief returns a wave consisting of function tags (see FunctionTagStrings)
static Function/WAVE GetTagConstants()

	Make/T/FREE tagConstants = {UTF_FTAG_NOINSTRUMENTATION, UTF_FTAG_TD_GENERATOR, UTF_FTAG_EXPECTED_FAILURE, UTF_FTAG_SKIP, UTF_FTAG_TAP_DIRECTIVE, UTF_FTAG_TAP_DESCRIPTION, UTF_FTAG_NO_WAVE_TRACKING, UTF_FTAG_RETRY_FAILED}

	return tagConstants
End

/// @brief Checks if the line has the specified function/procedure tag.
///
/// @param tag         The function/procedure tag to check
/// @param line        The line to search tag
/// @param[out] value  The value of the tag if found, otherwise an empty string
///
/// @returns 1 if tag matched, 0 if not
static Function IsTagMatch(tag, line, value)
	string tag, line
	string &value

	string expr, tagValue

	value = ""

	if(CmpStr("IUTF_", tag[0, 4]))
		// function tags that do not use the IUTF_ prefix
		expr = "\/{2,}[[:space:]]*\\Q" + tag + "\\E(?::)?(.*)$"
	else
		// compatibility layer to allow the deprecated UTF_ and the new IUTF_ prefix for
		// function tags
		expr = "\/{2,}[[:space:]]*I?\\Q" + tag[1, Inf] + "\\E(?::)?(.*)$"
	endif

	SplitString/E=expr line, tagValue
	if(V_flag != 1)
		return 0
	endif

	value = tagValue
	return 1
End

/// @brief Reads the function tags in the comments preceding the function keyword
/// returns a wave containing the tag values with their tag names as dimLabel
/// see FunctionTagStrings for possible tags
///
/// @param funcName Name of function
/// @returns        a wave containing the tag values with their tag names as dimLabel
static Function/WAVE GetFunctionTagWave(funcName)
	string funcName

	string msg, expr, funcText, funcTextWithoutContext, funcTextWithContext, funcLine, tagName, tagValue, varName, allVarList
	variable i, j, numUniqueTags, numLines, numFound
	WAVE/T tag_constants = GetTagConstants()

	WAVE templates = IUTF_Test_MD_MMD#GetMMDVarTemplates()
	numUniqueTags = DimSize(tag_constants, UTF_ROW)

	numFound = 0

	funcTextWithContext = ProcedureText(funcName, -1, "[" + GetIndependentModuleName() + "]")
	funcTextWithoutContext = ProcedureText(funcName, 0, "[" + GetIndependentModuleName() + "]")
	funcText = ReplaceString(funcTextWithoutContext, funcTextWithContext, "")
	numLines = ItemsInList(funcText, "\r")

	Make/FREE/T/N=(numLines) tagValueWave

	for(i = numLines - 1; numLines > 0 && i >= 0; i -= 1 )
		funcLine = StringFromList(i, funcText, "\r")
		if(IUTF_Utils#IsEmpty(funcLine))
			continue
		endif

		for(j = 0; j < numUniqueTags; j += 1 )
			tagName = tag_constants[j]
			if(!IsTagMatch(tagName, funcLine, tagValue))
				continue
			endif

			tagValue = TrimString(tagValue)
			if(FindDimLabel(tagValueWave, 0, tagName) != -2)
				sprintf msg, "Test case %s has the tag %s at least twice.", funcName, tagValue
				IUTF_Reporting#ReportErrorAndAbort(msg)
			endif

			if(!CmpStr(tagName, UTF_FTAG_TD_GENERATOR) && ItemsInList(tagValue, ":") == 2)
				varName = StringFromList(0, tagvalue, ":")
				tagName = UTF_FTAG_TD_GENERATOR + " " + varName
				allVarList = IUTF_Test_MD_MMD#GetMMDAllVariablesList()
				if(WhichListItem(varName, allVarList, ";", 0, 0) == -1)
					sprintf msg, "Test case %s uses an unknown variable name %s in the tag %s.", funcName, varName, tagValue
					IUTF_Reporting#ReportErrorAndAbort(msg)
				endif
				tagValue = StringFromList(1, tagvalue, ":")
			endif

			tagValueWave[numFound] = tagValue
			SetDimLabel UTF_ROW, numFound, $tagName, tagValueWave
			numfound += 1
			break
		endfor
	endfor

	Redimension/N=(numFound) tagValueWave
	return tagValueWave
End
