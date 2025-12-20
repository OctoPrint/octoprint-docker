ARG PYTHON_BASE_IMAGE=3.13-slim-trixie

FROM python:${PYTHON_BASE_IMAGE} AS build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential \
  curl \
  ffmpeg \
  libffi-dev \
&& rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 octoprint \
  && useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash -m octoprint \
  && mkdir -p /octoprint/octoprint /octoprint/plugins \
  && chown -R octoprint:octoprint /octoprint

COPY docker-entrypoint.sh /usr/local/bin

ARG octoprint_ref 
ENV octoprint_ref=${octoprint_ref:-master}

RUN mkdir -p /tmp/octoprint \
  && curl -fsSLO --output-dir /tmp --compressed --retry 3 --retry-delay 10 \
    https://github.com/OctoPrint/OctoPrint/archive/${octoprint_ref}.tar.gz \
  && tar xzf /tmp/${octoprint_ref}.tar.gz --strip-components 1 -C /tmp/octoprint \
  && pip install --no-cache-dir /tmp/octoprint \
  && rm -rf /tmp/*
  
USER octoprint
ENV PYTHONUSERBASE=/octoprint/plugins
ENV PIP_USER=true

WORKDIR /octoprint
COPY config.yaml /octoprint/octoprint

VOLUME /octoprint
EXPOSE 5000

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["octoprint", "--basedir", "/octoprint/octoprint", "serve"]
