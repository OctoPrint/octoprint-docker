ARG PYTHON_BASE_IMAGE=3.13-slim-trixie

FROM python:${PYTHON_BASE_IMAGE} AS build

RUN apt-get update && apt-get install -y \
  build-essential \
  curl \
  ffmpeg \
  libffi-dev \
  libjpeg-dev \
  zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*

ARG octoprint_ref
ENV octoprint_ref=${octoprint_ref:-main}

# Install OctoPrint into the image's site-packages rather than the volume, so pulling
# a newer image upgrades it. Plugins still install into the volume (PYTHONUSERBASE below).
RUN curl -fsSL --compressed --retry 3 --retry-delay 10 -o /tmp/octoprint.tar.gz \
    https://github.com/OctoPrint/OctoPrint/archive/${octoprint_ref}.tar.gz \
  && mkdir /tmp/octoprint \
  && tar xzf /tmp/octoprint.tar.gz --strip-components 1 -C /tmp/octoprint \
  && pip install --no-cache-dir --root-user-action=ignore /tmp/octoprint \
  && rm -rf /tmp/octoprint /tmp/octoprint.tar.gz

RUN groupadd --gid 1000 octoprint \
  && useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -m octoprint \
  && mkdir -p /octoprint/octoprint /octoprint/plugins \
  && chown -R octoprint:octoprint /octoprint

COPY docker-entrypoint.sh /usr/local/bin

USER octoprint

ENV PYTHONUSERBASE=/octoprint/plugins
ENV PIP_USER=true
ENV PATH="${PYTHONUSERBASE}/bin:${PATH}"

WORKDIR /octoprint
COPY config.yaml /octoprint/octoprint

VOLUME /octoprint
EXPOSE 5000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["octoprint", "--basedir", "/octoprint/octoprint", "serve"]
