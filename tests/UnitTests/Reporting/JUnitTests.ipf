#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Reporting_JUnit

/// The former implementation of JU_TrimSOUT(), its runtime is quadratic in the number of lines
static Function/S ReferenceTrimSOUT(input, listSepStr)
	string input
	string listSepStr

	variable i, numItems
	string output = ""

	numItems = ItemsInList(input, listSepStr)
	for(i = 0; i < numItems; i += 1)
		output += TrimString(StringFromList(i, input, listSepStr))
		output += listSepStr
	endfor

	return output
End

static Function CheckTrimSOUT(input, [listSepStr])
	string input
	string listSepStr

	string expected, result

	if(ParamIsDefault(listSepStr))
		expected = ReferenceTrimSOUT(input, "\r")
		result   = IUTF_JUnit#JU_TrimSOUT(input)
	else
		expected = ReferenceTrimSOUT(input, listSepStr)
		result   = IUTF_JUnit#JU_TrimSOUT(input, listSepStr = listSepStr)
	endif

	INFO("input \"%s\"", s0 = input)
	CHECK_EQUAL_STR(expected, result)
End

static Function Test_TrimSOUT_SameAsBefore()
	CheckTrimSOUT("")
	CheckTrimSOUT("a")
	CheckTrimSOUT("a\r")
	CheckTrimSOUT("a\rb")
	CheckTrimSOUT("a\rb\r")
	CheckTrimSOUT("\r")
	CheckTrimSOUT("\r\r")
	CheckTrimSOUT("a\r\rb")
	CheckTrimSOUT("a\rb\r\r")
	CheckTrimSOUT("  a \r\t b\t\r")
	CheckTrimSOUT(" \r\t\r  ")
	CheckTrimSOUT("a\nb\r")
	CheckTrimSOUT("\na\n\r b c \r")

	CheckTrimSOUT("a ; b;; c", listSepStr = ";")
	CheckTrimSOUT(" a \r\n b\r\n\r\n", listSepStr = "\r\n")
End

static Function Test_TrimSOUT_IsLinear()
	variable i, numLines, start, elapsed
	string input, expected, result

	numLines = 50000

	Make/FREE/T/N=(numLines) linesWave
	WAVE/T lines = linesWave
	lines = "  line " + num2istr(p) + " with some text\t"

	input    = IUTF_Utils#TextWaveToList(lines, "\r")
	lines    = "line " + num2istr(p) + " with some text"
	expected = IUTF_Utils#TextWaveToList(lines, "\r")

	start   = StopMSTimer(-2)
	result  = IUTF_JUnit#JU_TrimSOUT(input)
	elapsed = (StopMSTimer(-2) - start) / 1e6

	CHECK_EQUAL_STR(expected, result)

	// the former quadratic implementation needs more than a minute for these lines
	INFO("JU_TrimSOUT took %g s for %d lines", n0 = elapsed, n1 = numLines)
	CHECK(elapsed < 20)
End
