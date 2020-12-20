# syntax = docker/dockerfile:1.2
FROM octoprint/octoprint:1.5.2

ARG username=octoprint

RUN --mount=type=secret,id=password octoprint --basedir /octoprint/octoprint user add \
  --admin --password $(cat /run/secrets/password) ${username}
