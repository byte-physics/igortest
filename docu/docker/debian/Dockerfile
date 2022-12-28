FROM debian:bullseye
MAINTAINER Thomas Braun thomas.braun@byte-physics.de

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&                                                     \
  apt-get install --assume-yes --no-install-recommends ca-certificates && \
  apt-get clean

RUN echo "deb https://mirror.byte-physics.de/debian bullseye main contrib non-free" > /etc/apt/sources.list &&                                  \
  echo "deb https://mirror.byte-physics.de/debian-security/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb-src https://mirror.byte-physics.de/debian bullseye main contrib non-free" >> /etc/apt/sources.list

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
