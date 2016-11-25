# Start with Ubuntu base image
# Based off of https://git.corp.adobe.com/yumer/DockerFiles

FROM ubuntu

MAINTAINER Michael Wilber <wilber@adobe.com>

RUN apt-get update
RUN apt-get install -y nodejs npm libncurses5-dev nodejs-legacy

RUN useradd ifbot \
    --home /home/ifbot \
    --create-home \
    --shell /usr/bin/bash
ADD . /home/ifbot/
RUN chown -R ifbot /home/ifbot/
USER ifbot
WORKDIR /home/ifbot

RUN npm install .
RUN tar xf bocfel-0.6.3.2.tar.gz
RUN cd bocfel-0.6.3.2; make GLK=

CMD /home/ifbot/bin/hubot -a slack

#ADD dotfiles.tar /home/wilber/
#ENV HOME=/home/wilber
#RUN /home/wilber/.dotfiles/propagate
#VOLUME /home/wilber/share
#WORKDIR /home/wilber
