#!/bin/bash
set -e
source "${BASH_SOURCE[0]%/*}/docu-common-functions.sh"
require doxygen gawk git breathe-apidoc sphinx-build make

# run doxygen
cd "${DOCUMENTATION_ROOT}/doxygen"
sed --expression '
	s/\(^\s*GENERATE_XML\s*=\s*\)\(YES\|NO\)/\1YES/
	' Doxyfile | doxygen -
warning doxygen.log doxygen

# generate sphinx source dir
cd "${DOCUMENTATION_ROOT}/sphinx/source"
cp --force --recursive "${DOCUMENTATION_ROOT}/doxygen/xml" ./
rm --force --recursive file group struct filelist.rst grouplist.rst structlist.rst
breathe-apidoc -o . "${DOCUMENTATION_ROOT}/doxygen/xml"

# run sphinx
cd "${DOCUMENTATION_ROOT}/sphinx"
make html
warning sphinx.log "sphinx html builder"
timediff "${DOCUMENTATION_ROOT}/sphinx/build/html/index.html"

make latexpdf
warning sphinx.log "sphinx pdf builder"
cp --force build/latex/IgorUnitTestingFramework.pdf "${DOCUMENTATION_ROOT}/manual.pdf"
timediff "${DOCUMENTATION_ROOT}/manual.pdf"
