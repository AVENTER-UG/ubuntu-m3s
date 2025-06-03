#Dockerfile vars

#vars
IMAGENAME=ubuntu-m3s
IMAGEFULLNAME=avhost/${IMAGENAME}
LASTCOMMIT=$(shell git log -1 --pretty=short | tail -n 1 | tr -d " " | tr -d "UPDATE:")
BUILDDATE=$(shell date -u +%Y%m%d)

ifeq (${BRANCH}, master) 
	BRANCH=latest
endif

ifneq ($(shell echo $(LASTCOMMIT) | grep -E '^v|([0-9]+\.){0,2}(\*|[0-9]+)'),)
	BRANCH=${LASTCOMMIT}
else
	BRANCH=latest
endif

BRANCH=22.04

build:
	@echo ">>>> Build docker image" ${BRANCH}_${BUILDDATE} 
	docker build -t ${IMAGEFULLNAME}:${BRANCH}_${BUILDDATE} .

push:
	@echo ">>>> Publish docker image" ${BRANCH}_${BUILDDATE}
	docker buildx create --use --name buildkitd
	docker buildx build --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:${BRANCH}_${BUILDDATE} .
	docker buildx build --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:${BRANCH} .
	docker buildx build --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:latest .
	docker buildx rm buildkitd

imagecheck:
	trivy image ${IMAGEFULLNAME}:${BRANCH}_${BUILDDATE}


all: build imagecheck
