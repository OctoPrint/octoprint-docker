#!/bin/bash

set -ex

configure() {
  update_docker_package
  update_docker_configuration

  echo "SUCCESS:
  Done! Finished setting up Travis
  "
}

update_docker_package() {
  echo "INFO:
  updating docker-ce
  "
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge"
  sudo apt-get update -y
  sudo apt-get -y -o Dpkg::Options::="--force-confnew" install docker-ce
  docker info
}

update_docker_configuration() {
  echo "INFO:
  Updating docker daemon config for buildkit
  "

  echo '{
  "experimental": true,
  "features": {
    "buildkit": true}
}' | sudo tee /etc/docker/daemon.json
  sudo service docker restart
}

configure
