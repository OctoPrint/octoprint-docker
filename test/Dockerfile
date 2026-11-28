# syntax=docker/dockerfile:1
FROM ghcr.io/octoprint/octoprint:2.0.2

ARG username=octoprint

RUN --mount=type=secret,id=password octoprint --basedir /octoprint/octoprint user add \
  --admin --password $(cat /run/secrets/password) ${username}
