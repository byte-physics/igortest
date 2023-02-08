#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Test_Proto

///@cond HIDDEN_SYMBOL

/// Prototype for test cases
Function TEST_CASE_PROTO()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototypes for multi data test cases
Function TEST_CASE_PROTO_MD_VAR([var])
	variable var

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_STR([str])
	string str

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WV([wv])
	WAVE wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WVTEXT([wv])
	WAVE/T wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WVDFREF([wv])
	WAVE/DF wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_WVWAVEREF([wv])
	WAVE/WAVE wv

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_DFR([dfr])
	DFREF dfr

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

Function TEST_CASE_PROTO_MD_CMPL([cmpl])
	variable/C cmpl

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

#if (IgorVersion() >= 7.0)

Function TEST_CASE_PROTO_MD_INT([int])
	int64 int

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

#else

Function TEST_CASE_PROTO_MD_INT([int])
	variable int

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

#endif

/// Prototype for multi data test cases data generator
Function/WAVE TEST_CASE_PROTO_DGEN()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototype for run functions in autorun mode
Function AUTORUN_MODE_PROTO()

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototype for hook functions
Function USER_HOOK_PROTO(str)
	string str

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

/// Prototype for multi multi data test case functions
Function TEST_CASE_PROTO_MD([md])
	STRUCT IUTF_mData &md

	string msg

	sprintf msg, "Error: Prototype function %s was called.", GetRTStackInfo(1)
	IUTF_Reporting#ReportErrorAndAbort(msg)
End

///@endcond // HIDDEN_SYMBOL
