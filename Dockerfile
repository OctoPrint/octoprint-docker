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
FROM python:3.8-slim-buster AS cura-compiler

RUN apt install -y g++ make

RUN mkdir -p /opt/cura/build
WORKDIR /opt/cura
COPY --from=deps /opt/cura .
RUN make

# build ocotprint
FROM python:3.8-slim-buster AS compiler
EXPOSE 5000
LABEL maintainer badsmoke "dockerhub@badcloud.eu"

ENV CURA_VERSION=15.04.6
ARG tag=master

WORKDIR /opt/octoprint


#install necessary packages
RUN apt install wget git xz-utils g++ make -y
RUN rm -rf /var/lib/apt/lists/*

#install venv            
RUN pip install virtualenv

#install ffmpeg
RUN cd /tmp \
  && wget -O ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-i686-static.tar.xz \
	&& mkdir -p /opt/ffmpeg \
	&& tar xvf ffmpeg.tar.xz -C /opt/ffmpeg --strip-components=1 \
  && rm -Rf /tmp/*

FROM python:3.8-slim-buster
#Create an octoprint user
RUN useradd -ms /bin/bash octoprint && adduser octoprint dialout
RUN chown octoprint:octoprint /opt/octoprint
USER octoprint
#This fixes issues with the volume command setting wrong permissions
RUN mkdir /home/octoprint/.octoprint
#Install Octoprint
RUN git clone --branch $tag https://github.com/foosel/OctoPrint.git /opt/octoprint \
  && virtualenv venv \
	&& ./venv/bin/python setup.py install
VOLUME /home/octoprint/.octoprint


CMD ["/opt/octoprint/venv/bin/octoprint", "serve"]
