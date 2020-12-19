# Contributing to the official octoprint Docker image

Call for maintainers! Are you experienced with Docker? Are you an OctoPrint enthusiast?
Do you have a hour or more of time to spare each week answering questions about octoprint-docker
and reviewing PR's? Let us know! 

If this sounds like you, join the [OctoPrint Discord][] and message `@CHIEFdotJS` in the `#dev-docker` channel.

- [Contributing to the official octoprint Docker image](#contributing-to-the-official-octoprint-docker-image)
  - [Building images](#building-images)
    - [Simple test images](#simple-test-images)
    - [Testing your changes on all architectures](#testing-your-changes-on-all-architectures)

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
Octoprint will be accessible on [http://localhost:53113](), and the config-editor will be stood up on [http://localhost:8443]()

### Testing your changes on all architectures

Before submitting your changes, you should make sure the image builds on all supported architectures. 

Running `make test` will check to make sure your machine can build all supported architectures, and then build the image
for all architectures using cache from both your local machine and the latest upstream docker image tag.

If you don't have multi-arch support enabled on your machine, you can run `make setup-multi-arch` to add this support.

[OctoPrint Discord]: https://discord.octoprint.org
