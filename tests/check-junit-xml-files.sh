#!/bin/bash

set -e

for i in $(ls *.xml)
do
  xmllint --noout --schema ../docu/sphinx/source/junit.xsd $i
done
