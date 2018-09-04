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

Executed at the **begin** of a :cpp:func:`Test Run<RunTest()>`.

.. cpp:function:: TEST_END_OVERRIDE()

Executed at the **end** of a :cpp:func:`Test Run<RunTest()>`.

.. cpp:function:: TEST_SUITE_BEGIN_OVERRIDE()

Executed at the **begin** of a :ref:`TestSuite`.

.. cpp:function:: TEST_SUITE_END_OVERRIDE()

Executed at the **end** of a :ref:`TestSuite`.

.. cpp:function:: TEST_CASE_BEGIN_OVERRIDE()

Executed at the **begin** of a :ref:`TestCase`.

.. cpp:function:: TEST_CASE_END_OVERRIDE()

Executed at the **end** of a :ref:`TestCase`.

.. note::

   As :cpp:func:`TEST_END_OVERRIDE()` is executed at the very end of a test run
   so that the Igor debugger state is already reset to the state it had before
   :cpp:func:`RunTest()` was executed.

.. note::

   The functions :cpp:func:`TEST_SUITE_BEGIN_OVERRIDE()` and
   :cpp:func:`TEST_SUITE_END_OVERRIDE()` as well as
   :cpp:func:`TEST_CASE_BEGIN_OVERRIDE()` and
   :cpp:func:`TEST_CASE_END_OVERRIDE()` can also be defined locally in a test
   suite with the `static` keyword.  :ref:`example2` shows how `static`
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

.. note::

   If the locally defined function should only extend a global function the
   user can call the global function within the local function as follows:

   .. code-block:: igor

      FUNCREF USER_HOOK_PROTO tcbegin_global = TEST_CASE_BEGIN_OVERRIDE
      tcbegin_global(TestCaseName)

To give a possible use case, take a look at the following scenario: By default,
each :ref:`TestCase` is executed in its own temporary data folder.
:cpp:func:`TEST_CASE_BEGIN_OVERRIDE` can be used to set the data folder to
`root:`. This will result that each Test Case gets executed in `root:` and no
cleanup is done afterward. The *next* Test Case then starts with the data the
*previous* Test Case left in `root:`.

.. todo::
   Add code of the replacement hook to the above use case.

.. note::
   By default the Igor debugger is disabled during the execution of a test run.

see also :ref:`file_hooks`

JUNIT Output
------------

The igor unit testing framework supports output of test run results in JUNIT
compatible format. The output can be enabled by adding the optional parameter
`enableJU=1` to :cpp:func:`RunTest()`. The XML output files are written to the
experiments `home` directory with naming `JU_Experiment_Date_Time.xml`. If a
file with the same name already exists a three digit number is added to the
name. The JUNIT Output also contains the history log of each test case and test
suite.

.. todo::

   reference function parameters with their breathe links

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
and directives for each Test Case can be added in the two lines preceding the
function of a Test Case:

.. code-block:: igor

   // #TAPDescription: My description here
   // #TAPDirective: My directive here

For directives two additional key words are defined that can be written at the
beginning of the directive message.

- `TODO` indicates a Test that includes a part of the program still in
  development. Failures here will be ignores by a TAP consumer.

- `SKIP` indicates a Test that should be skipped. A Test with this directive
  key word is not executed and reported always as 'ok'.

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

see also :ref:`file_tap`

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

See also :ref:`example6` and :ref:`file_autorun`.

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
