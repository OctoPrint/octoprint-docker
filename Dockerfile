ARG PYTHON_BASE_IMAGE=3.8-slim-buster

FROM ubuntu AS s6build
ARG S6_RELEASE
ENV S6_VERSION ${S6_RELEASE:-v2.0.0.1}
RUN apt-get update && apt-get install -y curl
RUN echo "$(dpkg --print-architecture)"
WORKDIR /tmp
RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
  amd64) ARCH='amd64';; \
  arm64) ARCH='aarch64';; \
  armhf) ARCH='armhf';; \
  *) echo "unsupported architecture: $(dpkg --print-architecture)"; exit 1 ;; \
  esac \
  && set -ex \
  && echo $S6_VERSION \
  && curl -fsSLO "https://github.com/just-containers/s6-overlay/releases/download/$S6_VERSION/s6-overlay-$ARCH.tar.gz"


FROM python:${PYTHON_BASE_IMAGE} AS build

ARG tag
ENV tag ${tag:-master}

USER root

RUN apt-get update && apt-get install -y \
  avrdude \
  build-essential \
  cmake \
  curl \
  imagemagick \
  fontconfig \
  g++ \
  git \
  haproxy \
  libjpeg-dev \
  libjpeg62-turbo \
  libprotobuf-dev \
  libv4l-dev \
  openssh-client \
  v4l-utils \
  xz-utils \
  zlib1g-dev

# unpack s6
COPY --from=s6build /tmp /tmp
RUN s6tar=$(find /tmp -name "s6-overlay-*.tar.gz") \
  && tar xzf $s6tar -C / 

# Install octoprint
RUN	curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/OctoPrint/OctoPrint/archive/${tag}.tar.gz \
	&& mkdir -p /opt/octoprint \
  && tar xzf ${tag}.tar.gz --strip-components 1 -C /opt/octoprint --no-same-owner

WORKDIR /opt/octoprint
RUN pip install -r requirements.txt
RUN python setup.py install
RUN ls -s ~/.octoprint /octoprint

# Install mjpg-streamer
RUN curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/jacksonliam/mjpg-streamer/archive/master.tar.gz \
  && mkdir /mjpg \
  && tar xzf master.tar.gz -C /mjpg

WORKDIR /mjpg/mjpg-streamer-master/mjpg-streamer-experimental
RUN make
RUN make install

# Copy services into s6 servicedir and set default ENV vars
COPY root /
ENV CAMERA_DEV /dev/video0
ENV MJPEG_STREAMER_INPUT -y -n -r 640x480
ENV PIP_USER true
ENV PYTHONUSERBASE /octoprint/plugins

# port to access haproxy frontend
EXPOSE 80

ENTRYPOINT ["/init"]
CMD ["octoprint", "serve", "--iknowwhatimdoing", "--host", "0.0.0.0"]
