#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_FunctionTags

/// @brief Returns a global wave that stores the Function Tag Waves of this testrun
static Function/WAVE GetFunctionTagWaves()

	string name = "FunctionTagWaves"

	DFREF dfr = GetPackageFolder()
	WAVE/Z/WAVE wv = dfr:$name
	if(WaveExists(wv))
		return wv
	endif

	Make/WAVE/N=0 dfr:$name/WAVE=wv

	return wv
End

static Function AddFunctionTagWave(fullFuncName)
	string fullFuncName

	variable size

	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	WAVE/T tags = GetFunctionTagWave(fullFuncName)
	if(DimSize(tags, UTF_ROW))
		size = DimSize(ftagWaves, UTF_ROW)
		Redimension/N=(size + 1) ftagWaves
		ftagWaves[size] = tags
		SetDimLabel UTF_ROW, size, $fullFuncName, ftagWaves
	endif
End

/// @brief returns 1 if the comments above a function contain a certain tag, zero otherwise
///
/// @param funcName function name
/// @param tagName  tag that is searched (see FunctionTagStrings for possible tags)
/// @returns        1 if the comments above a function contain a certain tag, zero otherwise
static Function HasFunctionTag(funcName, tagName)
	string funcName, tagName

	variable funcPos

	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	funcPos = FindDimLabel(ftagWaves, UTF_ROW, funcName)
	if(funcPos == -2)
		return 0
	endif

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

	variable tagPosition, funcPos
	string tagValue, msg

	err = UTF_TAG_ABORTED
	WAVE/WAVE ftagWaves = GetFunctionTagWaves()
	funcPos = FindDimlabel(ftagWaves, UTF_ROW, funcName)
	if(funcPos == -2)
		err = UTF_TAG_NOT_FOUND
		sprintf msg, "The tag %s was not found.", tagName
		return msg
	endif

	WAVE/T tagValueWave = ftagWaves[funcPos]
	tagPosition = FindDimLabel(tagValueWave, UTF_ROW, tagName)
	if(tagPosition == -2)
		err = UTF_TAG_NOT_FOUND
		sprintf msg, "The tag %s was not found.", tagName
		return msg
	endif

	tagValue = tagValueWave[tagPosition]
	if(UTF_Utils#IsEmpty(tagValue))
		err = UTF_TAG_EMPTY
		sprintf msg, "The tag %s has no value.", tagName
		return msg
	endif

	err = UTF_TAG_OK

	return tagValue
End

/// @brief returns a wave consisting of function tags (see FunctionTagStrings)
static Function/WAVE GetTagConstants()

	Make/T/FREE tagConstants = {UTF_FTAG_NOINSTRUMENTATION, UTF_FTAG_TD_GENERATOR, UTF_FTAG_EXPECTED_FAILURE, UTF_FTAG_SKIP, UTF_FTAG_TAP_DIRECTIVE, UTF_FTAG_TAP_DESCRIPTION, UTF_FTAG_NO_WAVE_TRACKING}

	return tagConstants
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

	WAVE templates = UTF_Basics#GetMMDVarTemplates()
	numUniqueTags = DimSize(tag_constants, UTF_ROW)

	numFound = 0

	funcTextWithContext = ProcedureText(funcName, -1, "[" + GetIndependentModuleName() + "]")
	funcTextWithoutContext = ProcedureText(funcName, 0, "[" + GetIndependentModuleName() + "]")
	funcText = ReplaceString(funcTextWithoutContext, funcTextWithContext, "")
	numLines = ItemsInList(funcText, "\r")

	Make/FREE/T/N=(numLines) tagValueWave

	for(i = numLines - 1; numLines > 0 && i >= 0; i -= 1 )
		funcLine = StringFromList(i, funcText, "\r")
		if(UTF_Utils#IsEmpty(funcLine))
			continue
		endif

		for(j = 0; j < numUniqueTags; j += 1 )
			tagName = tag_constants[j]
			expr = "\/{2,}[[:space:]]*\\Q" + tagName + "\\E(.*)$"

			SplitString/E=expr funcLine, tagValue
			if(V_flag != 1)
				continue
			endif

			tagValue = TrimString(tagValue)
			if(FindDimLabel(tagValueWave, 0, tagName) != -2)
				sprintf msg, "Test case %s has the tag %s at least twice.", funcName, tagValue
				UTF_Reporting#ReportErrorAndAbort(msg)
			endif

			if(!CmpStr(tagName, UTF_FTAG_TD_GENERATOR) && ItemsInList(tagValue, ":") == 2)
				varName = StringFromList(0, tagvalue, ":")
				tagName = UTF_FTAG_TD_GENERATOR + " " + varName
				allVarList = UTF_Basics#GetMMDAllVariablesList()
				if(WhichListItem(varName, allVarList, ";", 0, 0) == -1)
					sprintf msg, "Test case %s uses an unknown variable name %s in the tag %s.", funcName, varName, tagValue
					UTF_Reporting#ReportErrorAndAbort(msg)
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