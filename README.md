# OctoPrint-docker [![Chat](https://img.shields.io/badge/chat-on%20discord-7289da.svg)](https://discord.octoprint.org)

This repository builds the OctoPrint Docker image, published as `ghcr.io/octoprint/octoprint`. It is designed to work like, and support the same out of the box features as, the OctoPi Raspberry Pi image.

Tags follow the version of OctoPrint in the image. A tag can be rebuilt with the same OctoPrint version, for example to pick up Debian security updates or changes to the image, so check the [CHANGELOG](CHANGELOG.md) before pulling, even for a tag you already use.

In addition, we know that OctoPrint is not the best suited type of application for containerization, but we're working hard to make it as compatible as possible.

> [!IMPORTANT]
> The image has moved from Docker Hub to `ghcr.io/octoprint/octoprint`, and now runs Python 3.13. `octoprint/octoprint` on Docker Hub no longer gets updates. Before you switch, read [Upgrading to the Python 3.13 images](#upgrading-to-the-python-313-images): plugins installed through the Plugin Manager need to be reinstalled.

**Tags and platforms**

Every image is published for `amd64`, `arm64` and `arm/v7`.

| Main image | [Minimal image](docs/using_the_minimal_image.md) | Follows |
| --- | --- | --- |
| `latest` | `minimal` | The latest stable OctoPrint release |
| `X.Y`, `X` | `X.Y-minimal`, `X-minimal` | The latest stable release, while it's in that line |
| `X.Y.Z` | `X.Y.Z-minimal` | That OctoPrint release, prereleases included |
| `edge` | `edge-minimal` | The newest release, prereleases included |
| `dev` | `dev-minimal` | OctoPrint's [`dev`](https://github.com/OctoPrint/OctoPrint/tree/dev) branch |

Every tag also has a `-pythonX.Y` alias with the image's Python version, such as `latest-python3.13` or `2.0.2-minimal-python3.13`. Pin one of those if you want to choose when the Python version changes.

**Table of Contents**

- [OctoPrint-docker ](#octoprint-docker-)
  - [Upgrading to the Python 3.13 images](#upgrading-to-the-python-313-images)
  - [Usage](#usage)
    - [Configuration](#configuration)
      - [Enabling Webcam Support with Docker](#enabling-webcam-support-with-docker)
      - [Container Environment Variables](#container-environment-variables)
      - [Restarting OctoPrint](#restarting-octoprint)
      - [Editing Config files manually](#editing-config-files-manually)
  - [Without Docker Compose](#without-docker-compose)
  - [Extended Documentation](#extended-documentation)
  - [Contributions Welcome](#contributions-welcome)

## Upgrading to the Python 3.13 images

The images now run Python 3.13 on Debian trixie. Earlier images ran Python 3.10 (main image) or Python 3.11 (minimal image). OctoPrint 2.1 won't support Python 3.10, so every release from here on uses the new images. To see which Python your container runs:

```shell
docker compose exec octoprint python --version
```

If it shows 3.10 or 3.11, read this before you pull.

**What carries over:** your settings, users, uploaded files, timelapses and single-file plugins. They live in OctoPrint's config folder, `/octoprint/octoprint`, in your volume.

**What doesn't:** plugins installed through the Plugin Manager. They're Python packages in `/octoprint/plugins/lib/python3.10/site-packages` (`python3.11` on the minimal image), and Python 3.13 doesn't look there. Their settings are kept, so reinstalling them brings them back as they were.

To upgrade:

1. Under **Settings » Backup & Restore**, create a backup and download it.
2. Under **Settings » Plugin Manager**, click **Export**. This downloads your plugin list as a `plugin_list.json` file.
3. If your `docker-compose.yml` still says `image: octoprint/octoprint`, change it to `image: ghcr.io/octoprint/octoprint`, keeping any tag you use. Then pull the new image and recreate the container:

   ```shell
   docker compose pull
   docker compose up -d
   ```

4. Under **Settings » Plugin Manager**, click **Get More**, and in **... from an uploaded file** choose `plugin_list.json`. Restart OctoPrint when asked.
5. Optional: once everything works, remove the old packages to free up space. On the minimal image, use `python3.11`:

   ```shell
   docker compose exec octoprint rm -rf /octoprint/plugins/lib/python3.10
   ```

**Not ready yet?** The last images on the old Python stay available as `ghcr.io/octoprint/octoprint:2.0.2-python3.10` and `ghcr.io/octoprint/octoprint:2.0.2-minimal-python3.11`. They won't get any more updates, so use them only to put the upgrade off for a while.

**Choosing when Python changes next:** every tag also has a `-python3.13` variant, such as `latest-python3.13` or `2.0.2-minimal-python3.13`. If you pin one of those, the next Python upgrade only reaches you when you change the tag.

**Installing plugins from the command line:** older plugins whose `setup.py` imports `octoprint_setuptools` only build with pip's `--no-build-isolation` flag. The Plugin Manager adds it by itself; on the command line, add it yourself and restart OctoPrint afterwards:

```shell
docker compose exec octoprint pip install --no-build-isolation <plugin archive URL>
```

**Changes in OctoPrint 2.0 itself:** some old plugins no longer load on OctoPrint 2.0, whichever image you use. See the [plugin migration guide](https://docs.octoprint.org/en/dev/plugins/migration_2_0_0.html). If you use an authentication proxy with `accessControl.trustRemoteUser`, check the trusted authentication proxies setting described in the [2.0.0 release notes](https://github.com/OctoPrint/OctoPrint/releases/tag/2.0.0).

## Usage

We recommend you use Docker Compose to run octoprint via docker, and have included a recommended [docker-compose.yml](docker-compose.yml) file for your convenience.

Save the contents of this file on your machine as `docker-compose.yml`, and then run `docker compose up -d`.

Open octoprint at `http://<octoprint_ip_or_url>`

### Configuration

#### Enabling Webcam Support with Docker

In order to use the webcam, you'll need to make sure the webcam service is enabled.
This is done by setting the environment variable `ENABLE_MJPG_STREAMER=true` in your`docker run` command, or in the `docker-compose.yml` file.

> [!IMPORTANT]
> If you are running octoprint with docker compose and you had already started the compose file without the enabled mjpeg streamer you need to recreate the container with `docker compose down` and `docker compose up -d`.
> Otherwise the streamer will not start.


You'll also need to add `--device /dev/video0:/dev/video0` to your `docker run`, or ensure it's listed in the `devices` array in your `docker-compose.yml`.

If you map a video device _other_ than `/dev/video0`, you will additionally need to set an environment variable for `CAMERA_DEV` to match the mapped device mapping.

Make sure you use the following internal configuration (Settings » Webcam & Timelapse):
- Path to FFMPEG: `/usr/bin/ffmpeg`

Additionally, also use the following plugin configuration (Settings » Classic Webcam):
- Stream URL: `/webcam/?action=stream`
- Snapshot URL: `http://localhost:8080/?action=snapshot`

URLs for reaching the camera from outside the container are:

- Stream: `http://dockerIP:dockerport/webcam/?action=stream`
- Snapshot: `http://dockerIP:dockerport/webcam/?action=snapshot`

See [container Environment Variables](#container-environment-variables) for a full list of webcam configuration options configured with docker.

#### Container Environment Variables

There are configuration values that you pass using container `--environment` options.
Listed below are the options and their defaults. These are implicit in example [docker-compose.yml](docker-compose.yml), and if you wish to change them, refer to the Docker Compose docs on setting environment variables.

| variable               | default         | description                                                                                                                                                                                                                                             |
| ---------------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CAMERA_DEV`           | `/dev/video0`   | The camera device inside the container. (See [Camera Devices](#camera-devices) note below)                                                                                                                                                              |
| `MJPG_STREAMER_INPUT`  | `-n -r 640x480` | params for mjpg-streamer                                                                                                                                                                                                                                |
| `ENABLE_MJPG_STREAMER` | `false`         | enable or disable mjpg-streamer                                                                                                                                                                                                                         |
| `AUTOMIGRATE`          | `false`         | Will attempt to detect and migrate filesystems structures from previous versions of this image to be compatible with the latest release version. recommend you backup before trying this as this is a new feature that has been difficult to test fully |

##### Camera Devices

You will still need to declare the `device` mapping in your docker-compose file or docker command, even if you explicitly declare the `CAMERA_DEV`.
The value of `CAMERA_DEV` is used in starting the mjpg-streamer service, whereas the `devices` mapping is used by docker to make sure the container has access to the device.

For example, if you change the `CAMERA_DEV` to be `/dev/video1`, you would also need to map `/dev/video1:/dev/video1` in your container.

#### Restarting OctoPrint

Whilst the container should be pre-configured to allow for OctoPrint to be restarted within the container, there are still some edge cases where this pre-configuration does not take effect. If the option to restart OctopPrint is not present in the user interface, ensure the following command is present in the `Restart OctoPrint` field under the Server section of the OctoPrint Settings.

```shell
s6-svc -r /run/service/octoprint
```

Volumes set up by older images contain `s6-svc -r /var/run/s6/services/octoprint` instead. That path keeps working, so there's no need to change it.

#### Editing Config files manually

This docker-compose file also contains a container based instance of [vscode][], accessible via your browser at the same url as your octoprint instance, allowing you to edit configuration files without needing to login to your octoprint host.

To make use of this editor, just uncomment the indicated lines in your [docker-compose.yml](docker-compose.yml#L18-L35) then run the following commands:

```shell
docker compose up -d config-editor
```

Now go to `http://<octoprint_ip_or_url>:8443/?folder=/octoprint` in your browser to edit your octoprint files!
Use the 'explorer' (accessible by clicking the hamburger menu icon) to explore folder and files to load into the editor workspace.

All configuration files are in the `octoprint` folder, and the active configuration will be accessible at `/octoprint/octoprint/config.yaml`

When you're done, we recommend you stop and remove this service/container:

```shell
docker compose stop config-editor && docker compose rm config-editor
```

For full documentation about the config editor, see the docs for the product at [github.com/coder/code-server][code-server].

## Without Docker Compose

If you prefer to run without Docker Compose, first create an `octoprint` docker volume on the host, and then start your container:

```shell
docker volume create octoprint
docker run -d -v octoprint:/octoprint --device /dev/ttyACM0:/dev/ttyACM0 --device /dev/video0:/dev/video0 -e ENABLE_MJPG_STREAMER=true -p 80:80 --name octoprint ghcr.io/octoprint/octoprint
```

[code-server]: https://github.com/coder/code-server
[vscode]: https://code.visualstudio.com

## Extended Documentation

We are in the process of creating more extensive documentation for using the `ghcr.io/octoprint/octoprint` image. Check out the [docs](docs/README.md)

If you would like to build the docker image yourself, please read [building-an-octoprint-image](docs/README.md#building-your-own-octoprint-image)

## Contributions Welcome

We are welcoming contributions, and looking to add maintainers to the team. View [CONTRIBUTING.md](CONTRIBUTING.md) for more info!
