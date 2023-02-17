#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.09
#pragma ModuleName=TestExampleMain

#include "igortest"

#include ":test_example_sub1"
#include ":test_example_sub2"

Function run_IGNORE()

	RunTest("test_example.ipf")
End

static Function/WAVE dataGenTestExample()
	Make/FREE/T data = {"TestExampleMain"}
	return data
End

// IUTF_TD_GENERATOR dataGenTestExample
static Function MDTestCaseVar1([var])
	string var

	string ref = "TestExampleMain"
	CHECK_EQUAL_STR(var, ref)
End

// IUTF_TD_GENERATOR TestExampleSub1#dataGenTestExample
static Function MDTestCaseVar2([var])
	string var

	string ref = "TestExampleSub1"
	CHECK_EQUAL_STR(var, ref)
End

// IUTF_TD_GENERATOR TestExampleSub1#dataGenGlobal
static Function MDTestCaseVar3([var])
	string var

	string ref = "TestExampleSub1"
	CHECK_EQUAL_STR(var, ref)
End

// IUTF_TD_GENERATOR dataGenGlobal
static Function MDTestCaseVar4([var])
	string var

	string ref = "ProcGlobal"
	CHECK_EQUAL_STR(var, ref)
End
