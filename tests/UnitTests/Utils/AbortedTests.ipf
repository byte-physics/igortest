#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_Aborted

static Function TEST_CASE_BEGIN_OVERRIDE(string testcase)

	variable/G root:historyRef = CaptureHistoryStart()
End

static Function TEST_CASE_END_OVERRIDE(string testcase)

	NVAR/SDFR=root: historyRef
	string/G root:history = CaptureHistory(historyRef, 1)
End

// IUTF_EXPECTED_FAILURE
static Function AbortWithNegativeValue()

	AbortOnValue 1, -10
End

static Function EvaluateAbortWithNegativeValue()

	SVAR/SDFR=root: history

	INFO("%s", s0 = history)

	CHECK_GE_VAR(strsearch(history, "Encountered \"AbortOnValue\" Code -10 in test case \"TEST_Aborted#AbortWithNegativeValue\" (AbortedTests.ipf)", 0), 0)
End
