#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TestTracing

#include "igortest"

// IPT_FORMAT_OFF

#undef UTF_ALLOW_TRACING
#if Exists("TUFXOP_Version")

#if IgorVersion() >= 10.00
#define UTF_ALLOW_TRACING
#elif (IgorVersion() >= 9.00) && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)
#define UTF_ALLOW_TRACING
#endif

#endif

#ifdef UTF_ALLOW_TRACING

// Before Constants
static Constant NUMCONST = 1
static StrConstant STRCONST = "1"

structure struct_TESTTRACING
	variable var
endstructure

// Before Function 1
threadsafe Function Function1()
End
// After Function 1

// Before Function 2
threadsafe static Function Function2()
End
// After Function 2

// Before Function 3
Function Function3_TESTTRACING()
End
// After Function 3

// Before Function 4
static Function Function4()
End
// After Function 4

static Function paramTest1(val, str, w, dfr, f, s, c, wc, wt, i, i64, ui64, d, comp)
	variable val
	string str
	WAVE w
	DFREF dfr
	FUNCREF Function1 f
	STRUCT struct_TESTTRACING &s
	variable/C c
	WAVE/C wc
	WAVE/T wt
	int i
	int64 i64
	uint64 ui64
	double d
	complex comp

	variable local

	print "So many parameters"
End

static Function [DFREF dfr, STRUCT struct_TESTTRACING s] paramTest2()
End

#if IgorVersion() < 9
// Before Function 6
static Function Function6a()
	print "not nine"
End
// After Function 6
#else
// Before Function 6
static Function Function6b()
	print "nine"
End
// After Function 6
#endif

// Before Function 7
static Function Function7()
#if IgorVersion() < 9
	print "not nine"
#else
	print "nine"
#endif
End
// After Function 7

static Function iftest()

	if(1 == (1 + 0))
		print "1"
	elseif(1)
		print "2"
	else
		print "3"
	endif

	if (1 == (1 + 0))
		print "4"
	elseif (1)
		print "5"
	else
		print "6"
	endif

	print "7"
End

static Function switchtest()

	switch(1)
		// cmt
		case 1:
			print "case"
			break
			// cmt
		default:
			print "default"
			break
	endswitch
	print "after endswitch"

	switch(1)
		case 1:
			print "case"
			break
		default :
			print "default"
			break
	endswitch;
	print "after endswitch"

	switch(1)
	endswitch ;
	print "after endswitch"
End

static Function commenttest()

	// Here we have some
	// important comments
	// to test the
	// instrumentation
	print "commenttest end"
End

// Before TraceMacroTest
Macro TraceMacroTest()
	print "1"

	print "2"
EndMacro

// Before TraceWindowTest
Window TraceWindowTest() : Panel
	print "1"

	print "2"
EndMacro

// Before TraceProcTest
Proc TraceProcTest()
	print "1"

	print "2"
EndMacro

// Before uninstrumented Macro
// IUTF_NOINSTRUMENTATION
Macro TraceMacroNoInstrument()
	print "1"

	print "2"
EndMacro
#endif

// IPT_FORMAT_ON
