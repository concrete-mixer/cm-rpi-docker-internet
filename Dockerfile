FROM resin/rpi-raspbian:jessie-20160831

RUN apt-get update && \
	apt-get -qy install \
        alsa-utils \
        bison \
        build-essential \
	curl \
        flex \
        git \
        icecast2 \
        libasound2-dev \
	libav-tools \
        libjack-jackd2-0 \
        libmp3lame0 \
        libpulse0 \
        libsamplerate0 \
        libsndfile1-dev \
        libtwolame0 \
        make \
	nginx \
	python-dev \
	python-pip \
	python-virtualenv\
        supervisor

# Install darkice from custom binary
COPY deb-pkg /deb-pkg

RUN dpkg -i /deb-pkg/darkice_1.2.0.2~mp3+1_armhf.deb

# Install chuck and chugins
RUN git clone https://github.com/ccrma/chuck.git
RUN cd chuck/src && make linux-alsa && sudo make install && cd -

RUN git clone https://github.com/ccrma/chugins.git
RUN cd chugins && make linux-alsa && sudo make install && cd -

# Install Concrete Mixer
RUN git clone https://github.com/concrete-mixer/concrete-mixer.git

# Install CMR node info

## Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo bash -

RUN apt-get install nodejs -y

## Install libs
RUN git clone https://github.com/concrete-mixer/cmr-node-info.git
RUN cd /cmr-node-info && npm install

# Set up configs
RUN rm -v /etc/nginx/nginx.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY conf/darkice.cfg /etc/darkice.cfg
COPY conf/icecast.xml /etc/icecast2/

RUN chown icecast2:icecast /etc/icecast2/icecast.xml

COPY conf/concrete.conf /concrete-mixer/concrete.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create logging directory for supervisord
RUN mkdir -p /var/log/supervisor

EXPOSE 80
EXPOSE 8000
EXPOSE 2424
EXPOSE 2718
EXPOSE 9999

RUN useradd -ms /bin/bash cmuser && addgroup cmuser audio

# RUN cd /concrete-mixer && pip install -r requirements.txt

CMD ["/usr/bin/supervisord"]
