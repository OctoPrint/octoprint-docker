# OctoPrint-docker 

This is the primary image of `octoprint/octoprint`. It is designed to work similarly, and support the
same out of the box features as the octopi raspberry-pi machine image, using docker.

**Tags**

- `latest` - will always follow the latest _stable_ release 
- `edge` - will always follow the latest release _including prereleases_.
- `canary` - follows the [OctoPrint/Octoprint@maintenance](https://github.com/OctoPrint/OctoPrint/tree/maintenance) branch
- `bleeding`- follows the [OctoPrint/Octoprint@devel](https://github.com/OctoPrint/OctoPrint/tree/devel) branch

**Table of Contents**
- [OctoPrint-docker](#octoprint-docker)
  - [Usage](#usage)
    - [Configuration](#configuration)
      - [Enabling Webcam Support with Docker](#enabling-webcam-support-with-docker)
      - [Webcam Setup in OctoPrint](#webcam-setup-in-octoprint)
      - [Container Environment based configs](#container-environment-based-configs)
      - [Editing Config files manually](#editing-config-files-manually)
  - [Without docker-compose](#without-docker-compose)
  - [Building the image yourself](#building-the-image-yourself)

## Usage

We recommend you use docker-compose to run octoprint via docker, and have included
a recommended [docker-compose.yml](docker-compose.yml) file for your convenience.

Save the contents of this file on your machine as `docker-compose.yml`, and then
run `docker-compose up -d`.

Open octoprint at `http://<octoprint_ip_or_url`

See [Initial Setup](#initial-setup) for configuration values to use during your fist
launch of OctoPrint using docker.

### Configuration

#### Enabling Webcam Support with Docker

In order to use the webcam, you'll need to make sure the webcam service is enabled. 
This is done by setting the environment variable `ENABLE_MJPG_STREAMER=true` in your
`docker run` command, or in the `docker-compose.yml` file.

You'll also need to add `--device /dev/video0:/dev/video0` to your `docker run`, or ensure
it's listed in the `devices` array in your `docker-compose.yml`.

If you map a video device _other_ than `/dev/video0`, you will additionally need to set an
environment variable for `CAMERA_DEV` to match the mapped device mapping.

See [container environment based configs](#container-environment-based-configs) for a full
list of webcam configuration options configured with docker.

#### Webcam Setup in OctoPrint

Use the following values in the webcam & timelapse settings screen of the initial setup:

| Setting | Value |
| ------- | ----- |
| Stream URL | `/webcam/?action=stream` |
| Snapshot URL |  `http://localhost:8080/?action=snapshot` |
| Path to FFMPEG | `/usr/bin/ffmpeg` |

#### Container Environment based configs

There are configuration values that you pass using container `--environment` options.
Listed below are the options and their defaults. These are implicit in example [docker-compose.yml](docker-compose.yml),
and if you wish to change them, refer to the docker-compose docs on setting environment variables.

| variable | default |
| -------- | ------- |
| `CAMERA_DEV` | `/dev/video0` (see [note](#devices_note)) |
| `MJPG_STREAMER_INPUT` | `-y -n -r 640x480` |
| `ENABLE_MJPG_STREAMER` | `false` |

**note:** You will still need to declare the `device` mapping in your docker-compose file or docker command,
even if you explicitly declare the `CAMERA_DEV`.  The value of `CAMERA_DEV` is used in starting the mjpg-streamer
service, whereas the `devices` mapping is used by docker to make sure the container has access to the device.

For example, if you change the `CAMERA_DEV` to be `/dev/video1`, you would also need to map `/dev/video1:/dev/video1`
in your container.

#### Editing Config files manually

This docker-compose file also contains a container based instance of [vscode][], accessible
via your browser at the same url as your octoprint instance, allowing you to edit configuration
files without needing to login to your octoprint host.

To make use of this editor, just uncomment the indicated lines in your [docker-compose.yml](docker-compose.yml#L20-L32)
then run the following commands:

```
docker-compose up -d config-editor
```

Now go to `http://<octoprint_ip_or_url>:8443/?folder=/config` in your browser to edit your octoprint files!
Use the 'explorer' (accessible by clicking the hamburger menu icon) to explore folder and files to load
into the editor workspace. 

All configuration files are in the `/config` folder, and the active configuration will be accessible at `/config/config.yaml`

When you're done, we recommend you stop and remove this service/container:

```
docker-compose stop config-editor && docker-compose rm config-editor
```

For full documentation about the config editor, see the docs for the product at [github.com/cdr/code-server][code-server].

## Without docker-compose

If you prefer to run without docker-compose, first create an `octoprint` docker volume
on the host, and then start your container:

```
docker volume create octoprint
docker run -d -v octoprint:/octoprint --device /dev/ttyACM0:/dev/ttyACM0 --device /dev/video0:/dev/video0 -e ENABLE_MJPG_STREAMER=true -p 80:80 --name octoprint octoprint/octoprint
```

[code-server]: https://github.com/cdr/code-server
[vscode]: https://code.visualstudio.com

## Building the image yourself

If you would like to build the docker image yourself, please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to do so.
