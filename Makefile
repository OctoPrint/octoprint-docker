.PHONY: build-alpine
build-alpine:
	docker build -t octoprint -f Dockerfile .
