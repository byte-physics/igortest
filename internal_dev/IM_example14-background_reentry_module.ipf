#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"
#pragma IndependentModule=Example14
#pragma ModuleName=MyModule

#include "igortest"

// This example shows the usage of ModuleName for static function in combination with
// an IndependentModule. Please note how the functions are referenced in BackgroundTest()


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

	CtrlNamedBackGround testtask, proc=Example14#MyModule#ReEntryTask, period=1, start
	RegisterUTFMonitor("testtask", 1, "MyModule#FirstReentry_reentry")
End


// The registered reentry function from BackgroundTest()
// This does not has to be the end of this test case, so lets assume there is more work to do
// and we register our testtask again, but this time with another reentry function.
static Function FirstReentry_REENTRY()

	PASS()
End
