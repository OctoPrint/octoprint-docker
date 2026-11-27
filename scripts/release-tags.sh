#!/usr/bin/env bash
# Print the tags for one released image, one per line.
#
# Inputs, from the environment:
#
#   IMAGE    the image name, e.g. ghcr.io/octoprint/octoprint
#   VARIANT  main or minimal
#   VERSION  the OctoPrint version, e.g. 2.0.2, or "dev"
#   PYTHON   the image's Python version, e.g. 3.13
#   LATEST   true if VERSION is the latest stable release (from release-plan.sh)
#   EDGE     true if VERSION is the newest release, prereleases included
#
# Tags for the main image, with the minimal image's in brackets:
#
#   X.Y.Z   (X.Y.Z-minimal)  every release
#   X.Y, X  (X.Y-minimal, X-minimal) and latest (minimal)  the latest stable release
#   edge    (edge-minimal)   the newest release, prereleases included
#   dev     (dev-minimal)    builds of OctoPrint's dev branch, which get no version tag
#
# Every tag also gets a -pythonX.Y alias, e.g. latest-python3.13 or
# 2.0.2-minimal-python3.13, so users can choose when the Python version changes.
set -euo pipefail

: "${IMAGE:?}" "${VARIANT:?}" "${VERSION:?}" "${PYTHON:?}"

case "$VARIANT" in
  main)
    suffix=""
    latest_name=latest
    ;;
  minimal)
    suffix=-minimal
    latest_name=minimal
    ;;
  *)
    echo "unknown variant: '$VARIANT'" >&2
    exit 1
    ;;
esac

if ! [[ "$PYTHON" =~ ^[0-9]+\.[0-9]+$ ]]; then
  echo "not a Python version: '$PYTHON'" >&2
  exit 1
fi

tags=()
if [ "$VERSION" = dev ]; then
  tags+=("dev$suffix")
else
  tags+=("$VERSION$suffix")
  if [ "${LATEST:-false}" = true ]; then
    IFS=. read -r major minor _ <<<"$VERSION"
    tags+=("$major.$minor$suffix" "$major$suffix" "$latest_name")
  fi
  if [ "${EDGE:-false}" = true ]; then
    tags+=("edge$suffix")
  fi
fi

for tag in "${tags[@]}"; do
  echo "$IMAGE:$tag"
  echo "$IMAGE:$tag-python$PYTHON"
done
