#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.09
#pragma ModuleName = IUTF_Debug

///@cond HIDDEN_SYMBOL

/// @brief Set the debug mode at the start of the test run
static Function SetDebugger(debugMode)
	variable debugMode

	InitIgorDebugVariables()
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_state
	NVAR/SDFR=dfr igor_debug_assertion

	if(!debugMode)
		igor_debug_state = SetIgorDebugger(IUTF_DEBUG_DISABLE)
	endif
	if(debugMode & (IUTF_DEBUG_ENABLE | IUTF_DEBUG_ON_ERROR | IUTF_DEBUG_NVAR_SVAR_WAVE | IUTF_DEBUG_FAILED_ASSERTION))
		igor_debug_assertion = !!(debugMode & IUTF_DEBUG_FAILED_ASSERTION)
		igor_debug_state = SetIgorDebugger(debugMode | IUTF_DEBUG_ENABLE)
	endif
End

/// @brief Restores the debugger to the state before SetDebugger(debugMode)
static Function RestoreDebugger()
	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_state
	SetIgorDebugger(igor_debug_state)
End

/// Create the variables igor_debug_state and igor_debug_assertion
/// in PKG_FOLDER and initialize it to zero
static Function InitIgorDebugVariables()
	DFREF dfr = GetPackageFolder()
	Variable/G dfr:igor_debug_state = 0
	Variable/G dfr:igor_debug_assertion = 0
End

/// Set the Igor Debugger, returns the previous state
/// @param state		3 bits to set
///						0x01: debugger enable
///						0x02: debug on error
///						0x04: debug on NVAR SVAR WAVE reference error
static Function SetIgorDebugger(state)
	variable state

	variable prevState, enable, debugOnError, nvarSvarWave

	prevState = GetCurrentDebuggerState()

	enable = !!(state & IUTF_DEBUG_ENABLE)
	debugOnError = !!(state & IUTF_DEBUG_ON_ERROR)
	nvarSvarWave = !!(state & IUTF_DEBUG_NVAR_SVAR_WAVE)

	DebuggerOptions enable=enable, debugOnError=debugOnError, NVAR_SVAR_WAVE_Checking=nvarSvarWave

	return prevState
End

/// Opens the Debugger if the assertion failed and the debugMode option is set
static Function DebugFailedAssertion(result)
	variable result

	DFREF dfr = GetPackageFolder()
	NVAR/SDFR=dfr igor_debug_assertion

	if(igor_debug_assertion && !result)
		Debugger
	endif
End

/// Returns the current state of the Igor Debugger as ORed bitmask of IUTF_DEBUG_* constants
static Function GetCurrentDebuggerState()

	DebuggerOptions
	return (!!V_enable) * IUTF_DEBUG_ENABLE | (!!V_debugOnError) * IUTF_DEBUG_ON_ERROR | (!!V_NVAR_SVAR_WAVE_Checking) * IUTF_DEBUG_NVAR_SVAR_WAVE
End

/// Returns 1 if debug output is enabled and zero otherwise
static Function EnabledDebug()
	DFREF dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr verbose

	if(NVAR_EXISTS(verbose) && verbose == 1)
		return 1
	endif

	return 0
End

/// Output debug string in assertions
/// @param str            debug string
/// @param booleanValue   assertion state
static Function DebugOutput(str, booleanValue)
	string &str
	variable booleanValue

	str = str + ": is " + SelectString(booleanValue, "false", "true") + "."
	if(EnabledDebug())
		IUTF_Reporting#ReportError(str, incrGlobalErrorCounter = 0)
	endif
End

///@endcond // HIDDEN_SYMBOL

///@addtogroup Helpers
///@{

/// Turns debug output on
Function EnableDebugOutput()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:verbose = 1
End

/// Turns debug output off
Function DisableDebugOutput()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:verbose = 0
End

///@}
