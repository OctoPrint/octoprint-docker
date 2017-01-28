# OctoPrint-docker

This repository contains everything you need to run [Octoprint](https://github.com/foosel/OctoPrint) in a docker environment.

# Use the image

## Using only docker
```
docker run -d -v --device /dev/ttyACM0:/dev/ttyACM0 -p 5000:5000 --name octoprint gaetancollaud/octoprint
```

## Docker compose

You can copy the docker-compose.yml file from this repo and use it to start octoprint using docker-compose. Don't forget to uncomment the _devices_ part so you can like it to your 3D printer.
```
docker-compose up -d
```

# Additional tools

## FFMPEG

Octoprint allows you to make timelapses using ffmpeg. It is installed in `/opt/ffmpeg`

## Cura Engine

Octoprint allows you to import .STL files and slice them directly in the application. For this you need to upload the profiles that you want to use (you can export them from Cura). Cura is installed in `opt/cura/CuraEngine`.
