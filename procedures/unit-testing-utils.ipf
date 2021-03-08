#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.08
#pragma TextEncoding="UTF-8"
#pragma ModuleName=UTF_Utils

// Licensed under 3-Clause BSD, see License.txt

static Constant UTF_MAXDIFFCOUNT = 10

///@cond HIDDEN_SYMBOL

// Choosen so that we don't hit the IP6 limit of 1000 chars
// with two %s and some other text.
static Constant MAX_STRING_LENGTH = 250

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

/// @brief Prepare the passed string for output
///
/// We return a fixed string if it is null and limit its size so that it can be used in a sprintf statement using plain
/// "%s". We also do that for IP9, where this limit does not exist anymore, to have a consistent output across all IP
/// versions.
static Function/S PrepareStringForOut(str, [maxLen])
	string &str
	variable maxLen

	variable length
	string suffix

	if(IsNull(str))
		return "(null)"
	endif

	maxLen = ParamIsDefault(maxLen) ? MAX_STRING_LENGTH : maxLen

	length = strlen(str)

	if(length < maxLen)
		return str
	endif

	suffix = ".."
	return str[0, maxLen - 1 - strlen(suffix)] + suffix
End

///@endcond // HIDDEN_SYMBOL

/// @brief Returns 1 if all wave elements in wave reference wave wv are of type subType, 0 otherwise
static Function HasConstantWaveTypes(wv, subType)
	WAVE/WAVE wv
	variable subType

	Make/FREE/N=(DimSize(wv, UTF_ROW)) matches
	MultiThread matches = WaveType(wv[p], 1) == subType

	FindValue/V=(0) matches
	return V_Value == -1
End

static Function/S GetTypeStrFromWaveType(wv)
	WAVE wv

	string str = ""
	variable type1, type0

	type0 = WaveType(wv)
	if(type0)
		if(type0 & IUTF_WAVETYPE0_CMPL)
			str += "complex "
		endif
		if(type0 & IUTF_WAVETYPE0_USGN)
			str += "unsigned "
		endif
		if(type0 & IUTF_WAVETYPE0_FP32)
			str += "32-bit float"
		endif
		if(type0 & IUTF_WAVETYPE0_FP64)
			str += "64-bit float"
		endif
		if(type0 & IUTF_WAVETYPE0_INT8)
			str += "8-bit integer"
		endif
		if(type0 & IUTF_WAVETYPE0_INT16)
			str += "16-bit integer"
		endif
		if(type0 & IUTF_WAVETYPE0_INT32)
			str += "32-bit integer"
		endif
		if(type0 & IUTF_WAVETYPE0_INT64)
			str += "64-bit integer"
		endif
		return str
	else
		type1 = WaveType(wv, 1)

		if(type1 == IUTF_WAVETYPE1_NULL)
			return "null wave"
		endif
		if(type1 == IUTF_WAVETYPE1_TEXT)
			return "text wave"
		endif
		if(type1 == IUTF_WAVETYPE1_DFR)
			return "DFREF wave"
		endif
		if(type1 == IUTF_WAVETYPE1_WREF)
			return "WAVE REF wave"
		endif
	endif

	return "UNKNOWN wave type"
End

/// This function assumes that EqualWaves(wv1, wv2, WAVE_DATA, tol) != 1.
static Function/S DetermineWaveDataDifference(wv1, wv2, tol)
	WAVE/Z wv1, wv2
	variable tol

	string msg
	variable isComplex1, isComplex2
	string wvName1, wvName2
	string wvNamePrefix, tmpStr1, tmpStr2

	// Generate names for reference
	if(WaveExists(wv1))
		wvName1 = GetWaveNameInDFStr(wv1)
	else
		wvName1 = "_null_"
	endif
	if(WaveExists(wv2))
		wvName2 = GetWaveNameInDFStr(wv2)
	else
		wvName2 = "_null_"
	endif
	wvNamePrefix = "Wave1: " + wvName1 + "\rWave2: " + wvName2 + "\r"

	// Size Check
	Make/FREE/D wv1Dims = {DimSize(wv1, UTF_ROW), DimSize(wv1, UTF_COLUMN), DimSize(wv1, UTF_LAYER), DimSize(wv1, UTF_CHUNK)}
	Make/FREE/D wv2Dims = {DimSize(wv2, UTF_ROW), DimSize(wv2, UTF_COLUMN), DimSize(wv2, UTF_LAYER), DimSize(wv2, UTF_CHUNK)}
	if(!EqualWaves(wv1Dims, wv2Dims, WAVE_DATA, 0))
		Make/FREE/T/N=(2, 1) table
		wfprintf tmpStr1,"[%d]", wv1Dims
		wfprintf tmpStr2,"[%d]", wv2Dims
		table[0][0] = tmpStr1
		table[1][0] = tmpStr2
		msg = NicifyTableText(table, "Dimension Sizes;")
		sprintf msg, "Waves differ in dimension sizes\r%s%s", wvNamePrefix, msg
		return msg
	endif

	// complex type
	isComplex1 = WaveType(wv1) & IUTF_WAVETYPE0_CMPL
	isComplex2 = WaveType(wv2) & IUTF_WAVETYPE0_CMPL
	if(isComplex1 != isComplex2)
		Make/FREE/T/N=(2, 1) table
		table[0][0] = GetTypeStrFromWaveType(wv1)
		table[1][0] = GetTypeStrFromWaveType(wv2)
		msg = NicifyTableText(table, "Wave Types;")
		sprintf msg, "Waves differ in complex number type\r%s%s", wvNamePrefix, msg
		return msg
	endif

	// Data Check
	Make/FREE/T/N=(2 * UTF_MAXDIFFCOUNT, 3) table
	SetDimLabel UTF_COLUMN, 0, DIMS, table
	SetDimLabel UTF_COLUMN, 1, DIMLABEL, table
	SetDimLabel UTF_COLUMN, 2, ELEMENT, table
	IterateOverWaves(table, wv1, wv2, wv1Dims[0], wv1Dims[1], wv1Dims[2], wv1Dims[3], tol)
	if(WaveType(wv1, 1) & IUTF_WAVETYPE1_TEXT)
		msg = NicifyTableText(table, "Dimensions;Labels;Text;")
		return "Text waves difference:\r" + wvNamePrefix + msg
	else
		msg = NicifyTableText(table, "Dimensions;Labels;Value;")
		if(tol != 0)
			sprintf tmpStr1, "Waves difference (tolerance limit %15f):\r", tol
		else
			tmpStr1 = "Waves difference:\r"
		endif
		return tmpStr1 + wvNamePrefix + msg
	endif

	return ""
End

static Function IterateOverWaves(table, wv1, wv2, rows, cols, layers, chunks, tol)
	WAVE/T table
	WAVE wv1, wv2
	variable rows, cols, layers, chunks, tol

	variable i, j, k, l
	variable locCount
	variable runTol

	if(chunks)
		for(l = 0; l < chunks; l += 1)
			for(k = 0; k < layers; k += 1)
				for(j = 0; j < cols; j += 1)
					for(i = 0; i < rows; i += 1)
						AddValueDiffImpl(table, wv1, wv2, locCount, i, j, k, l, runTol, tol)
						if(locCount == UTF_MAXDIFFCOUNT)
							return NaN
						endif
					endfor
				endfor
			endfor
		endfor
	elseif(layers)
		for(k = 0; k < layers; k += 1)
			for(j = 0; j < cols; j += 1)
				for(i = 0; i < rows; i += 1)
					AddValueDiffImpl(table, wv1, wv2, locCount, i, j, k, l, runTol, tol)
					if(locCount == UTF_MAXDIFFCOUNT)
						return NaN
					endif
				endfor
			endfor
		endfor
	elseif(cols)
		for(j = 0; j < cols; j += 1)
			for(i = 0; i < rows; i += 1)
				AddValueDiffImpl(table, wv1, wv2, locCount, i, j, k, l, runTol, tol)
				if(locCount == UTF_MAXDIFFCOUNT)
					return NaN
				endif
			endfor
		endfor
	else
		for(i = 0; i < rows; i += 1)
			AddValueDiffImpl(table, wv1, wv2, locCount, i, j, k, l, runTol, tol)
			if(locCount == UTF_MAXDIFFCOUNT)
				return NaN
			endif
		endfor
	endif

	Redimension/N=(2 * locCount, -1) table
	return NaN
End

static Function/S GetWaveNameInDFStr(w)
	WAVE w

	string str, tmpStr
	variable err

	str = NameOfWave(w)
	if(WaveType(w, 2) != IUTF_WAVETYPE2_FREE)
		str += " in " + GetWavesDataFolder(w, 1)
	else
		Make/FREE/WAVE/N=1 wRef
		wRef[0] = w
		WAVE wNum = wRef
#if IgorVersion() < 9.00
		sprintf tmpStr, "0x08%x", wNum[0]
#else
		if(GetRTError(0))
			tmpStr = "_free_"
		else
			sprintf tmpStr, "0x08%x", wNum[0]; err = GetRTError(1)
		endif
#endif
		str = tmpStr
	endif

	return str
End

static Function ValueEqualInclNaN(v1, v2)
	variable v1, v2

	variable isNaN1, isNaN2, isInf1, isInf2, isnegInf1, isnegInf2

	isNaN1 = IsNaN(v1)
	isNaN2 = IsNaN(v2)
	if(isNaN1 && isNaN2)
		return 1
	endif
	isInf1 = v1 == Inf
	isInf2 = v2 == Inf
	if(isInf1 && isInf2)
		return 1
	endif
	isnegInf1 = v1 == -Inf
	isnegInf2 = v2 == -Inf
	if(isnegInf1 && isnegInf2)
		return 1
	endif
	if(v1 == v2)
		return 1
	endif

	return 0
End

static Function/S SPrintWaveElement(w, row, col, layer, chunk)
	WAVE w
	variable row, col, layer, chunk

	string str, tmpStr
	variable err
	variable majorType = WaveType(w, 1)
	variable minorType = WaveType(w)

	if(majorType == IUTF_WAVETYPE1_NUM)
		if(minorType & IUTF_WAVETYPE0_CMPL)
			if(minorType & (IUTF_WAVETYPE0_INT8 | IUTF_WAVETYPE0_INT16 | IUTF_WAVETYPE0_INT32))
				Make/FREE/N=1/C/Y=(WaveType(w)) wTmp
				wTmp[0] = w[row][col][layer][chunk]
				if(minorType & IUTF_WAVETYPE0_USGN)
					wfprintf str, "(%u, %u)", wTmp
				else
					wfprintf str, "(%d, %d)", wTmp
				endif
			elseif(minorType & IUTF_WAVETYPE0_INT64)
#if IgorVersion() >= 7.00
				if(minorType & IUTF_WAVETYPE0_USGN)
					WAVE/C/L/U wCLU = w
					Make/FREE/N=1/C/L/U wTmpCLU
					wTmpCLU[0] = wCLU[row][col][layer][chunk]
					wfprintf str, "(%u, %u)", wTmpCLU
				else
					WAVE/C/L wCLS = w
					Make/FREE/N=1/C/L wTmpCLS
					wTmpCLS[0] = wCLS[row][col][layer][chunk]
					wfprintf str, "(%d, %d)", wTmpCLS
				endif
#endif
			else
				Make/FREE/N=1/C/Y=(WaveType(w)) wTmp
				wTmp[0] = w[row][col][layer][chunk]
				wfprintf str, "(%f, %f)", wTmp
			endif
		else
			if(minorType & (IUTF_WAVETYPE0_INT8 | IUTF_WAVETYPE0_INT16 | IUTF_WAVETYPE0_INT32))
				if(minorType & IUTF_WAVETYPE0_USGN)
					sprintf str, "%u", w[row][col][layer][chunk]
				else
					sprintf str, "%d", w[row][col][layer][chunk]
				endif
			elseif(minorType & IUTF_WAVETYPE0_INT64)
#if IgorVersion() >= 7.00
				if(minorType & IUTF_WAVETYPE0_USGN)
					WAVE/L/U wLU = w
					sprintf str, "%u", wLU[row][col][layer][chunk]
				else
					WAVE/L wLS = w
					sprintf str, "%d", wLS[row][col][layer][chunk]
				endif
#endif
			else
				sprintf str, "%f", w[row][col][layer][chunk]
			endif
		endif
	elseif(majorType == IUTF_WAVETYPE1_TEXT)
		WAVE/T wtext = w
		str = AutoExtendedStringOutput(wtext[row][col][layer][chunk])
	elseif(majorType == IUTF_WAVETYPE1_DFR)
		WAVE/DF wdfref = w
		tmpStr = GetDataFolder(1, wdfref[row][col][layer][chunk])
		if(IsEmpty(tmpStr))
			tmpStr = "_null DFR_"
		elseif(DataFolderRefStatus(wdfref[row][col][layer][chunk]) == 3)
			tmpStr = "_free DFR_"
		endif
#if IgorVersion() < 9.00
		sprintf str, "0x%08x : %s", w[row][col][layer][chunk], tmpStr
#else
		if(GetRTError(0))
			str = "_free_"
		else
			sprintf str, "0x%08x : %s", w[row][col][layer][chunk], tmpStr; err = GetRTError(1)
		endif
#endif
	elseif(majorType == IUTF_WAVETYPE1_WREF)
		WAVE/WAVE wref = w
		tmpStr = GetWavesDataFolder(wref[row][col][layer][chunk], 2)
		if(IsEmpty(tmpStr))
			tmpStr = "_free wave_"
		endif
#if IgorVersion() < 9.00
		sprintf str, "0x%08x : %s", w[row][col][layer][chunk], tmpStr
#else
		if(GetRTError(0))
			str = "_free_"
		else
			sprintf str, "0x%08x : %s", w[row][col][layer][chunk], tmpStr; err = GetRTError(1)
		endif
#endif
	else
		sprintf str, "Unknown wave type"
	endif

	return str
End

static Function AddValueDiffImpl(table, wv1, wv2, locCount, row, col, layer, chunk, runTol, tol)
	WAVE/T table
	WAVE wv1, wv2
	variable &locCount
	variable row, col, layer, chunk
	variable &runTol
	variable tol

	variable type1, type2, baseType1, baseType2
	variable isInt1, isInt2, isInt641, isInt642, isComplex, v1, v2, isText1
	variable bothWref, bothDFref
	variable curTol
	variable/C c1, c2
	string s1, s2, str
#if IgorVersion() >= 7.0
	INT64 cmpI64R
#endif

	baseType1 = WaveType(wv1, 1)
	baseType2 = WaveType(wv2, 1)
	type1 = WaveType(wv1)
	type2 = WaveType(wv2)

	bothWref = (baseType1 == IUTF_WAVETYPE1_WREF) && (baseType2 == IUTF_WAVETYPE1_WREF)
	bothDFref = (baseType1 == IUTF_WAVETYPE1_DFR) && (baseType2 == IUTF_WAVETYPE1_DFR)
	isText1 = baseType1 == IUTF_WAVETYPE1_TEXT
	if(istext1)
		WAVE/T wv1t = wv1
		WAVE/T wv2t = wv2

		s1 = wv1t[row][col][layer][chunk]
		s2 = wv2t[row][col][layer][chunk]

#if IgorVersion() >= 7.0
		if(!CmpStr(s1, s2, 2))
			return NaN
		endif
#else
		Make/FREE/T s1w = {s1}
		Make/FREE/T s2w = {s2}

		if(EqualWaves(s1w, s2w, WAVE_DATA))
			return NaN
		endif
#endif
	elseif(bothWref)
		WAVE/WAVE wWRef1 = wv1
		WAVE/WAVE wWRef2 = wv2
		if(WaveRefsEqual(wWRef1[row][col][layer][chunk], wWRef2[row][col][layer][chunk]))
			return NaN
		endif
	elseif(bothDFref)
		WAVE/DF wDFRef1 = wv1
		WAVE/DF wDFRef2 = wv2
		if(DataFolderRefsEqual(wDFRef1[row][col][layer][chunk], wDFRef2[row][col][layer][chunk]))
			return NaN
		endif
	else
		isInt1 = type1 & (IUTF_WAVETYPE0_INT8 | IUTF_WAVETYPE0_INT16 | IUTF_WAVETYPE0_INT32 | IUTF_WAVETYPE0_INT64)
		isInt2 = type2 & (IUTF_WAVETYPE0_INT8 | IUTF_WAVETYPE0_INT16 | IUTF_WAVETYPE0_INT32 | IUTF_WAVETYPE0_INT64)
		isInt641 = type1 & IUTF_WAVETYPE0_INT64
		isInt642 = type2 & IUTF_WAVETYPE0_INT64
		isComplex = type1 & IUTF_WAVETYPE0_CMPL

		if(isInt1 && isInt2)
			// Int compare
			if(isInt641 || isInt642)
#if IgorVersion() >= 7.0
				if(isComplex)
					Make/FREE/C/L/N=1 wInt64Diff
					wInt64Diff[0] = wv2[row][col][layer][chunk] - wv1[row][col][layer][chunk]
					v1 = real(wInt64Diff[0])
					v2 = imag(wInt64Diff[0])
					if(!v1 && !v2)
						return NaN
					elseif(tol != 0)
						curTol = v1 * v1 + v2 * v2
					endif
				else
					cmpI64R = wv2[row][col][layer][chunk] - wv1[row][col][layer][chunk]
					if(!cmpI64R)
						return NaN
					elseif(tol != 0)
						curTol = cmpI64R * cmpI64R
					endif
				endif
#endif
			else
				if(isComplex)
					c1 = wv2[row][col][layer][chunk] - wv1[row][col][layer][chunk]
					v1 = real(c1)
					v2 = imag(c1)
					if(!v1 && !v2)
						return NaN
					elseif(tol != 0)
						curTol = v1 * v1 + v2 * v2
					endif
				else
					v1 = wv1[row][col][layer][chunk]
					v2 = wv2[row][col][layer][chunk]
					if(v1 == v2)
						return NaN
					elseif(tol != 0)
						curTol = (v1 - v2) * (v1 - v2)
					endif
				endif
			endif
		else
			// FP compare
			if(isComplex)
				c1 = wv1[row][col][layer][chunk]
				c2 = wv2[row][col][layer][chunk]
				if(ValueEqualInclNaN(real(c1), real(c2)) && ValueEqualInclNaN(imag(c1), imag(c2)))
					return NaN
				elseif(tol != 0)
					v1 = GetToleranceValues(real(c1), real(c2))
					v1 = IsFinite(v1) ? real(c1) - real(c2) : Inf
					v2 = GetToleranceValues(imag(c1), imag(c2))
					v2 = IsFinite(v1) ? imag(c1) - imag(c2) : Inf
					curTol = v1 * v1 + v2 * v2
				endif
			else
				v1 = wv1[row][col][layer][chunk]
				v2 = wv2[row][col][layer][chunk]
				if(ValueEqualInclNaN(v1, v2))
					return NaN
				elseif(tol != 0)
					curTol = GetToleranceValues(v1, v2)
				endif
			endif
		endif
	endif

	if(!(istext1 | bothWref | bothDFref))
		runTol += curTol
		if(runTol < tol)
			return NaN
		endif
	endif

	sprintf str, "[%d][%d][%d][%d]", row, col, layer, chunk
	table[2 * locCount][%DIMS] = str
	Make/FREE/T wDL1 = {GetDimLabel(wv1, UTF_ROW, row), GetDimLabel(wv1, UTF_COLUMN, col), GetDimLabel(wv1, UTF_LAYER,layer), GetDimLabel(wv1, UTF_CHUNK, chunk)}
	str = wDL1[0] + wDL1[1] + wDL1[2] + wDL1[3]
	if(!IsEmpty(str))
		sprintf str, "%s;%s;%s;%s;", wDL1[0], wDL1[1], wDL1[2], wDL1[3]
		table[2 * locCount][%DIMLABEL] = str
	endif
	Make/FREE/T wDL2 = {GetDimLabel(wv2, UTF_ROW, row), GetDimLabel(wv2, UTF_COLUMN, col), GetDimLabel(wv2, UTF_LAYER,layer), GetDimLabel(wv2, UTF_CHUNK, chunk)}
	str = wDL2[0] + wDL2[1] + wDL2[2] + wDL2[3]
	if(!IsEmpty(str))
		sprintf str, "%s;%s;%s;%s;", wDL2[0], wDL2[1], wDL2[2], wDL2[3]
		table[2 * locCount + 1][%DIMLABEL] = str
	endif
	table[2 * locCount][%ELEMENT] = SPrintWaveElement(wv1, row, col, layer, chunk)
	table[2 * locCount + 1][%ELEMENT] = SPrintWaveElement(wv2, row, col, layer, chunk)

	locCount += 1
End

// This function assumes that v1 != v2 and not both are NaN
static Function GetToleranceValues(v1, v2)
	variable v1, v2

	variable isNaN1, isNaN2, isInf1, isInf2, isnegInf1, isnegInf2

	isNaN1 = IsNaN(v1)
	isNaN2 = IsNaN(v2)
	if(isNaN1 || isNaN2)
		return Inf
	endif
	isInf1 = v1 == Inf
	isInf2 = v2 == Inf
	if(isInf1 != isInf2)
		return Inf
	endif
	isnegInf1 = v1 == -Inf
	isnegInf2 = v2 == -Inf
	if(isnegInf1 != isnegInf2)
		return Inf
	endif

	return (v1 - v2) * (v1 - v2)
End

static Function/S NicifyTableText(table, titleList)
	WAVE/T table
	string titleList

	variable numCols, numRows, i, j, padVal
	string str

	InsertPoints/M=(UTF_ROW) 0, 2, table
	numCols = min(DimSize(table, UTF_COLUMN), ItemsInList(titleList))
	for(i = 0; i < numCols; i += 1)
		table[0][i] = StringFromList(i, titleList)
	endfor

	numCols = DimSize(table, UTF_COLUMN)
	numRows = DimSize(table, UTF_ROW)
	Make/FREE/N=(numRows, numCols)/D strSizes

	strSizes = strlen(table[p][q])

	for(j = 0; j < numRows; j += 1)
		padVal = j == 1 ? 0x2d : 0x20
		for(i = 0; i < numCols; i += 1)
#if IgorVersion() >= 7.00
			WaveStats/Q/M=1/RMD=[][i, i] strSizes
#else
			Make/FREE/N=(DimSize(strSizes, UTF_ROW)) strSizeCol
			strSizeCol[] = strSizes[p][i]
			WaveStats/Q/M=1 strSizeCol
#endif
			table[j][i] = PadString(table[j][i], V_Max, padVal)
		endfor
	endfor

	str = ""
	for(j = 0; j < numRows; j += 1)
		for(i = 0; i < numCols; i += 1)
			str += table[j][i] + "|"
		endfor
		str += "\r"
	endfor

	return str
End

/// @brief Based on DisplayHelpTopic "Character-by-Character Operations"
static Function NumBytesInUTF8Character(str, byteOffset)
	string str
	variable byteOffset

	variable firstByte
	variable numBytesInString = strlen(str)

	if(byteOffset < 0 || byteOffset >= numBytesInString)
		return 0
	endif

	firstByte = char2num(str[byteOffset]) & 0xFF

	if(firstByte < 0x80)
		return 1
	endif

	if(firstByte >= 0xC2 && firstByte <= 0xDF)
		return 2
	endif

	if(firstByte >= 0xE0 && firstByte <= 0xEF)
		return 3
	endif

	if(firstByte >= 0xF0 && firstByte <= 0xF4)
		return 4
	endif

	// Invalid UTF8 code point
	return 1
End

#if IgorVersion() >= 7.00
static Function/S AutoExtendedStringOutput(str)
	string str

	variable bytePos, charNum, numBytes, code
	variable extPrint, len
	string format, hexOut
	string extOut = ""

	Make/FREE/I/U biDiChars = { \
							char2num("\u200E"), char2num("\u200F"), char2num("\u061C"), char2num("\u202A"), \
							char2num("\u202D"), char2num("\u202B"), char2num("\u202E"), char2num("\u202C"), \
							char2num("\u2066"), char2num("\u2067"), char2num("\u2068"), char2num("\u2069")}

	len = strlen(str)
	if(len)
		do
			numBytes = NumBytesInUTF8Character(str, bytePos)
			code = char2num(str[bytePos, bytePos + numBytes - 1])
			if(code >= char2num("\u0000") && code <= char2num("\u001F"))
				// C0 controls
				extPrint = 1
			elseif(code >= char2num("\u007F") && code <= char2num("\u009F"))
				// C1 controls
				extPrint = 1
			else
				// Bi Directional characters
				FindValue/V=(code) biDiChars
				if(V_Value >= 0)
					extPrint = 1
				endif
			endif
			format = "%0" + num2str(2 * numBytes) + "x"
			sprintf hexOut, format, code
			extOut += hexOut + " "
			bytePos += numBytes
		while(bytePos < len)
	endif

	return SelectString(extPrint, str, ": " + extOut)
End
#else
static Function/S AutoExtendedStringOutput(str)
	string str

	variable bytePos, code
	variable extPrint, len
	string format, hexOut
	string extOut = ""

	len = strlen(str)
	for(bytePos = 0; bytePos < len; bytePos += 1)
		code = char2num(str[bytePos]) & 0x7F
		if(code >= 0 && code <= 31)
			extPrint = 1
		elseif(code == 127)
			extPrint = 1
		endif
		sprintf hexOut, "%02x", code
		extOut += hexOut + " "
	endfor

	return SelectString(extPrint, str, ": " + extOut)
End
#endif
