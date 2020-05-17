# OctoPrint-docker ![deploy latest with python2.7](https://github.com/OctoPrint/docker/workflows/deploy%20latest%20with%20python2.7/badge.svg)

## State of OctoPrint/docker and Notice to Docker Users

This image is currently under development, and is by no means stable, or guaranteed
to work. We are tracking the steps needed to get to a stable release in the 
[Stable Automated Docker Releases](https://github.com/OctoPrint/docker/projects/1)
project in this repository.

At the moment, we do _strongly recommend_ installing OcotPrint natively, or using
OctoPi. Making this image work will require you use only basic OctoPrint functionality,
or that you be a skilled docker user.

** Why is this not stable?**

Docker is not a VM, and is designed to isolate a process by providing all the system
libraries and toolchains required to run that process inside a container. 

This means that containers are inherently stateless, and introducing state complicates
the ability to execute the container.

Using docker, you typically update your software by deploying a new image. OctoPrint however, is designed to update itself.

This is further complicated with Plugin Management, which OctoPrint manages by
altering the host state (installs plugins).

This combination of environment manipulation makes it exceedingly difficult to share
that state with the _container's_ host (the physical machine).

Additionally, things like device and gpio access have to mapped and set up in specific
ways, and are not easily automated (which native OctoPrint can handle very well)


## Setup and Usage

We recommend you use docker-compose to run octoprint via docker. 

At the moment, we recommend that you do _not_ create a host mounted path for OctoPrint
configuration.  Instead we recommend you create a docker volume for octoprint
configuration, and mount that volume to the container.

We have included a `docker-compose.yml` file in this project that will run octoprint.
You will need to either copy that file into a directory on your machine, or clone this
project.

After the `docker-compose.yml` file is on your machine, you'll want to open it for
editing, and add device mappings for your serial port.

```
git clone https://github.com/OctoPrint/docker.git octoprint-docker && cd octoprint-docker

# search for you 3D printer serial port (usually it's /dev/ttyUSB0 or /dev/ttyACM0)
ls /dev | grep tty

// edit the docker-compose file to set your 3D printer serial port
vi docker-compose.yml

docker-compose up -d
```

You can then go to http://localhost:5000

You can display the log using `docker-compose logs -f`

## Without docker-compose

If you prefer to run without docker-compose, first create an `octoprint` docker volume
on the host, and then start your container:

```
docker volume create octoprint
docker run -d -v octoprint:/home/octoprint --device /dev/ttyACM0:/dev/ttyACM0 -p 5000:5000 --name octoprint octoprint/octoprint

```
