# Contributing to the official octoprint Docker image

Call for maintainers! Are you experienced with Docker? Are you an OctoPrint enthusiast?
Do you have a hour or more of time to spare each week answering questions about octoprint-docker
and reviewing PR's? Let us know! 

If this sounds like you, join the [OctoPrint Discord][] and message `@CHIEFdotJS` in the `#dev-docker` channel.

- [Contributing to the official octoprint Docker image](#contributing-to-the-official-octoprint-docker-image)
  - [Pull Requests](#pull-requests)
  - [Building images](#building-images)
    - [Simple test images](#simple-test-images)
    - [Testing your changes on all architectures](#testing-your-changes-on-all-architectures)

## Pull Requests

- Pull Requests that are intended to fix a bug should have a related issue. It is acceptable to create the issue
at the time you open the PR.
  - Pull Requests that are for fixing typos, updating docs, or adding features/enhancements can be submitted without a related issue
  - Pull Requests that add enhancements should have an adequate description, and should make any relevant changes to documentation
- Pull Requests that will result in new images being published must build on all supported architectures (`arm64,arm/v7,amd64`) (see [Testing your changes on all architectures](#testing-your-changes-on-all-architectures))
- any documentation should be exclusive to this project, or affect the majority of users/contributors.
- any packages/dependencies added to the image should be available on all supported architectures, AND:
  - should be required by the majority of users or plugins OR
  - be bundled by OctoPi (try to increase parity with usage docs of OctoPi whenever possible)

## Building images

Prerequisites:

- docker and its dependencies installed and up to date
- buildx enabled in the docker daemon (experimental features should be true)

### Simple test images

Simple test images are built only for the architecture of the machine you are on, using docker-compose.

We have simplified running the docker-compose commands using the Makefile. To build and run the test image,
make your changes to the repo, then run:

```
make build && make up
```

This will build the image from the main Dockerfile, and stand it up, with the logs running in the terminal.
Octoprint will be accessible on [http://localhost:53333](), and the config-editor will be stood up on [http://localhost:8443]()

### Testing your changes on all architectures

Before submitting your changes, you should make sure the image builds on all supported architectures. 

Running `make test` will check to make sure your machine can build all supported architectures, and then build the image
for all architectures using cache from both your local machine and the latest upstream docker image tag.

If you don't have multi-arch support enabled on your machine, you can run `make setup-multi-arch` to add this support.

[OctoPrint Discord]: https://discord.octoprint.org
