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
Z_(0, 32)
Z_(0, 33)
End
// After Function 1

// Before Function 2
threadsafe static Function Function2()
Z_(0, 37)
Z_(0, 38)
End
// After Function 2

// Before Function 3
Function Function3_TESTTRACING()
Z_(0, 42)
Z_(0, 43)
End
// After Function 3

// Before Function 4
static Function Function4()
Z_(0, 47)
Z_(0, 48)
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

Z_(0, 51)
Z_(0, 70)
Z_(0, 67)
	variable local

Z_(0, 69)
	print "So many parameters"
End

static Function [DFREF dfr, STRUCT struct_TESTTRACING s] paramTest2()
Z_(0, 72)
Z_(0, 73)
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
Z_(0, 83)
Z_(0, 85)
Z_(0, 84)
	print "nine"
End
// After Function 6
#endif

// Before Function 7
static Function Function7()
Z_(0, 90)
Z_(0, 96)
#if IgorVersion() < 9
Z_(0, 92)
	print "not nine"
#else
Z_(0, 94)
	print "nine"
#endif
End
// After Function 7

static Function iftest()
Z_(0, 99)
Z_(0, 118)

	if(Z_(0, 101, c=(1 == (1 + 0))))
Z_(0, 102)
		print "1"
	elseif(Z_(0, 103, c=(1)))
Z_(0, 104)
		print "2"
	else
Z_(0, 105)
Z_(0, 106)
		print "3"
	endif
Z_(0, 107)

	if (Z_(0, 109, c=(1 == (1 + 0))))
Z_(0, 110)
		print "4"
	elseif (Z_(0, 111, c=(1)))
Z_(0, 112)
		print "5"
	else
Z_(0, 113)
Z_(0, 114)
		print "6"
	endif
Z_(0, 115)

Z_(0, 117)
	print "7"
End

static Function switchtest()
Z_(0, 120)
Z_(0, 147)

Z_(0, 122)
	switch(1)
		// cmt
		case 1:
Z_(0, 124)
Z_(0, 125)
			print "case"
Z_(0, 126)
			break
			// cmt
		default:
Z_(0, 128)
Z_(0, 129)
			print "default"
Z_(0, 130)
			break
	endswitch
Z_(0, 131)
Z_(0, 132)
	print "after endswitch"

Z_(0, 134)
	switch(1)
		case 1:
Z_(0, 135)
Z_(0, 136)
			print "case"
Z_(0, 137)
			break
		default :
Z_(0, 138)
Z_(0, 139)
			print "default"
Z_(0, 140)
			break
	endswitch;
Z_(0, 141)
Z_(0, 142)
	print "after endswitch"

Z_(0, 144)
	switch(1)
	endswitch ;
Z_(0, 145)
Z_(0, 146)
	print "after endswitch"
End

static Function commenttest()
Z_(0, 149)
Z_(0, 156)

Z_(0, 151)
	// Here we have some
Z_(0, 152)
	// important comments
Z_(0, 153)
	// to test the
Z_(0, 154)
	// instrumentation
Z_(0, 155)
	print "commenttest end"
End

// Before TraceMacroTest
Macro TraceMacroTest()
Z_(0, 159)
Z_(0, 163)
Z_(0, 160)
	print "1"

Z_(0, 162)
	print "2"
EndMacro

// Before TraceWindowTest
Window TraceWindowTest() : Panel
Z_(0, 166)
Z_(0, 170)
Z_(0, 167)
	print "1"

Z_(0, 169)
	print "2"
EndMacro

// Before TraceProcTest
Proc TraceProcTest()
Z_(0, 173)
Z_(0, 177)
Z_(0, 174)
	print "1"

Z_(0, 176)
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
Function IUTF_TagFunc_2c4825972717351a1e6e21b29ee64c5d2572501d0f67b2d3231ce87cee9d0a9b_IGNORE()
End
