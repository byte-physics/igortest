#pragma rtGlobals=3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors=1
#pragma ModuleName=TestTracing

#include "unit-testing"

#if (IgorVersion() >= 9.00) && Exists("TUFXOP_Version") && (NumberByKey("BUILD", IgorInfo(0)) >= 37631)

// Before Constants
static Constant NUMCONST = 1
static StrConstant STRCONST = "1"

structure struct_TESTTRACING
	variable var
endstructure

// Before Function 1
threadsafe Function Function1()
Z_(0, 18)
Z_(0, 19)
End
// After Function 1

// Before Function 2
threadsafe static Function Function2()
Z_(0, 23)
Z_(0, 24)
End
// After Function 2

// Before Function 3
Function Function3_TESTTRACING()
Z_(0, 28)
Z_(0, 29)
End
// After Function 3

// Before Function 4
static Function Function4()
Z_(0, 33)
Z_(0, 34)
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

Z_(0, 37)
Z_(0, 56)
Z_(0, 53)
	variable local

Z_(0, 55)
	print "So many parameters"
End

static Function [DFREF dfr, STRUCT struct_TESTTRACING s] paramTest2()
Z_(0, 58)
Z_(0, 59)
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
Z_(0, 69)
Z_(0, 71)
Z_(0, 70)
	print "nine"
End
// After Function 6
#endif

// Before Function 7
static Function Function7()
Z_(0, 76)
Z_(0, 82)
Z_(0, 77)
#if IgorVersion() < 9
Z_(0, 78)
	print "not nine"
Z_(0, 79)
#else
Z_(0, 80)
	print "nine"
Z_(0, 81)
#endif
End
// After Function 7

static Function iftest()
Z_(0, 85)
Z_(0, 104)

	if(Z_(0, 87, c=(1 == (1 + 0))))
Z_(0, 88)
		print "1"
	elseif(1)
Z_(0, 89)
Z_(0, 90)
		print "2"
	else
Z_(0, 91)
Z_(0, 92)
		print "3"
	endif
Z_(0, 93)

	if (Z_(0, 95, c=(1 == (1 + 0))))
Z_(0, 96)
		print "4"
	elseif (1)
Z_(0, 97)
Z_(0, 98)
		print "5"
	else
Z_(0, 99)
Z_(0, 100)
		print "6"
	endif
Z_(0, 101)

Z_(0, 103)
	print "7"
End

static Function switchtest()
Z_(0, 106)
Z_(0, 131)

Z_(0, 108)
	switch(1)
		case 1:
Z_(0, 109)
Z_(0, 110)
			print "case"
Z_(0, 111)
			break
		default:
Z_(0, 112)
Z_(0, 113)
			print "default"
Z_(0, 114)
			break
	endswitch
Z_(0, 115)
Z_(0, 116)
	print "after endswitch"

Z_(0, 118)
	switch(1)
		case 1:
Z_(0, 119)
Z_(0, 120)
			print "case"
Z_(0, 121)
			break
		default :
Z_(0, 122)
Z_(0, 123)
			print "default"
Z_(0, 124)
			break
	endswitch;
Z_(0, 125)
Z_(0, 126)
	print "after endswitch"

Z_(0, 128)
	switch(1)
	endswitch ;
Z_(0, 129)
Z_(0, 130)
	print "after endswitch"
End

static Function commenttest()
Z_(0, 133)
Z_(0, 140)

Z_(0, 135)
	// Here we have some
Z_(0, 136)
	// important comments
Z_(0, 137)
	// to test the
Z_(0, 138)
	// instrumentation
Z_(0, 139)
	print "commenttest end"
End

#endif
Function IUTF_TagFunc_2c4825972717351a1e6e21b29ee64c5d2572501d0f67b2d3231ce87cee9d0a9b_IGNORE()
End
