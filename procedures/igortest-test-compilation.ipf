#pragma rtGlobals = 3
#pragma TextEncoding = "UTF-8"
#pragma rtFunctionErrors = 1
#pragma version=1.10
#pragma ModuleName = IUTF_Test_Compilation

static Constant COMP_INIT       = 0x01
static Constant COMP_UNCOMPILED = 0x02
static Constant COMP_COMPILED   = 0x04

static Function/S GetCompState(state)
	variable state

	string msg

	switch(state)
		case COMP_INIT:
			return "COMP_INIT"
		case COMP_UNCOMPILED:
			return "COMP_UNCOMPILED"
		case COMP_COMPILED:
			return "COMP_COMPILED"
		default:
			sprintf msg, "Undefined (%d)", state
			return msg
	endswitch
End

static Function SetCompilationFlag()
	DFREF dfr = GetPackageFolder()
	variable/G dfr:compilationState = IsProcGlobalCompiled() ? COMP_COMPILED : COMP_UNCOMPILED
End

static Function DoExecute(command)
	string command

	Execute/P/Q command
End

static Function TestCompilation(file, flags, defines, reentry, noCompile)
	string file, reentry
	variable flags, noCompile
	WAVE/T defines

	variable i
	variable length = DimSize(defines, UTF_ROW)
	string importFile = RemoveEnding(file, ".ipf")

	// backup arguments that are needed for the reentry
	DFREF dfr = GetPackageFolder()
	string/G dfr:COMP_File = file
	variable/G dfr:COMP_Flags = flags
	string/G dfr:COMP_Reentry = reentry
	variable/G dfr:COMP_NoCompile = noCompile
	string/G dfr:COMP_Callstack = GetRTStackInfo(3)

	// setup reentry
	variable/G dfr:BCKG_Registered = 1
	variable/G dfr:COMP_Mode = 1

	// set compilation state
	variable/G dfr:compilationState = COMP_INIT

	// emit commands that tests the compilation
	DoExecute("INSERTINCLUDE \"" + importFile + "\"")
	for(i = 0; i < length; i += 1)
		DoExecute("SetIgorOption poundDefine=" + defines[i])
	endfor
	DoExecute("COMPILEPROCEDURES ")
	DoExecute(GetIndependentModuleName() + "#IUTF_Test_Compilation#SetCompilationFlag()")
	DoExecute("DELETEINCLUDE \"" + importFile + "\"")
	for(i = 0; i < length; i += 1)
		DoExecute("SetIgorOption poundUnDefine=" + defines[i])
	endfor

	// don't leave ProcGlobal uncompiled
	DoExecute("COMPILEPROCEDURES ")

	// emit commands for reentry
	DoExecute(GetIndependentModuleName() + "#RunTest(\":COMPILATION_REENTRY:\")")
End

/// @brief Return true if ProcGlobal is compiled, false if not
///
/// Observed behaviour:
/// - ProcGlobal is compiled after all independent modules
/// - FunctionInfo returns an empty string for a non existing function,
///   but an error message if ProcGlobal is not compiled
Function IsProcGlobalCompiled()

	string funcInfo = FunctionInfo("ProcGlobal#NON_EXISTING_FUNCTION")
	return !cmpstr(funcInfo, "")
End

static Function TestCompilationReentry()

	string file, reentry, callstack, msg
	variable flags, noCompile, compilationState, success

	// restore arguments
	DFREF dfr = GetPackageFolder()
	SVAR/Z str = dfr:COMP_File
	file = str
	NVAR/Z var = dfr:COMP_Flags
	flags = var
	SVAR/Z str = dfr:COMP_Reentry
	reentry = str
	NVAR/Z var = dfr:COMP_NoCompile
	noCompile = var
	SVAR/Z str = dfr:COMP_Callstack
	callstack = str
	NVAR/Z var = dfr:compilationState
	compilationState = var

	// cleanup datafolder
	KillStrings/Z dfr:COMP_File, dfr:COMP_Reentry, dfr:COMP_Callstack
	KillVariables/Z dfr:COMP_Flags, dfr:COMP_NoCompile, dfr:compilationState, dfr:COMP_Mode

	// setup reentry
	if(!IUTF_Utils#IsEmpty(reentry))
		variable/G dfr:BCKG_Registered = 1
		string/G dfr:BCKG_ReentryFunc = reentry
		DoExecute(GetIndependentModuleName() + "#RunTest(\":POST_COMPILATION_REENTRY:\")")
		variable/G dfr:COMP_Mode = 2
	endif

	// perform assertion
	if(noCompile)
		sprintf msg, "File \"%s\" could be compiled (state: %s)", file, GetCompState(compilationState)
		success = compilationState != COMP_COMPILED
	else
		sprintf msg, "File \"%s\" could not be compiled (state: %s)", file, GetCompState(compilationState)
		success = compilationState == COMP_COMPILED
	endif
	EvaluateResults(success, msg, flags, callStack = callStack)
End
