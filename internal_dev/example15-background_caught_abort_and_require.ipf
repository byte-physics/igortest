#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma TextEncoding="UTF-8"
#pragma ModuleName=ExampleXX

#include "igortest"

static Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name

End

static Function ReEntryTask(s)
	STRUCT WMBackgroundStruct &s

	return !mod(trunc(datetime), 5)
End

// We issue an abort after the registration that is caught be the IUTF
// and the reentry function is called
static Function BackgroundTesta()

	CtrlNamedBackGround testtask, proc=ExampleXX#ReEntryTask, period=1, start
	RegisterIUTFMonitor("testtask", 1, "ExampleXX#FirstReentry_reentry")
	Abort
End

// We issue a REQUIRE after the registration where the IUTF should abort further testing
// The (internal) IUTF background monitor is stopped and the reentry function NOT called.
static Function BackgroundTestb()

	CtrlNamedBackGround testtask, proc=ExampleXX#ReEntryTask, period=1, start
	RegisterIUTFMonitor("testtask", 1, "ExampleXX#FirstReentry_reentry")
	REQUIRE(0)
End

static Function FirstReentry_REENTRY()

	PASS()
End
