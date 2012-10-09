#pragma rtGlobals=3		// Use modern global access method.

Function TEST_SUITE_BEGIN(testSuite)
	string testSuite

	KillVariables/Z root:error_count

	printf "Entering test suite \"%s\"\r", testSuite
End

Function TEST_SUITE_END(testSuite)
	string testSuite
	
	NVAR/Z error_count = root:error_count
	
	if(!NVAR_Exists(error_count) || error_count == 0)
		printf "Finished with no errors\r",
	else
		printf "Failed with %d errors\r", error_count
	endif
	
	printf "Leaving test suite \"%s\"\r", testSuite
End

Function TEST_CASE_BEGIN(testCase)
	string testCase
	
	// kill all paths
	KillPath/A/Z

	// create a new unique folder as working folder
	SetDataFolder root:
	string/G lastDF = GetDataFolder(1)
	string targetDF = UniqueName("tempFolder", 11, 0)
	NewDataFolder/S $targetDF
	
	printf "Entering test case \"%s\"\r", testCase
End

Function TEST_CASE_END(testCase)
	string testCase

	// delete the working folder if it exists
	string currentDF = GetDataFolder(1)
	SVAR/Z lastDF = root:lastDF
	if(SVAR_Exists(lastDF) && DataFolderExists(lastDF))
		SetDataFolder $lastDF
		KillDataFolder $currentDF
	endif

	printf "Leaving test case \"%s\"\r", testCase
End
