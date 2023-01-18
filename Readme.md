# Igor Pro Universal Testing Framework

[![Contributors](https://img.shields.io/github/contributors-anon/byte-physics/igor-unit-testing-framework?style=plastic)](https://github.com/byte-physics/igor-unit-testing-framework/graphs/contributors)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/byte-physics/igor-unit-testing-framework?style=plastic)](https://github.com/byte-physics/igor-unit-testing-framework/releases)
[![License](https://img.shields.io/github/license/byte-physics/igor-unit-testing-framework?style=plastic)](https://github.com/byte-physics/igor-unit-testing-framework/blob/main/License.txt)

The **Igor Pro Universal Testing Framework** (IUTF) is a versatile tool to write and run tests for [Igor Pro](https://www.wavemetrics.com/products/igorpro) code.
The results of the tests is outputted in standardized formats that can be parsed by common
[CI](https://en.wikipedia.org/wiki/Continuous_integration) frameworks. Test runs can also be fully automated as part of a CI/CD workflow.
For simpler usage scenarios a summary of the test run is shown in the history after it finished.

## What can IUTF be used for?

The IUTF offers great flexibility for writing test cases. It is supported to run the same test case with multiple inputs as
well as Igor Pro specific features such as independent modules or background activities.

The IUTF is applied as a reliable tool in larger Igor Pro projects such as [MIES](https://github.com/AllenInstitute/MIES).

```igorpro
#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3

#include "unit-testing"

// Simple demo example that tests the abs() function
Function TestAbsolute()

	CHECK_EQUAL_VAR(abs(1.5), 1.5)
	CHECK_EQUAL_VAR(abs(-1.5), 1.5)
	CHECK_EQUAL_VAR(abs(NaN), NaN)
	CHECK_EQUAL_VAR(abs(Inf), Inf)
	CHECK_EQUAL_VAR(abs(-Inf), Inf)
End
```

The framework itself combines numerous features:

* Test assertions for all kinds of conditions in three main flavours: Warnings, Checks and Requirements
* Test cases can be grouped in test suites, run with multiple inputs, run in independent modules and contain background activity
* Support of standard output formats like [JUNIT](https://junit.org/junit4) and [TAP](https://testanything.org/tap-version-13-specification.html)
* Support for automated execution as part of a CI pipeline
* Optional code coverage determination
* Optional memory leak tracking
* Fully documented and comes with lots of examples
* Easily expandable and adaptable

## Documentation

The [documentation](https://docs.byte-physics.de/igor-unit-testing-framework)
contains a [guided tour](https://docs.byte-physics.de/igor-unit-testing-framework/guided-tour.html)
and an [introduction](https://docs.byte-physics.de/igor-unit-testing-framework/basic.html) to the basic structure.

## Requirements

Igor Pro version 6.37 or newer on Windows and MacOSX

## Installation

1. Download the zip file attached to the newest
   [Release](https://github.com/byte-physics/igor-unit-testing-framework/releases/latest).
   The file name is something like `UnitTestingFramework-v1.09.zip`.
2. Extract the zip file into a folder, e. g. `alice/IgorTestingFramework`
3. Open the Igor Pro user folder by selecting `Help/Show Igor Pro User Files`
   from the menu in Igor Pro
4. Create a link from `alice/IgorTestingFramework/procedures` in the `User
   Procedures` subfolder
5. Installation finished. You are ready to use IUTF in Igor Pro. Have a look at
   the [documentation](https://docs.byte-physics.de/igor-unit-testing-framework)
   or the example experiments

## License

Most parts of IUTF are licensed under the [BSD-3 clause](License.txt).

## Versioning

We plan to adopt [Semantic Versioning](http://semver.org/) in the future. See
[issue 386](https://github.com/byte-physics/igor-unit-testing-framework/issues/386)
for further details. For the versions available, see the [tags on this
repository](https://github.com/byte-physics/igor-unit-testing-framework/tags)
or our [releases](https://github.com/byte-physics/igor-unit-testing-framework/releases).
