default: docu-doxygen clean

build-docker-doxygen: debian
	@make -C docker/doxygen

docu-doxygen: build-docker-doxygen
	@make -C docker/doxygen doxygen
	@make -C docker/doxygen links

debian:
	@make -C docker/debian

shell:
	@make -C docker/doxygen shell

links:
	@make -C docker/doxygen links

clean:
	@scripts/delete_containers.sh
	@scripts/delete_danglingimages.sh

all: docu-doxygen clean

