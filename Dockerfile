FROM resin/rpi-raspbian:jessie-20160831

RUN apt-get update && \
	apt-get -qy install \
        alsa-utils \
        bison \
        build-essential \
        flex \
        git \
        icecast2 \
        libasound2-dev \
        libjack-jackd2-0 \
        libmp3lame0 \
        libpulse0 \
        libsamplerate0 \
        libsndfile1-dev \
        libtwolame0 \
        make \
        supervisor

COPY deb-pkg /deb-pkg

RUN dpkg -i /deb-pkg/darkice_1.2.0.2~mp3+1_armhf.deb

RUN git clone https://github.com/ccrma/chuck.git
RUN cd chuck/src && make linux-alsa && sudo make install && cd -

RUN git clone https://github.com/ccrma/chugins.git
RUN cd chugins && make linux-alsa && sudo make install && cd -

RUN git clone https://github.com/concrete-mixer/concrete-mixer.git
RUN cd /concrete-mixer && git checkout soundcloud-poc

COPY conf/darkice.cfg /etc/darkice.cfg
COPY conf/icecast.xml /etc/icecast2/
RUN chown icecast2:icecast /etc/icecast2/icecast.xml

COPY conf/concrete.conf /concrete-mixer/concrete.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


RUN mkdir -p /var/log/supervisor

EXPOSE 8000

RUN useradd -ms /bin/bash cmuser && addgroup cmuser audio

CMD ["/usr/bin/supervisord"]
