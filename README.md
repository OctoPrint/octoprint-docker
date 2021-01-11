# OctoPrint-docker [![Chat](https://img.shields.io/badge/chat-on%20discord-7289da.svg)](https://discord.octoprint.org)

This is the primary image of `octoprint/octoprint`. It is designed to work similarly, and support the
same out of the box features as the octopi raspberry-pi machine image, using docker.

The `octoprint/octoprint` image uses semantic versioning, but the tags for `octoprint/octoprint` follow the
version of octoprint contained in the image. As a result we recommend you always check the [CHANGELOG](CHANGELOG.md)
or [Releases](https://github.com/OctoPrint/octoprint-docker/releases) before pulling an image, _even if you are pulling the same tag_.

You can subscribe to be notified of releases as well, by selecting the Watch button in the upper right corner, 
choosing "Custom", and checking "Releases".

In addition, we know that OctoPrint is not the best suited type of application for containerization, but we're
working hard to make it as compatible as possible. Please check out our [Roadmap](https://github.com/OctoPrint/octoprint-docker/projects/4),
or join the discussion in the `#dev-docker` or `#support-docker` channels on the official OctoPrint Discord
[discord.octoprint.org](https://discord.octoprint.org).

**Tags and platforms**

All images for the `octoprint/octoprint` image are multi-arch images, and we publish for `arm64`, `arm/v7`, and `amd64` using the below tags:

- `latest` - will always follow the latest _stable_ release 
- `edge` - will always follow the latest release _including prereleases_.
- `canary` - follows the [OctoPrint/Octoprint@maintenance](https://github.com/OctoPrint/OctoPrint/tree/maintenance) branch
- `bleeding`- follows the [OctoPrint/Octoprint@devel](https://github.com/OctoPrint/OctoPrint/tree/devel) branch
- `X`,`X.Y`,`X.Y.Z`,`X.Y.Z-rc` - these tags will follow the latest build that matches the tag
- `minimal` - This is built whenever `latest` is built, but uses the [minimal image](docs/using_the_minimal_image.md)
- `latest|edge|canary|bleeding|X.Y.Z-minimal` - a minimal version of each of the tags described above, published under the same condition but from the [minimal image](docs/using_the_minimal_image.md)

**Table of Contents**
- [OctoPrint-docker ![Chat](https://discord.octoprint.org)](#octoprint-docker-)
  - [Usage](#usage)
    - [Configuration](#configuration)
      - [Enabling Webcam Support with Docker](#enabling-webcam-support-with-docker)
      - [Container Environment based configs](#container-environment-based-configs)
      - [Restarting OctoPrint](#restarting-octoprint)
      - [Editing Config files manually](#editing-config-files-manually)
  - [Without docker-compose](#without-docker-compose)
  - [Building the image yourself](docs/README.md#building-your-own-octoprint-image)
  - [Contributions Welcome](#contributions-welcome)

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

#### Container Environment based configs

There are configuration values that you pass using container `--environment` options.
Listed below are the options and their defaults. These are implicit in example [docker-compose.yml](docker-compose.yml),
and if you wish to change them, refer to the docker-compose docs on setting environment variables.

| variable | default | description |
| -------- | ------- | ----------- |
| `CAMERA_DEV` | `/dev/video0` | (see [note](#devices_note)) |
| `MJPG_STREAMER_INPUT` | `-n -r 640x480` | params for mjpg-streamer |
| `ENABLE_MJPG_STREAMER` | `false` | enable or disable mjpg-streamer
| `AUTOMIGRATE` | `false` | Will attempt to detect and migrate filesystems structures from previous versions of this image to be compatible with the latest release version. recommend you backup before trying this as this is a new feature that has been difficult to test fully |

**note:** You will still need to declare the `device` mapping in your docker-compose file or docker command,
even if you explicitly declare the `CAMERA_DEV`.  The value of `CAMERA_DEV` is used in starting the mjpg-streamer
service, whereas the `devices` mapping is used by docker to make sure the container has access to the device.

For example, if you change the `CAMERA_DEV` to be `/dev/video1`, you would also need to map `/dev/video1:/dev/video1`
in your container.

#### Restarting OctoPrint

Whilst the container should be pre-configured to allow for OctoPrint to be restarted within the container, there are still some edge cases where this pre-configuration does not take effect. If the option to restart OctopPrint is not present in the user interface, ensure the following command is present in the `Restart OctoPrint` field under the Server section of the OctoPrint Settings.

```text
s6-svc -r /var/run/s6/services/octoprint
```

#### Editing Config files manually

This docker-compose file also contains a container based instance of [vscode][], accessible
via your browser at the same url as your octoprint instance, allowing you to edit configuration
files without needing to login to your octoprint host.

To make use of this editor, just uncomment the indicated lines in your [docker-compose.yml](docker-compose.yml#L20-L32)
then run the following commands:

```
docker-compose up -d config-editor
```

Now go to `http://<octoprint_ip_or_url>:8443/?folder=/octoprint` in your browser to edit your octoprint files!
Use the 'explorer' (accessible by clicking the hamburger menu icon) to explore folder and files to load
into the editor workspace. 

All configuration files are in the `octoprint` folder, and the active configuration will be accessible at `/octoprint/octoprint/config.yaml`

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

## Extended Documentation

We are in the process of creating more extensive documentation for using the octoprint/octprint image. Check out the [docs](docs/README.md)

If you would like to build the docker image yourself, please read [building-an-octoprint-image](docs/README.md#building-your-own-octoprint-image)

## Contributions Welcome

We are welcoming contributions, and looking to add maintainers to the team. View [CONTRIBUTING.md](CONTRIBUTING.md) for more info!
