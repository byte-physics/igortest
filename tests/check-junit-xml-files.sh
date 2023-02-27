#!/bin/bash

set -e

for file in **/JU_*.xml; do
  xmllint --noout --schema ../docu/sphinx/source/junit.xsd "$file"
done

for file in **/Cobertura_*.xml; do
  # Cannot use xmllint directly as it tries to load DTD from https which isn't supported in xmllint.
  # Using this trick we can use our local copy of DTD which doesn't rely on internet connection or
  # external server.
  echo "check $file"
  sed 's@https://cobertura.sourceforge.net/xml/coverage-04.dtd@../docu/sphinx/source/coverage-04.dtd@' "$file" | \
    xmllint --noout --dtdvalid ../docu/sphinx/source/coverage-04.dtd -
done
