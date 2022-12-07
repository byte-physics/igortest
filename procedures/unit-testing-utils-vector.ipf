#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = UTF_Utils_Vector

// Vector is a special concept that is similar to Vec<> in Rust or List<T> in C#. It represents a
// dynamically sized array of elements. All operation should be done using these methods. The wave
// that is returned here is the internal buffer and can contain more elements then it's length.

static StrConstant LENGTH_KEY = "NOTE_LENGTH"

static Function SetNumberInWaveNote(wv, key, value)
	WAVE wv
	string key
	variable value

	Note/K wv, ReplaceNumberByKey(key, note(wv), value)
End

/// @brief Set the length of the vector. This doesn't change the capacity or size of any dimension.
static Function SetLength(wv, value)
	WAVE wv
	variable value

	SetNumberInWaveNote(wv, LENGTH_KEY, value)
End

/// @brief Returns the length of the vector. This doesn't output the capacity or the real size of
/// any dimension.
static Function GetLength(wv)
	WAVE wv

	return NumberByKey(LENGTH_KEY, note(wv))
End

/// @brief Automatically increase the wave row size if required to fit the specified index.
///        The actual (filled) wave size is not tracked, the caller has to do that.
///        Returns 1 if the wave was resized, 0 if it was not resized
///
/// Known Limitations: Igor 32 bit has a limit of 2 GB and 64bit a limit of 200 GB a wave can be.
static Function EnsureCapacity(wv, indexShouldExist)

	WAVE wv
	variable indexShouldExist

	variable size = DimSize(wv, UTF_ROW)
	variable targetSize

	if(indexShouldExist < size)
		return 0
	endif

	// the wave is smaller than any usable chunk
	if(size < IUTF_WAVECHUNK_SIZE && indexShouldExist < IUTF_WAVECHUNK_SIZE)
		targetSize = IUTF_WAVECHUNK_SIZE
	// exponential sizing for smaller waves as this behave asymptotic better
	elseif(indexShouldExist < IUTF_BIGWAVECHUNK_SIZE)
		// Calculate the target size. This is a shortcut because we need most times to increase the
		// size only for a small amount and a single multiplication is faster then the complex
		// operation below.
		targetSize = size * 2
		if(targetSize <= indexShouldExist)
			// target size: n
			// indexShouldExist: m
			// chunk size: c
			// exponent: e
			//
			// n = c * 2 ^ e >= m + 1
			// => 2 ^ e >= (m + 1)/c
			// => e >= log_2((m + 1) / c)
			// => e = ceil(log_2((m + 1) / c))
			// => n = c * 2 ^ ceil(log_2((m + 1) / c)) = c * 2 ^ ceil(ln((m + 1) / c) / ln(2))
			targetSize = IUTF_WAVECHUNK_SIZE * 2 ^ ceil(ln((indexShouldExist + 1) / IUTF_WAVECHUNK_SIZE) / ln(2))
		endif
	// linear sizing for really large waves with high system memory impact. This is to reduce system
	// memory stress.
	else
		// target size: n
		// indexShouldExist: m
		// big chunk size: c
		// multiplicator: a
		//
		// n = c * a >= m + 1
		// => a >= (m + 1) / c
		// => a = ceil((m + 1) / c)
		// => n = c * ceil((m + 1) / c)
		targetSize = IUTF_BIGWAVECHUNK_SIZE * ceil((indexShouldExist + 1) / IUTF_BIGWAVECHUNK_SIZE)
	endif

	Redimension/N=(targetSize, -1, -1, -1) wv

	return 1
End

/// @brief Add a new row to the end of the vector and ensures if the wave has enough capacity for it.
/// This also updates the dimension label "CURRENT" to the new added row.
/// @param wv The wave for which a new row should be added
/// @returns The row index of the added row.
static Function AddRow(wv)
	WAVE wv

	return AddRows(wv, 1)
End

/// @brief Add count new rows at the end of the vector and ensures if the wave has enough capacity
/// for it. This also updates the dimension label "CURRENT" to the last added row.
/// @param wv    The wave for which new rows should be added.
/// @param count The number of new rows to add. If this parameter is less or equal than 0 the wave
///              remains unchanged.
/// @returns The row index of the last added row or -1 if the list is kept unchanged.
static Function AddRows(wv, count)
	WAVE wv
	variable count

	variable oldLength, newLength

	if(count <= 0)
		return -1
	endif

	oldLength = GetLength(wv)
	newLength = oldLength + count
	EnsureCapacity(wv, newLength - 1)
	SetLength(wv, newLength)

	UTF_Utils_Waves#RemoveDimLabel(wv, UTF_ROW, "CURRENT")
	SetDimLabel UTF_ROW, newLength - 1, CURRENT, wv

	return newLength - 1
End
