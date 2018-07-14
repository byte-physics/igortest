Examples
========
Start by reading the :doc:`main page<index>`.

Example1
--------
example showing the basic working principle

.. literalinclude:: ../../examples/example1-plain.ipf
   :caption: example1-plain
   :name: example1

Example2
--------
Test suite with run routine and module/static usage.
See the section about :ref:`Test Cases<TestCase>` why the function
`run_IGNORE()` is not considered a test case.

.. literalinclude:: ../../examples/example2-plain.ipf
   :caption: example2-plain
   :name: example2

Example3
--------
Test suite emphasising the difference between the
:cpp:func:`WARN()`
:cpp:func:`CHECK()`
and
:cpp:func:`REQUIRE()`
assertion variants.

:cpp:func:`WARN()`

See also :ref:`AssertionTypes`.

.. literalinclude:: ../../examples/example3-plain.ipf
   :caption: example3-plain
   :name: example3

Example4
--------
Test suite showing some test assertions Xfor waves.

.. literalinclude:: ../../examples/example4-wavechecking.ipf
   :caption: example4-wavechecking
   :name: example4

Example5
--------
Two test suites showing how to use test hook overrides.

.. literalinclude:: ../../examples/example5-extensionhooks.ipf
   :caption: example5-extensionhooks
   :name: example5

.. _example6:

Example6
--------
Test suite showing how to automate
testing from the command line. See also @ref secAutomaticExecution.

.. literalinclude:: ../../examples/Example6/example6-automatic-invocation.ipf
   :caption: example6-automatic-invocation
   :name: example6-1

.. literalinclude:: ../../examples/Example6/example6-runner.ipf
   :caption: example6-runner
   :name: example6-2

Example7
--------
Test suite showing how unhandled aborts in test cases are handled.

.. literalinclude:: ../../examples/example7-uncaught-aborts.ipf
   :caption: example7-uncaught-aborts
   :name: example7

Example8
--------
Test suite showing how runtime errors are treated.

.. literalinclude:: ../../examples/example8-uncaught-runtime-errors.ipf
   :caption: example8-uncaught-runtime-errors
   :name: example8

Example9
--------
Test suite showing how running the whole framework in an independent module works.

.. literalinclude:: ../../examples/example9-IM.ipf
   :caption: example9-IM
   :name: example9
