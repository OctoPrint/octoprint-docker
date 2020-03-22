.PHONY: build-master
build-master:
	docker build -t octoprint -f Dockerfile .
