FROM byte-physics/igor-utf-docu-doxygen
MAINTAINER Matthias J. Kastner matthias.kastner@byte-physics.de

USER root
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get upgrade --assume-yes && \
	apt-get install --assume-yes --no-install-recommends \
		doxygen=1.8.13* \
		gawk \
		git \
		latexmk \
		make \
		python \
		python-pip \
		python-setuptools \
		python-wheel \
		rsync \
		texlive-fonts-recommended \
		texlive-latex-extra \
		texlive-latex-recommended && \
	apt-get clean
RUN pip install \
	'breathe==4.10.0' \
	'sphinx==1.7.5' \
	sphinx-autobuild \
	sphinxcontrib-fulltoc

USER user
WORKDIR /var/igor-unit-testing-framework/docu
