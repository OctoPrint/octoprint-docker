#import config.
# You can change the default config with `make cnf="config_special.env" build`
cnf ?= env.mk
include $(cnf)
IMG = "$(REGISTRY)/$(IMAGE):$(TAG)"
CACHE = $(REGISTRY)/$(IMAGE):cache

OCTOPRINT_VERSION:= $(shell ./scripts/version.sh "foosel/OctoPrint")

.DEFAULT_GOAL := build

clean:
	docker stop buildkit && docker rm buildkit

install: ./scripts/install.sh
	
binfmt: 
	@docker run --rm --privileged docker/binfmt:a7996909642ee92942dcd6cff44b9b95f08dad64

prepare: 
	@docker buildx create --use

build:
	@echo '[default]: building local octoprint image with all default options'
	@docker build -t octoprint .


buildx:
	@echo '[buildx]: building image: ${IMG} for all architectures'
	@docker buildx build --platform linux/amd64,linux/arm64 \
		--cache-from ${CACHE} \
		--cache-to	${CACHE} \
		--build-arg PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE) \
		--progress plain -t ${IMG} .

buildx-push: prepare
	@echo '[buildx]: building and pushing images: ${IMG} for all supported architectures'
	docker buildx build --push --platform linux/arm64,linux/amd64 \
		--cache-from ${CACHE} \
		--cache-to	${CACHE} \
		--build-arg PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE) \
		--progress plain -t ${IMG} .
