FROM byte-physics/debian:latest
MAINTAINER Thomas Braun thomas.braun@byte-physics.de

USER root
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get install --assume-yes --no-install-recommends \
		doxygen \
		gawk \
		git && \
	apt-get clean

USER user
WORKDIR /var/igortest/docu
