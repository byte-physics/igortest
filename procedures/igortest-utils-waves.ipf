#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.10
#pragma ModuleName = IUTF_Utils_Waves

#if (IgorVersion() >= 9.00)
static Constant RANDOM_NUMBER_GENERATOR = 3 // Xoshiro256
#else
static Constant RANDOM_NUMBER_GENERATOR = 2 // Merseene Twister
#endif

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

/// @brief Shuffles the entries in the wave wv in a random order. It will always use the best PRNGs
/// for the current Igor version.
///
/// @param wv          a 1 dimension text wave that need to be shuffled
/// @param startIndex  (optional, default 0) The inclusive start index where the shuffle should
///                    start.
/// @param endIndex    (optional, default DimSize(wv, UTF_ROW)) The exclusive end index where the
///                    shuffle should stop. This is usefull for vectors.
static Function InPlaceShuffleText1D(wv, [startIndex, endIndex])
	WAVE/T wv
	variable startIndex, endIndex

	variable i1, i2, halfRange
	string tmp

	startIndex = ParamIsDefault(startIndex) ? 0 : startIndex
	endIndex = ParamIsDefault(endIndex) ? DimSize(wv, UTF_ROW) : endIndex

	// basic shuffle algorithm
	for(i1 = startIndex; i1 < endIndex - 1; i1 += 1)
		// getting second index
		halfRange = (endIndex - i1) * 0.5
		i2 = i1 + floor(halfRange + enoise(halfRange, RANDOM_NUMBER_GENERATOR))
		// triangle swap
		tmp = wv[i1]
		wv[i1] = wv[i2]
		wv[i2] = tmp
	endfor
End
