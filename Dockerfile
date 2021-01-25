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

ARG octoprint_ref
ENV octoprint_ref ${octoprint_ref:-master}

# install build pkgs without extras
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# unpack s6 and remove .tar.gz
COPY --from=s6build /tmp /tmp
RUN s6tar=$(find /tmp -name "s6-overlay-*.tar.gz") \
  && tar xzf $s6tar -C / \
  && rm -rf $s6tar

# Install octoprint and remove .tar.gz
RUN	curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/OctoPrint/OctoPrint/archive/${octoprint_ref}.tar.gz \
  && mkdir -p /opt/octoprint \
  && tar xzf ${octoprint_ref}.tar.gz --strip-components 1 -C /opt/octoprint --no-same-owner \
  && rm -rf ${octoprint_ref}.tar.gz

# install without pip wheel caching
WORKDIR /opt/octoprint
RUN pip install . --no-cache-dir
RUN mkdir -p /octoprint/octoprint /octoprint/plugins

# Install mjpg-streamer and remove .tar.gz
RUN curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/jacksonliam/mjpg-streamer/archive/master.tar.gz \
  && mkdir /mjpg \
  && tar xzf master.tar.gz -C /mjpg \
  && rm -rf ./master.tar.gz

WORKDIR /mjpg/mjpg-streamer-master/mjpg-streamer-experimental
RUN make
RUN make install

# remove build/dev packages and it's dependencies from runtime image
RUN apt remove -y build-essential \
  cmake \
  curl \  
  g++ \
  git \
  libjpeg-dev \
  imagemagick \
  fontconfig \
  libprotobuf-dev \
  libv4l-dev \
  openssh-client \
  xz-utils \
  zlib1g-dev \
  && apt autoremove -y

# Copy services into s6 servicedir and set default ENV vars
COPY root /
ENV CAMERA_DEV /dev/video0
ENV MJPG_STREAMER_INPUT -n -r 640x480
ENV PIP_USER true
ENV PYTHONUSERBASE /octoprint/plugins
ENV PATH "${PYTHONUSERBASE}/bin:${PATH}"
# set WORKDIR 
WORKDIR /octoprint

# port to access haproxy frontend
EXPOSE 80

VOLUME /octoprint

ENTRYPOINT ["/init"]
