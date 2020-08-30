# OctoPrint-docker 

## Tags

- `latest`, `1.4.2`, `1.4`, `1` ([Dockerfile](Dockerfile))
- `camera`, `1.4.2-camera`, `1.4-camera`, `1-camera` ([Dockerfile](camera/Dockerfile.camera))

## Setup and Usage (Default image)

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

You can then go to http://localhost

You can display the log using `docker-compose logs -f`

## Without docker-compose

If you prefer to run without docker-compose, first create an `octoprint` docker volume
on the host, and then start your container:

```
docker volume create octoprint
docker run -d -v octoprint:/home/octoprint --device /dev/ttyACM0:/dev/ttyACM0 -p 5000:5000 --name octoprint octoprint/octoprint

```
