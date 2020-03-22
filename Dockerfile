ARG PYTHON_IMAGE_TAG=2.7-slim-buster

FROM python:${PYTHON_IMAGE_TAG} AS cura-compiler

RUN apt update && apt install g++ make
RUN curl -fsSLO https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && mkdir -p /opt \
  && tar -xzf ${CURA_VERSION}.tar.gz --strip-components=1 -C /opt --no-same-owner
RUN make

# build ocotprint
FROM python:${PYTHON_IMAGE_TAG} AS compiler

ARG tag
ENV tag ${tag:-master}

RUN apt update && apt install make g++

RUN	curl -fsSLO --compressed https://github.com/foosel/OctoPrint/archive/${tag}.tar.gz \
	&& mkdir -p /opt \
  && tar xzf ${tag}.tar.gz --strip-components 1 -C /opt --no-same-owner

#install venv            
RUN pip install virtualenv
RUN python -m virtualenv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY --from=deps /var/opt/octoprint .
RUN python setup.py install


FROM python:${PYTHON_IMAGE_TAG} AS build
LABEL maintainer badsmoke "dockerhub@badcloud.eu"

RUN groupadd --gid 1000 octoprint \
  && useradd --uid 1000 --gid octoprint --shell /bin/bash --create-home octoprint

# Install cura engine
COPY --from=deps /opt/ffmpeg /opt/ffmpeg

# Install ffmpeg
RUN mkdir /opt/ffmpeg \
	&& curl -L https://johnvansicle.com/ffmpeg/releases/ffmpeg-release-i686-static.tar.xz \
	| tar zx --strip 1 -C /opt/ffmpeg

#Install Octoprint
RUN mkdir /opt/octoprint
WORKDIR /opt/octoprint
COPY --from=compiler /opt/venv /opt/octoprint
ENV PATH="/opt/octoprint:$PATH"

EXPOSE 5000
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["octoprint", "serve"]
