This project aims at providing a complete set of tools for programmers for writing and maintaining unit tests.

# Features:
* Runs on Windows and MacOSX
* Completely documented and with lots of examples
* Includes more than ten test assertions coming in three versions
* Allows for the arbitrary grouping of test cases
* Easily expandable and adaptable
* Support for executing test suites from the command line

Planned features (open for collaboration):
* Threadsafe test assertions
* Igor Pro help file documentation

# Documentation

The documentation can be found
[here](https://docs.byte-physics.de/igor-unit-testing-framework/). It contains
a [guided
tour](https://docs.byte-physics.de/igor-unit-testing-framework/guided-tour.html)
and an [introduction to the basic
structure](https://docs.byte-physics.de/igor-unit-testing-framework/basic.html).

# Requirements

Igor Pro version 6.2.0 or later

# Installation

1. Install Igor
2. Start Igor, this will create a folder called WaveMetrics in Documents
3. Extract the zip file into the a folder, e. g. `thomas/unitTestingFramework` somewhere on your disc
4. Create a link from `unitTestingFramework/procedures` to `Documents\WaveMetrics\Igor Pro 6 User Files\User Procedures`
5. Have a look at the manual or the example experiments

# Building the documentation

## Requirements:
The build process is fully automated using [docker containers](https://www.docker.com/). You will need
- [docker](https://www.docker.com/get-docker)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## build
run `make` from the documentation root directory `docu/`:
```bash
cd docu
make
```

This will create a docker container with all the required dependencies and output the manual as pdf to `docu/manual.pdf` and html to the `docu/sphinx/html` subdirectory.
The documentation is built using [doxygen](http://www.doxygen.org/), a [home-built awk script](https://github.com/byte-physics/doxygen-filter-ipf/), [breathe](https://github.com/michaeljones/breathe) and [sphinx](http://www.sphinx-doc.org).

[The current documentation can be found on our website.](https://docs.byte-physics.de/igor-unit-testing-framework/)
# Bug Reporting
**Please** report all bugs and major/minor annoyances either as an issue here or directly to (thomas \<dot\> braun \<aehht\> byte \<minus\> physics \<dottt\> de)!
