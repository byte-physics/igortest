.. vim: set et sts=3 sw=3 tw=79:

.. _function_tags:

Function Tags
=============

Function tags are single line comments above a function. IUTF reads them to
decide how that function is treated during a test run: whether it runs at all,
which data generator supplies its arguments, how it is reported, and whether
code coverage instrumentation covers it.

The :ref:`tag_reference` below lists every tag IUTF recognises, each with the
section that explains the feature around it.

How tags are read
-----------------

IUTF examines the comment block above the ``Function`` keyword. That block
extends back to the end of the previous function, so it can be of any length;
blank lines inside it are ignored. Every tag needs a line of its own.

A tag line consists of at least two slashes, the tag name, and optionally a
colon followed by the value::

   // IUTF_SKIP
   // TAPDirective: SKIP hardware not present on this machine
   // IUTF_TD_GENERATOR: DataGeneratorFunction

The colon is optional. The value is the remainder of the line with surrounding
blanks removed. A tag may appear at most once per function; a repeated tag
aborts the test run with ``Test case <name> has the tag <tag> at least
twice.``

Tags written with the deprecated ``UTF_`` prefix are still recognised, see
:ref:`deprecated_names`.

.. _tag_reference:

Tag reference
-------------

.. list-table::
   :header-rows: 1
   :widths: auto

   * - Tag
     - Value
     - Effect
     - Explained in
   * - ``IUTF_SKIP``
     - not used
     - The test case is not executed. JUNIT reports it as skipped, and TAP
       treats it like ``// TAPDirective: SKIP``.
     - :ref:`JUNITOutput`, :ref:`tap_output`
   * - ``IUTF_EXPECTED_FAILURE``
     - not used
     - The assertion failures of this test case are intended. They neither
       raise the error counter nor cancel the test run, and the test case is
       not reported as failed. The test case has to contain at least one
       failing assertion, otherwise it fails with the message ``doesn't
       contain at least one assertion error``.
     - :ref:`abort_code_handling`
   * - ``IUTF_TD_GENERATOR``
     - required, a missing value aborts the test run
     - Names the data generator function whose wave supplies the arguments of
       the test case. For multi-multi data test cases the tag is given once per
       variable in the form ``varName:dataGeneratorFunction``.
     - :ref:`multi_data_test_cases`, :ref:`multi_multi_data_test_cases`
   * - ``IUTF_RETRY_FAILED``
     - not used
     - The test case is retried on failure when retries are enabled with the
       ``IUTF_RETRY_FAILED_UNTIL_PASS`` mode. Without the tag a test case is
       retried only if ``IUTF_RETRY_MARK_ALL_AS_RETRY`` is set as well.
     - :ref:`flaky_tests`
   * - ``IUTF_NOINSTRUMENTATION``
     - not used
     - The function or macro is excluded from code coverage instrumentation.
     - :ref:`code_coverage`
   * - ``IUTF_NO_WAVE_TRACKING``
     - not used
     - The test case is exempt from free and local wave tracking. This has no
       effect unless the ``waveTrackingMode`` of :cpp:func:`RunTest` is set,
       which requires Igor Pro 9.
     - the ``waveTrackingMode`` parameter of :cpp:func:`RunTest`
   * - ``TAPDirective``
     - used, an empty value counts as no directive at all
     - Sets the TAP directive of the test case. A directive beginning with
       ``TODO`` or ``SKIP`` has additional meaning.
     - :ref:`tap_output`
   * - ``TAPDescription``
     - used, an empty value counts as no description at all
     - Adds a description to the TAP output line of the test case.
     - :ref:`tap_output`

Procedure tags
--------------

One tag belongs to a procedure file instead of a single function:
``// IUTF_NO_SHUFFLE_TEST_CASE``. IUTF looks for it in the first 20 lines of the
file and, when present, keeps the test case order of that file while the rest of
the test run is shuffled. See :ref:`shuffle_test_case_order`.

Unlike function tags, this scan is bounded: a tag placed below line 20 of the
file is not found.
