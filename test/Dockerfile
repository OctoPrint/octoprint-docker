# syntax = docker/dockerfile:1.2
FROM octoprint/octoprint:2.0.1

ARG username=octoprint

RUN --mount=type=secret,id=password octoprint --basedir /octoprint/octoprint user add \
  --admin --password $(cat /run/secrets/password) ${username}
