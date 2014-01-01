FROM tianon/debian:jessie

MAINTAINER Jonathan Dray <jonathan.dray+docker@gmail.com>


# Debian update package information
ENV DEBIAN_FRONTEND noninteractive
RUN sed -i 's/ftp.us/ftp.fr/g' /etc/apt/sources.list
RUN apt-get -y update


# System locales configuration
RUN apt-get install -y --no-install-recommends locales
RUN echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
ENV LANG fr_FR.UTF-8


# Install requirements
RUN apt-get install -y --no-install-recommends curl wget


# Install network utilities
RUN apt-get install -y --no-install-recommends net-tools iputils-ping iptables


# Install pipework
RUN cd /usr/local/bin &&\
    wget --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework &&\
    chmod +x pipework


# Add plex repository information and update apt cache
RUN echo "deb http://shell.ninthgate.se/packages/debian wheezy main" > /etc/apt/sources.list.d/plexmediaserver.list
RUN curl http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | apt-key add -
RUN apt-get -y update


# Install plex media server
ENV PLEX_HOME /usr/local/share/plex
RUN apt-get install -y plexmediaserver


# Create configuration directory
RUN mkdir -p $PLEX_HOME
ADD resources/usr/local/bin/pms.sh /usr/local/bin/pms.sh


# Command to launch when container is started
CMD \
    echo Setting up iptables... &&\
    iptables -t nat -A POSTROUTING -j MASQUERADE &&\
    echo Waiting for pipework to give us the eth1 interface... &&\
    pipework --wait &&\
    echo Starting Plex Media Server &&\
    /usr/local/bin/pms.sh
