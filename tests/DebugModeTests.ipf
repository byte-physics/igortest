#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma rtFunctionErrors=1
#pragma ModuleName=UTF_DebugMode

// Licensed under 3-Clause BSD, see License.txt

static Function FAILVerification()
	FAIL() // Helper TC -> Previous TestCase had wrong restored Debugger Settings
End

static Function TestAllowDebugOff()

	DebuggerOptions

	V_enable = !!V_enable
	V_debugOnError = !!V_debugOnError
	V_NVAR_SVAR_WAVE_Checking = !!V_NVAR_SVAR_WAVE_Checking

	CHECK_EQUAL_VAR(V_enable, 0)
	CHECK_EQUAL_VAR(V_debugOnError, 0)
	CHECK_EQUAL_VAR(V_NVAR_SVAR_WAVE_Checking, 0)
End

static Function TestAllowDebugOn()

	DebuggerOptions

	V_enable = !!V_enable
	V_debugOnError = !!V_debugOnError
	V_NVAR_SVAR_WAVE_Checking = !!V_NVAR_SVAR_WAVE_Checking

	CHECK_EQUAL_VAR(V_enable, 1)
	CHECK_EQUAL_VAR(V_debugOnError, 0)
	CHECK_EQUAL_VAR(V_NVAR_SVAR_WAVE_Checking, 1)
End

static Function TestDebugModeEnable()

	DebuggerOptions

	V_enable = !!V_enable
	V_debugOnError = !!V_debugOnError
	V_NVAR_SVAR_WAVE_Checking = !!V_NVAR_SVAR_WAVE_Checking

	CHECK_EQUAL_VAR(V_enable, 1)
	CHECK_EQUAL_VAR(V_debugOnError, 0)
	CHECK_EQUAL_VAR(V_NVAR_SVAR_WAVE_Checking, 0)
End

static Function TestDebugModeOnError()

	DebuggerOptions

	V_enable = !!V_enable
	V_debugOnError = !!V_debugOnError
	V_NVAR_SVAR_WAVE_Checking = !!V_NVAR_SVAR_WAVE_Checking

	CHECK_EQUAL_VAR(V_enable, 1)
	CHECK_EQUAL_VAR(V_debugOnError, 1)
	CHECK_EQUAL_VAR(V_NVAR_SVAR_WAVE_Checking, 0)
End

static Function TestDebugModeChecking()

	DebuggerOptions

	V_enable = !!V_enable
	V_debugOnError = !!V_debugOnError
	V_NVAR_SVAR_WAVE_Checking = !!V_NVAR_SVAR_WAVE_Checking

	CHECK_EQUAL_VAR(V_enable, 1)
	CHECK_EQUAL_VAR(V_debugOnError, 0)
	CHECK_EQUAL_VAR(V_NVAR_SVAR_WAVE_Checking, 1)
End
