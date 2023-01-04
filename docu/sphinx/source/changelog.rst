.. vim: set ts=2 sw=3 tw=119 et :

Changelog
=========

All notable changes to this project will be documented in this file.

The format is based on `Keep a Changelog <https://keepachangelog.com/en/1.0.0/>`_.

1.09 (01/04/2023)
-----------------

General
~~~~~~~

   - Add Code Coverage determination, see :ref:`here <code_coverage>` (IP9 Build 38812 or higher)
   - Allow analytics of code coverage tracing data, see :ref:`here <coverage_statistics>`
   - Add support for :ref:`multi data <multi_data_test_cases>` and :ref:`multi-multi data
     <multi_multi_data_test_cases>` test cases
   - Add :cpp:func:`INFO` function to output more information on failed test assertions, see :ref:`here <example14>`
   - Add support for test code running in background functions, see also :ref:`here <tests_with_background_activity>`.
   - Add support for checking for free/local wave leaks (IP9 Build 39622 or higher)
   - Add ``UTF_SKIP`` tag
   - Mark test cases with zero sized data generator waves as skipped
   - Call data generator only once for MD/MMD test cases
   - Enforce that we have at least one assertion in each test case
   - Fix hitting the sprintf limit (IP 8 or lower)
   - Abort flag does no longer cover runtime errors
   - Execute the test cases from top to bottom in each test suite
   - Test the basic parts of our testing framework using the very tiny test environment ``VTTE``
   - Add generic function to report wrapper results
   - Reorganize code and split it into more files
   - TestCaseEnd: Silently ignore non-killable working folder
   - Output state messages to stdout (IP 8 or higher)
   - Enhance output on failed test assertion in test cases
   - Tighten the check for test case signatures
   - AfterFileOpenHook: Make it more robust
   - Execute the builtin hooks also for failing user test hooks
   - Always clear runtime errors before ``AbortOnRTE``
   - .gitlab.ci.yml: Add CI
   - Moved ``NULL_WAVE`` flag to major flags for wave comparison in documentation
   - Output failure summary at the end
   - Allow unsaved experiments in some cases
   - Allow fixed log file naming
   - New option ``debugMode`` for more fine-grained debug control

Test assertions
~~~~~~~~~~~~~~~

   - :cpp:func:`*_CLOSE_VAR <CHECK_CLOSE_VAR>`: Prevent singularity
   - :cpp:func:`*_SMALL_VAR <CHECK_SMALL_VAR>`: Change tolerance so that ``0`` is considered small with zero tolerance
   - Add assertions <, <=, >, >= for double arguments, see :cpp:func:`*_LT_VAR <CHECK_LT_VAR>`,
     :cpp:func:`*_LE_VAR <CHECK_LE_VAR>`, :cpp:func:`*_GT_VAR <CHECK_GT_VAR>`, and :cpp:func:`*_GE_VAR <CHECK_GE_VAR>`
   - :cpp:func:`*_EQUAL_STR <CHECK_EQUAL_STR>`: Make case sensitive comparison the default
   - Added assertions for Int64 and UInt64 variables, see :cpp:func:`*_EQUAL_INT64 <CHECK_EQUAL_INT64>` and
     :cpp:func:`*_EQUAL_UINT64 <CHECK_EQUAL_UINT64>`

:cpp:func:`*_WAVE <CHECK_WAVE>`
"""""""""""""""""""""""""""""""

   - Require valid types as arguments
   - Make the output more human readable

:cpp:func:`*_EQUAL_WAVES <CHECK_EQUAL_WAVES>` and :cpp:func:`*_EQUAL_TEXTWAVES <CHECK_EQUAL_TEXTWAVES>`
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

   - Allow to check matching sizes of waves of different types
   - Allow identical wave references
   - Compare zero sized waves properly with set mode
   - Make error reporting for custom mode patterns better
   - Output descriptive error messages in ``WAVE_DATA`` mode
   - Handle invalid mode correctly
   - Work around EqualWaves dimension labels bug with certain IP versions
   - Complain for unknown modes
   - Make modes wave signed thus allowing -1 to be passed in to check all modes

JUNIT output
~~~~~~~~~~~~

   - Improve accuracy of test case/suite durations
   - Remove optional TestSuite attribute ``disabled``
   - Add a ``<failure>`` tag for each failed assertion
   - Handle expected failure test cases as skipped
   - Add JUNIT reference and updated JUNIT section in documentation
   - Drop timezone information as required by the "standard"
   - Nicify properties output

TAP output
~~~~~~~~~~

   - Handle ``TODO`` gracefully
   - Now also holds skipped testcases

1.08 (02/15/2019)
-----------------

- EvaluateRTE: Avoid Igor crash due to wrong printf usage
- Avoid passing CHECK_WAVE(..., NULL_WAVE) assertion for existing wave. This required to change the value of NULL_WAVE.
- Documentation/Readme.md: minor style fixes

1.07 (09/17/2018)
-----------------

- Convert documentation to sphinx and extend it a lot!
- Allow selecting test cases and test suites using a regular expression as parameter to RunTest.
- Define a fixed order of the builtin hooks and the user hooks in which they are called. The begin user hooks are
  called after the builtin ones, the end user hooks before the builtin ones.
- Catch aborts in user hooks
- Lots of code cleanup
- Output more info in assertion failure
- Extend the wave checking assertions
- Handle manual aborts during execution better
- Add new run mode for automated execution
- JUNIT support: Make testcase classname unique for successive runs
- Add support for running the unit testing framework in an Independent Module
- JUNIT output: Avoid hitting sprintf string limit

1.06 (03/24/2017)
-----------------

- The unit testing framework is now licensed under 3-Clause BSD. All contributors agreed to this license.
- Add option to create TAP compatible log files
- Add option to create JUNIT compatible log files
- Fixed edge cases with empty test suites, non-reachable test cases and similiar
- Overwrite check for output files
- Add optional arguments keepDataFolder and allowDebug to RunTest
- Split of TestBegin functions in internal and user part

  TestBegin, TestEnd, TestSuiteBegin, TestSuiteEnd, TestCaseBegin and TestCaseEnd were split into an internal function
  that is always executed and a hookable function where a user can extend functionality. The User functions are called
  directly after the internal functions.

- More detailed error message on unexpected runtime errors
- FIX: AbortFlag was not initialized on TEST_BEGIN
- FIX: Check for Procedure File Names was Case-Sensitive
- Docu: Use tabwidth of 4 for igor pro example code
- Nicify examples
- TEST_BEGIN/TEST_END: Turn off Igor Pro Debugger during test execution Turning off the debugger allows us to support
  non-interactive runs better as we don't rely on any defaults.

1.05 (11/17/2016)
-----------------

- Add wrapper functions for text waves
  One can write like CHECK_EQUAL_TEXTS( somefunction(), {"a","b","c"} ). In old version, CHECK_EQUAL_WAVES(
  somefunction(), {"a","b","c"} ) makes compile error.
- Fix and extend the wave type constants
- INT16_WAVE is 0x10 and not 0x16. Add also INT64_WAVE, DATAFOLDER_WAVE and WAVE_WAVE.
- Add \*_PROPER_STR
  In many cases one wants to check if some string is filled with content. Until now one would need to use
  \*_NON_NULL_STR and \*_NON_EMPTY_STR. This looks clumsy and does not make the intent clear.
- Add new assertions types for strings
  Checking that a string is non null or non empty was not possible out of the box. Add assertions \*_NON_EMPTY_STR and
  \*_NON_NULL_STR for testing the assertions that a string is not null or not empty. For convenience a null string is
  not considered non-empty but an empty string non-null.
- Fix example4-wavechecking.ipf
- Make/T/D w does not make a text wave but a double wave.
- Fix boolean value 'result' in TEST_WAVE_WRAPPER
- Fix order of arguments of TEST_WAVE_WRAPPER

Thanks to `ryotako <https://github.com/ryotako>`__ for a few patches.

1.04 (06/06/2016)
-----------------

- Enhance error checking for override test hooks
- CLOSE_VAR: Add forgotten abs
- Move history saving to operation queue
- Make history copy handling functions available for all callers
- TEST_CASE_BEGIN: Always start in root:
- Fix whitespace issues in the code

1.03 (05/14/2015)
-----------------

- Add variants of CLOSE and SMALL check for complex numbers
- Modify example7 to show how uncaught aborts are handled
- Report unhandled aborts in test cases
- Enhance call stack traversing in getInfo. Now we traverse the call stack from bottom up and report the first function
  not in one of the unit testing procedure files.
- Update documentation to use doxygen 1.8.9.1

1.02 (10/31/2013)
-----------------

Fix documentaton

1.01 (10/22/2013)
-----------------

- Add PASS() which just increases the assertion counter.
- Add also one more example and documentation for the usage of PASS() and FAIL().
- Fix bug in debug output steaming from an incorrect parameter order of SelectString.

1.00 (02/27/2013)
-----------------

Initial release
