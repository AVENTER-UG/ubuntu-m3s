#Dockerfile vars

#vars
TAG=focal
IMAGENAME=ubuntu-m3s
IMAGEFULLNAME=avhost/${IMAGENAME}
LASTCOMMIT=$(shell git log -1 --pretty=short | tail -n 1 | tr -d " " | tr -d "UBDATE:")

help:
	    @echo "Makefile arguments:"
	    @echo ""
	    @echo "Makefile commands:"
	    @echo "build"
			@echo "publish-latest"
			@echo "publish-tag"

.DEFAULT_GOAL := all

ifeq (${BRANCH}, master) 
	BRANCH=latest
endif

ifneq ($(shell echo $(LASTCOMMIT) | grep -E '^v([0-9]+\.){0,2}(\*|[0-9]+)'),)
	BRANCH=${LASTCOMMIT}
else
	BRANCH=latest
endif


				        

build:
	@echo ">>>> Build docker image"
	docker build -t ${IMAGEFULLNAME}:${BRANCH} .

push:
	@echo ">>>> Publish docker image"
	docker buildx create --use --name buildkitd
	docker buildx build --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:${BRANCH} .
	docker buildx build --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:latest .
	docker buildx rm buildkitd


all: build push
