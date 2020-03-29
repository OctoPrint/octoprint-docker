#import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= env.mk
include $(cnf)
IMG = "$(REGISTRY)/$(IMAGE):$(TAG)"

OCTOPRINT_VERSION:= $(shell ./version.sh "foosel/OctoPrint")

.DEFAULT_GOAL := build

prepare:
	@docker buildx create --use

build:
	@echo '[default]: building local octoprint image with all default options'
	@docker build -t octoprint .

buildx: prepare
	@echo '[buildx]: building image: ${IMG} for all architectures'
	@docker buildx build --platform linux/amd64,linux/arm64/v8 \
		--build-arg PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE) \
		--progress plain -t ${IMG} .

buildx-push: prepare
	@echo '[buildx]: building and pushing images: ${IMG} for all supported architectures'
	docker buildx build --push --platform linux/arm64,linux/amd64 \
		--build-arg PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE) \
		--progress plain -t ${IMG} .
