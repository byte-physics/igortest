#!/bin/bash

set -e

for file in **/JU_*.xml; do
  xmllint --noout --schema ../docu/sphinx/source/junit.xsd "$file"
done
