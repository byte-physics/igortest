NAME      := byte-physics/igor-utf-docu-doxygen
LATEST    := ${NAME}:latest
TOP_LEVEL := $$(git rev-parse --show-toplevel)
LINKDIR   := -v ${TOP_LEVEL}:/var/igortest

default: build-docker

build-docker:
	docker build -t ${LATEST} .

shell: build-docker
	docker run --rm -t ${LINKDIR} ${LATEST} /bin/bash

requirements: build-docker
	@echo "checking docker image:"
	@docker run -t --rm ${LATEST} /bin/bash -c '\
		echo -n "doxygen version: " && doxygen --version && \
		gawk --version | head -n 1 && \
		git --version'

doxygen: requirements
	docker run -t --rm ${LINKDIR} ${LATEST} /var/igortest/docu/scripts/docu-doxygen.sh

links:
	@stat "${TOP_LEVEL}/docu/doxygen/html/index.html"
	@echo "\e]8;;file://${TOP_LEVEL}/docu/doxygen/html/index.html\a→open doxygen html documentation\e]8;;\a"
