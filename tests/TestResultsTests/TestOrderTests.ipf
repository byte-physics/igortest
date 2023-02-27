#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.09
#pragma ModuleName = TS_TestOrderTests

#include "igortest"
#include "TestUtils"

#include "TestOrderTestsA"
#include "TestOrderTestsB"
#include "TestOrderTestsC"
#include "TestOrderTestsD"

// These tests the execution of the test case order

static Function TestDefaultTestCaseOrder()

	string procNames = "TestOrderTestsA.ipf;TestOrderTestsC.ipf;TestOrderTestsB.ipf;"
	string testCases = ".*"
	variable regex = 1
	variable shuffle = IUTF_SHUFFLE_NONE
	Make/T/FREE expect = { "A4", "A1", "A2", "A3", "C4", "C2", "C1", "C3", "B4", "B1", "B3", "B2" }

	TestHelper(procNames, testCases, regex, shuffle, expect)
End

static Function TestDefinedTestCaseOrder()

	string procNames = "TestOrderTestsA.ipf;TestOrderTestsC.ipf;TestOrderTestsB.ipf;"
	string testCases = "Test1;Test3;Test2;Test4;"
	variable regex = 0
	variable shuffle = IUTF_SHUFFLE_NONE
	Make/T/FREE expect = { "A1", "A3", "A2", "A4", "C1", "C3", "C2", "C4", "B1", "B3", "B2", "B4" }

	TestHelper(procNames, testCases, regex, shuffle, expect)
End

static Function TestRandomTestCaseOrder()
	variable seed

	string procNames = "TestOrderTestsA.ipf;TestOrderTestsC.ipf;TestOrderTestsB.ipf;"
	string testCases = ".*"
	variable regex = 1
	variable shuffle = IUTF_SHUFFLE_ALL
#if (IgorVersion() >= 7.00) && (IgorVersion() < 9.00)
	Make/T/FREE expect = { "A2", "A4", "A3", "A1", "B4", "B1", "B2", "B3", "C4", "C3", "C1", "C2" }
#else
	Make/T/FREE expect = { "A1", "A2", "A3", "A4", "C2", "C1", "C3", "C4", "B2", "B4", "B3", "B1" }
#endif

	SetRandomSeed 0

	TestHelper(procNames, testCases, regex, shuffle, expect)
End

static Function TestRandomTestCaseOrder2()
	variable seed

	string procNames = "TestOrderTestsA.ipf;TestOrderTestsD.ipf;TestOrderTestsB.ipf;"
	string testCases = ".*"
	variable regex = 1
	variable shuffle = IUTF_SHUFFLE_ALL
#if (IgorVersion() >= 7.00) && (IgorVersion() < 9.00)
	Make/T/FREE expect = { "A2", "A4", "A3", "A1", "B4", "B1", "B2", "B3", "D4", "D2", "D1", "D3" }
#else
	Make/T/FREE expect = { "A1", "A2", "A3", "A4", "D4", "D2", "D1", "D3", "B1", "B3", "B2", "B4" }
#endif

	SetRandomSeed 0

	TestHelper(procNames, testCases, regex, shuffle, expect)
End

static Function TestHelper(procNames, testCases, regex, shuffle, expect)
	string procNames, testCases
	variable regex, shuffle
	WAVE/T expect

	variable i, length, errCode, rtcode
	string errMsg, fullName, rtmsg

	variable aborted = 0

	Utils#Backup()
	try
		errCode = IUTF_Basics#CreateTestRunSetup(procNames, testCases, regex, errMsg, 0, IUTF_DEBUG_DISABLE, shuffle)
		// Cannot use CHECK_NO_RTE() inside Backup-Restore fence as there is no access to current
		// test results
		rtmsg = GetRTErrMessage()
		rtcode = GetRTError(1)
	catch
		aborted = 1
	endtry
	Utils#Restore()

	INFO("Error: %s", s0=rtmsg)
	CHECK_EQUAL_VAR(0, rtcode)

	CHECK_EQUAL_VAR(0, aborted)
	CHECK_EQUAL_VAR(0, errCode)
	CHECK_NULL_STR(errMsg)

	WAVE/T/Z wv = root:Copy:igortest:TestRunData
	CHECK_WAVE(wv, TEXT_WAVE)

	length = DimSize(expect, UTF_ROW)
	CHECK_EQUAL_VAR(length, DimSize(wv, UTF_ROW))
	CHECK_GT_VAR(length, 0)
	for(i = 0; i < length; i += 1)
		sprintf fullName, "TS_TestOrderTests_%s#Test%s", (expect[i])[0], (expect[i])[1]

		INFO("%d: expect %s, got %s", n0 = i, s0 = fullName, s1 = wv[i][%FULLFUNCNAME])
		CHECK_EQUAL_STR(fullName, wv[i][%FULLFUNCNAME])
	endfor
End
