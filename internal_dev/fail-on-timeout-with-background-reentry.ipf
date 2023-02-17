#pragma rtGlobals=3
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma TextEncoding="UTF-8"

#include "igortest"

// Example of how to use the failOnTimeOut feature
// The testcase `First` must have one error in the end.

Function ReEntryTask(s)
	STRUCT WMBackgroundStruct &s

	return !mod(trunc(datetime), 5)
End

Function First()

	CtrlNamedBackGround testtask, proc=ReEntryTask, period = 1, start
	RegisterIUTFMonitor("testtask", 1, "Second_reentry", timeout = 1, failOntimeout = 1)
End

Function Second_REENTRY()

	PASS()
End
