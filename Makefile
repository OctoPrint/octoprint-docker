#import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# get the version of the latest stable release for build
VERSION := $(shell ./version.sh)

.DEFAULT_GOAL := build

build: build-stable build-stable-python3

build-master:
	@echo 'building $(IMAGE) from master with python 2.7'
	docker build -t $(IMAGE) .

build-master-python3:
	@echo 'building $(IMAGE) from master with python 3'
	docker build --build-arg PYTHON_IMAGE_TAG=slim-buster -t $(IMAGE):python3

build-stable:
	@echo 'building stable, version: $(VERSION) with python 2'
	docker build --build-arg PYTHON_IMAGE_TAG=$(PYTHON_IMAGE_TAG) --build-arg tag=$(VERSION) -t $(IMAGE):$(VERSION) .

build-stable-python3:
	@echo 'building stable, version: $(VERSION) with python 3'
	docker build --build-arg PYTHON_IMAGE_TAG=slim-buster --build-arg tag=$(VERSION) -t $(IMAGE):$(VERSION)-python3 .

release:
	docker push $(IMAGE):latest
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):python3
	docker push $(IMAGE):$(VERSION)-python3

validate:
	@echo latest stable release: $(VERSION)
