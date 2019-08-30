########################################################################################################################
## GLOBAL VARIABLES & GENERAL PURPOSE TARGETS
########################################################################################################################

SHELL := /bin/bash
BUILD_FILE := ./build/sqltocsv
PROJECT_NAME := sqltocsv

.PHONY: no-args
no-args:
# Do nothing by default. Ensure this is first in the list of tasks

.PHONY: all
all: dep test build

.PHONY: dep
dep:
	go get -u github.com/golang/dep/cmd/dep
	dep ensure


.PHONY: test
test:
	# TODO: add tests 

.PHONY: build
build:
	go build -v -o=${BUILD_FILE} .

$(BUILD_FILE):
	go build -v -o=${BUILD_FILE} .

.PHONY: clean
clean:
	rm $(BUILD_FILE)

########################################################################################################################
## CI & DOCKER RELATED TARGETS
########################################################################################################################

REGISTRY := localhost:5000/tapjoy
GIT_SHA := `git rev-parse HEAD`



.PHONY: artifact-prep
artifact-prep: dep build
	# All build-time steps needed for preparing a deployment artifact should be contained here
	# This would generally be tasks like bundle installs, asset building, bundling GeoIP data and so on
	## NOTE: Once slugs of a project are no longer deployed, this task can be moved to the Dockerfile

	# Unless WITH_GIT exists, remove everything but the build directory, the Procfile, the .git, deploy, and data folders
	[[ "${WITH_GIT:-}" ]] || rm -r `ls -A | grep -v "build" | grep -v ".git" | grep -v "Procfile" | grep -v "deploy" | grep -v "data" | grep -v "grace-shepherd" | grep -v "pids"`

	# Create shafile containing current git SHA
	echo ${GIT_SHA} > shafile

	# Move the built binary and remove the build directory
	mv ${BUILD_FILE} ./ && rm -rf build

.PHONY: artifact-publish
artifact-publish: artifact
	docker push ${REGISTRY}/${PROJECT_NAME}:${GIT_SHA}
	# We'll need to clean up after ourselves so long as legacy Jenkins is the builder component
	docker rmi ${REGISTRY}/${PROJECT_NAME}:${GIT_SHA}
	docker rmi `docker images -q -f dangling=true`
