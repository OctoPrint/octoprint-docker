# Configs for build and test
REGISTRY?=docker.io
DOCKER_USERNAME?=octoprint
IMAGE?=octoprint/octoprint
PLATFORM?=arm64
DOCKERFILE_LOCATION?="./Dockerfile"
PYTHON_BASE_IMAGE?=3.8-slim-buster
PLATFORMS="linux/arm64,linux/amd64,linux/arm/v7"
