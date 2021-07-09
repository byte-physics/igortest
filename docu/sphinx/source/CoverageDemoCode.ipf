#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1

// IUTF_Coverage_example1_begin
Function Run1()
	string exclFun = ""
	string traceOptions = ""
	string testsuite = "myTests.ipf"

	// Use traceWinList as regular expression
	traceOptions = ReplaceNumberByKey(UTF_KEY_REGEXP, traceOptions, 1)

	// This is the list of functions that are excluded from instrumentation
	exclFun = AddListItem("IsNaN", exclFun, ",", inf)
	exclFun = AddListItem("IsFinite", exclFun, ",", inf)
	exclFun = AddListItem("MyModule#IsEmpty", exclFun, ",", inf)
	exclFun = AddListItem("ASSERT", exclFun, ",", inf)
	traceOptions = ReplaceStringByKey(UTF_KEY_NOINSTR, traceOptions, exclFun)

	RunTest(testsuite, traceWinList="CODE_.*\.ipf", traceOptions=traceOptions)
End
// IUTF_Coverage_example1_end


// IUTF_Coverage_example2_begin
Function Run2()
	string traceOptions = ""
	string testsuite = "myTests.ipf"

	// Use traceWinList as regular expression
	traceOptions = ReplaceNumberByKey(UTF_KEY_REGEXP, traceOptions, 1)
	// Execute only instrumentation
	traceOptions = ReplaceNumberByKey(UTF_KEY_INSTRUMENTATIONONLY, traceOptions, 1)

	RunTest(testsuite, traceWinList="CODE_.*\.ipf", traceOptions=traceOptions)
End
// IUTF_Coverage_example2_end
