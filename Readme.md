This project aims at providing a complete set of tools for programmers for writing and maintaining unit tests.

Features:
* Runs on Windows and MacOSX
* Completely documented and with lots of examples
* Includes more than ten test assertions coming in three versions
* Allows for the arbitrary grouping of test cases
* Easily expandable and adaptable
* Support for executing test suites from the command line

Planned features (open for collaboration):
* Threadsafe test assertions
* Igor Pro help file documentation

The PDF manual of the latest version can be downloaded [here](http://www.byte-physics.de/Downloads/Manual-UnitTestingFramework-latest.pdf).

### Requirements

Igor Pro version 6.2.0 or later

### Installation

1. Install Igor
2. Start Igor, this will create a folder called WaveMetrics in Documents
3. Extract the zip file into the a folder, e. g. thomas/unitTestingFramework somewhere on your disc
4. Create a link from unitTestingFramework/procedures to Documents\WaveMetrics\Igor Pro 6 User Files\User Procedures
5. Have a look at the manual or the example experiments

Building the documentation in Windows:

Requirements:
- Doxygen
- git
- [GAWK](http://gnuwin32.sourceforge.net/packages/gawk.htm).
- [MikTex](https://miktex.org/download) or [TeX Live](https://www.tug.org/texlive/acquire-netinstall.html).
- [Python](https://www.python.org/downloads/) (2.7.5 is recommended, but 2.7.6 works too)
- Install the phython-pip package and then the Pygments package following these [instructions](http://tex.stackexchange.com/questions/108661/how-to-use-minted-under-miktex-and-windows-7)
- Download the [Doxygen filter for Igor procedure files](http://www.igorexchange.com/project/doxIPFFilter) and put the doxygen-filter-ipf.awk in /docu

Run build.bat

MikTex will download and install the minted package for latex and its dependencies automatically.

**Please** report all bugs and major/minor annoyances to (thomas \<dot\> braun \<aehht\> byte \<minus\> physics \<dottt\> de)!
