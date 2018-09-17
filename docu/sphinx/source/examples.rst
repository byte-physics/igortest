.. vim: set et sts=3 sw=3 tw=79:

.. _examples:

Examples
========

The example section shows the usage of the Igor Unit Testing Framework. If you
are just starting to use this framework, consider taking the :ref:`tour`.

.. _example1:

Example1
--------

This example is showing the basic working principle of the compare assertion.
Constant values are given as input to the unit :code:`abs()` and the output is
checked for equality.

This unit test makes sure that the function :code:`abs()` behaves as expected.
For example if you use the unit :code:`abs()` in a function and you give
:code:`NaN` as an input value the output value will also be :code:`NaN`. The
function is also capable of handling :code:`INF` singularities.

.. literalinclude:: ../../examples/example1-plain.ipf
   :caption: example1-plain.ipf
   :linenos:
   :emphasize-lines: 11

The test suite can be executed using the following command:

.. code-block:: igor
   :caption: command

   RunTest("example1-plain.ipf")

By looking at line 10 in this example it becomes clear that
:cpp:func:`CHECK_EQUAL_VAR` is a better way of comparing numeric variables then
the plain :cpp:func:`CHECK` assertion since :code:`NaN == NaN` is false. The
error is skipped by using the :cpp:func:`WARN` variant and will not raise the
error counter. If you want to know up to what extend those methods differ, take
a look at the section on :ref:`AssertionTypes` .

.. note::

   It is recommended to take a look at the :doc:`complete list of assertions
   <assertions>`. This will help in choosing the right assertion type for a
   comparison.

   The definition for the assertions in this test suite:

   * :cpp:func:`CHECK_EQUAL_VAR`
   * :cpp:func:`WARN`

.. _example2:

Example2
--------

This test suite has its own run routine. The :code:`run_IGNORE` function serves
as an entry point for :code:`"example2-plain.ipf"`. By using the
:code:`_IGNORE` suffix, the function itself will be ignored as a test case.
This is also explained in the section about :ref:`Test Cases<TestCase>`. It is
important to note that calling :cpp:func:`RunTest` would otherwise lead to a
recursion error.

There are multiple calls to :cpp:func:`RunTest` in :code:`run_IGNORE` to
demonstrate the use of optional arguments. Calling the function without any
optional argument will lead to a search for all available test cases in the
procedure file. You can also execute specific test cases by supplying them with
the :code:`testCase` parameter.

The optional parameter :code:`name` is especially useful for bundling more than
one procedure file into a single test run.

The test suite itself lives in a module and all test cases are static to that
module. This is the recommended environment for a test suite. When using the
static keyword, you also have to define a module with :code:`#pragma
ModuleName=Example2`

.. literalinclude:: ../../examples/example2-plain.ipf
   :caption: example2-plain.ipf
   :name: example2
   :emphasize-lines: 3

.. code-block:: igor
   :caption: command

   run_IGNORE()

.. note::

   The definition for the :doc:`assertions` in this test suite:

   * :cpp:func:`CHECK_EQUAL_STR`
   * :cpp:func:`CHECK_NEQ_STR`
   * :cpp:func:`CHECK_EMPTY_STR`
   * :cpp:func:`CHECK_NULL_STR`

.. _example3:

Example3
--------

This test suite emphasizes the difference between the :cpp:func:`WARN`,
:cpp:func:`CHECK`, and :cpp:func:`REQUIRE` assertion variants.

The :cpp:func:`WARN_* <WARN>` variant does not increment the error count if the
executed assertion fails. :cpp:func:`CHECK_* <CHECK>` variants increase the
error count. :cpp:func:`REQUIRE_* <REQUIRE>` variants also increment the error
count but will stop the execution of the test case immediately if the assertion
fails.

Even if a test has failed, the test end hook is still executed. See
:ref:`example5` for more details on hooks.

.. literalinclude:: ../../examples/example3-plain.ipf
   :caption: example3-plain.ipf

.. code-block:: igor
   :caption: command

   print RunTest("example3-plain.ipf")

The error count this test suite returns is 2

.. note::

   See also the section on :ref:`AssertionTypes`.

   * :cpp:func:`CHECK`
   * :cpp:func:`WARN`
   * :cpp:func:`REQUIRE`

.. _example4:

Example4
--------

This test suite shows the use of test assertions for waves.

The type of a wave can be checked with :cpp:func:`CHECK_EQUAL_WAVES` and
binary flags for the :ref:`flags_testwave_minor` and
:ref:`flags_testwave_major`. All flags are defined in :ref:`flags_testwave` and
can be concatenated as shown in line 45. If the comparison is done against such a
concatenation, it will fail if a single flag is not true. This is also shown in
line 47 where the free wave does not exist but as proven before, it is
definitely numeric.

It is noteworthy that each test case is executed in a fresh and empty
datafolder. There is no need to use :code:`KillWaves` or :code:`Make/O` here.

.. literalinclude:: ../../examples/example4-wavechecking.ipf
   :caption: example4-wavechecking.ipf
   :linenos:
   :emphasize-lines: 10,45,47

.. code-block:: igor
   :caption: command

   print RunTest("example4-wavechecking.ipf")

Helper functions to check wave types and compare with reference waves are also
provided in :doc:`assertions`.

.. note::

   The definition for the :doc:`assertions` in this test suite:

   * :cpp:func:`CHECK_EMPTY_FOLDER`
   * :cpp:func:`CHECK_WAVE`
   * :cpp:func:`CHECK_EQUAL_VAR`
   * :cpp:func:`CHECK_EMPTY_STR`
   * :cpp:func:`CHECK_EQUAL_WAVES`

.. _example5:

Example5
--------

The two test suites show how to use test hook overrides.

Here is shown how user code can be added to the Test Run at certain points. In
this test suite, additional code can be executed at the beginning and end of
the test cases. This is done by declaring the :code:`TEST_CASE_BEGIN_OVERRIDE`
or :code:`TEST_CASE_END_OVERRIDE` function :code:`'static'`. Functions with
this sepcific naming and the :code:`_OVERRIDE` suffix are automatically found
and registered as hooks.

Be aware that a :code:`'static'` defined hook overrides any global
:code:`TEST_CASE_BEGIN_OVERRIDE` functions for this Test Suite. If you want to
execute the global :code:`TEST_CASE_BEGIN_OVERRIDE` as well add this code to
the static override function:

.. code-block:: igor

   FUNCREF USER_HOOK_PROTO tcbegin_global = $"ProcGlobal#TEST_CASE_BEGIN_OVERRIDE"
   tcbegin_global(name)

The second procedure file :ref:`example5-code-2` is in :code:`ProcGlobal`
context so the test hook extensions are also global.

.. literalinclude:: ../../examples/example5-extensionhooks.ipf
   :caption: example5-extensionhooks.ipf
   :name: example5-code-1

.. literalinclude:: ../../examples/example5-extensionhooks-otherSuite.ipf
   :caption: example5-extensionhooks-otherSuite.ipf
   :name: example5-code-2

.. code-block:: igor
   :caption: command

   RunTest("example5-extensionhooks.ipf;example5-extensionhooks-otherSuite.ipf")

Each hook will output a message starting with :code:`>>`. After the Test Run
has finished you can see at which points the additional user code was executed.

.. note::

   Also take a look at the :ref:`TestHooks` section.

   The definition for the :doc:`assertions` in this test suite:

   * :cpp:func:`CHECK_EQUAL_VAR`
   * :cpp:func:`CHECK_CLOSE_VAR`

.. _example6:

Example6
--------

This test suite shows the automatic execution of test runs from the command line.
On Windows, call the "autorun-test-xxx.bat" from the helper folder.

The autorun batch script executes test runs for all pxp experiment files in the
current folder. After the run, a log file is created in the folder. The log
file includes the history of the Igor Pro Experiment. See also the section
on :ref:`automate`.

.. literalinclude:: ../../examples/Example6/example6-automatic-invocation.ipf
   :caption: example6-automatic-invocation.ipf
   :name: example6-code-1

.. literalinclude:: ../../examples/Example6/example6-runner.ipf
   :caption: example6-runner.ipf
   :name: example6-code-2

.. note::

   The definition for the :doc:`assertion <assertions>` in this test suite:

   * :cpp:func:`CHECK_EQUAL_VAR`

.. _example7:

Example7
--------

This test suite is showing how unhandled aborts in the test cases are displayed.

The Test environment catches such conditions and treats them accordingly. This
works with both :code:`Abort` and :code:`AbortOnValue`.

.. literalinclude:: ../../examples/example7-uncaught-aborts.ipf
   :caption: example7-uncaught-aborts.ipf

.. code-block:: igor
   :caption: command

   RunTest("example7-uncaught-aborts.ipf")

.. note::

   Relevant definitions for the :doc:`assertions` in this test suite:

   * :cpp:func:`PASS`

.. _example8:

Example8
--------

This test suite shows the behaviour of the unit testing environment if user
code generates an uncaught Runtime Error. The test environment catches this
condition and gives a detailed error message in the history. The runtime error
(RTE) is of course treated as :cpp:func:`FAIL`.

In this example, the highlighted lines both generate such a RTE due to a
missing data folder reference.

There might be situations where the user wants to catch a runtime error (RTE)
himself. In line 12 :code:`TestWaveOpSelfCatch` shows how to catch the RTE
before the test environment handles it. The test environment is controlled
manually by :cpp:func:`PASS` and :cpp:func:`FAIL`. :cpp:func:`PASS` increases
the assertion counter and :cpp:func:`FAIL` treats this assertion as fail when a
RTE was caught.

.. literalinclude:: ../../examples/example8-uncaught-runtime-errors.ipf
   :caption: example8-uncaught-runtime-errors
   :linenos:
   :emphasize-lines: 9,15

.. code-block:: igor
   :caption: command

   RunTest("example8-uncaught-runtime-errors.ipf")

.. note::

   Relevant definitions for the doc:`assertions` in this test suite:

   * :cpp:func:`PASS`
   * :cpp:func:`FAIL`

.. _example9:

Example9
--------

This examples shows how the whole framework can be run in an independent
module.

Please note that when calling the test suite, the procedure window name does
*not* need to include any independent module specification.

.. literalinclude:: ../../examples/example9-IM.ipf
   :caption: example9-IM.ipf
   :emphasize-lines: 3

.. code-block:: igor
   :caption: command

   Example9#RunTest("example9-IM.ipf")

.. note::

   Definition for the :doc:`assertion <assertions>` in this test suite:

   * :cpp:func:`CHECK_EQUAL_VAR`

.. _example10:

Example10
---------

This example tests the functionality of a peak find library found `on
github <https://github.com/ukos-git/igor-common-utilities.git>`__. It
demonstrates that by defining a unit test, we can rely on the functionality of
an external library. Even though we can not see the code itself from this unit,
we can test it and see if it fits our needs. Keep in mind that a program is
only as good as the unit test the define it.

.. literalinclude:: ../../examples/example10-peakfind.ipf
   :caption: example10-peakfind.ipf

.. code-block:: igor
   :caption: command

   RunTest("example10-peakfind.ipf")

.. note::

   Definition for the :doc:`assertions` in this test suite:

   * :cpp:func:`CHECK_WAVE`
   * :cpp:func:`CHECK_EQUAL_VAR`
   * :cpp:func:`CHECK_CLOSE_VAR`
