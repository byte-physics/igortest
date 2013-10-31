doxygen
cd latex
pdflatex -shell-escape refman.tex
makeindex -s ../refman.ist refman.idx
pdflatex -shell-escape refman.tex
pdflatex -shell-escape refman.tex
cd ..
copy latex\refman.pdf .
