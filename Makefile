SHELL := /bin/bash

# ---

# Read default configuration
include config.default
export $(shell sed 's/=.*//' config.default)

# Image to build
BUILD_IMAGE ?= $(BUILD_NAMESPACE)/$(IMAGE_NAME)
export BUILD_IMAGE

# ---

SED_MATCH ?= [^a-zA-Z0-9._-]

ifeq ($(CIRCLECI),true)
# Configure build variables based on CircleCI environment vars
BUILD_NUM = $(CIRCLE_BUILD_NUM)
BRANCH_NAME ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_BRANCH)")
BUILD_TAG ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_TAG)")
else
# Not in CircleCI environment, try to set sane defaults
BUILD_NUM = local
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD | sed 's/$(SED_MATCH)/-/g')
BUILD_TAG ?= $(shell git tag -l --points-at HEAD | tail -n1 | sed 's/$(SED_MATCH)/-/g')
endif

# If BUILD_TAG is blank there's no tag on this commit
ifeq ($(strip $(BUILD_TAG)),)
# Default to branch name
BUILD_TAG := $(BRANCH_NAME)
else
# Consider this the new :latest image
# FIXME: implement build tests before tagging with :latest
PUSH_LATEST := true
endif

REVISION_TAG = $(shell git rev-parse --short HEAD)

export BUILD_NUM
export BUILD_TAG
export BRANCH_NAME

# ---

# Check necessary commands exist
DOCKER := $(shell command -v docker 2> /dev/null)

# ============================================================================

.DEFAULT_GOAL := all

.PHONY: all lint Dockerfile prepare build

all: prepare lint build

lint: lint-docker

lint-docker:
ifndef DOCKER
	$(error "docker is not installed: https://docs.docker.com/install/")
endif
	@docker run --rm -i hadolint/hadolint < Dockerfile >/dev/null

prepare: Dockerfile

Dockerfile:
	envsubst '$${BASE_NAMESPACE},$${BASE_IMAGE},$${BASE_TAG}' \
		< Dockerfile.in > Dockerfile

build:
ifndef DOCKER
$(error "docker is not installed: https://docs.docker.com/install/")
endif
	docker build \
		--tag=$(BUILD_IMAGE):$(BUILD_TAG) \
		--tag=$(BUILD_IMAGE):build-$(BUILD_NUM) \
		--tag=$(BUILD_IMAGE):$(REVISION_TAG) \
		.

push: push-tag push-latest

push-tag:
	docker push $(BUILD_IMAGE):$(BUILD_TAG)
	docker push $(BUILD_IMAGE):build-$(BUILD_NUM)

push-latest:
	if [[ "$(PUSH_LATEST)" = "true" ]]; then { \
		docker tag $(BUILD_IMAGE):$(BUILD_NUM) $(BUILD_IMAGE):latest; \
		docker push $(BUILD_IMAGE):latest; \
	}	else { \
		echo "Not tagged.. skipping latest"; \
	} fi
