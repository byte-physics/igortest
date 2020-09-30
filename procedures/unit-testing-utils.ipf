#pragma rtGlobals=3
#pragma version=1.08
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Utils

// Licensed under 3-Clause BSD, see License.txt

///@cond HIDDEN_SYMBOL

/// @brief Returns 1 if var is a finite/normal number, 0 otherwise
///
/// @hidecallgraph
/// @hidecallergraph
threadsafe static Function IsFinite(var)
	variable var

	return numType(var) == 0
End

/// @brief Returns 1 if var is a NaN, 0 otherwise
///
/// @hidecallgraph
/// @hidecallergraph
threadsafe static Function IsNaN(var)
	variable var

	return numType(var) == 2
End

/// @brief Returns 1 if str is null, 0 otherwise
/// @param str must not be a SVAR
///
/// @hidecallgraph
/// @hidecallergraph
threadsafe static Function IsNull(str)
	string& str

	variable len = strlen(str)
	return numtype(len) == 2
End

/// @brief Returns one if str is empty or null, zero otherwise.
/// @param str must not be a SVAR
///
/// @hidecallgraph
/// @hidecallergraph
threadsafe static Function IsEmpty(str)
	string& str

	variable len = strlen(str)
	return numtype(len) == 2 || len <= 0
End

/// @brief Returns one if var is a nonfinite integer, zero otherwise
threadsafe static Function IsInteger(var)
	variable var

	return trunc(var) == var && numtype(var) == 0
End

/// @brief Convert a text wave to string list
///
/// @param[in] txtWave 1D text wave
/// @param[in] sep separator string
/// @returns string with list of former text wave elements
static Function/S TextWaveToList(txtWave, sep)
	WAVE/T txtWave
	string sep

	string list = ""
	variable i, numRows

	numRows = DimSize(txtWave, 0)
	for(i = 0; i < numRows; i += 1)
		list = AddListItem(txtWave[i], list, sep, inf)
	endfor

	return list
End

/// @brief returns a wave consisting of function tags (see UTF_UTILS#FunctionTagStrings)
static Function/WAVE GetTagConstants()

	Make/T/FREE tagConstants = {UTF_FTAG_TD_GENERATOR, UTF_FTAG_EXPECTED_FAILURE, UTF_FTAG_TAP_DIRECTIVE, UTF_FTAG_TAP_DESCRIPTION}
	
	return tagConstants
End

/// @brief Reads the function tags in the comments preceding the function keyword
/// returns a wave containing the tag values with their tag names as dimLabel
/// see UTF_UTILS#FunctionTagStrings for possible tags
///
/// @param funcName Name of function
/// @returns        a wave containing the tag values with their tag names as dimLabel
static Function/WAVE GetFunctionTagWave(funcName)
	string funcName

	string msg, expr, funcText, funcTextWithoutContext, funcTextWithContext, funcLine, tagName, tagValue
	variable i, j, numPossibleTags, numLines, numFound
	WAVE/T tag_constants = GetTagConstants()

	numPossibleTags = DimSize(tag_constants, 0)
	Make/FREE/T/N=(numPossibleTags) tagValueWave

	numFound = 0

	funcTextWithContext = ProcedureText(funcName, -1, "[" + GetIndependentModuleName() + "]")
	funcTextWithoutContext = ProcedureText(funcName, 0, "[" + GetIndependentModuleName() + "]")
	funcText = ReplaceString(funcTextWithoutContext, funcTextWithContext, "")
	numLines = ItemsInList(funcText, "\r")

	for(i = numLines - 1; numLines > 0 && i >= 0; i -= 1 )
		funcLine = StringFromList(i, funcText, "\r")
		if(IsEmpty(funcLine))
			continue
		endif

		for(j = 0; j < numPossibleTags; j += 1 )
			tagName = tag_constants[j]
			expr = "\/\/*[[:space:]]*\\Q" + tagName + "\\E(.*)$"

			SplitString/E=expr funcLine, tagValue
			if(V_flag != 1)
				continue
			endif

			tagValue = TrimString(tagValue)
			if(FindDimLabel(tagValueWave, 0, tagName) != -2)
				sprintf msg, "Test case %s has the tag %s at least twice.", funcName, tagValue
				Abort msg
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

/// @brief returns 1 if the comments above a function contain a certain tag, zero otherwise
///
/// @param funcName function name
/// @param tagName  tag that is searched (see UTF_UTILS#FunctionTagStrings for possible tags)
/// @returns        1 if the comments above a function contain a certain tag, zero otherwise
static Function HasFunctionTag(funcName, tagName)
	string funcName, tagName

	WAVE tagValues = GetFunctionTagWave(funcName)
	
	return (FindDimLabel(tagValues, UTF_ROW, tagName) != -2)
End

/// @brief returns the value belonging to a certain tag in the comments above a function.
/// In case of an error, returns a detailed error message instead.
///
/// @param[in]  funcName function name
/// @param[in]  tagName  tag that is searched (see UTF_UTILS#FunctionTagStrings for possible tags)
/// @param[out] err      error code (see constants UTF_UTILS#TAG*)
/// @returns             value belonging to a certain tag in the comments above a function, error message if not found
static Function/T GetFunctionTagValue(funcName, tagName, err)
	string funcName, tagName
	variable &err

	variable tagPosition
	string tagValue, msg

	err = UTF_TAG_ABORTED
	WAVE/T tagValueWave = GetFunctionTagWave(funcName)

	tagPosition = FindDimLabel(tagValueWave, UTF_ROW, tagName)
	if(tagPosition == -2)
		err = UTF_TAG_NOT_FOUND
		sprintf msg, "The tag %s was not found.", tagName
		return msg
	endif
	
	tagValue = tagValueWave[tagPosition]
	if(IsEmpty(tagValue))
		err = UTF_TAG_EMPTY
		sprintf msg, "The tag %s has no value.", tagName
		return msg
	endif

	err = UTF_TAG_OK
	return tagValue
End
///@endcond // HIDDEN_SYMBOL
