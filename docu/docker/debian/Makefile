NAME   := byte-physics/debian
LATEST := ${NAME}:latest

default: build

build:
	@docker build -t ${LATEST} .

shell:
	docker run --rm -t ${LATEST} /bin/bash
