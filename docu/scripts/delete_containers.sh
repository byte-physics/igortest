#!/bin/bash

CONTAINERS=$(docker ps -a -q)
if [ -z "$CONTAINERS" ]; then
	exit 0;
fi
docker rm "$@" $CONTAINERS
