.PHONY: build-alpine deps
build-alpine:
	docker build -t octoprint -f Dockerfile .
deps:
	docker build -t octoprint:deps --target deps -f Dockerfile .
