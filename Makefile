#Dockerfile vars

#vars
TAG=focal
IMAGENAME=ubuntu-m3s
IMAGEFULLNAME=avhost/${IMAGENAME}
BRANCH=${shell git symbolic-ref --short HEAD}

help:
	    @echo "Makefile arguments:"
	    @echo ""
	    @echo "Makefile commands:"
	    @echo "build"
			@echo "publish-latest"
			@echo "publish-tag"

.DEFAULT_GOAL := all

build:
	@echo ">>>> Build docker image"
	docker buildx build --build-arg TAG=${TAG} --build-arg BUILDDATE=${BUILDDATE} -t ${IMAGEFULLNAME}:${BRANCH} .

publish-latest:
	@echo ">>>> Publish docker image"
	docker tag ${IMAGEFULLNAME}:${BRANCH} ${IMAGEFULLNAME}:latest
	docker push ${IMAGEFULLNAME}:latest

publish-tag:
	@echo ">>>> Publish docker image"
	docker tag ${IMAGEFULLNAME}:${BRANCH} ${IMAGEFULLNAME}:${TAG}
	docker push ${IMAGEFULLNAME}:${TAG}


all: build publish-latest
