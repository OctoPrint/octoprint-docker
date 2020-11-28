ARG PYTHON_BASE_IMAGE=2.7-slim-buster

FROM python:${PYTHON_BASE_IMAGE} AS cura-compiler

ARG CURA_VERSION
ENV CURA_VERSION ${CURA_VERSION:-15.04.6}

RUN apt-get update && apt-get install -y g++ make curl
RUN curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && mkdir -p /opt \
  && tar -xzf ${CURA_VERSION}.tar.gz --strip-components=1 -C /opt --no-same-owner
WORKDIR /opt
RUN make

# build ocotprint
FROM python:${PYTHON_BASE_IMAGE} AS compiler

ARG tag
ENV tag ${tag:-master}

RUN apt-get update && apt-get install -y build-essential curl

RUN	curl -fsSLO --compressed --retry 3 --retry-delay 10 \
  https://github.com/OctoPrint/OctoPrint/archive/${tag}.tar.gz \
	&& mkdir -p /opt/venv \
  && tar xzf ${tag}.tar.gz --strip-components 1 -C /opt/venv --no-same-owner

#install venv            
RUN pip install virtualenv
RUN python -m virtualenv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /opt/venv
RUN pip install .


FROM python:${PYTHON_BASE_IMAGE} AS build

RUN apt-get update && apt-get install -y \
  build-essential \
  ffmpeg

RUN groupadd --gid 1000 octoprint \
  && useradd --uid 1000 --gid octoprint -G dialout --shell /bin/bash --create-home octoprint

#Install Octoprint, ffmpeg, and cura engine
COPY --from=compiler /opt/venv /opt/venv
COPY --from=cura-compiler /opt/build /opt/cura

RUN chown -R octoprint:octoprint /opt/venv
ENV PATH="/opt/venv/bin:/opt/ffmpeg:/opt/cura:$PATH"

EXPOSE 5000
COPY docker-entrypoint.sh /usr/local/bin/
USER octoprint
VOLUME /home/octoprint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["octoprint", "serve"]
