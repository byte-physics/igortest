doxygen
cd latex
pdflatex -interaction=nonstopmode -shell-escape refman.tex
makeindex -s ../refman.ist refman.idx
pdflatex -interaction=nonstopmode -shell-escape refman.tex
pdflatex -interaction=nonstopmode -shell-escape refman.tex
cd ..
cp latex/refman.pdf .
