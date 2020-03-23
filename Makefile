#import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# get the version of the latest stable release for build
VERSION=$(shell ./version.sh | sed 's/"//g')

.PHONY: build-master build-stable

build-master:
	docker build -t $(IMAGE) .

build-stable:
	docker build --build-arg tag=${VERSION} -t $(IMAGE):${VERSION} .

