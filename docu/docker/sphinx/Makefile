NAME      := byte-physics/igor-utf-docu-sphinx
LATEST    := ${NAME}:latest
LOCAL_TOP_LEVEL := $$(git rev-parse --show-toplevel)
DOCKER_TOP_LEVEL := /var/igor-unit-testing-framework
LINKDIR   := -v ${LOCAL_TOP_LEVEL}:${DOCKER_TOP_LEVEL}

default: build-docker

# build the docker container from latest Dockerfile.
# this function will overwrite any current container of this type.
build-docker:
	docker build -t ${LATEST} .

# start a docker container and run sphinx-autobuild in it.
# Function is considered for dev purpose at writing the rsf files.
shell: build-docker
	docker run --rm -t ${LINKDIR} ${LATEST} /bin/bash

# starts sphix autobuild for dev purposes
docker-autobuild: build-docker
	docker run --rm -t -p 8000:8000 ${LINKDIR} ${LATEST} /bin/bash -c \
		'make -C "${DOCKER_TOP_LEVEL}/docu/sphinx" autobuild'

# echo basic requirements for current container.
# this will also assure that the container is built correctly.
requirements: build-docker
	@echo "checking container:"
	@docker run -t --rm ${LATEST} /bin/bash -c '\
		echo -n "doxygen version: " && doxygen --version && \
		gawk --version | head -n 1 && \
		git --version'

sphinx: requirements
	docker run -t --rm ${LINKDIR} ${LATEST} /bin/bash /var/igor-unit-testing-framework/docu/scripts/docu-sphinx.sh

sphinx-debug: requirements
	docker run -t --rm ${LINKDIR} ${LATEST} /bin/bash -c \
		'make -C "${DOCKER_TOP_LEVEL}/docu/sphinx" debug'
links:
	@stat "${LOCAL_TOP_LEVEL}/docu/sphinx/build/html/index.html"
	@echo "\e]8;;file://${LOCAL_TOP_LEVEL}/docu/manual.pdf\a→open sphinx pdf documentation\e]8;;\a"
	@echo "\e]8;;file://${LOCAL_TOP_LEVEL}/docu/sphinx/build/html/index.html\a→open sphinx html documentation\e]8;;\a"
