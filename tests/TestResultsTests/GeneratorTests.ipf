#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access
#pragma DefaultTab={3, 20, 4} // Set default tab width in Igor Pro 9 and later
#pragma version=1.10
#pragma ModuleName=TS_GeneratorTests

#include "igortest"
#include "TestUtils"

// These are some tests that test the behavior of data generator

static Function/WAVE GeneratorEmpty()
	Make/FREE data = {1337}

	return data
End

// IUTF_TD_GENERATOR GeneratorEmpty
static Function GeneratorEmpty_Verify([var])
	variable var

	string expect, result
	variable childStart, childEnd, startTime, endTime

	CHECK_EQUAL_VAR(1337, var)

	WAVE/Z/T tc = Utils#LastTestCase(tcName = "TS_GeneratorTests#GeneratorEmpty", globalSearch = 1)
	INFO("Bug: test case not found")
	REQUIRE_WAVE(tc, TEXT_WAVE)

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
	INFO("Check if no children are defined")
	CHECK_EQUAL_VAR(childStart, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime   = str2num(tc[0][%ENDTIME])
	INFO("Check if endtime is not before the starttime")
	CHECK_LE_VAR(startTime, endTime)

	INFO("Check if no errors are thrown")
	result = tc[0][%STDERR]
	CHECK_EMPTY_STR(result)

	INFO("Check if no assertion errors are set")
	expect = "0"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "0"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

static Function/WAVE GeneratorSucceed()
	Make/FREE data = {1337}

	PASS()

	return data
End

// IUTF_TD_GENERATOR GeneratorSucceed
static Function GeneratorSucceed_Verify([var])
	variable var

	string expect, result
	variable childStart, childEnd, startTime, endTime

	CHECK_EQUAL_VAR(1337, var)

	WAVE/Z/T tc = Utils#LastTestCase(tcName = "TS_GeneratorTests#GeneratorSucceed", globalSearch = 1)
	INFO("Bug: test case not found")
	REQUIRE_WAVE(tc, TEXT_WAVE)

	INFO("Check if status is success")
	expect = IUTF_STATUS_SUCCESS
	result = tc[0][%STATUS]
	CHECK_EQUAL_STR(expect, result)

	childStart = str2num(tc[0][%CHILD_START])
	childEnd   = str2num(tc[0][%CHILD_END])
	INFO("Check if no children are defined")
	CHECK_EQUAL_VAR(childStart, childEnd)

	startTime = str2num(tc[0][%STARTTIME])
	endTime   = str2num(tc[0][%ENDTIME])
	INFO("Check if endtime is not before the starttime")
	CHECK_LE_VAR(startTime, endTime)

	INFO("Check if no errors are thrown")
	result = tc[0][%STDERR]
	CHECK_EMPTY_STR(result)

	INFO("Check if no assertion errors are set")
	expect = "0"
	result = tc[0][%NUM_ASSERT_ERROR]
	CHECK_EQUAL_STR(expect, result)

	INFO("Check if the assertion counter is correct")
	expect = "1"
	result = tc[0][%NUM_ASSERT]
	CHECK_EQUAL_STR(expect, result)
End

static Function TestGenAbort()
	string   errMsg
	variable errCode
	variable aborted = 0

	Utils#Backup()
	try
		errCode = IUTF_Basics#CreateTestRunSetup("GeneratorTestsExtra.ipf", "TCAbort;", 0, errMsg, 0, IUTF_DEBUG_DISABLE, 0)
	catch
		aborted = 1
	endtry
	Utils#Restore()

	INFO("Expect to be aborted")
	CHECK_EQUAL_VAR(1, aborted)
End

static Function TestGenRTE()
	string   errMsg
	variable errCode
	variable aborted = 0

	Utils#Backup()
	try
		errCode = IUTF_Basics#CreateTestRunSetup("GeneratorTestsExtra.ipf", "TCRTE;", 0, errMsg, 0, IUTF_DEBUG_DISABLE, 0)
	catch
		aborted = 1
	endtry
	Utils#Restore()

	INFO("Expect to be aborted")
	CHECK_EQUAL_VAR(1, aborted)
End

static Function TestGenNull()
	string   errMsg
	variable errCode
	variable aborted = 0

	Utils#Backup()
	try
		errCode = IUTF_Basics#CreateTestRunSetup("GeneratorTestsExtra.ipf", "TCNull;", 0, errMsg, 0, IUTF_DEBUG_DISABLE, 0)
	catch
		aborted = 1
	endtry
	Utils#Restore()

	INFO("Expect to be aborted")
	CHECK_EQUAL_VAR(1, aborted)
End

static Function TestGen2D()
	string   errMsg
	variable errCode
	variable aborted = 0

	Utils#Backup()
	try
		errCode = IUTF_Basics#CreateTestRunSetup("GeneratorTestsExtra.ipf", "TC2D;", 0, errMsg, 0, IUTF_DEBUG_DISABLE, 0)
	catch
		aborted = 1
	endtry
	Utils#Restore()

	INFO("Expect to be aborted")
	CHECK_EQUAL_VAR(1, aborted)
End

static Function TestGenSignature()
	string   errMsg
	variable errCode
	variable aborted = 0

	Utils#Backup()
	try
		errCode = IUTF_Basics#CreateTestRunSetup("GeneratorTestsExtra.ipf", "TCSignature;", 0, errMsg, 0, IUTF_DEBUG_DISABLE, 0)
	catch
		aborted = 1
	endtry
	Utils#Restore()

	INFO("Expect to be aborted")
	CHECK_EQUAL_VAR(1, aborted)
End
