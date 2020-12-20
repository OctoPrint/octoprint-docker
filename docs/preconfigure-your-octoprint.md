# Preconfigure Your OctoPrint Container

You can preconfigure your container the following ways:

- after the container is started, exec into the container and run octoprint cli commands
- volume mount a config.yaml file on your host machine to the container config.yaml file
- build your own image and include your own config.yaml
- build your own image and use octoprint cli commands to set configuration values
- open the config-editor service and edit config files, then restart octoprint service

### Which way is right for you?

There are a few considerations around which of these techniques are right for you. You can also combine
approaches. Only you can decide which approach is best for your situation, however we recommend that you:

- avoid committing any configuration value that is considered sensitive (passwords, certs, api keys, etc..)
- aim for portability whenever possible (try not to tie to a specific computer)
- make sure you know how to upgrade with the chosen techniques
