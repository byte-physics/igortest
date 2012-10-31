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
	string/G workDF = "root:" + UniqueName("tempFolder", 11, 0)
	NewDataFolder/S $workDF
	
	printf "Entering test case \"%s\"\r", testCase
End

Function TEST_CASE_END(testCase)
	string testCase

	// delete the working folder if it exists
	SVAR/Z lastDF = root:lastDF
	SVAR/Z workDF = root:workDF

	if(SVAR_Exists(lastDF) && DataFolderExists(lastDF) && SVAR_Exists(workDF) && DataFolderExists(workDF))
		SetDataFolder $lastDF
		KillDataFolder $workDF
	endif

	printf "Leaving test case \"%s\"\r", testCase
End
