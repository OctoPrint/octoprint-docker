FROM curlimages/curl AS deps 

ARG CURA_VERSION
ENV CURA_VERSION ${CURA_VERSION:-15.04.6}
ARG tag
ENV tag ${tag:-master}

RUN mkdir -p /var/opt/octoprint \
	&& curl -L https://github.com/foosel/OctoPrint/archive/${VERSION}.tar.gz \
	| tar zx --strip 1 -C /var/opt/octoprint

RUN mkdir /opt/ffmpeg \
	&& curl -L https://johnvansicle.com/ffmpeg/releases/ffmpeg-release-i686-static.tar.xz \
	| tar zx --strip 1 -C /opt/ffmpeg

RUN mkdir /opt/cura \
	&& curl -L https://github.com/Ultimaker/CuraEngine/archive/${CURA_VERSION}.tar.gz \
	| tar zx --strip 1 -C /opt/cura


# build cura engine
FROM python:slim AS cura-compiler

RUN mkdir -p /opt/cura/build
WORKDIR /opt/cura
COPY --from=deps /opt/cura .
RUN make

# build ocotprint
FROM python:2.7-slim AS compiler

#install venv            
RUN pip install virtualenv


FROM python:2.7-slim
LABEL maintainer badsmoke "dockerhub@badcloud.eu"
# Install cura engine and ffmpeg
COPY --from=deps /opt/ffmpeg /opt/ffmpeg
COPY --from=cura-compiler /opt/cura/build /opt/cura

#Install Octoprint


EXPOSE 5000
CMD ["/opt/octoprint/venv/bin/octoprint", "serve"]
