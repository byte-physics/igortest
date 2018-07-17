#!/bin/bash
set -e
source "${BASH_SOURCE[0]%/*}/docu-common-functions.sh"
require doxygen gawk git

# run doxygen
cd "${DOCUMENTATION_ROOT}/doxygen"
sed -e 	'
	s/\(^\s*GENERATE_HTML\s*=\s*\)\(YES\|NO\)/\1YES/
	s/\(^\s*SOURCE_BROWSER\s*=\s*\)\(YES\|NO\)/\1YES/
	' Doxyfile | doxygen -
warning doxygen.log doxygen
timediff "${TOP_LEVEL}/docu/doxygen/html/index.html"
