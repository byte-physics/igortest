#pragma TextEncoding="UTF-8"
#pragma version=1.10
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1

// IUTF_Coverage_example1_begin
Function Run1()
	string traceOptions = ""
	string testsuite    = "myTests.ipf"

	// Use traceWinList as regular expression
	traceOptions = ReplaceNumberByKey(UTF_KEY_REGEXP, traceOptions, 1)

	RunTest(testsuite, traceWinList = "CODE_.*\.ipf", traceOptions = traceOptions)
End
// IUTF_Coverage_example1_end

// IUTF_Coverage_example2_begin
Function Run2()
	string traceOptions = ""
	string testsuite    = "myTests.ipf"

	// Use traceWinList as regular expression
	traceOptions = ReplaceNumberByKey(UTF_KEY_REGEXP, traceOptions, 1)
	// Execute only instrumentation
	traceOptions = ReplaceNumberByKey(UTF_KEY_INSTRUMENTATIONONLY, traceOptions, 1)

	RunTest(testsuite, traceWinList = "CODE_.*\.ipf", traceOptions = traceOptions)
End
// IUTF_Coverage_example2_end

// IUTF_Coverage_example3_begin
Function Run3()
	string traceOptions = ""
	string testsuite    = "myTests.ipf"

	// Enables the output of Cobertura files
	traceOptions = ReplaceNumberByKey(UTF_KEY_COBERTURA, traceOptions, 1)
	// Disables the output of HTML files
	traceOptions = ReplaceNumberByKey(UTF_KEY_HTMLCREATION, traceOptions, 0)

	RunTest(testsuite, traceWinList = testsuite, traceOptions = traceOptions)
End
// IUTF_Coverage_example3_end
