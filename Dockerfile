ARG PYTHON_IMAGE_TAG=2.7-slim-buster

FROM buildpack-deps:curl AS ffmpeg
RUN apt update && apt install -y xz-utils
RUN curl -fsSLO https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-i686-static.tar.xz \
  && mkdir -p /opt \
  && tar -xJf ffmpeg-release-i686-static.tar.xz --strip-components=1 -C /opt


FROM python:${PYTHON_IMAGE_TAG} AS cura-compiler

ARG CURA_VERSION
ENV CURA_VERSION ${CURA_VERSION:-15.04.6}

RUN apt update && apt install -y g++ make curl
RUN curl -fsSLO https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
  && mkdir -p /opt \
  && tar -xzf ${CURA_VERSION}.tar.gz --strip-components=1 -C /opt --no-same-owner
WORKDIR /opt
RUN make

# build ocotprint
FROM python:${PYTHON_IMAGE_TAG} AS compiler

ARG tag
ENV tag ${tag:-master}

RUN apt update && apt install -y make g++ curl

RUN	curl -fsSLO --compressed https://github.com/foosel/OctoPrint/archive/${tag}.tar.gz \
	&& mkdir -p /opt \
  && tar xzf ${tag}.tar.gz --strip-components 1 -C /opt --no-same-owner

#install venv            
RUN pip install virtualenv
RUN python -m virtualenv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /opt
RUN python setup.py install


FROM python:${PYTHON_IMAGE_TAG} AS build
LABEL maintainer badsmoke "dockerhub@badcloud.eu"

RUN groupadd --gid 1000 octoprint \
  && useradd --uid 1000 --gid octoprint --shell /bin/bash --create-home octoprint


#Install Octoprint, ffmpeg, and cura engine
COPY --from=compiler /opt/venv /opt/octoprint
COPY --from=ffmpeg /opt /opt/ffmpeg
COPY --from=cura-compiler /opt /opt/cura

# symlink packages to path
#RUN ln -s /opt/cura /usr/local/bin/cura
EXPOSE 5000
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["octoprint", "serve"]
