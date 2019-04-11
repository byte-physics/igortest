#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma ModuleName=ExampleXX

#include "unit-testing"

static Function TEST_CASE_BEGIN_OVERRIDE(name)
	string name

End

static Function ReEntryTask(s)
	STRUCT WMBackgroundStruct &s

	return !mod(trunc(datetime), 5)
End

// We issue an abort after the registration that is caught be the UTF
// and the reentry function is called
static Function BackgroundTesta()

	CtrlNamedBackGround testtask, proc=ExampleXX#ReEntryTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "ExampleXX#FirstReentry_reentry")
	Abort
End

// We issue a REQUIRE after the registration where the UTF should abort further testing
// The (internal) UTF background monitor is stopped and the reentry function NOT called.
static Function BackgroundTestb()

	CtrlNamedBackGround testtask, proc=ExampleXX#ReEntryTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "ExampleXX#FirstReentry_reentry")
	REQUIRE(0)
End

static Function FirstReentry_REENTRY()

	PASS()
End
