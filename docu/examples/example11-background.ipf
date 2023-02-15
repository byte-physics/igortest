#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma version=1.09
#pragma ModuleName=Example11

#include "igortest"

// A task that is run by the test, could be data acquisition
// but to keep it simple this task runs until the current seconds
// are dividable by 5 with a remainder of 0
static Function ReEntryTask(s)
	STRUCT WMBackgroundStruct &s

	return !mod(trunc(datetime), 5)
End

// A test case that setups the tests task, registers the task to be monitored
// and registers a reentry function that is called when the tests task finishes (or times out).
// The reentry functions code belongs to the same test case BackgroundTest()
Function BackgroundTest()

	CtrlNamedBackGround testtask, proc=Example11#ReEntryTask, period=1, start
	RegisterIUTFMonitor("testtask", 1, "FirstReentry_reentry")
End

// A second test case that registers our second reentry function.
Function BackgroundTest2()

	CtrlNamedBackGround testtask, proc=Example11#ReEntryTask, period=1, start
	RegisterIUTFMonitor("testtask", 1, "SecondReentry_REENTRY", timeout=2)
End

// The registered reentry function from BackgroundTest()
// This does not has to be the end of this test case, so lets assume there is more work to do
// and we register our testtask again, but this time with another reentry function.
Function FirstReentry_REENTRY()

	WARN_EQUAL_VAR(1, 0)
	// Setup follow up background task
	CtrlNamedBackGround testtask, proc=Example11#ReEntryTask, period=1, start
	RegisterIUTFMonitor("testtask", 1, "SecondReentry_REENTRY")
End

// After two tasks run our BackgroundTest() test case concludes with this final reentry function.
// Note that the test case BackgroundTest2() registers this function as well as reentry function.
// So the code in this function is part of both test cases.
Function SecondReentry_reentry()

	WARN_EQUAL_VAR(2, 0)
End
