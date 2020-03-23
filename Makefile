#import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# get the version of the latest stable release for build
VERSION=$(shell ./version.sh | sed 's/"//g')

.DEFAULT_GOAL := build

build: build-stable build-stable-python3

build-master:
	docker build -t $(IMAGE) .

build-master-python3:
	docker build --build-arg PYTHON_IMAGE_TAG=slim-buster -t $(IMAGE):python3

build-stable:
	docker build --build-arg tag=${VERSION} -t $(IMAGE):${VERSION} .

build-stable-python3:
	docker build --build-arg PYTHON_IMAGE_TAG=slim-buster --build-arg tag=${VERSION} -t $(IMAGE):${VERSION}-python3 .

