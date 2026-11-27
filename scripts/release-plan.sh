#!/usr/bin/env bash
# Decide which OctoPrint version a release run builds, and how it is tagged.
#
# Reads the triggering event from the environment and prints key=value lines
# for $GITHUB_OUTPUT:
#
#   version  the OctoPrint version to build: a release tag such as 2.0.2, or "dev"
#            (also the git ref the Dockerfiles download, since tags and the dev
#            branch share these names)
#   latest   true if version is the latest stable OctoPrint release
#   edge     true if version is the newest OctoPrint release, prereleases included,
#            or the run was triggered by a prerelease
#   dev      true for builds of OctoPrint's dev branch
#
# Inputs:
#
#   EVENT          github.event_name: push, workflow_dispatch or repository_dispatch
#   ACTION         github.event.action of a repository_dispatch: released, prereleased or dev
#   PAYLOAD_TAG    github.event.client_payload.tag_name of a repository_dispatch
#   INPUT_VERSION  the version input of a manual run; empty means the latest stable release
#   STABLE         the latest stable OctoPrint release tag
#   NEWEST         the newest OctoPrint release tag, prereleases included
set -euo pipefail

: "${EVENT:?}" "${STABLE:?}" "${NEWEST:?}"

case "$EVENT" in
  push)
    version=$STABLE
    ;;
  workflow_dispatch)
    version=${INPUT_VERSION:-$STABLE}
    ;;
  repository_dispatch)
    case "${ACTION:-}" in
      dev) version=dev ;;
      released | prereleased) version=${PAYLOAD_TAG:-} ;;
      *)
        echo "unsupported repository_dispatch action: '${ACTION:-}'" >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "unsupported event: '$EVENT'" >&2
    exit 1
    ;;
esac

# The version ends up in image tags and a download URL, so only accept plain versions
if [ "$version" != dev ] && ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+[0-9a-z.]*$ ]]; then
  echo "not an OctoPrint version: '$version'" >&2
  exit 1
fi

latest=false
edge=false
dev=false
if [ "$version" = dev ]; then
  dev=true
else
  if [ "$version" = "$STABLE" ]; then
    latest=true
  fi
  if [ "${ACTION:-}" = prereleased ] || [ "$version" = "$NEWEST" ]; then
    edge=true
  fi
fi

echo "version=$version"
echo "latest=$latest"
echo "edge=$edge"
echo "dev=$dev"
