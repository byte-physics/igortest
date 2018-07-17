FROM debian:stretch
MAINTAINER Thomas Braun thomas.braun@byte-physics.de

# add local repository
#RUN echo "deb http://abakus/debian stretch main contrib non-free" > /etc/apt/sources.list

# activate color terminal
ENV TERM xterm-256color

# man-db     manual pages
# procps     command ps           (1430kB)
# vim-tiny   minimal text editor  (1545kB)
RUN DEBIAN_FRONTEND=noninteractive \
	apt-get update && \
	apt-get install --assume-yes \
		man man-db \
		procps \
		vim-tiny && \
	apt-get clean

# add local user.
RUN useradd -ms /bin/bash user
# change with USER directive as follows
USER user
