# syntax = docker/dockerfile:1.0-experimental
FROM octoprint/octoprint:1.5.2

ARG username=octoprint

COPY config.yaml /octoprint/octoprint/config.yaml

RUN --mount=type=secret,id=password octoprint --basedir /octoprint/octoprint user add \
  --admin --password $(cat /run/secrets/password) ${username}
