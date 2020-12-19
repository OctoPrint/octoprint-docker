builddir=.build
cachedir=$(builddir)/.cache
octoprint_ref?= $(shell ./scripts/version.sh "OctoPrint/OctoPrint")
platforms?="linux/arm/v7,linux/arm64,linux/amd64"

.PHONY: test

build:
	docker-compose -f test/compose.test.yml build

down:
	docker-compose -f test/compose.test.yml down

up:
	docker-compose -f test/compose.test.yml up

clean:
	docker-compose -f test/compose.test.yml down --rmi local -v
	rm -rf ${builddir}

setup-multi-arch:
	docker run --privileged --rm tonistiigi/binfmt --install arm64,arm/v7,amd64

multi-build-test:
	./scripts/buildx_check.sh
	@echo '[buildx]: building .Dockerfile for all supported architectures and caching locally'
	mkdir -p $cachedir
	docker buildx build \
		--platform ${platforms} \
		--cache-from type=registry,ref=docker.io/octoprint/octoprint:${octoprint_ref} \
		--cache-from type=local,src=${cachedir} \
		--cache-to type=local,dest=${cachedir} \
		--build-arg octoprint_ref=${octoprint_ref} \
		--output type=local,dest=${builddir} \
		--progress tty -t octoprint/octoprint:test .
