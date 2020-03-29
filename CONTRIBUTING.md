# Contributing

## Pre-requisites

A build environment that:
- supports docker multi-stage builds
- has `make` and `jq` commands available

### Building

The `make` command will pull in the `env.mk` file, and 
utilize the variables within during the various stages of build,
test, and release.

To build alternate infrastructures, or get use different base images
for end-use, you have a few options:

- change the variables in `env.mk`
- provide alternate saved configsets by using `cnf=<some_other_env.mk`
argument supplied to `make` (and creating/savig `some_other_env.mk`) 
- set the variables found in `env.mk` in the build environment or supply them to command line
to override the default configs

**Travis**

To test and publish your builds automatically, you can set the following travis
environment variables to override the default configs.

```
# tell build what docker repository to push to
IMAGE <your_dockerhub_username>/octoprint
# used during image push
DOCKER_PASSWORD <your_dockerhub_password>  (don't show in logs)
# used during image push
DOCKER_USERNAME <your dockerhub username> 
# (optional) push to a private registry instead of docker hub
REGISTRY <registry_url>
```
