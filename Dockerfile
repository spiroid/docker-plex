FROM ubuntu:precise

RUN apt-get update

RUN apt-get install -y language-pack-en
ENV LANG en_US.UTF-8

RUN apt-get install -y curl

RUN echo "deb http://plex.r.worldssl.net/PlexMediaServer/ubuntu-repo lucid main" >> /etc/apt/sources.list
RUN curl http://plexapp.com/plex_pub_key.pub | apt-key add -
RUN apt-get update

RUN apt-get install -y plexmediaserver
RUN mkdir -p /config

ADD start.sh /start.sh

#EXPOSE 32400

ENTRYPOINT ["/start.sh"]
