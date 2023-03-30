#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=IUTF_Polyfill

#if (IgorVersion() >= 7.0)
#else
/// trimstring function for Igor 6
Function/S trimstring(str)
	string str

	variable s, e
	s = -1
	do
		s += 1
	while(!cmpstr(" ", str[s]) || !cmpstr("\t", str[s]) || !cmpstr("\r", str[s]) || !cmpstr("\n", str[s]))
	e = strlen(str)
	do
		e -= 1
	while(!cmpstr(" ", str[e]) || !cmpstr("\t", str[e]) || !cmpstr("\r", str[e]) || !cmpstr("\n", str[e]))
	return (str[s, e])
End
#endif

#if (IgorVersion() >= 7.0)
    // ListToTextWave is available
#else
/// @brief Convert a string list to a text wave
///
/// @param[in] list string list
/// @param[in] sep separator string
/// @returns wave reference to free wave
Function/WAVE ListToTextWave(list, sep)
    string list, sep

    Make/T/FREE/N=(ItemsInList(list, sep)) result = StringFromList(p, list, sep)

    return result
End
#endif
