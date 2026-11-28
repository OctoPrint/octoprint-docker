#!/usr/bin/env bash
# Tests for release-plan.sh and release-tags.sh. Run from anywhere:
#   scripts/test-release-scripts.sh
set -uo pipefail

cd "$(dirname "$0")" || exit 1
failures=0

# check NAME EXPECTED -- COMMAND...: run COMMAND and compare its output with EXPECTED
check() {
  local name=$1 expected=$2
  shift 3
  local actual
  if ! actual=$("$@" 2>&1); then
    echo "FAIL $name: exited non-zero"
    echo "$actual" | sed 's/^/    /'
    failures=$((failures + 1))
  elif [ "$actual" != "$expected" ]; then
    echo "FAIL $name"
    diff <(echo "$expected") <(echo "$actual") | sed 's/^/    /'
    failures=$((failures + 1))
  else
    echo "ok   $name"
  fi
}

# rejects NAME -- COMMAND...: COMMAND must exit non-zero
rejects() {
  local name=$1
  shift 2
  if "$@" >/dev/null 2>&1; then
    echo "FAIL $name: expected an error"
    failures=$((failures + 1))
  else
    echo "ok   $name"
  fi
}

plan() { env -i PATH="$PATH" "$@" ./release-plan.sh; }
tags() { env -i PATH="$PATH" IMAGE=ghcr.io/octoprint/octoprint PYTHON=3.13 "$@" ./release-tags.sh; }

echo "== release-plan.sh"

check "push builds the latest stable release" "$(printf '%s\n' version=2.0.2 latest=true edge=true dev=false)" -- \
  plan EVENT=push STABLE=2.0.2 NEWEST=2.0.2

check "push while a prerelease is newest is not edge" "$(printf '%s\n' version=2.0.2 latest=true edge=false dev=false)" -- \
  plan EVENT=push STABLE=2.0.2 NEWEST=2.1.0rc1

check "released dispatch of the new stable release" "$(printf '%s\n' version=2.0.3 latest=true edge=true dev=false)" -- \
  plan EVENT=repository_dispatch ACTION=released PAYLOAD_TAG=2.0.3 STABLE=2.0.3 NEWEST=2.0.3

check "prereleased dispatch is edge only" "$(printf '%s\n' version=2.1.0rc1 latest=false edge=true dev=false)" -- \
  plan EVENT=repository_dispatch ACTION=prereleased PAYLOAD_TAG=2.1.0rc1 STABLE=2.0.2 NEWEST=2.1.0rc1

check "prereleased dispatch is edge even before the API lists it" "$(printf '%s\n' version=2.1.0rc2 latest=false edge=true dev=false)" -- \
  plan EVENT=repository_dispatch ACTION=prereleased PAYLOAD_TAG=2.1.0rc2 STABLE=2.0.2 NEWEST=2.1.0rc1

check "maintenance release of an older line moves nothing" "$(printf '%s\n' version=1.11.9 latest=false edge=false dev=false)" -- \
  plan EVENT=repository_dispatch ACTION=released PAYLOAD_TAG=1.11.9 STABLE=2.0.2 NEWEST=2.0.2

check "dev dispatch" "$(printf '%s\n' version=dev latest=false edge=false dev=true)" -- \
  plan EVENT=repository_dispatch ACTION=dev PAYLOAD_TAG=dev STABLE=2.0.2 NEWEST=2.0.2

check "manual run without a version builds the latest stable release" "$(printf '%s\n' version=2.0.2 latest=true edge=true dev=false)" -- \
  plan EVENT=workflow_dispatch STABLE=2.0.2 NEWEST=2.0.2

check "manual run of an older release" "$(printf '%s\n' version=2.0.1 latest=false edge=false dev=false)" -- \
  plan EVENT=workflow_dispatch INPUT_VERSION=2.0.1 STABLE=2.0.2 NEWEST=2.0.2

check "manual run of dev" "$(printf '%s\n' version=dev latest=false edge=false dev=true)" -- \
  plan EVENT=workflow_dispatch INPUT_VERSION=dev STABLE=2.0.2 NEWEST=2.0.2

rejects "a payload that isn't a version" -- \
  plan EVENT=repository_dispatch ACTION=released 'PAYLOAD_TAG=2.0.2; true' STABLE=2.0.2 NEWEST=2.0.2
rejects "a released dispatch without a tag" -- \
  plan EVENT=repository_dispatch ACTION=released STABLE=2.0.2 NEWEST=2.0.2
rejects "an unknown dispatch action" -- \
  plan EVENT=repository_dispatch ACTION=deploy PAYLOAD_TAG=2.0.2 STABLE=2.0.2 NEWEST=2.0.2
rejects "an unknown event" -- \
  plan EVENT=schedule STABLE=2.0.2 NEWEST=2.0.2
rejects "a manual version that isn't one" -- \
  plan EVENT=workflow_dispatch INPUT_VERSION=latest STABLE=2.0.2 NEWEST=2.0.2

echo "== release-tags.sh"

check "main, latest stable release" "$(printf 'ghcr.io/octoprint/octoprint:%s\n' \
  2.0.2 2.0.2-python3.13 2.0 2.0-python3.13 2 2-python3.13 latest latest-python3.13 edge edge-python3.13)" -- \
  tags VARIANT=main VERSION=2.0.2 LATEST=true EDGE=true

check "minimal, latest stable release" "$(printf 'ghcr.io/octoprint/octoprint:%s\n' \
  2.0.2-minimal 2.0.2-minimal-python3.13 2.0-minimal 2.0-minimal-python3.13 2-minimal 2-minimal-python3.13 \
  minimal minimal-python3.13 edge-minimal edge-minimal-python3.13)" -- \
  tags VARIANT=minimal VERSION=2.0.2 LATEST=true EDGE=true

check "main, prerelease" "$(printf 'ghcr.io/octoprint/octoprint:%s\n' \
  2.1.0rc1 2.1.0rc1-python3.13 edge edge-python3.13)" -- \
  tags VARIANT=main VERSION=2.1.0rc1 LATEST=false EDGE=true

check "main, older release" "$(printf 'ghcr.io/octoprint/octoprint:%s\n' 1.11.9 1.11.9-python3.13)" -- \
  tags VARIANT=main VERSION=1.11.9 LATEST=false EDGE=false

check "main, dev" "$(printf 'ghcr.io/octoprint/octoprint:%s\n' dev dev-python3.13)" -- \
  tags VARIANT=main VERSION=dev LATEST=false EDGE=false

check "minimal, dev" "$(printf 'ghcr.io/octoprint/octoprint:%s\n' dev-minimal dev-minimal-python3.13)" -- \
  tags VARIANT=minimal VERSION=dev LATEST=false EDGE=false

rejects "an unknown variant" -- tags VARIANT=slim VERSION=2.0.2 LATEST=true EDGE=true
rejects "a Python version that isn't one" -- tags VARIANT=main VERSION=2.0.2 PYTHON=3 LATEST=true EDGE=true

echo
if [ "$failures" -ne 0 ]; then
  echo "$failures failed"
  exit 1
fi
echo "all passed"
