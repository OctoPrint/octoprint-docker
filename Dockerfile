# syntax=docker/dockerfile:1
ARG PYTHON_BASE_IMAGE=3.13-slim-trixie

FROM debian:trixie-slim AS s6build
ARG S6_RELEASE
ENV S6_VERSION=${S6_RELEASE:-v3.2.3.2}
RUN apt-get update && apt-get install -y curl
WORKDIR /tmp
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
  amd64) ARCH='x86_64';; \
  arm64) ARCH='aarch64';; \
  armhf) ARCH='armhf';; \
  *) echo "unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;; \
  esac \
  && set -ex \
  && echo $S6_VERSION \
  && curl -fsSLO "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-noarch.tar.xz" \
  && curl -fsSLo /tmp/s6-overlay-arch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-$ARCH.tar.xz" \
  && curl -fsSLO "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-symlinks-noarch.tar.xz" \
  && curl -fsSLO "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-symlinks-arch.tar.xz"


FROM python:${PYTHON_BASE_IMAGE} AS build

RUN apt-get update && apt-get install -y \
  avrdude \
  build-essential \
  cmake \
  curl \
  imagemagick \
  ffmpeg \
  fontconfig \
  g++ \
  git \
  haproxy \
  libffi-dev \
  libjpeg-dev \
  libjpeg62-turbo \
  libprotobuf-dev \
  libudev-dev \
  libusb-1.0-0-dev \
  libv4l-dev \
  openssh-client \
  v4l-utils \
  xz-utils \
  zlib1g-dev \
  x265

# Unpack s6-overlay straight from the s6build stage. The tarballs are mounted for this
# step only, so they never end up in a layer (#277). On merged-/usr bases such as
# trixie, --keep-directory-symlink stops tar from replacing the /bin symlink.
RUN --mount=type=bind,from=s6build,source=/tmp,target=/tmp/s6 \
  if [ "$(readlink -f /bin)" = /usr/bin ]; then keep=--keep-directory-symlink; else keep=; fi \
  && for t in noarch arch symlinks-noarch symlinks-arch; do \
       tar xJf "/tmp/s6/s6-overlay-$t.tar.xz" $keep -C / || exit 1; \
     done

# Declared after the apt and s6 layers, so building another OctoPrint version reuses them
ARG octoprint_ref
ENV octoprint_ref=${octoprint_ref:-main}

# Install OctoPrint, then remove the downloaded tarball and source tree (#276)
RUN curl -fsSL --compressed --retry 3 --retry-delay 10 -o /tmp/octoprint.tar.gz \
    https://github.com/OctoPrint/OctoPrint/archive/${octoprint_ref}.tar.gz \
  && mkdir /tmp/octoprint \
  && tar xzf /tmp/octoprint.tar.gz --strip-components 1 -C /tmp/octoprint --no-same-owner \
  && pip install --no-cache-dir --root-user-action=ignore --upgrade pip setuptools wheel \
  && pip install --no-cache-dir --root-user-action=ignore /tmp/octoprint \
  && rm -rf /tmp/octoprint /tmp/octoprint.tar.gz \
  && mkdir -p /octoprint/octoprint /octoprint/plugins

# Build and install mjpg-streamer from a pinned commit, then remove its source and
# build tree. 310b29f is the tip of jacksonliam/mjpg-streamer master (2021-02-20).
ARG MJPG_STREAMER_COMMIT=310b29f4a94c46652b20c4b7b6e5cf24e532af39
RUN curl -fsSL --compressed --retry 3 --retry-delay 10 -o /tmp/mjpg-streamer.tar.gz \
    https://github.com/jacksonliam/mjpg-streamer/archive/${MJPG_STREAMER_COMMIT}.tar.gz \
  && mkdir /tmp/mjpg-streamer \
  && tar xzf /tmp/mjpg-streamer.tar.gz --strip-components 1 -C /tmp/mjpg-streamer \
  && make -C /tmp/mjpg-streamer/mjpg-streamer-experimental \
  && make -C /tmp/mjpg-streamer/mjpg-streamer-experimental install \
  && rm -rf /tmp/mjpg-streamer /tmp/mjpg-streamer.tar.gz

# Copy services into s6 servicedir and set default ENV vars
COPY root /

ENV CAMERA_DEV=/dev/video0
ENV MJPG_STREAMER_INPUT="-n -r 640x480"
ENV PIP_USER=true
ENV PYTHONUSERBASE=/octoprint/plugins
ENV PATH="${PYTHONUSERBASE}/bin:${PATH}"
# set WORKDIR 
WORKDIR /octoprint

# port to access haproxy frontend
EXPOSE 80

VOLUME /octoprint

ENTRYPOINT ["/init"]
