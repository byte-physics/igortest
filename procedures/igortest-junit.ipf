#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=IUTF_JUnit

// number of bytes up to which JU_TrimLines() trims the lines in a loop instead of splitting them further in Igor Pro 6
static Constant JU_TRIM_LOOP_BYTES = 2048

/// trim leading and trailing white spaces from
/// every line of the given string
static Function/S JU_TrimSOUT(input, [listSepStr])
	string input
	string listSepStr

	if(ParamIsDefault(listSepStr))
		listSepStr = "\r"
	endif

#if (IgorVersion() >= 7.0)
	// trimming the lines in a loop is linear from Igor Pro 7 on, and faster than splitting the input
	return JU_TrimLines(input, listSepStr, 0)
#else
	return JU_TrimLines(input, listSepStr, !JU_CanOverlap(listSepStr))
#endif
End

#if (IgorVersion() < 7.0)

/// @brief Return 1 if two occurrences of sep can overlap, e.g. for ";;", 0 otherwise
///
/// An occurrence of such a separator found from the middle of a string is not necessarily one which a search from its
/// start finds.
static Function JU_CanOverlap(sep)
	string sep

	variable i, len

	len = strlen(sep)
	for(i = 1; i < len; i += 1)
		// a prefix of sep which is also a suffix of it
		if(!cmpstr(sep[0, len - i - 1], sep[i, len - 1], 1))
			return 1
		endif
	endfor

	return 0
End

#endif

/// @brief Trim leading and trailing white spaces from every line of input and end every line with sep
///
/// With split, a long input is split at a line separator near the middle and the halves are trimmed recursively, so
/// that every character is copied about log2(n) times. Appending every line to the result in a single loop is
/// quadratic in Igor Pro 6, which copies the whole string on every append. strsearch and substrings take time
/// proportional to the length of the whole string there as well, so the halves are passed on as strings of
/// their own instead of as ranges of input.
/// The separator must not be one whose occurrences can overlap, e.g. ";;", for a split, as an occurrence found from
/// the middle is not necessarily a line boundary, see JU_CanOverlap().
///
/// @param[in] input string with lines
/// @param[in] sep   line separator
/// @param[in] split 1 to split a long input, 0 to trim all lines in a loop
/// @returns trimmed lines
static Function/S JU_TrimLines(input, sep, split)
	string input, sep
	variable split

	variable len, pos, next, mid, sepLength
	string output = ""

	len       = strlen(input)
	sepLength = strlen(sep)

	if(split && len > JU_TRIM_LOOP_BYTES)
		mid  = trunc(len / 2)
		next = strsearch(input, sep, mid)
		if(next < 0 || (next + sepLength) >= len)
			// the second half is part of the last line, split before it
			next = strsearch(input, sep, mid, 1)
		endif

		if(next >= 0 && (next + sepLength) < len)
			return JU_TrimLines(input[0, next + sepLength - 1], sep, split) + JU_TrimLines(input[next + sepLength, len - 1], sep, split)
		endif

		// the input is a single line
	endif

	for(pos = 0; pos < len; pos = next + sepLength)
		next = strsearch(input, sep, pos)
		if(next < 0)
			next = len
		endif

		output += TrimString(input[pos, next - 1]) + sep
	endfor

	return output
End

/// Formats the specified TimeStamp in the form yyyy-mm-ddThh:mm:ss in local time
static Function/S JU_GetISO8601TimeStamp(localtime)
	variable localtime

	return (Secs2Date(localtime, -2) + "T" + Secs2Time(localtime, 3))
End

static Function/S JU_AssertionOut(assertionIndex)
	variable assertionIndex

	string out, message, type, context, severity
	variable i, startIndex, endIndex

	WAVE/T wvAssertion = IUTF_Reporting#GetTestAssertionWave()
	WAVE/T wvInfo      = IUTF_Reporting#GetTestInfoWave()

	if(!CmpStr(IUTF_SEVERITY_WARN, wvAssertion[assertionIndex][%SEVERITY]))
		// skip JUnit output for warning severity
		return ""
	endif

	startIndex = str2num(wvAssertion[assertionIndex][%CHILD_START])
	endIndex   = str2num(wvAssertion[assertionIndex][%CHILD_END])
	context    = ""
	for(i = startIndex; i < endIndex; i += 1)
		context += "\t\t\t\tInfo: " + wvInfo[i][%MESSAGE] + "\n"
	endfor

	message = IUTF_Utils_XML#ToXMLCharacters(wvAssertion[assertionIndex][%MESSAGE])
	type    = IUTF_Utils_XML#ToXMLCharacters(wvAssertion[assertionIndex][%TYPE])
	// we are outputing everything as error to keep the same behavior as older versions of IUTF

	// strswitch(wvAssertion[i][%TYPE])
	// 	case IUTF_STATUS_FAIL:
	// 		s += "\t\t\t<failure message=\"" + message + "\" type=\"" + type + "\"></failure>\n"
	// 		break
	// 	case IUTF_STATUS_ERROR:
	out  = "\t\t\t<error message=\"" + message + "\" type=\"" + type + "\">\n"
	out += context
	out += "\t\t\t</error>\n"
	// 		break
	// 	default:
	// 		break
	// endswitch

	return out
End

/// Evaluates last Test Case and returns JUNIT XML Output from Test Case
static Function/S JU_CaseToOut(testSuiteIndex, testCaseIndex)
	variable testSuiteIndex, testCaseIndex

	string out, name, classname, message, type
	variable i, timeTaken, startIndex, endIndex

	variable skip = 0

	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()
	WAVE/T wvTestCase  = IUTF_Reporting#GetTestCaseWave()
	WAVE/T wvAssertion = IUTF_Reporting#GetTestAssertionWave()

	classname = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestCase[testCaseIndex][%NAME]))
	name      = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestSuite[testSuiteIndex][%PROCEDURENAME]))
	sprintf name, "%s in %s (%d)", classname, name, testCaseIndex
	timeTaken = str2num(wvTestCase[testCaseIndex][%ENDTIME]) - str2num(wvTestCase[testCaseIndex][%STARTTIME])

	sprintf out, "\t\t<testcase name=\"%s\" classname=\"%s\" time=\"%.3f\">\n", name, classname, timeTaken
	if(!CmpStr(IUTF_STATUS_SKIP, wvTestCase[testCaseIndex][%STATUS]))
		skip = 1
	endif
	if(!CmpStr(IUTF_STATUS_RETRY, wvTestCase[testCaseIndex][%STATUS]))
		skip = 1
	endif

	if(skip)
		out += "\t\t\t<skipped/>\n"
	else
		startIndex = str2num(wvTestCase[testCaseIndex][%CHILD_START])
		endIndex   = str2num(wvTestCase[testCaseIndex][%CHILD_END])
		for(i = startIndex; i < endIndex; i += 1)
			out += JU_AssertionOut(i)
		endfor
	endif

	message = wvTestCase[testCaseIndex][%STDOUT]
	if(!IUTF_Utils#IsEmpty(message))
		out += "\t\t<system-out>" + IUTF_Utils_XML#ToXMLCharacters(JU_TrimSOUT(message)) + "</system-out>\n"
	endif
	message = wvTestCase[testCaseIndex][%STDERR]
	if(!IUTF_Utils#IsEmpty(message))
		out += "\t\t<system-err>" + IUTF_Utils_XML#ToXMLCharacters(message) + "</system-err>\n"
	endif

	return (out + "\t\t</testcase>\n")
End

/// Converts the reference time string that is stored in the result storage waves into an absolute
/// time which counts the seconds since 1904-01-01.
static Function JU_ToAbsoluteTime(str)
	string str

	// Seconds since the start of the computer
	variable num = str2num(str)

	// This is the difference between two time measuring systems. DateTime is counting the seconds
	// since 1904-01-01 and StopMSTimer(-2) * IUTF_MICRO_TO_ONE since the start of the computer.
	// We need this difference as num is a time stamp in the seconds time system and need to
	// convert it to the first one.
	// During test executing runtime it is very unlikely that this difference change and therefore
	// can be treaded as constant.
	variable difference = DateTime - StopMSTimer(-2) * IUTF_MICRO_TO_ONE

	// Seconds since 1904-01-01
	return num + difference
End

/// Returns combined JUNIT XML Output for TestSuite consisting of all TestCases run in Suite
static Function/S JU_ToTestSuiteString(testRunIndex, testSuiteIndex)
	variable testRunIndex, testSuiteIndex

	string out, format, s
	string package, name, timestamp, hostname, tests, failures, errors, skipped
	variable i, timeTaken, childStart, childEnd

	WAVE/T wvTestRun   = IUTF_Reporting#GetTestRunWave()
	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()

	package   = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestSuite[testSuiteIndex][%PROCEDURENAME]))
	name      = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestSuite[testSuiteIndex][%PROCEDURENAME]))
	timestamp = JU_GetISO8601TimeStamp(JU_ToAbsoluteTime(wvTestSuite[testSuiteIndex][%STARTTIME]))
	hostname  = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestRun[testRunIndex][%HOSTNAME]))
	tests     = wvTestSuite[testSuiteIndex][%NUM_TESTS]
	failures  = "0" // the number of failures are not tracked right now
	errors    = wvTestSuite[testSuiteIndex][%NUM_ERROR]
	skipped   = wvTestSuite[testSuiteIndex][%NUM_SKIPPED]
	timeTaken = str2num(wvTestSuite[testSuiteIndex][%ENDTIME]) - str2num(wvTestSuite[testSuiteIndex][%STARTTIME])

	format = "\t<testsuite package=\"%s\" id=\"%d\" name=\"%s\" timestamp=\"%s\" hostname=\"%s\" tests=\"%s\" failures=\"%s\" errors=\"%s\" skipped=\"%s\" time=\"%.3f\">\n"
	sprintf out, format, package, testSuiteIndex, name, timestamp, hostname, tests, failures, errors, skipped, timeTaken

	out += "\t\t<properties>\n"
	out += JU_ToPropertyString("User", wvTestRun[testRunIndex][%USERNAME])
	out += JU_ToPropertyString("System", JU_NicifyList(wvTestRun[testRunIndex][%SYSTEMINFO]))
	out += JU_ToPropertyString("Experiment", wvTestRun[testRunIndex][%EXPERIMENT])
	out += JU_ToPropertyString("IUTFversion", wvTestRun[testRunIndex][%VERSION])
	out += JU_ToPropertyString("IgorInfo", JU_NicifyList(wvTestRun[testRunIndex][%IGORINFO]))
	out += "\t\t</properties>\n"

	childStart = str2num(wvTestSuite[testSuiteIndex][%CHILD_START])
	childEnd   = str2num(wvTestSuite[testSuiteIndex][%CHILD_END])
	for(i = childStart; i < childEnd; i += 1)
		out += JU_CaseToOut(testSuiteIndex, i)
	endfor

	s = wvTestSuite[testSuiteIndex][%STDOUT]
	if(!IUTF_Utils#IsEmpty(s))
		out += "\t\t<system-out>" + IUTF_Utils_XML#ToXMLCharacters(JU_TrimSOUT(s)) + "</system-out>\n"
	endif
	s = wvTestSuite[testSuiteIndex][%STDERR]
	if(!IUTF_Utils#IsEmpty(s))
		out += "\t\t<system-err>" + IUTF_Utils_XML#ToXMLCharacters(s) + "</system-err>\n"
	endif

	return (out + "\t</testsuite>\n")
End

static Function/S JU_ToPropertyString(name, value)
	string name, value

	string s

	if(IUTF_Utils#IsEmpty(value))
		return ""
	endif

	name  = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(name))
	value = IUTF_Utils_XML#ToXMLCharacters(value)
	sprintf s, "\t\t\t<property name=\"%s\" value=\"%s\"/>\n", name, value

	return s
End

/// Replaces all chars >= 0x80 by "?" in str and returns the resulting string
static Function/S JU_UTF8Filter(str)
	string str

	string sret
	variable i, len

	sret = ""
	len  = strlen(str)
	for(i = 0; i < len; i += 1)
		if(char2num(str[i]) < 0)
			sret += "?"
		else
			sret += str[i]
		endif
	endfor
	return sret
End

/// Writes JUNIT XML output to derived file name
static Function JU_WriteOutput()
	variable fnum, i, childStart, childEnd
	string out, juFileName, msg

	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
	childStart = str2num(wvTestRun[%CURRENT][%CHILD_START])
	childEnd   = str2num(wvTestRun[%CURRENT][%CHILD_END])

	out = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<testsuites>\n"
	for(i = childStart; i < childEnd; i += 1)
		out += JU_ToTestSuiteString(0, i)
	endfor
	out += "</testsuites>\n"
#if (IgorVersion() >= 7.0)
	// UTF-8 support
#else
	out = JU_UTF8Filter(out)
#endif

	IUTF_Utils_XML#WriteXML("JU_", out)
End

/// Add a EOL (`\r`) after every element of a `;` separated list.
/// Intended for better readability.
static Function/S JU_NicifyList(list)
	string list

	list = RemoveEnding(list, ";")

	if(IUTF_Utils#IsEmpty(list))
		return list
	endif

	return ReplaceString(";", list, ";\r")
End
