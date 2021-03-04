.. vim: set et sts=3 sw=3 tw=79:

.. _advanced:

Advanced Usage
==============

.. _TestHooks:

Test Hooks
----------

A Test Run can be extended with user-defined code at specific points during its
execution. These pre-defined injection points are at the beginning and
respectively at the end of a complete :ref:`Test Run<RunTest>`, a
:ref:`TestSuite`, and a :ref:`TestCase`.

The following functions are reserved for user code injections:

.. cpp:function:: TEST_BEGIN_OVERRIDE()

Executed at the **begin** of a :cpp:func:`Test Run<RunTest>`.

.. cpp:function:: TEST_END_OVERRIDE()

Executed at the **end** of a :cpp:func:`Test Run<RunTest>`.

.. cpp:function:: TEST_SUITE_BEGIN_OVERRIDE()

Executed at the **begin** of a :ref:`TestSuite`.

.. cpp:function:: TEST_SUITE_END_OVERRIDE()

Executed at the **end** of a :ref:`TestSuite`.

.. cpp:function:: TEST_CASE_BEGIN_OVERRIDE()

Executed at the **begin** of a :ref:`TestCase`.

.. cpp:function:: TEST_CASE_END_OVERRIDE()

Executed at the **end** of a :ref:`TestCase`.

.. note::

   :cpp:func:`TEST_END_OVERRIDE()` is executed at the very end of a test run
   so that the Igor debugger state is already reset to the state it had before
   :cpp:func:`RunTest()` was executed.

.. note::

   The functions :cpp:func:`TEST_SUITE_BEGIN_OVERRIDE()` and
   :cpp:func:`TEST_SUITE_END_OVERRIDE()` as well as
   :cpp:func:`TEST_CASE_BEGIN_OVERRIDE()` and
   :cpp:func:`TEST_CASE_END_OVERRIDE()` can also be defined locally in a test
   suite with the `static` keyword. :ref:`example2` shows how `static`
   functions are called the framework.

These functions are executed automatically if they are defined anywhere in
global or local context. For example, :cpp:func:`TEST_CASE_BEGIN_OVERRIDE` gets
executed at the beginning of each :ref:`TestCase`. Locally defined functions
always override globally defined ones of the same name. To visualize this
behavior, take a look at the following scenario: A user would like to have code
executed only in a specific :ref:`TestSuite`. Then the functions
:cpp:func:`TEST_SUITE_BEGIN_OVERRIDE` and :cpp:func:`TEST_SUITE_END_OVERRIDE`
can be defined locally within the current :ref:`TestSuite` by declaring them
`static` to the current Test Suite. The local (`static`) functions then replace
any previously defined global functions. The functionality with additional user
code at certain points of a Test Run is demonstrated in :ref:`example5`.

To give a possible use case, take a look at the following scenario: By default,
each :ref:`TestCase` is executed in its own temporary data folder.
:cpp:func:`TEST_CASE_BEGIN_OVERRIDE` can be used to set the data folder to
`root:`. This will result that each Test Case gets executed in `root:` and no
cleanup is done afterward. The *next* Test Case then starts with the data the
*previous* Test Case left in `root:`.

.. note::
   By default the Igor debugger is disabled during the execution of a test run.

.. _JUNITOutput:

JUNIT Output
------------

All common continuous integration frameworks support input as JUNIT XML files.
The igor unit testing framework supports output of test run results in JUNIT
XML format. The output can be enabled by adding the optional parameter
:code:`enableJU=1` to :cpp:func:`RunTest()`.

The XML output files are written to the experiments `home` directory with naming
`JU_Experiment_Date_Time.xml`. If a file with the same name already exists a
three digit number is added to the name. The JUNIT Output includes the results
and history log of each test case and test suite.

The format reference that the IUTF uses is described in the section
:ref:`junit_reference`.

Test Anything Protocol Output
-----------------------------

Output according to the `Test Anything Protocol (TAP) standard 13
<https://testanything.org/tap-version-13-specification.html>`__ can be enabled
with the optional parameter `enableTAP = 1` of :cpp:func:`RunTest()`.

.. todo::

   reference function parameters with their breathe links

The output is written into a file in the experiment folder with a unique
generated name `tap_'time'.log`. This prevents accidental overwrites of
previous test runs. A TAP output file combines all Test Cases from all Test
Suites given in :cpp:func:`RunTest()`. Additional TAP compliant descriptions
and directives for each Test Case can be added in the lines preceeding the
function of a Test Case (maximum 4 lines above :code:`Function` are considered
as tags, every tag in separate line):

.. code-block:: igor

   // #TAPDescription: My description here
   // #TAPDirective: My directive here

For directives two additional keywords are defined that can be written at the
beginning of the directive message.

- `TODO` indicates a Test that includes a part of the program still in
  development. Failures here will be ignored by a TAP consumer.

- `SKIP` indicates a Test that should be skipped. A Test with this directive
  keyword is not executed and reported always as 'ok'.

Examples:
^^^^^^^^^

.. code-block:: igor

   // #TAPDirective: TODO routine that should be tested is still under development

or

.. code-block:: igor

   // #TAPDirective: SKIP this test gets skipped

See the Experiment in the TAP_Example folder for reference.

.. todo::

   add reference to the example, include example code


.. _automate:

Automate Test Runs
------------------

To further simplify test execution it is possible to automate test runs from
the command line.

Steps to do that include:

- Implement a function called `run()` in `ProcGlobal` context taking no
  parameters. This function must perform all necessary steps for test
  execution, which is at least one call to :cpp:func:`RunTest`.

- Put the test experiment together with your :ref:`Test Suites<TestSuite>` and
  the script `helper/autorun-test.bat` into its own folder.

- Run the batch file `autorun-test.bat`.

- Inspect the created log file.

The example batch files for autorun create a file named `DO_AUTORUN.TXT` before
starting Igor Pro. This enables autorun mode. After the `run()` function is
executed and returned the log is saved in a file on disk and Igor Pro quits.

A different autorun mode is enabled if the file is named
`DO_AUTORUN_PLAIN.TXT`. In this mode no log file is saved after the test
execution and Igor Pro does not quit. This mode also does not use the Operation
Queue.

See also :ref:`example6`.

Running in an Independent Module
--------------------------------

The unit-testing framework can be run itself in an independent module.
This can be required in very rare cases when the `ProcGlobal` procedures
might not always be compiled.

See also :ref:`example9`.

Handling of Abort Code
----------------------

The unit-testing framework continues with the next test case after catching
`Abort` and logs the abort code. Currently differentiation of different abort
conditions include manual user aborts, stack overflow and an encountered
`Abort` in the code. The framework is terminated when manually pressing the
Abort button.

.. note::

   Igor Pro 6 can not differentiate between manual user aborts and programmatic
   abort codes. Pressing the Abort button in Igor Pro 6 will therefore
   terminate only the current test case and continue with the next queued test
   case.

Test Cases with Background Activity
-----------------------------------

There exist situations where a test case needs to return temporary to the Igor
command prompt and continue after a background task has finished. A real world
use case is for example a testing code that runs data acquisition in a
background task and the test case should continue after the acquisition finished.

The unit-testing framework supports such cases with a feature that allows to
register one or more background tasks that should be monitored. A procedure name
can be given that is called when the monitored background tasks finish. After the
current test case procedure finishes the framework will return to Igors command
prompt. This allows the users background task(s) to do its job. After the
task(s) finish the framework continues the test case with the registered procedure.

The registration is done by calling :cpp:func:`RegisterUTFMonitor()` from a
test case or a BEGIN hook. The registration allows to give a list of
background tasks that should be monitored. The mode parameter sets if all or one
task has to finish to continue test execution. Optional a timeout can be set
after the test continues independently of the user task(s) state.

See also :ref:`flags_UTFBackgroundMonModes`.

Function definition of RegisterUTFMonitor
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. doxygenfunction:: RegisterUTFMonitor

The function that is registered to continue the test execution must have the
same format as a test case function and the name has to end with `_REENTRY`.
When the unit-testing framework temporary drops to Igors command line and resumes later
no begin/end hooks are executed. Logically the unit-testing frame work stays in
the same test case. It is allowed to register another monitoring in
the `_REENTRY` function.

Multiple subsequent calls to :cpp:func:`RegisterUTFMonitor()` in the same
function overwrite the previous registration.

Test Cases with background activity are supported from multi data test cases, see
`Multi Data Test Cases with Background Activity`_.

 See also :ref:`example11`.

 See also :ref:`example12`.

Multi Data Test Cases
---------------------

Often the same test should be run multiple times with different sets of data. The
unit-testing framework offers direct support for such tests. Test cases that are
run with multiple data take one optional argument. To the test case a data generator
function is attributed that returns a wave. For each element of that wave the test
case is run. This sketches a simple multi data test case:

.. code-block:: igor

   // UTF_TD_GENERATOR DataGeneratorFunction
   Function myTestCase([arg])
     variable arg
     // add checks here
   End

   Function/WAVE DataGeneratorFunction()
     Make/FREE data = {1, 2, 3, 4}
     return data
   End

To the test case `myTestCase` a data generator function name is attributed with the
comment line above following the tag word `UTF_TD_GENERATOR`.
A maximum of four lines above :code:`Function` are considered as tags with every tag in a separate line.
If the data generator function is not found in the current procedure file it is searched
in all procedure files of the current compilation unit as a non-static function. (ProcGlobal context)
Also a static data generator function in another procedure file can be specified by
adding the Module name in the specification. There is no search in other procedure
files if such specified function is not found.

.. code-block:: igor

   // UTF_TD_GENERATOR GeneratorModule#DataGeneratorFunction

The data generator `DataGeneratorFunction` returns a wave of numeric type and the
test case takes one optional argument of numeric type. When run `myTestCase` is
executed four times with argument arg 1, 2, 3 and 4.

Supported types for `arg` are variable, string, complex, Integer64, data folder
references and wave references. The type of the returned wave of the attributed
data generator function must fit to the argument type that the multi data test
case takes.
The data generator function name must be attributed with a comment within four
lines above the test cases Function line. The key word is `UTF_TD_GENERATOR` with
the data generators function name following as seen in the simple example here.
If no data generator is given or the format of the test case function does not fit
to the wave type then a error message is printed and the test run is aborted.

The test case names are by default extended with `:num` where num is the index
of the wave returned from the data generator. For convenience in the data generator
dimension labels can be set for each wave element that are used instead of the index.

.. code-block:: igor

   Function/WAVE DataGeneratorFunction()
     Make/FREE data = {1, 2, 3, 4}
     SetDimLabel 0, 0, first, data
     SetDimLabel 0, 1, second, data
     SetDimLabel 0, 2, third, data
     SetDimLabel 0, 3, fourth, data
     return data
   End

The test case names would now be `myTestCase:first`, `myTestCase:second` and so on.

The optional argument of the test case function is always given from the data
generator wave elements. Thus the case that `ParamIsDefault(arg)` is true never
happens.

When setting up a multi data test case with a data generator returning wave
references then the test case can also use typed waves. Supported are
text waves (``WAVE/T``), waves with data folder references (``WAVE/DF``) and
waves with wave references (``WAVE/WAVE``). For such a test case or reentry
function the associated data generator must return a wave reference wave where
each wave element refers to a wave of the fitting type.
For a test case setup with the generic ``WAVE`` the type is not fixed for all
elements of from the data generator.

 See also :ref:`example13`.

Multi Data Test Cases with Background Activity
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Multi data test cases that register a background task to be monitored are
supported. For a multi data test case each reentry function can have one of two
different formats:

- Function fun_REENTRY() with no argument as described in `Test Cases with Background Activity`_
- Function fun_REENTRY([arg]) with the same argument type as the originating multi data test case.

For the second case, the reentry function is called with the same wave element as argument as
when the multi data test case was started.

If the reentry function uses a different argument type than the test case entry function
then on reentry to the unit-testing framework an error is printed and further
test execution is aborted.

.. code-block:: igor

   // UTF_TD_GENERATOR DataGeneratorFunction
   Function myTestCase([var])
     variable var

     CtrlNamedBackGround testtask, proc=UserTask, period=1, start
     RegisterUTFMonitor("testtask", 1, "testCase_REENTRY")
     CHECK(var == 1 || var == 5)
   End

   Function UserTask(s)
     STRUCT WMBackgroundStruct &s

     return !mod(trunc(datetime), 5)
   End

   Function/WAVE DataGeneratorFunction()
     Make/FREE data = {5, 1}
     SetDimLabel 0, 0, first, data
     SetDimLabel 0, 1, second, data
     return data
   End

   Function testCase_REENTRY([var])
     variable var

     print "Reentered test case with argument ", var
     PASS()
   End

.. _Jenkins XUnit plugin: https://github.com/jenkinsci/xunit-plugin/blob/master/src/main/resources/org/jenkinsci/plugins/xunit/types/model/xsd/junit-10.xsd

.. _junit_reference:

JUNIT Reference
---------------

The JUNIT implementation in the IUTF is based on the XML scheme definition from `Jenkins XUnit plugin`_.

Example XML reference file.

.. literalinclude:: junit.xml
   :caption: Example XML file with attributes used also supported by the Jenkins JUnit plugin based on the file published at <https://llg.cubic.org/docs/junit/>.
   :name: JUNIT_XML_Example
   :language: xml
   :force:
   :dedent:
   :tab-width: 4

.. literalinclude:: junit.xsd
   :caption: XSD (XML scheme definition) file for JUNIT
   :name: JUNIT_XSD
   :language: xml
   :dedent:
   :tab-width: 4
