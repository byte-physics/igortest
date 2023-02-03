#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Utils_Waves

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

/// @brief Moves the specified dimension label to the new index and removes it from the old
/// position. If the same dimension label is used on more than one place it will only remove the
/// first one.
///
/// @param wv         The wave where the dimension label should be moved
/// @param dimension  The dimension to search in
/// @param label      The label to move
/// @param newIndex   The new index to move the label to
///
/// @return The old index of the dimension label. This return -2 if the dimension label was not
/// found and -1 if the whole column had the dimension label.
static Function MoveDimLabel(wv, dimension, label, newIndex)
	WAVE wv
	variable dimension, newIndex
	string label

	variable oldIndex = FindDimLabel(wv, dimension, label)
	if(oldIndex != -2)
		SetDimLabel dimension, oldIndex, $"", wv
	endif
	SetDimLabel dimension, newIndex, $label, wv

	return oldIndex
End
