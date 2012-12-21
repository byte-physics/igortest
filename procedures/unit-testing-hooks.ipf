#pragma rtGlobals=3		// Use modern global access method.

Function TEST_BEGIN(testName)
	string testName

	KillDataFolder/Z $PKG_FOLDER
	initGlobalError()
	
	printf "Start of test \"%s\"\r", testName
End

Function TEST_END(testName)
	string testName

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr global_error_count
	
	if(global_error_count == 0)
		printf "Complete test finished with no errors\r"
	else
		printf "Complete test finished with %d errors\r", global_error_count
	endif
	
	printf "End of test \"%s\"\r", testName
End

Function TEST_SUITE_BEGIN(testSuite)
	string testSuite
	
	initError()
	printf "Entering test suite \"%s\"\r", testSuite
End

Function TEST_SUITE_END(testSuite)
	string testSuite

	dfref dfr = GetPackageFolder()
	NVAR/SDFR=dfr error_count
	
	if(error_count == 0)
		printf "Finished with no errors\r"
	else
		printf "Failed with %d errors\r", error_count
	endif

	NVAR/SDFR=dfr global_error_count
	global_error_count += error_count
	
	printf "Leaving test suite \"%s\"\r", testSuite
End

Function TEST_CASE_BEGIN(testCase)
	string testCase
	
	// kill all paths
	KillPath/A/Z

	initAssertCount()

	// create a new unique folder as working folder
	dfref dfr = GetPackageFolder()
	string/G dfr:lastFolder = GetDataFolder(1)
	string/G dfr:workFolder = "root:" + UniqueName("tempFolder", 11, 0)
	SVAR/SDFR=dfr workFolder
	NewDataFolder/O/S $workFolder
	
	printf "Entering test case \"%s\"\r", testCase
End

Function TEST_CASE_END(testCase)
	string testCase

	dfref dfr = GetPackageFolder()
	SVAR/Z/SDFR=dfr lastFolder
	SVAR/Z/SDFR=dfr workFolder
	NVAR/SDFR=dfr assert_count
	
	if(assert_count == 0)
		printf "The test case \"%s\" did not make any assertions!\r", testCase
	endif

	if( SVAR_Exists(lastFolder) && DataFolderExists(lastFolder) )
		SetDataFolder $lastFolder
	endif
	if( SVAR_Exists(workFolder) && DataFolderExists(workFolder) )
		KillDataFolder $workFolder
	endif

	printf "Leaving test case \"%s\"\r", testCase
End
