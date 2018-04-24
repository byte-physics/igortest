#!/bin/sh

SAVED_PWD="$(pwd)"
trap "cd $SAVED_PWD" EXIT
DOCUMENTATION_ROOT="$( cd ${BASH_SOURCE[0]%/*} 2> /dev/null && pwd )"
cd "$DOCUMENTATION_ROOT"

doxygen
cd latex
rm -Rf _minted-*
pdflatex -interaction=nonstopmode -shell-escape refman.tex
makeindex -s ../refman.ist refman.idx
pdflatex -interaction=nonstopmode -shell-escape refman.tex
pdflatex -interaction=nonstopmode -shell-escape refman.tex
cd ..
cp latex/refman.pdf .
