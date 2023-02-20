#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Utils_XML

// Helper functions to create XML files.

/// XML properties
/// New Line is \n
/// The xs:int signed 32 bit Integer
/// The xs:decimal generic fp with max. 18 digits, exponential or scientific notation not supported.
/// The xs:string data type can contain characters, line feeds, carriage returns, and tab characters, needs also entity escapes.
/// The xs:token data type also contains characters, but the XML processor will remove
/// line feeds, carriage returns, tabs, leading and trailing spaces, and multiple spaces.
/// it is a subtype of xs:string, entity escapes apply here
/// XML: Reduces a string to a xs:token
static Function/S ToXMLToken(str)
	string str
	variable i

	str = ReplaceString("\n", str, "")
	str = ReplaceString("\r", str, "")
	str = ReplaceString("\t", str, "")
#if (IgorVersion() >= 7.0)
	return (TrimString(str, 1))
#else
	for(i = 0; strsearch(str, "  ", 0) >= 0;)
		str = ReplaceString("  ", str, " ")
	endfor
	return (TrimString(str))
#endif
End

/// entity references
/// &lt;    <  less than
/// &gt;    >  greater than
/// &amp;   &  ampersand
/// &apos;  '  apostrophe
/// &quot;  "  quotation mark
/// XML: Escape Entity Replacer for strings
static Function/S ToXMLCharacters(str)
	string str

	str = ReplaceString("&", str, "&amp;")
	str = ReplaceString("<", str, "&lt;")
	str = ReplaceString(">", str, "&gt;")
	str = ReplaceString("'", str, "&apos;")
	str = ReplaceString("\"", str, "&quot;")

	return str
End

/// Writes the report xml to a local file.
///
/// @param prefix   The name of the prefix which is prepended to the file name
/// @param content  The XML content that should be written
static Function WriteXML(prefix, content)
	string prefix, content

	string fileName, msg
	variable fnum

	fileName = IUTF_Utils_Paths#AtHome(prefix + GetBaseFilename() + ".xml", unusedName = 1)
	Open/Z fnum as fileName
	if(!V_flag)
		FBinWrite fnum, content
		Close fnum
	else
		sprintf msg, "Error: Could not create XML output file at %s", fileName
		IUTF_Reporting#IUTF_PrintStatusMessage(msg)
	endif
End
