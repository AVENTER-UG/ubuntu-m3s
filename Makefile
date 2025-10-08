#Dockerfile vars

#vars
TAG=24.04-2
BRANCH=${TAG}
IMAGENAME=ubuntu-m3s
IMAGEFULLNAME=avhost/${IMAGENAME}
LASTCOMMIT=$(shell git log -1 --pretty=short | tail -n 1 | tr -d " " | tr -d "UPDATE:")
BRANCHSHORT=$(shell echo ${TAG} | awk -F. '{ print $$1 }')
BUILDDATE=$(shell date -u +%Y%m%d)

build:
	@echo ">>>> Build docker image" ${BRANCH}_${BUILDDATE} 
	docker buildx build --progress=plain --load -t ${IMAGEFULLNAME}:latest .

push:
	@echo ">>>> Publish docker image" ${BRANCH} ${BRANCHSHORT}
	-docker buildx create --use --name buildkitd
	@docker buildx build --sbom=true --provenance=true --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:${BRANCH} .
	@docker buildx build --sbom=true --provenance=true --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:${BRANCHSHORT} .
	@docker buildx build --sbom=true --provenance=true --platform linux/amd64,linux/arm64 --push -t ${IMAGEFULLNAME}:latest .
	-docker buildx rm buildkitd

sboom:
	syft dir:. > sbom.txt
	syft dir:. -o json > sbom.json

seccheck:
	grype --add-cpes-if-none .

imagecheck:
	grype --add-cpes-if-none ${IMAGEFULLNAME}:latest > cve-report.md


check: sboom seccheck
all: check build imagecheck

