FROM byte-physics/igor-utf-docu-doxygen
MAINTAINER Thomas Braun thomas.braun@byte-physics.de

ARG DEBIAN_FRONTEND=noninteractive

USER root
RUN apt-get update &&                                  \
	apt-get upgrade --assume-yes &&                      \
	apt-get install --assume-yes --no-install-recommends \
  make                                                 \
  python3                                              \
  python3-pip                                          \
  python-is-python3                                    \
  rsync &&                                             \
  apt-get clean

RUN pip3 install \
  wheel          \
  setuptools

RUN pip3 install                 \
  'breathe==4.34.0'              \
  'sphinx==4.5.0'                \
  'docutils==0.17'               \
  'sphinxcontrib-fulltoc==1.2.0' \
  'sphinxcontrib-images==0.9.4'  \
  'sphinx-copybutton==0.5.0'

USER user
WORKDIR /var/igortest/docu
