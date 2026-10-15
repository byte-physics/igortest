#pragma rtGlobals=3
#pragma TextEncoding="UTF-8"
#pragma rtFunctionErrors=1
#pragma version=1.10
#pragma ModuleName=TEST_PackageGlobals

static Constant COUNTOBJECTS_WAVES      = 1
static Constant COUNTOBJECTS_VAR        = 2
static Constant COUNTOBJECTS_STR        = 3
static Constant COUNTOBJECTS_DATAFOLDER = 4

static StrConstant KNOWN_WAVES     = "DataGeneratorRefs;DataGeneratorWaves;FailedProcWave;FuncLocations;FunctionTagRefs;FunctionTagWaves;InfoMsg;MMDataState;MMDataStateRefs;ProcSizes;TestAssertionResult;TestCaseResult;TestInfoResult;TestRunData;TestRunResult;TestSuiteResult;TracingAnalyticResult;"
static StrConstant KNOWN_VARIABLES = "BCKG_EndTime;BCKG_FailOnTimeout;BCKG_Mode;BCKG_Registered;COMP_Callstack;COMP_File;COMP_Flags;COMP_Mode;COMP_NoCompile;COMP_Reentry;abortFromRequireFlag;abortFromSkipFlag;abortFlag;expected_failure_flag;igor_debug_assertion;igor_debug_state;waveTrackingMode;"
static StrConstant KNOWN_STRINGS   = "BCKG_ReentryFunc;BCKG_TaskList;baseFilename;baseFilenameOverwrite;homePath;lastFolder;mmdAllVariablesList;workFolder;"

// Objects are created on first use and kept afterwards, so the folder holds
// everything belonging to the features used by the runs of the session. The
// "Global Variables" section of developer.rst describes the same objects and has
// to be updated together with the lists above.
static Function Test_OnlyKnownObjects()
	DFREF    dfr = IUTF_Basics#GetPackageFolder()
	string   known, name
	variable type, index, num

	for(type = COUNTOBJECTS_WAVES; type <= COUNTOBJECTS_DATAFOLDER; type += 1)
		if(type == COUNTOBJECTS_WAVES)
			known = KNOWN_WAVES
		elseif(type == COUNTOBJECTS_VAR)
			known = KNOWN_VARIABLES
		elseif(type == COUNTOBJECTS_STR)
			known = KNOWN_STRINGS
		else
			known = ""
		endif

		num = CountObjectsDFR(dfr, type)
		for(index = 0; index < num; index += 1)
			name = GetIndexedObjNameDFR(dfr, type, index)

			INFO("Type %d, object %d: %s", n0 = type, n1 = index, s0 = name)
			CHECK(FindListItem(name, known) >= 0)
		endfor
	endfor
End
