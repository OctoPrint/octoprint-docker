# Contributing

## Pre-requisites

A build environment that:
- supports docker multi-stage builds
- has `make` and `jq` commands available

### Building locally

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

**Github Actions**

To test and publish your builds automatically, you can set the following
github secrets to automatically override the default configs.

| Variable      | Secret | Default Value |
|---------------|--------|---------------|
| `IMAGE` | `DOCKER_IMAGE_ORGANIZATION` |`github.repository_owner/octoprint` |  
| `REGISTRY` | `DOCKER_IMAGE_REGISTRY` | `docker.io` |
