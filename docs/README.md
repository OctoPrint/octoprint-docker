# Extended docs for OctoPrint Docker Image

- [Extended docs for OctoPrint Docker Image](#extended-docs-for-octoprint-docker-image)
  - [Configuring Docker](#configuring-docker)
  - [Building your own OctoPrint image](#building-your-own-octoprint-image)
  - [Preconfiguring Your OctoPrint Container](#preconfiguring-your-octoprint-container)
    - [Configuration Considerations](#configuration-considerations)

The purpose of the docs here will not be to teach you docker, as it is assumed if you are using
the docker image you have a basic working knowledge of docker. Unless stated otherwise, all of 
things described in these docs are leveraging basic docker usage techniques. 

If you have questions about a particular technique, we recommend diving deeper into docker. 
Here are some helpful resources on docker that we recommend:

- [Dockerfile Tutorial with Example | Creating your First Dockerfile | Docker Training | Edureka](https://www.youtube.com/watch?v=2lU9zdrs9bM)

## Configuring Docker

We recommend using docker 19.03 or higher, and enabling experimental support for your docker engine.
The examples used in these docs will all use experimental features enabled.

1. Open `/etc/docker/daemon.json`
2. Add the experimental true setting:

```json
{
  "experimental": true
}
```

## Building your own OctoPrint image

In some circumstances, the best approach for running octoprint in a container
will be to build off of the base `octoprint/octoprint` image and add your own 
customizations. Here are a few common scenarios you might find yourself wanting to do this:

- you require additional OS packages for plugins
- you want to distribute your own special version of OctoPrint 
- you want a common set of plugins installed for a distributable image
- you want to [preconfigure your octoprint instance](preconfigure-your-octoprint.md)

## Preconfiguring Your OctoPrint Container

You can preconfigure your container the following ways:

- after the container is started, exec into the container and run octoprint cli commands
- volume mount a config.yaml file on your host machine to the container config.yaml file
- build your own image and include your own config.yaml
- build your own image and use octoprint cli commands to set configuration values
- open the config-editor service and edit config files, then restart octoprint service

### Configuration Considerations

There are a few considerations around which of these techniques are right for you. You can also combine
approaches. Only you can decide which approach is best for your situation, however we recommend that you:

- avoid committing any configuration value that is considered sensitive (passwords, certs, api keys, etc..)
- aim for portability whenever possible (try not to tie to a specific computer)
- make sure you know how to upgrade with the chosen techniques
