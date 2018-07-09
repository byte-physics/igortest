NAME   := byte-physics/debian
LATEST := ${NAME}:latest

default: build

build:
	@docker build -t ${LATEST} .

shell:
	docker run --rm -it ${LATEST} /bin/bash
