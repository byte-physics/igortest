default: docu-sphinx clean

build-docker-doxygen: debian
	@make -C docker/doxygen

build-docker-sphinx: build-docker-doxygen
	@make -C docker/sphinx

docu-doxygen: build-docker-doxygen
	@make -C docker/doxygen doxygen
	@make -C docker/doxygen links

docu-sphinx: build-docker-sphinx
	@make -C docker/sphinx sphinx
	@make -C docker/sphinx links

autobuild: build-docker-sphinx
	@make -C docker/sphinx docker-autobuild

debug: build-docker-sphinx
	@make -C docker/sphinx sphinx-debug

debian:
	@make -C docker/debian

shell:
	@make -C docker/sphinx shell

links:
	@make -C docker/sphinx links
	@make -C docker/doxygen links

clean:
	@scripts/delete_containers.sh
	@scripts/delete_danglingimages.sh

all: docu-doxygen docu-sphinx clean
