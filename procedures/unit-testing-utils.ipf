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


// @brief Convert a text wave to string list
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

///@endcond // HIDDEN_SYMBOL
