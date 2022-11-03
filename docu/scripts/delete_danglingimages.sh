#!/bin/bash

DOCKER_IMAGES=$(docker images --filter=dangling=true -q)
if [ -z "$DOCKER_IMAGES" ]; then
	exit 0;
fi
docker rmi $DOCKER_IMAGES
