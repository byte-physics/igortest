#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma version=1.08

// Licensed under 3-Clause BSD, see License.txt

Structure strTestSuite
	// exported attributes, * = requires, XML type
	string package // *xs:token
	variable id // *xs:int
	string name // *xs:token
	string timestamp // *xs:dateTime
	string hostname // *xs:token
	variable tests // *xs:int
	variable failures // *xs:int
	variable errors // *xs:int
	variable skipped // xs:int
	variable disabled // xs:int
	variable timeTaken // *xs:decimal
	string systemErr // pre-string with preserved whitespaces
	string systemOut // pre-string with preserved whitespaces
	// for internal use
	variable timeStart
EndStructure

Structure strSuiteProperties
	string propNameList // xs:token, min length 1
	string propValueList // xs:string
EndStructure

Structure strTestCase
	string name // *xs:token
	string className // *xs:token
	variable timeTaken // *xs:decimal
	variable assertions // xs:int
	string status // xs:int
	string message // xs:string
	string type // *xs-string
	string systemErr // pre-string with preserved whitespaces
	string systemOut // pre-string with preserved whitespaces
	// for internal use
	variable timeStart
	variable error_count
	string history
	// 0 ok, 1 failure, 2 error, 3 skipped
	variable testResult
EndStructure

Structure JU_Props
	variable enableJU
	struct strSuiteProperties juTSProp
	struct strTestCase juTC
	struct strTestSuite juTS
	string testCaseList
	variable testSuiteNumber
	string testSuiteOut, testCaseListOut
EndStructure

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

/// XML properties
/// New Line is \n
/// The xs:int signed 32 bit Integer
/// The xs:decimal generic fp with max. 18 digits, exponential or scientific notation not supported.
/// The xs:string data type can contain characters, line feeds, carriage returns, and tab characters, needs also entity escapes.
/// The xs:token data type also contains characters, but the XML processor will remove
/// line feeds, carriage returns, tabs, leading and trailing spaces, and multiple spaces.
/// it is a subtype of xs:string, entity escapes apply here
/// XML: Reduces a string to a xs:token
static Function/S JU_ToXMLToken(str)
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
/// &lt; 	< 	less than
/// &gt; 	> 	greater than
/// &amp; 	& 	ampersand
/// &apos; 	' 	apostrophe
/// &quot; 	" 	quotation mark
/// XML: Escape Entity Replacer for strings
static Function/S JU_ToXMLCharacters(str)
	string str

	str = ReplaceString("&", str, "&amp;")
	str = ReplaceString("<", str, "&lt;")
	str = ReplaceString(">", str, "&gt;")
	str = ReplaceString("'", str, "&apos;")
	str = ReplaceString("\"", str, "&quot;")

	return str
End

/// trim leading and trailing white spaces from
/// every line of the given string
static Function/S JU_TrimSOUT(input, [listSepStr])
	string input
	string listSepStr

	variable i, numItems
	string output = ""

	if(ParamIsDefault(listSepStr))
		listSepStr = "\r"
	endif

	numItems = ItemsInList(input, listSepStr)
	for(i = 0; i < numItems; i += 1)
		output += TrimString(StringFromList(i, input, listSepStr))
		output += listSepStr
	endfor

	return output
End

/// Returns the current TimeStamp in the form yyyy-mm-ddThh:mm:ssZ±hh:mm in UTC + time zone
static Function/S JU_GetISO8601TimeStamp()
	variable timezone, utctime
	variable tzmin, tzhour
	string tz

	timezone = Date2Secs(-1,-1,-1)
	utctime = DateTime - timezone
	sprintf tz, "%+03d:%02d", trunc(timezone / 3600), abs(mod(timezone / 60, 60))
	return (Secs2Date(utctime, -2) + "T" + Secs2Time(utctime, 3) + "Z" + tz)
End

/// Evaluates last Test Case and returns JUNIT XML Output from Test Case
static Function/S JU_CaseToOut(juTC)
	STRUCT strTestCase &juTC

	string sout, s

	juTC.name = JU_ToXMLToken( JU_ToXMLCharacters(juTC.name))
	juTC.classname = JU_ToXMLToken( JU_ToXMLCharacters(juTC.classname))
	juTC.message = JU_ToXMLCharacters(juTC.message)
	juTC.type = JU_ToXMLCharacters(juTC.type)

	sprintf sout, "\t\t<testcase name=\"%s\" classname=\"%s\" time=\"%.3f\">\n", juTC.name, juTC.classname, juTC.timeTaken
	s = ""
	switch(juTC.testResult)
		case 3:
			s = "\t\t\t<skipped/>\n"
			break
		case 1:
			sprintf s, "\t\t\t<failure message=\"%s\" type=\"%s\"></failure>\n", juTC.message, juTC.type
			break
		case 2:
			sprintf s, "\t\t\t<error message=\"%s\" type=\"%s\"></error>\n", juTC.message, juTC.type
			break
		default:
			break
	endswitch
	sout += s

	if(strlen(juTC.systemOut))
		sout += "\t\t<system-out>" + JU_ToXMLCharacters(JU_TrimSOUT(juTC.systemOut)) + "</system-out>\n"
	endif
	if(strlen(juTC.systemErr))
		sout += "\t\t<system-err>" + JU_ToXMLCharacters(juTC.systemErr) + "</system-err>\n"
	endif

	return (sout + "\t\t</testcase>\n")
End

/// Adds a JUNIT Test Suite property to the list of properties for current Suite
static Function JU_AddTSProp(juTSProp, propName, propValue)
	STRUCT strSuiteProperties &juTSProp
	string propName
	string propValue

	if(strlen(propName))
		propName = JU_ToXMLToken( JU_ToXMLCharacters(propName))
		propValue = JU_ToXMLCharacters(propValue)
		juTSProp.propNameList = AddListItem(propName, juTSProp.propNameList, "<")
		juTSProp.propValueList = AddListItem(propValue, juTSProp.propValueList, "<")
	endif
End

/// Returns combined JUNIT XML Output for TestSuite consisting of all TestCases run in Suite
static Function/S JU_CaseListToSuiteOut(juTestCaseListOut, juTS, juTSProp)
	string juTestCaseListOut
	STRUCT strTestSuite &juTS
	STRUCT strSuiteProperties &juTSProp

	string propName, propValue
	string sout, sformat, s
	variable i, numEntries

	juTS.hostname = JU_ToXMLToken( JU_ToXMLCharacters(juTS.hostname))
	juTS.name = JU_ToXMLToken( JU_ToXMLCharacters(juTS.name))
	juTS.package = JU_ToXMLToken( JU_ToXMLCharacters(juTS.package))

	sformat = "\t<testsuite package=\"%s\" id=\"%d\" name=\"%s\" timestamp=\"%s\" hostname=\"%s\" tests=\"%d\" failures=\"%d\" errors=\"%d\" skipped=\"%d\" disabled=\"%d\" time=\"%.3f\">\n"
	sprintf sout, sformat, juTS.package, juTS.id, juTS.name, juTS.timestamp, juTS.hostname, juTS.tests, juTS.failures, juTS.errors, juTS.skipped, juTS.disabled, juTS.timeTaken

	if(ItemsInList(juTSProp.propNameList, "<"))
		sout += "\t\t<properties>\n"

		numEntries = ItemsInList(juTSProp.propNameList, "<")
		for(i = 0; i < numEntries; i += 1)
			propName = StringFromList(i, juTSProp.propNameList, "<")
			propValue = StringFromList(i, juTSProp.propValueList, "<")
			sprintf s, "\t\t\t<property name=\"%s\" value=\"%s\"/>\n", propName, propValue
			sout += s
		endfor
		sout += "\t\t</properties>\n"
	endif

	sout += juTestCaseListOut

	if(strlen(juTS.systemOut))
		sout += "\t\t<system-out>" + JU_ToXMLCharacters(JU_TrimSOUT(juTS.systemOut)) + "</system-out>\n"
	endif
	if(strlen(juTS.systemErr))
		sout += "\t\t<system-err>" + JU_ToXMLCharacters(juTS.systemErr) + "</system-err>\n"
	endif

	return (sout + "\t</testsuite>\n")
End

/// Replaces all chars >= 0x80 by "?" in str and returns the resulting string
static Function/S JU_UTF8Filter(str)
	string str

	string sret
	variable i,len

	sret = ""
	len = strlen(str)
	for(i = 0;i < len; i += 1)
		if(char2num(str[i]) < 0)
			sret += "?"
		else
			sret += str[i]
		endif
	endfor
	return sret
End

/// Writes JUNIT XML output to derived file name
Function JU_WriteOutput(s)
	STRUCT JU_Props& s

	variable fnum
	string sout, juFileName

	if(!s.enableJU)
		return NaN
	endif

	sout = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<testsuites>\n"
	sout += s.testSuiteOut
	sout += "</testsuites>\n"
#if (IgorVersion() >= 7.0)
// UTF-8 support
#else
	sout = JU_UTF8Filter(sout)
#endif
	PathInfo home
	juFileName = getUnusedFileName(S_path + "JU_" + GetBaseFilename() + ".xml")
	if(!strlen(juFileName))
		printf "Error: Unable to determine unused file name for JUNIT output in path %s !\r", S_path
		return NaN
	endif

	open/Z/P=home fnum as juFileName
	if(!V_flag)
		fBinWrite fnum, sout
		close fnum
	else
		PathInfo home
		printf "Error: Could not create JUNIT output file at %s\r", S_path + juFileName
	endif
End

/// Prepare JUNIT output for a test run
Function JU_TestBegin(s)
	STRUCT JU_Props& s

	if(!s.enableJU)
		return NaN
	endif

	s.testSuiteOut = ""
End

/// Add a EOL ('\r') after every element of a `;` separated list.
/// Intended for better readability.
static Function/S JU_NicifyList(list)
	string list

	list = RemoveEnding(list, ";")

	if(strlen(list) == 0)
		return list
	endif

	return ReplaceString(";", list, ";\r")
End

/// Prepares JUNIT Test Suite structure for a new Test Suite
Function JU_TestSuiteBegin(s, name, procWin)
	STRUCT JU_Props& s
	string name
	string procWin

	if(!s.enableJU)
		return NaN
	endif

	s.juTS.package = procWin
	s.juTS.id = s.testSuiteNumber
	s.juTS.name = name
	s.juTS.timestamp = JU_GetISO8601TimeStamp()
	s.juTS.hostname = "localhost"
	s.juTS.tests = ItemsInList(s.testCaseList)
	s.juTS.timeStart = DateTime
	s.juTS.failures = 0
	s.juTS.errors = 0
	s.juTS.skipped = 0
	s.juTS.disabled = 0
	s.juTS.systemOut = ""
	s.juTS.systemErr = ""
	s.juTSProp.propNameList = ""
	s.juTSProp.propValueList = ""
	s.testCaseListOut = ""
	JU_AddTSProp(s.juTSProp, "IgorInfo", JU_NicifyList(IgorInfo(0)))
	JU_AddTSProp(s.juTSProp, "UTFversion", GetVersion())
	JU_AddTSProp(s.juTSProp, "Experiment", IgorInfo(1))
	JU_AddTSProp(s.juTSProp, "System", JU_NicifyList(IgorInfo(3)))
#if (IgorVersion() >= 7.00)
	strswitch(IgorInfo(2))
		case "Windows":
			s.juTS.hostname = GetEnvironmentVariable("COMPUTERNAME")
			break
		case "Macintosh":
			s.juTS.hostname = GetEnvironmentVariable("HOSTNAME")
			break
		default:
			break
	endswitch
	JU_AddTSProp(s.juTSProp, "User", IgorInfo(7))
#endif
End

/// Prepares JUNIT Test Case structure for a new Test Case
Function JU_TestCaseBegin(s, fullfuncName, procWin)
	STRUCT JU_Props &s
	string fullfuncName
	string procWin

	if(!s.enableJU)
		return NaN
	endif

	NVAR/SDFR=GetPackageFolder() error_count, run_count

	s.juTC.name = fullfuncName + " in " + procWin + " (" + num2str(run_count) + ")"
	s.juTC.className = fullfuncName
	s.juTC.timeStart = DateTime
	s.juTC.error_count = error_count
	Notebook HistoryCarbonCopy, getData = 1
	s.juTC.history = S_Value
	s.juTC.message = ""
	s.juTC.type = ""
	s.juTC.systemOut = ""
	s.juTC.systemErr = ""
End

/// Evaluate status of previously run Test Case
Function JU_TestCaseEnd(s, funcName, procWin)
	STRUCT JU_Props &s
	string funcName, procWin

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr error_count
	NVAR/SDFR=dfr assert_count
	SVAR/SDFR=dfr message
	SVAR/SDFR=dfr type
	SVAR/SDFR=dfr systemErr

	if(!s.enableJU)
		return NaN
	endif

	s.juTC.timeTaken = DateTime - s.juTC.timeStart
	s.juTC.error_count = error_count - s.juTC.error_count
	// skip code 3, disabled code 4 is currently not implemented
	if(shouldDoAbort())
		s.juTC.testResult = 2
		s.juTS.errors += 1
	else
		s.juTC.testResult = (s.juTC.error_count != 0)
		s.juTS.failures += (s.juTC.error_count != 0)
	endif
	if(s.juTC.testResult)
		s.juTC.message = message
		s.juTC.type = type
	else
		if(!assert_count)
			s.juTC.systemOut += "No Assertions found in Test Case " + funcName + ", procedure file " + procWin + "\r"
		endif
	endif
	Notebook HistoryCarbonCopy, getData = 1
	s.juTC.systemOut += S_Value[strlen(s.juTC.history), Inf]
	s.juTS.systemOut += s.juTC.systemOut
	s.juTC.systemErr += systemErr
	s.juTS.systemErr += systemErr
	s.testCaseListOut += JU_CaseToOut(s.juTC)
End

/// return XML output for TestSuite
Function JU_TestSuiteEnd(s)
	STRUCT JU_Props &s

	if(!s.enableJU)
		return NaN
	endif

	s.juTS.timeTaken = DateTime - s.juTS.timeStart
	s.testSuiteOut += JU_CaseListToSuiteOut(s.testCaseListOut, s.juTS, s.juTSProp)
End
