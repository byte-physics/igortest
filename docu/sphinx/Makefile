# Makefile for Sphinx documentation

SPHINXOPTS    = -w sphinx.log
SPHINXBUILD   = sphinx-build
SPHINXAUTO    = sphinx-autobuild
SPHINXPROJ    = IgorUnitTestingFramework
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

autobuild:
	@$(SPHINXAUTO) \
		-b html \
		--ignore "*.swp" \
		--ignore "*~" \
		"$(SOURCEDIR)" "$(BUILDDIR)/html"

debug:
	@$(SPHINXBUILD) \
		-n -E \
		"$(SOURCEDIR)" "$(BUILDDIR)/pseudoxml" \
		-b pseudoxml # -W

deploy:
	@lftp -e "mirror --reverse -n -e build/html /www/doc/igor-unit-testing-framework; bye" byte-physics

.PHONY: help Makefile

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
