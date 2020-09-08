# OctoPrint-docker 

The primary image of `octoprint/octoprint`, is designed to work similarly, and support the
same out of the box features as the octopi raspberry-pi machine image, using docker.

## Tags

- `latest`, `1.4.2`, `1.4`, `1` ([Dockerfile](Dockerfile))

## Usage

We recommend you use docker-compose to run octoprint via docker, and have included
a recommended [docker-compose.yml](docker-compose.yml) file for your convenience.

Save the contents of this file on your machine as `docker-compose.yml`, and then
run `docker-compose up -d`.

Open octoprint at `http://<octoprint_ip_or_url`

See [Initial Setup](#initial-setup) for configuration values to use during your fist
launch of OctoPrint using docker.

### Configuration

#### Initial Setup

Use the following values in the webcam & timelapse settings screen of the initial setup:

| Setting | Value |
| ------- | ----- |
| Stream URL | `/webcam/?action=stream` |
| Snapshot URL |  `http://localhost:8080/?action=snapshot` |
| Path to FFMPEG | `/usr/bin/ffmpeg` |

### Container Environment based configs

There are configuration values that you pass using container `--environment` options.
Listed below are the options and their defaults. These are implicit in example [docker-compose.yml](docker-compose.yml),
and if you wish to change them, refer to the docker-compose docs on setting environment variables.

| variable | default |
| -------- | ------- |
| `CAMERA_DEV` | `/dev/video0` (see [note](#devices_note)) |
| `CAMERA_DEV` | `MJPEG_STREAMER_INPUT -y -n -r 640x48` |

**note:** You will still need to declare the `device` mapping in your docker-compose file or docker command,
even if you explicitly declare the `CAMERA_DEV`.  The value of `CAMERA_DEV` is used in starting the mjpeg-streamer
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

Now go to `http://<octoprint_ip_or_url>:8443` in your browser to edit your octoprint files!
Use the 'explorer' (accessible by clicking the hamburger menu icon) to explore folder and files to load
into the editor workspace.

The active configuration will be accessible at `/config/config.yaml`

When you're done, we recommend you stop and rm this service/container:

```
docker-compose stop config-editor && docker-compose rm config-editor
```

For full documenation about the config editor, see the docs for the product at [github.com/cdr/code-server][code-server].

## Without docker-compose

If you prefer to run without docker-compose, first create an `octoprint` docker volume
on the host, and then start your container:

```
docker volume create octoprint
docker run -d -v octoprint:/octoprint --device /dev/ttyACM0:/dev/ttyACM0 --device /dev/video0:/dev/video0 -p 80:80 --name octoprint octoprint/octoprint

```

[code-server]: https://github.com/cdr/code-server
[vscode]: https://code.visualstudio.com
