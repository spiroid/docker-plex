# docker-plex

## Description

[Docker](http://docker.io) image for [Plex Media Server](http://www.plexapp.com/). It is a fork of [@aostanin](https://github.com/aostanin/) [docker-plex](https://github.com/aostanin/docker-plex) repository, with some updates.

The main changes are:
 * Debian as base image instead of ubuntu
 * Install directory in the container located in /usr/local/share/plex
 * Add an environment variable `PLEX_HOME` that points to the plex main directory


Please check the git log for more details.

This repository comes with a Dockerfile to set up the image.


## Getting stared

### Requirements
 * [Git](http://git-scm.com/)
 * [Docker](http://docker.io)

### Get the source code
```
  $ git clone git@github.com:spiroid/docker-plex.git
  $ cd docker-plex
```

## Usage

### Building

Build the image with `docker build -t <your pseudo>/plex .` in this directory.

replace `<your pseudo>` by a prefix you want to appear in your local docker image registry.


### Running

Plex depends on Avahi and it's own GDM network discovery protocol to work so while there may be ways around this, the easiest way is probably to run the container on the same subnet as your LAN.

Since Docker is currently quite inflexible in its network setup, I personally resort to some ugly hacks to get around this. You might have better luck using something like [Pipework](http://github.com/jpetazzo/pipework) to set up networking.

#### Set Up a Bridge on the Host

I used Ubuntu's [KVM networking guide](http://help.ubuntu.com/community/KVM/Networking) to create a `br0` interface which is bridged to `eth0` and uses DHCP. If you want a similar setup, add the following to `/etc/network/interfaces`:

```
auto br0
iface br0 inet dhcp
  bridge_ports eth0
  bridge_stp off
  bridge_fd 0
  bridge_maxwait 0
```

Now just restart networking (`service networking restart`) or reboot.

#### Running the Container Using the Bridge

Docker allows you to overwrite the container's LXC configuration using `-lxc-conf`. While this is an ugly hack, I took advantage of it to set up networking manually in the container. I completely disabled Docker's network management on the container with `-n=false`. The container stores all the Plex configuration in the `/config` directory, so it may be a good idea to create a bind mount with the host with `-v` for persistent storage.

#### Example

The following starts the plex container with:

- The host's `/srv/media/videos` mounted inside the container's `/srv/videos`
- The host's `/srv/media/music` mounted inside the container's `/srv/music`
- The host's `/home/spiroid/config/plex` mounted inside the container's `/usr/local/share/plex` for persistent configuration storage.
- No network management from docker (`-n=false`)
- Bridged networking using the `br0` bridge with an IP address of `192.168.1.10` and gateway of `192.168.1.1`

```
docker run -d -n=false \
  -v /srv/media/videos:/srv/videos \
  -v /srv/media/music:/srv/music \
  -v /home/spiroid/config/plex:/usr/local/share/plex \
  -lxc-conf="lxc.network.type = veth" \
  -lxc-conf="lxc.network.flags = up" \
  -lxc-conf="lxc.network.link = br0" \
  -lxc-conf="lxc.network.ipv4 = 192.168.1.10" \
  -lxc-conf="lxc.network.ipv4.gateway=192.168.1.1" \
  <your pseudo>/plex
```

Now just navigate to `http://192.168.1.10:32400/web/` to set up Plex.
