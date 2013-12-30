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
RUN apt-get install -y curl


# Add plex repository information and update apt cache
RUN echo "deb http://shell.ninthgate.se/packages/debian wheezy main" > /etc/apt/sources.list.d/plexmediaserver.list
RUN curl http://shell.ninthgate.se/packages/shell-ninthgate-se-keyring.key | apt-key add -
RUN apt-get -y update


# Install plex media server
ENV PLEX_HOME /usr/local/share/plex
RUN apt-get install -y plexmediaserver


# Create configuration directory
RUN mkdir -p $PLEX_HOME
ADD start.sh $PLEX_HOME/start.sh


# Command to launch when container is started
ENTRYPOINT ["/usr/local/share/plex/start.sh"]
