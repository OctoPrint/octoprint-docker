echo $(dirname $0)

: ${PLATFORMS=linux/arm64,linux/amd64}

buildctl build \
  --frontend=dockerfile.v0 \
  --output type=image,name=${IMG},push=false \
  --export-cache type=registry,ref=${CACHE} \
  --import-cache type=registry,ref=${CACHE} \
  --local context=. \
  --local dockerfile=. \
  --opt platform=$(PLATFORMS)
  --opt build-arg:PYTHON_BASE_IMAGE=$(PYTHON_BASE_IMAGE)

