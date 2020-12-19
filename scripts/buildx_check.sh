#!/bin/bash

experimental_check(){
  local experimental= $(docker version -f '{{.Server.Experimental}}')

  if [ "$(docker version -f '{{.Server.Experimental}}')" != "true" ]; then
    echo "ERROR: buildx is not supported on this machine and is required for this build"
    echo "please enable experimental features in the docker engine and reload the daemon"
    return 1
  fi

  exit 0
}

experimental_check
