#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Utils_TextGrid

// TextGrid is a special case of a vector. A TextGrid is basically a 2 dimensional text wave. Each
// row is a single entry and the column has labels to define the values inside these entries.


/// @brief Creates a TextGrid. The names and number of columns are determined by the header
/// parameter.
static Function/WAVE Create(header)
	string header

	variable i
	string name
	variable count = ItemsInList(header)

	Make/T/N=(IUTF_WAVECHUNK_SIZE, count)/FREE wv

	for(i = 0; i < count; i += 1)
		name = StringFromList(i, header)
		SetDimLabel UTF_COLUMN, i, $name, wv
	endfor

	IUTF_Utils_Vector#SetLength(wv, 0)

	return wv
End
