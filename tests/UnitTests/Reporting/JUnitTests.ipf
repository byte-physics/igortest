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
	variable i
	string longLine, lines, overlap

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

	// separators whose occurrences can overlap, longer than the limit for splitting in Igor Pro 6
	overlap = ""
	for(i = 0; i < 500; i += 1)
		overlap += " x ;;;"
	endfor
	CheckTrimSOUT(PadString("", 2050, char2num(";")), listSepStr = ";;")
	CheckTrimSOUT(overlap, listSepStr = ";;")

	// long inputs, which Igor Pro 6 splits into halves, also before the middle if a long line follows it
	longLine = " " + PadString("", 5000, char2num("x")) + " "
	lines    = ""
	for(i = 0; i < 300; i += 1)
		lines += " line " + num2istr(i) + "\t\r"
	endfor

	CheckTrimSOUT(longLine)
	CheckTrimSOUT(longLine + "\r")
	CheckTrimSOUT(" a \r" + longLine)
	CheckTrimSOUT(lines)
	CheckTrimSOUT(lines + lines + lines)
	CheckTrimSOUT(lines + longLine)
	CheckTrimSOUT(lines + longLine + "\r" + lines + "\r")
	CheckTrimSOUT(longLine + "\r" + lines + longLine)
End

static Function Test_TrimSOUT_IsLinear()
	variable numLines, start, elapsed
	string input, expected, result

	// the lines are doubled instead of filled into a text wave, which is quadratic in Igor Pro 6
	input    = "  a line with some text\t\r"
	expected = "a line with some text\r"
	for(numLines = 1; numLines < 65536; numLines *= 2)
		input    += input
		expected += expected
	endfor

	start   = StopMSTimer(-2)
	result  = IUTF_JUnit#JU_TrimSOUT(input)
	elapsed = (StopMSTimer(-2) - start) / 1e6

	CHECK_EQUAL_STR(expected, result)

	// the former quadratic implementation needs more than a minute for these lines
	INFO("JU_TrimSOUT took %g s for %d lines", n0 = elapsed, n1 = numLines)
	CHECK(elapsed < 20)
End
