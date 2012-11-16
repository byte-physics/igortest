#pragma rtGlobals=3		// Use modern global access method.

Function TEST_SUITE_BEGIN(testSuite)
	string testSuite
	
	KillDataFolder $PKG_FOLDER

	printf "Entering test suite \"%s\"\r", testSuite
End

Function TEST_SUITE_END(testSuite)
	string testSuite

	dfref dfr = GetPackageFolder()
	NVAR/Z/SDFR=dfr error_count
	
	if(!NVAR_Exists(error_count) || error_count == 0)
		printf "Finished with no errors\r"
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
	dfref dfr = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/S $workFolder
	
	printf "Entering test case \"%s\"\r", testCase
End

Function TEST_CASE_END(testCase)
	string testCase

	dfref dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr lastFolder
	SVAR/Z/SDFR=dfr workFolder

	if( SVAR_Exists(lastFolder) && DataFolderExists(lastFolder) )
		SetDataFolder $lastFolder
	endif
	if( SVAR_Exists(workFolder) && DataFolderExists(workFolder) )
		KillDataFolder $workFolder
	endif

	printf "Leaving test case \"%s\"\r", testCase
End
