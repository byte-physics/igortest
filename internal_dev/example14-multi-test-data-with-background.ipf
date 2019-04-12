#pragma rtGlobals=3
#pragma ModuleName=Example14internal

#include "unit-testing"

// RunTest("example14-multi-test-data-with-background.ipf")

static Function ReEntryTask(s)
	STRUCT WMBackgroundStruct &s

	return !mod(trunc(datetime), 5)
End

static Function/WAVE tcDataGenVar()
	Make/FREE data = {5, 1}
	SetDimLabel 0, 0, first, data
	SetDimLabel 0, 1, second, data
	return data
End

static Function/WAVE tcDataGenVar2()
	Make/FREE data = {3, 4}
	SetDimLabel 0, 0, first, data
	SetDimLabel 0, 1, second, data
	return data
End

// UTF_TD_GENERATOR tcDataGenVar
static Function MDTestCaseVar([var])
	variable var

	CtrlNamedBackGround testtask, proc=Example14internal#ReEntryTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "Example14internal#FirstReentry_reentry")
	CHECK(var == 1 || var == 5)
End

// UTF_TD_GENERATOR tcDataGenVar2
static Function MDTestCaseVar2([var])
	variable var

	CtrlNamedBackGround testtask, proc=Example14internal#ReEntryTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "Example14internal#SecondReentry_reentry")
	CHECK(var == 3 || var == 4)
End

static Function FirstReentry_REENTRY([var])
	variable var

	print var
	PASS()
End

static Function SecondReentry_REENTRY([str])
	string str

	print str
	PASS()
End
