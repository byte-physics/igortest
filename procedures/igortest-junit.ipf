#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=IUTF_JUnit

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
	WAVE/T wvInfo = IUTF_Reporting#GetTestInfoWave()

	if(!CmpStr(IUTF_SEVERITY_WARN, wvAssertion[assertionIndex][%SEVERITY]))
		// skip JUnit output for warning severity
		return ""
	endif

	startIndex = str2num(wvAssertion[assertionIndex][%CHILD_START])
	endIndex = str2num(wvAssertion[assertionIndex][%CHILD_END])
	context = ""
	for(i = startIndex; i < endIndex; i += 1)
		context += "\t\t\t\tInfo: " + wvInfo[i][%MESSAGE] + "\n"
	endfor

	message = IUTF_Utils_XML#ToXMLCharacters(wvAssertion[assertionIndex][%MESSAGE])
	type = IUTF_Utils_XML#ToXMLCharacters(wvAssertion[assertionIndex][%TYPE])
	// we are outputing everything as error to keep the same behavior as older versions of IUTF

	// strswitch(wvAssertion[i][%TYPE])
	// 	case IUTF_STATUS_FAIL:
	// 		s += "\t\t\t<failure message=\"" + message + "\" type=\"" + type + "\"></failure>\n"
	// 		break
	// 	case IUTF_STATUS_ERROR:
			out = "\t\t\t<error message=\"" + message + "\" type=\"" + type + "\">\n"
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
	WAVE/T wvTestCase = IUTF_Reporting#GetTestCaseWave()
	WAVE/T wvAssertion = IUTF_Reporting#GetTestAssertionWave()

	classname = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestCase[testCaseIndex][%NAME]))
	name = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestSuite[testSuiteIndex][%PROCEDURENAME]))
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
		endIndex = str2num(wvTestCase[testCaseIndex][%CHILD_END])
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

	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
	WAVE/T wvTestSuite = IUTF_Reporting#GetTestSuiteWave()

	package = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestSuite[testSuiteIndex][%PROCEDURENAME]))
	name = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestSuite[testSuiteIndex][%PROCEDURENAME]))
	timestamp = JU_GetISO8601TimeStamp(JU_ToAbsoluteTime(wvTestSuite[testSuiteIndex][%STARTTIME]))
	hostname = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(wvTestRun[testRunIndex][%HOSTNAME]))
	tests = wvTestSuite[testSuiteIndex][%NUM_TESTS]
	failures = "0" // the number of failures are not tracked right now
	errors = wvTestSuite[testSuiteIndex][%NUM_ERROR]
	skipped = wvTestSuite[testSuiteIndex][%NUM_SKIPPED]
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
	childEnd = str2num(wvTestSuite[testSuiteIndex][%CHILD_END])
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

	name = IUTF_Utils_XML#ToXMLToken(IUTF_Utils_XML#ToXMLCharacters(name))
	value = IUTF_Utils_XML#ToXMLCharacters(value)
	sprintf s, "\t\t\t<property name=\"%s\" value=\"%s\"/>\n", name, value

	return s
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
static Function JU_WriteOutput()
	variable fnum, i, childStart, childEnd
	string out, juFileName, msg

	WAVE/T wvTestRun = IUTF_Reporting#GetTestRunWave()
	childStart = str2num(wvTestRun[%CURRENT][%CHILD_START])
	childEnd = str2num(wvTestRun[%CURRENT][%CHILD_END])

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
