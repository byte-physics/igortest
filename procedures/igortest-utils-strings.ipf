#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Utils_Strings

// This pattern is used to find all placeholder in the string. This pattern consists of multiple parts:
// #1: ^#2#(?:3#5)?$
//     The full pattern.
// #2: (.*?)
//     The prefix in front of the placeholder
// #3: (@?#6#4)
//     The pattern for our placeholder including wave placeholder extension
// #4: %[^a-zA-Z%]*(?:[feEgGdousxXbc]|W\dP)
//     The pattern for placeholder that are provided to printf
// #5: (.*)
//     The pattern after the placeholder
// #6: (?<!%)
//     At this position is no % sign allowed and do not consume this char. This is used to prevent %% matching.
static StrConstant USER_PRINT_PATTERN = "^(.*?)(?:(@?(?<!%)%[^a-zA-Z%]*(?:[feEgGdousxXbc]|W\\dP))(.*))?$"

/// @brief Formats the provided string with the arguments using printf. This allows a higher flexibility
/// as such as it supports are flexible number of arguments and custom extensions. @n
/// It is required to use all provided arguments in the format string. @n
/// If for some reasons the conversion failed the parameter err is set different to 0 and the error message is
/// returned.
/// @param      format   The format string with the parameter placeholder
/// @param      strings  The wave of strings that are used for the placeholder
/// @param      numbers  The wave of numbers that are used for the placeholder
/// @param[out] err      Set different to 0 if an error during conversion happens. Set to 0 if the conversion succeeds.
/// @returns             The formated message if succeeds. The error message if failed.
static Function/S UserPrintF(format, strings, numbers, err)
	string    format
	WAVE/T    strings
	WAVE      numbers
	variable &err

	string part1, part2, part3, str
	variable num, i, stringIndex, numberIndex
	variable stringLength = DimSize(strings, UTF_ROW)
	variable numberLength = DimSize(numbers, UTF_ROW)
	string   result       = ""

	err = 0

	if(GetRTError(0))
		sprintf result, "Pending RTE detected: \"%s\" in \"%s\"", GetRTErrMessage(), GetRTStackInfo(3)
		err = 1
		return result
	endif

	for(; !IUTF_Utils#IsEmpty(format);)
		SplitString/E=USER_PRINT_PATTERN format, part1, part2, part3
		num = V_flag

		if(num < 1)
			break
		endif

		sprintf str, part1; err = GetRTError(1)
		if(err)
			sprintf str, "PrintF failed: format=\"%s\", err=%d", part1, err
			return str
		endif
		result += str

		if(num < 2)
			break
		endif

		if(!CmpStr(part2[0], "@"))
			part2 = part2[1, Inf]
			if(!CmpStr(part2, "%s"))

				if(stringIndex > 0)
					err = 1
					return "Cannot use full string wave if single entries are used"
				endif

				result += "{"
				for(i = 0; i < stringLength; i += 1)
					if(i > 0)
						result += ", "
					endif
					result += strings[i]
				endfor
				result += "}"

				stringIndex = stringLength

			else

				if(numberIndex > 0)
					err = 1
					return "Cannot use full number wave if single entries are used"
				endif

				result += "{"
				for(i = 0; i < numberLength; i += 1)
					if(i > 0)
						result += ", "
					endif

					sprintf str, part2, numbers[i]; err = GetRTError(1)
					if(err)
						sprintf str, "Cannot format number %d (%g) using format \"%s\"", i, numbers[i], part2
						return str
					endif
					result += str
				endfor
				result += "}"

				numberIndex = numberLength

			endif
		else
			if(!CmpStr(part2, "%s"))

				if(stringIndex >= stringLength)
					err = 1
					sprintf str, "Cannot load string %d, only %d are provided", stringIndex, stringLength
					return str
				endif

				result      += strings[stringIndex]
				stringIndex += 1

			else

				if(numberIndex >= numberLength)
					err = 1
					sprintf str, "Cannot load number %d, only %d are provided", numberIndex, numberLength
					return str
				endif

				sprintf str, part2, numbers[numberIndex]; err = GetRTError(1)
				if(err)
					sprintf str, "Cannot format number %d (%g) using format \"%s\"", numberIndex, numbers[numberIndex], part2
					return str
				endif

				result      += str
				numberIndex += 1

			endif
		endif

		format = part3

	endfor

	if(stringIndex < stringLength)
		err = 1
		sprintf str, "Only %d out of %d strings are consumed", stringIndex, stringLength
		return str
	endif
	if(numberIndex < numberLength)
		err = 1
		sprintf str, "Only %d out of %d numbers are consumed", numberIndex, numberLength
		return str
	endif

	return result
End

/// @brief Shuffles the contents of a list with the best PRNG for the current Igor version.
///
/// @param list       The list that is requested to be shuffled
/// @param separator  (optional, default ";") the separator of the list elements
///
/// @returns The shuffled list
static Function/S ShuffleList(list, [separator])
	string list, separator

	string result

	separator = SelectString(ParamIsDefault(separator), separator, ";")

	WAVE/T wv = ListToTextWave(list, separator)
	IUTF_Utils_Waves#InPlaceShuffleText1D(wv)
	wfprintf result, "%s" + separator, wv

	return result
End

/// Returns 1 if text starts with prefix, 0 otherwise.
static Function IsPrefix(text, prefix)
	string text, prefix

	variable textLength   = strlen(text)
	variable prefixLength = strlen(prefix)

	if(textLength < prefixLength)
		return 0
	endif

	return !CmpStr(text[0, prefixLength - 1], prefix)
End

/// @brief Search for all matches of the specified regex in the text and replaces it with the
/// replacement
///
/// @param regex        The regular string that is used to find the text to replace. This string is
///                     not allowed to contain capture groups
/// @param text         The text to search in
/// @param replacement  The text that should be placed for all matches
///
/// @return The new text with all matches replaced
static Function/S ReplaceAllRegex(regex, text, replacement)
	string regex, text, replacement

	string part1, part2, part3
	string result = ""

	for(; !IUTF_Utils#IsEmpty(text);)
		SplitString/E=("^(.*?)(" + regex + ")(.*)$") text, part1, part2, part3

		if(!V_flag)
			return result + text
		endif

		result += part1 + replacement
		text    = part3
	endfor

	return result
End

/// @brief Count the number of matches of a regex in the specified text.
///
/// @param regex        The regular string that is used to count matches. This string is not allowed
///                     to contain capture groups
/// @param text         The text to search in
///
/// @return The number of matches
static Function CountRegex(regex, text)
	string regex, text

	string part1, part2, part3
	variable count

	for(; !IUTF_Utils#IsEmpty(text);)
		SplitString/E=("^(.*?)(" + regex + ")(.*)$") text, part1, part2, part3

		if(!V_flag)
			return count
		endif

		count += 1
		text   = part3
	endfor

	return count
End
