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
Z_(0, 21)
Z_(0, 22)
End
// After Function 1

// Before Function 2
threadsafe static Function Function2()
Z_(0, 26)
Z_(0, 27)
End
// After Function 2

// Before Function 3
Function Function3_TESTTRACING()
Z_(0, 31)
Z_(0, 32)
End
// After Function 3

// Before Function 4
static Function Function4()
Z_(0, 36)
Z_(0, 37)
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

Z_(0, 40)
Z_(0, 59)
Z_(0, 56)
	variable local

Z_(0, 58)
	print "So many parameters"
End

static Function [DFREF dfr, STRUCT struct_TESTTRACING s] paramTest2()
Z_(0, 61)
Z_(0, 62)
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
Z_(0, 72)
Z_(0, 74)
Z_(0, 73)
	print "nine"
End
// After Function 6
#endif

// Before Function 7
static Function Function7()
Z_(0, 79)
Z_(0, 85)
Z_(0, 80)
#if IgorVersion() < 9
Z_(0, 81)
	print "not nine"
#else
Z_(0, 82)
Z_(0, 83)
	print "nine"
#endif
Z_(0, 84)
End
// After Function 7

static Function iftest()
Z_(0, 88)
Z_(0, 107)

	if(Z_(0, 90, c=(1 == (1 + 0))))
Z_(0, 91)
		print "1"
	elseif(Z_(0, 92, c=(1)))
Z_(0, 93)
		print "2"
	else
Z_(0, 94)
Z_(0, 95)
		print "3"
	endif
Z_(0, 96)

	if (Z_(0, 98, c=(1 == (1 + 0))))
Z_(0, 99)
		print "4"
	elseif (Z_(0, 100, c=(1)))
Z_(0, 101)
		print "5"
	else
Z_(0, 102)
Z_(0, 103)
		print "6"
	endif
Z_(0, 104)

Z_(0, 106)
	print "7"
End

static Function switchtest()
Z_(0, 109)
Z_(0, 134)

Z_(0, 111)
	switch(1)
		case 1:
Z_(0, 112)
Z_(0, 113)
			print "case"
Z_(0, 114)
			break
		default:
Z_(0, 115)
Z_(0, 116)
			print "default"
Z_(0, 117)
			break
	endswitch
Z_(0, 118)
Z_(0, 119)
	print "after endswitch"

Z_(0, 121)
	switch(1)
		case 1:
Z_(0, 122)
Z_(0, 123)
			print "case"
Z_(0, 124)
			break
		default :
Z_(0, 125)
Z_(0, 126)
			print "default"
Z_(0, 127)
			break
	endswitch;
Z_(0, 128)
Z_(0, 129)
	print "after endswitch"

Z_(0, 131)
	switch(1)
	endswitch ;
Z_(0, 132)
Z_(0, 133)
	print "after endswitch"
End

static Function commenttest()
Z_(0, 136)
Z_(0, 143)

Z_(0, 138)
	// Here we have some
Z_(0, 139)
	// important comments
Z_(0, 140)
	// to test the
Z_(0, 141)
	// instrumentation
Z_(0, 142)
	print "commenttest end"
End

// Before TraceMacroTest
Macro TraceMacroTest()
Z_(0, 146)
Z_(0, 150)
Z_(0, 147)
	print "1"

Z_(0, 149)
	print "2"
EndMacro

// Before TraceWindowTest
Window TraceWindowTest() : Panel
Z_(0, 153)
Z_(0, 157)
Z_(0, 154)
	print "1"

Z_(0, 156)
	print "2"
EndMacro

// Before TraceProcTest
Proc TraceProcTest()
Z_(0, 160)
Z_(0, 164)
Z_(0, 161)
	print "1"

Z_(0, 163)
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
