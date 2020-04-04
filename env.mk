# Configs for build and test
REGISTRY?=docker.io
DOCKER_USERNAME?=octoprint
IMAGE?=octoprint/octoprint
PLATFORM?=arm64
DOCKERFILE_LOCATION?="./Dockerfile"
PYTHON_BASE_IMAGE?=2.7-slim-buster
PLATFORMS="linux/arm64,linux/amd64"
