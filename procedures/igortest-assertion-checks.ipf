#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Checks


/// @cond HIDDEN_SYMBOL

static Constant NUMTYPE_NAN = 2

/// @name CountObjects and CountObjectsDFR constant
/// @anchor TypeFlags
/// @{
static Constant COUNTOBJECTS_WAVES      = 1
static Constant COUNTOBJECTS_VAR        = 2
static Constant COUNTOBJECTS_STR        = 3
static Constant COUNTOBJECTS_DATAFOLDER = 4
/// @}

static Function IsDataFolderEmpty(folder)
	string folder

	return ((CountObjects(folder, COUNTOBJECTS_WAVES) + CountObjects(folder, COUNTOBJECTS_VAR) + CountObjects(folder, COUNTOBJECTS_STR) + CountObjects(folder, COUNTOBJECTS_DATAFOLDER)) == 0)
End

static Function IsTrue(var)
	variable var

	return (var != 0 && numType(var) != NUMTYPE_NAN)
End

static Function IsNullString(str)
	string &str

	return (numtype(strlen(str)) == NUMTYPE_NAN)
End

static Function IsEmptyString(str)
	string &str

	return (strlen(str) == 0)
End

static Function IsProperString(str)
	string &str

	return !IsEmptyString(str) && !IsNullString(str)
End

static Function AreBothVariablesNaN(var1, var2)
	variable var1, var2

	variable type1 = numType(var1)
	variable type2 = numType(var2)

	return (type1 == type2) && (type1 == NUMTYPE_NAN)
End

static Function AreVariablesEqual(var1, var2)
	variable var1, var2

	return AreBothVariablesNaN(var1, var2) || (var1 == var2)
End

static Function IsLessOrEqual(var1, var2)
	variable var1, var2

	return AreVariablesEqual(var1, var2) || IsLess(var1, var2)
End

static Function IsLess(var1, var2)
	variable var1, var2

	return var1 < var2
End

#if IgorVersion() >= 7.00

static Function AreINT64Equal(int64 var1, int64 var2)
	int64 IsEqual

	IsEqual = var1 == var2
	return IsEqual
End

static Function AreUINT64Equal(uint64 var1, uint64 var2)
	uint64 IsEqual

	IsEqual = var1 == var2
	return IsEqual
End

#endif

static Function IsVariableSmall(var, tol)
	variable var
	variable tol

	return (abs(var) <= abs(tol))
End

#if IgorVersion() >= 7.0

static Function IsINT64Small(int64 var, int64 tol)
	int64 comparison

	comparison = tol < 0
	if(comparison)
		tol = - tol
	endif

	comparison = var < 0
	if(comparison)
		var = - var
	endif

	comparison = var < tol
	return comparison
End

static Function IsUINT64Small(uint64 var, uint64 tol)
	uint64 comparison

	comparison = var < tol

	return comparison
End

#endif

static Function AreVariablesClose(var1, var2, tol, strong)
	variable var1, var2
	variable tol
	variable strong

	if(var1 == 0 || var2 == 0)
		return IsVariableSmall(var1 - var2, tol)
	endif

	strong = !!strong

	variable diff = abs(var1 - var2)
	variable d1   = diff / abs(var1)
	variable d2   = diff / abs(var2)

	// printf "d1 %.15g, d2 %.15g, d1 - d2 %.15g, strong %d, weak %d\r", d1, d2, d1 - d2, (d1 <= tol && d2 <= tol), (d1 <= tol || d2 <= tol)

	if(strong)
		return (d1 <= tol && d2 <= tol)
	else
		return (d1 <= tol || d2 <= tol)
	endif
End

#if IgorVersion() >= 7.0

static Function AreINT64Close(int64 var1, int64 var2, int64 tol)
	int64 temp, diff, comparison

	comparison = tol < 0
	if(comparison)
		tol = - tol
	endif

	comparison = var2 > var1
	if(comparison)
		temp = var1
		var1 = var2
		var2 = temp
	endif

	diff = var1 - var2
	comparison = diff < tol

	return comparison
End

static Function AreUINT64Close(uint64 var1, uint64 var2, uint64 tol)
	uint64 temp, diff, comparison

	comparison = var2 > var1
	if(comparison)
		temp = var1
		var1 = var2
		var2 = temp
	endif

	diff = var1 - var2
	comparison = diff < tol

	return comparison
End

#endif

/// @return 1 if both strings are equal and zero otherwise
static Function AreStringsEqual(str1, str2, case_sensitive)
	string &str1, &str2
	variable case_sensitive

	case_sensitive = !!case_sensitive

	if(IsNullString(str1) && IsNullString(str2))
		return 1
	elseif(IsNullString(str1) || IsNullString(str2))
		return 0
	else
		return (cmpstr(str1, str2, case_sensitive) == 0)
	endif
End

static Function AreWavesEqual(wv1, wv2, mode, tol, detailedMsg)
	Wave/Z wv1, wv2
	variable mode, tol
	string &detailedMsg

	string waveDataMsg = ""
	string dimLabelMsg = ""
	variable result, err

	if(mode == WAVE_DATA)
		if(!numpnts(wv1) || !numpnts(wv2))
			result = !numpnts(wv1) && !numpnts(wv2)
		elseif(WaveType(wv1, 1) != WaveType(wv2, 1))
			detailedMsg = "The base wave types are different, WAVE_DATA can not be compared."
			return 0
		else
			result = EqualWaves(wv1, wv2, mode, tol) == 1
		endif
	else
		result = EqualWaves(wv1, wv2, mode, tol) == 1
	endif

	if(!result)
		switch(mode)
			case WAVE_DATA:
				waveDataMsg = IUTF_Utils#DetermineWaveDataDifference(wv1, wv2, tol)
			case WAVE_DATA_TYPE:
			case WAVE_SCALING:
			case DATA_UNITS:
			case DIMENSION_UNITS:
			case WAVE_NOTE:
			case WAVE_LOCK_STATE:
			case DATA_FULL_SCALE:
			case DIMENSION_SIZES:
				// FIXME add detailed msg generation functions
				break
			case DIMENSION_LABELS:
				// work around buggy EqualWaves versions which detect some
				// waves as differing but they are not in reality
#if IgorVersion() >= 9.0
				GenerateDimLabelDifference(wv1, wv2, dimLabelMsg)
#elif IgorVersion() >= 8.0
#if NumberByKey("BUILD", IgorInfo(0)) >= 33425
				GenerateDimLabelDifference(wv1, wv2, dimLabelMsg)
#else // old IP8
				result = GenerateDimLabelDifference(wv1, wv2, dimLabelMsg)
#endif
#else // IP7 and older
				result = GenerateDimLabelDifference(wv1, wv2, dimLabelMsg)
#endif
				break
		endswitch

		detailedMsg = waveDataMsg
		if(!IUTF_Utils#IsEmpty(dimLabelMsg))
			detailedMsg += "\r" + dimLabelMsg
		endif
	else
		detailedMsg = ""
	endif


	return result
End

static Function AddIfFlagSet(var, flag, flagString, str)
	variable var, flag
	string flagString
	string &str

	if((var & flag) == flag)
		str = flagString + ", " + str
	endif
End

static Function GetWaveMajorType(wv)
	WAVE/Z wv

	variable type = 0
	variable type2 = WaveType(wv, 2)
	variable type1 = WaveType(wv, 1)

	if(type1 > 0 && type1 <= 4)
		type = type | 2^(type1 - 1)
	endif

	if(type2 > 0 && type2 <= 2)
		type = type | 2^(type2 + 3)
	endif

	if((type1 == 0 && type2 == 0) || !WaveExists(wv))
		type = NULL_WAVE
	endif

	return type
End

static Function HasWaveMajorType(wv, majorType)
	WAVE/Z wv
	variable majorType

	return (GetWaveMajorType(wv) & majorType) == majorType
End

static Function/S GetWaveMajorTypeString(type)
	variable type

	string str = ""

	if((type & NULL_WAVE) == NULL_WAVE)
		return "NULL_WAVE"
	endif
	AddIfFlagSet(type, NUMERIC_WAVE,    "NUMERIC_WAVE",    str)
	AddIfFlagSet(type, TEXT_WAVE,       "TEXT_WAVE",       str)
	AddIfFlagSet(type, DATAFOLDER_WAVE, "DATAFOLDER_WAVE", str)
	AddIfFlagSet(type, WAVE_WAVE,       "WAVE_WAVE",       str)
	AddIfFlagSet(type, NORMAL_WAVE,     "NORMAL_WAVE",     str)
	AddIfFlagSet(type, FREE_WAVE,       "FREE_WAVE",       str)

	if(!CmpStr(str, ""))
		return num2str(type)
	endif

	return RemoveEnding(str, ", ")
End

static Function GetWaveMinorType(wv)
	WAVE/Z wv

	variable type

	if(!WaveExists(wv))
		return NULL_WAVE
	endif

	type = WaveType(wv, 0)

	if(type == 0)
		type = NON_NUMERIC_WAVE
	endif

	return type
End

static Function HasWaveMinorType(wv, minorType)
	WAVE/Z wv
	variable minorType

	return (GetWaveMinorType(wv) & minorType) == minorType
End

static Function/S GetWaveMinorTypeString(type)
	variable type

	string str = ""

	if((type & NULL_WAVE) == NULL_WAVE)
		return "NULL_WAVE"
	endif
	AddIfFlagSet(type, NON_NUMERIC_WAVE, "NON_NUMERIC_WAVE", str)
	AddIfFlagSet(type, COMPLEX_WAVE,     "COMPLEX_WAVE",     str)
	AddIfFlagSet(type, FLOAT_WAVE,       "FLOAT_WAVE",       str)
	AddIfFlagSet(type, DOUBLE_WAVE,      "DOUBLE_WAVE",      str)
	AddIfFlagSet(type, INT8_WAVE,        "INT8_WAVE",        str)
	AddIfFlagSet(type, INT16_WAVE,       "INT16_WAVE",       str)
	AddIfFlagSet(type, INT32_WAVE,       "INT32_WAVE",       str)
	AddIfFlagSet(type, INT64_WAVE,       "INT64_WAVE",       str)
	AddIfFlagSet(type, UNSIGNED_WAVE,    "UNSIGNED_WAVE",    str)

	if(!CmpStr(str, ""))
		return num2str(type)
	endif

	return RemoveEnding(str, ", ")
End

static Function HasRTE(code)
	variable code

	variable rte = GetRTError(0)

	return rte == code
End

static Function HasAnyRTE()
	variable code

	variable rte = GetRTError(0)

	return !!rte
End

/// @endcond // HIDDEN_SYMBOL
