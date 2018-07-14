FROM byte-physics/igor-utf-docu-doxygen
MAINTAINER Matthias J. Kastner matthias.kastner@byte-physics.de

USER root
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get install --assume-yes --no-install-recommends \
		doxygen \
		gawk \
		git \
        latexmk \
		make \
		python \
		python-pip \
		python-setuptools \
		python-wheel \
        texlive-fonts-recommended \
        texlive-latex-extra \
        texlive-latex-recommended && \
	apt-get clean
RUN pip install \
	'breathe==4.9.1' \
	'sphinx==1.7.5' \
	sphinx-autobuild \
	sphinxcontrib-fulltoc

USER user
WORKDIR /var/igor-unit-testing-framework/docu
