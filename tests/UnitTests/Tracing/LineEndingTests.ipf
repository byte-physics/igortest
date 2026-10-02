#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Tracing_LineEnding

#undef UTF_ALLOW_TRACING
#if Exists("TUFXOP_Version")

#if IgorVersion() >= 10.00
#define UTF_ALLOW_TRACING
#elif (IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
#define UTF_ALLOW_TRACING
#endif

#endif

#ifdef UTF_ALLOW_TRACING

static Function Test_LineEnding_Single()
	CHECK_EQUAL_STR("\n", IUTF_Tracing#GetLineEnding("abc\ndef"))
	CHECK_EQUAL_STR("\r", IUTF_Tracing#GetLineEnding("abc\rdef"))
	CHECK_EQUAL_STR("\r\n", IUTF_Tracing#GetLineEnding("abc\r\ndef"))
	CHECK_EQUAL_STR("\n\r", IUTF_Tracing#GetLineEnding("abc\n\rdef"))

	// line ending at the start or end of the string
	CHECK_EQUAL_STR("\n", IUTF_Tracing#GetLineEnding("\nabc"))
	CHECK_EQUAL_STR("\r\n", IUTF_Tracing#GetLineEnding("abc\r\n"))
End

static Function Test_LineEnding_EmptyLines()
	// a second identical character is an empty line and not part of the line ending
	CHECK_EQUAL_STR("\n", IUTF_Tracing#GetLineEnding("abc\n\ndef"))
	CHECK_EQUAL_STR("\r", IUTF_Tracing#GetLineEnding("abc\r\rdef"))
	CHECK_EQUAL_STR("\n", IUTF_Tracing#GetLineEnding("abc\n\n\ndef"))
	CHECK_EQUAL_STR("\r\n", IUTF_Tracing#GetLineEnding("abc\r\n\r\ndef"))
End

static Function Test_LineEnding_Default()
	CHECK_EQUAL_STR("\r", IUTF_Tracing#GetLineEnding("", defEndL = "\r"))

	// no line ending in the string
	CHECK_EQUAL_STR("\r", IUTF_Tracing#GetLineEnding("abc", defEndL = "\r"))

	// the default is only used if no line ending is found
	CHECK_EQUAL_STR("\n", IUTF_Tracing#GetLineEnding("abc\ndef", defEndL = "\r"))
End

#endif // UTF_ALLOW_TRACING
