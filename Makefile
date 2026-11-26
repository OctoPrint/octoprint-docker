builddir=.build
cachedir=.cache
octoprint_ref?= $(shell ./scripts/version.sh "OctoPrint/OctoPrint")
platforms?="linux/arm/v7,linux/arm64,linux/amd64"

.PHONY: build down up clean setup-multi-arch test smoke smoke-minimal e2e build-minimal test-minimal clean-minimal

build:
	docker compose -f test/docker-compose.yml build

down:
	docker compose -f test/docker-compose.yml down

up:
	docker compose -f test/docker-compose.yml up

clean:
	docker compose -f test/docker-compose.yml down --rmi local -v
	rm -rf ${builddir}

setup-multi-arch:
	docker run --privileged --rm tonistiigi/binfmt --install arm64,arm/v7,amd64

test:
	@echo '[buildx]: building .Dockerfile for all supported architectures and caching locally'
	mkdir -p ${cachedir} ${builddir}
	docker buildx build \
		--platform ${platforms} \
		--cache-from type=registry,ref=docker.io/octoprint/octoprint:${octoprint_ref} \
		--cache-from type=local,src=${cachedir} \
		--cache-to type=local,dest=${cachedir} \
		--build-arg octoprint_ref=${octoprint_ref} \
		--output type=local,dest=${builddir} \
		--progress tty -t octoprint/octoprint:test .

smoke:
	docker build -t octoprint/octoprint:smoke --build-arg octoprint_ref=${octoprint_ref} .
	EXPECTED_VERSION=${octoprint_ref} ./scripts/smoke-test.sh octoprint/octoprint:smoke 80

smoke-minimal:
	docker build -t octoprint/octoprint:smoke-minimal --build-arg octoprint_ref=${octoprint_ref} ./minimal
	EXPECTED_VERSION=${octoprint_ref} ./scripts/smoke-test.sh octoprint/octoprint:smoke-minimal 5000

e2e:
	@echo '[buildx]: building with test structures and running e2e tests'
	docker build \
		--secret id=password,src=./test/password.txt \
		--file ./test/Dockerfile \
		--progress tty -t octoprint/octoprint:e2e ./test
	docker compose -f test/e2e-compose.yml up

build-minimal:
	docker build -t octoprint/octoprint:minimal -f minimal/Dockerfile --build-arg octoprint_ref=${octoprint_ref} ./minimal

test-minimal:
	docker run -it --name octoprint_minimal -p 55000:5000 octoprint/octoprint:minimal

clean-minimal:
	docker rm octoprint_minimal
