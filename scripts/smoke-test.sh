#!/usr/bin/env bash
# Start an OctoPrint image and wait until it answers over HTTP.
#
# usage: scripts/smoke-test.sh IMAGE CONTAINER_PORT [TIMEOUT_SECONDS]
#
#   IMAGE            the image to start, e.g. octoprint/octoprint:smoke
#   CONTAINER_PORT   80 for the main image (haproxy), 5000 for the minimal image
#   TIMEOUT_SECONDS  how long to wait for an answer, default 120
#
# Set EXPECTED_VERSION to also check the OctoPrint version installed in the image.
# The container is removed on exit; its logs are printed if the check fails.
set -euo pipefail

usage="usage: $0 IMAGE CONTAINER_PORT [TIMEOUT_SECONDS]"
image=${1:?$usage}
port=${2:?$usage}
timeout=${3:-120}
name="octoprint-smoke-$$"

dump_logs() {
  echo "--- logs of $name ---" >&2
  docker logs "$name" >&2 || true
}

cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

stopped() {
  echo "container stopped before it answered" >&2
  dump_logs
  exit 1
}

docker run -d --name "$name" -p "127.0.0.1::$port" "$image" >/dev/null
# docker port fails if the container has already exited
host_port=$(docker port "$name" "$port/tcp" 2>/dev/null | head -n1) || stopped
[ -n "$host_port" ] || stopped
url="http://127.0.0.1:${host_port##*:}/"

echo "waiting up to ${timeout}s for $image to answer on $url"
start=$SECONDS
until curl -fsS -o /dev/null "$url" 2>/dev/null; do
  if [ "$(docker inspect -f '{{.State.Running}}' "$name")" != "true" ]; then
    stopped
  fi
  if [ $((SECONDS - start)) -ge "$timeout" ]; then
    echo "no answer from $url after ${timeout}s" >&2
    dump_logs
    exit 1
  fi
  sleep 2
done
echo "answered after $((SECONDS - start))s"

version=$(docker exec "$name" python -c 'import octoprint; print(octoprint.__version__)')
echo "OctoPrint $version"
if [ -n "${EXPECTED_VERSION:-}" ] && [ "$version" != "$EXPECTED_VERSION" ]; then
  echo "expected OctoPrint $EXPECTED_VERSION, found $version" >&2
  dump_logs
  exit 1
fi
