#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TestTracing

#include "igortest"

// IPT_FORMAT_OFF

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 38812)

// Before Constants
static Constant NUMCONST = 1
static StrConstant STRCONST = "1"

structure struct_TESTTRACING
	variable var
endstructure

// Before Function 1
threadsafe Function Function1()
Z_(0, 19)
Z_(0, 20)
End
// After Function 1

// Before Function 2
threadsafe static Function Function2()
Z_(0, 24)
Z_(0, 25)
End
// After Function 2

// Before Function 3
Function Function3_TESTTRACING()
Z_(0, 29)
Z_(0, 30)
End
// After Function 3

// Before Function 4
static Function Function4()
Z_(0, 34)
Z_(0, 35)
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

Z_(0, 38)
Z_(0, 57)
Z_(0, 54)
	variable local

Z_(0, 56)
	print "So many parameters"
End

static Function [DFREF dfr, STRUCT struct_TESTTRACING s] paramTest2()
Z_(0, 59)
Z_(0, 60)
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
Z_(0, 70)
Z_(0, 72)
Z_(0, 71)
	print "nine"
End
// After Function 6
#endif

// Before Function 7
static Function Function7()
Z_(0, 77)
Z_(0, 83)
Z_(0, 78)
#if IgorVersion() < 9
Z_(0, 79)
	print "not nine"
#else
Z_(0, 80)
Z_(0, 81)
	print "nine"
#endif
Z_(0, 82)
End
// After Function 7

static Function iftest()
Z_(0, 86)
Z_(0, 105)

	if(Z_(0, 88, c=(1 == (1 + 0))))
Z_(0, 89)
		print "1"
	elseif(Z_(0, 90, c=(1)))
Z_(0, 91)
		print "2"
	else
Z_(0, 92)
Z_(0, 93)
		print "3"
	endif
Z_(0, 94)

	if (Z_(0, 96, c=(1 == (1 + 0))))
Z_(0, 97)
		print "4"
	elseif (Z_(0, 98, c=(1)))
Z_(0, 99)
		print "5"
	else
Z_(0, 100)
Z_(0, 101)
		print "6"
	endif
Z_(0, 102)

Z_(0, 104)
	print "7"
End

static Function switchtest()
Z_(0, 107)
Z_(0, 132)

Z_(0, 109)
	switch(1)
		case 1:
Z_(0, 110)
Z_(0, 111)
			print "case"
Z_(0, 112)
			break
		default:
Z_(0, 113)
Z_(0, 114)
			print "default"
Z_(0, 115)
			break
	endswitch
Z_(0, 116)
Z_(0, 117)
	print "after endswitch"

Z_(0, 119)
	switch(1)
		case 1:
Z_(0, 120)
Z_(0, 121)
			print "case"
Z_(0, 122)
			break
		default :
Z_(0, 123)
Z_(0, 124)
			print "default"
Z_(0, 125)
			break
	endswitch;
Z_(0, 126)
Z_(0, 127)
	print "after endswitch"

Z_(0, 129)
	switch(1)
	endswitch ;
Z_(0, 130)
Z_(0, 131)
	print "after endswitch"
End

static Function commenttest()
Z_(0, 134)
Z_(0, 141)

Z_(0, 136)
	// Here we have some
Z_(0, 137)
	// important comments
Z_(0, 138)
	// to test the
Z_(0, 139)
	// instrumentation
Z_(0, 140)
	print "commenttest end"
End

// Before TraceMacroTest
Macro TraceMacroTest()
Z_(0, 144)
Z_(0, 148)
Z_(0, 145)
	print "1"

Z_(0, 147)
	print "2"
EndMacro

// Before TraceWindowTest
Window TraceWindowTest() : Panel
Z_(0, 151)
Z_(0, 155)
Z_(0, 152)
	print "1"

Z_(0, 154)
	print "2"
EndMacro

// Before TraceProcTest
Proc TraceProcTest()
Z_(0, 158)
Z_(0, 162)
Z_(0, 159)
	print "1"

Z_(0, 161)
	print "2"
EndMacro

// Before uninstrumented Macro
// IUTF_NOINSTRUMENTATION
Macro TraceMacroNoInstrument()
	print "1"

	print "2"
EndMacro
#endif
Function IUTF_TagFunc_2c4825972717351a1e6e21b29ee64c5d2572501d0f67b2d3231ce87cee9d0a9b_IGNORE()
End

// IPT_FORMAT_ON
