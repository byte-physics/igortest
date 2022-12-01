#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Utils_Waves

/// @brief Search for the first occurrence of the specified dimension label and remove it. If the
/// label wasn't found nothing will be changed.
///
/// @param wv        The wave where the dimension label should be removed
/// @param dimension The dimension to search in
/// @param label     The label to remove
static Function RemoveDimLabel(wv, dimension, label)
	WAVE wv
	variable dimension
	string label

	variable index = FindDimLabel(wv, dimension, label)
	if(index != -2)
		SetDimLabel dimension, index, $"", wv
	endif
End
