# Using the `minimal` image

The `minimal` image variants of the `octoprint/octoprint` images behave like a more
traditional docker image. This means there is no process supervisor, and there is only one
process (octoprint). It has the following differences from the main image:

- it does not contain mjpg-streamer
- octoprint can't be restarted from within the container
- it runs as a non-root user (you can thus use docker user features)

## Who is it for, and why would you use it?

The `minimal` image is designed to fully embrace docker concepts, and is not intended
for users who are not comfortable with docker.

This image allows decoupling hardware such as webcams, gpio, and usb devices, allowing
it to be used in distributed or scaled architectures. This means you could run a container with a camera device in one container, and run octoprint in another container and even on
a different piece of hardware.
