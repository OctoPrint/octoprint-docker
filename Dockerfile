ARG PYTHON_BASE_IMAGE=3.8-slim-buster

FROM ubuntu AS s6build
ARG S6_RELEASE
ENV S6_VERSION ${S6_RELEASE:-v2.1.0.0}
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
ENV MJPG_STREAMER_INPUT -y -n -r 640x480

# Install octoprint
RUN groupadd --gid 1000 octoprint \
  && useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash --create-home octoprint


USER octoprint
ENV VIRTUAL_ENV=/home/octoprint
WORKDIR $VIRTUAL_ENV
RUN mkdir tmp
WORKDIR ${VIRTUAL_ENV}/tmp
RUN	curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/OctoPrint/OctoPrint/archive/${tag}.tar.gz \
  && tar xzf ${tag}.tar.gz --strip-components 1 -C $VIRTUAL_ENV
WORKDIR $VIRTUAL_ENV
RUN rm -rf ${VIRTUAL_ENV}/tmp

# activate virtual env
RUN python -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install .


# port to access haproxy frontend
EXPOSE 80

VOLUME /home/octoprint/.octoprint

ENTRYPOINT ["/init"]
CMD ["octoprint", "serve", "--host", "0.0.0.0"]
