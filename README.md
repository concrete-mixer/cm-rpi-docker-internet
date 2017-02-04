# Concrète Mixer internet radio Docker image

This repo contains files for a [Docker](https://www.docker.com/) image that runs:
- [Concrète Mixer](https://github.com/concrete-mixer/concrete-mixer) - an ambient sound file mixing audio app
- [Darkice](http://www.darkice.org)
- [Icecast](https://icecast.org)

The image is intended to run on a [Raspberry Pi](https://www.raspberrypi.org/) to provide a closet-based internet radio station.

# Prerequisites

A Raspberry Pi, preferably a model 3, preferably running Raspbian (though I _think_ any Linux with systemd should be fine), definitely running Docker. An internet connection is also a must.

# Installation

## Install snd-aloop module

The Docker container makes use of the ALSA snd-aloop module. Concrete Mixer directs sends its output to device Loopback,0 while Darkice listens for the output on Loopback,1. To set up snd-aloop to load on boot, run:

    sudo -i
    echo snd-aloop >> /etc/modules
    reboot

When the pi reboots, run `aplay -l` and in the sound hardware components listed you should see:

    card 0: Loopback [Loopback], device 0: Loopback PCM [Loopback PCM]
      Subdevices: 8/8
      ...
    card 0: Loopback [Loopback], device 1: Loopback PCM [Loopback PCM]
      Subdevices: 8/8
      ...

## Installing the docker image

With Docker installed on your pi, run:

    docker run -d --device=/dev/snd:/dev/snd -p 8000:8000 concretemixer/cm-rpi-internet:latest

Docker will download the image from dockerhub and build and run a new container.

All going well, at the end of the process you should hear Concrète Mixer playing on __http://{your Pi's ip address}:8000/concrete-mixer.mp3__.

## Setting the docker container to load on boot

To do this:

1. Copy the contents of [this file](https://raw.githubusercontent.com/concrete-mixer/cm-rpi-docker-internet/master/docker-concrete_mixer_internet.service) to `/etc/systemd/system/`:

2. Restart systemd so the new file is detected:

    `systemctl daemon-reload`

3. Enable the service:

    `systemctl enable docker-concrete_mixer_internet.service`

4. Reboot the pi, and the Concrète Mixer service should start automatically.

# Security

The conf/icecast2.xml file provides a default username and password. If you ever expose your Pi to the internet you should rebuild the docker image and specify secure credentials for all connections (including those used by darkice).

# See also

[An Concrète Mixer docker image that outputs audio thru the Pi's sound card](https://github.com/concrete-mixer/cm-rpi-docker-dac)
