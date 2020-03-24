# Contributing

## Pre-requisites

A build environment that:
- supports docker multi-stage builds
- has `make` and `jq` commands available

### Building

 - [building images from latest stable release tag](#stable)
 - [building images from master](#master)
 - [alternate build configuration](#build-config)

<a name="stable"></a>**Building stable release images**
Running `make` will run a build that will result in 2 images based on the `Dockerfile`
one using python 2.7, and one using the latest slim-buster python tag from docker hub.

Resulting Tags/Images:

```
octoprint/octoprint:<version> (python 2.7)
octoprint/octoprint:<version>-python3
```

<a name="master"></a>**Building 'latest' from master**

Run `make build-master` or `make build-master-python3` to build the
corresponding images:

```
octoprint/octoprint:latest
octoprint/octoprint:python3
```

**Build Configurations**

The `make` command will pull in the `config.env` file, and 
utilize the variables within during the various stages of build,
test, and release.

To build alternate infrastructures, or get use different base images
for end-use, you can either change the variables in `config.env`, or
provide alternate saved configsets by using `cnf=<some_other_config.env`
argument supplied to `make`. 

For example, let's say you want to build using the full `buster` instead of the default `slim`, and publish to your own private repo. You could create a `private_buster_full.env` file, supplying the content below:

```
IMAGE=my.private.repo:5000/someuser/octoprint
PYTHON_IMAGE_TAG=buster
```

Then run: `make cnf="private_buster_full.env" build-stable`, which would result in a python 3 based image with the tag `my.private.repo:5000/someuser/octoprint:<latest stable version>`
