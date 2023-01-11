#!/bin/bash

set -e

for file in **/*.xml; do
  xmllint --noout --schema ../docu/sphinx/source/junit.xsd "$file"
done
