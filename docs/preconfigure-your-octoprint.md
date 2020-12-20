# Preconfigure Your OctoPrint Container

You can preconfigure your container the following ways:

- after the container is started, exec into the container and run octoprint cli commands
- volume mount a config.yaml file on your host machine to the container config.yaml file
- build your own image and include your own config.yaml
- build your own image and use octoprint cli commands to set configuration values
- open the config-editor service and edit config files, then restart octoprint service
