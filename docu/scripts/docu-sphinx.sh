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

# copy doxygen xml to sphinx
rsync --update --recursive --delete "${DOCUMENTATION_ROOT}/doxygen/xml/" "${DOCUMENTATION_ROOT}/sphinx/source/xml"

# run sphinx
cd "${DOCUMENTATION_ROOT}/sphinx"
rm -f sphinx.log
if ! make html 2>/dev/null; then
	warning sphinx.log "sphinx html builder"
fi
timediff "${DOCUMENTATION_ROOT}/sphinx/build/html/index.html"
