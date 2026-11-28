#!/bin/sh
set -e

if [ "${1#-}" != "${1}" ]; then
  # only options, e.g. `--port 5001`: run the server with them
  # (OctoPrint 2.0 no longer serves when no subcommand is given)
  set -- octoprint --basedir /octoprint/octoprint serve "$@"
elif [ -z "$(command -v "${1}")" ]; then
  # an OctoPrint subcommand, e.g. `user list`: run it against the image's basedir
  set -- octoprint --basedir /octoprint/octoprint "$@"
fi

exec "$@"
