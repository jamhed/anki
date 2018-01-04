FROM debian:stretch
MAINTAINER Roman Galeev <jamhedd@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV APT_LISTCHANGES_FRONTEND=none

RUN apt-get -y update \
	&& apt-get -y install libjson-perl libdbi-perl libdbd-sqlite3-perl libwww-perl liburi-perl liblwp-protocol-https-perl git locales \
	&& echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
	&& locale-gen \
	&& useradd -s /bin/bash -m user

USER user
WORKDIR /home/user

RUN git clone https://github.com/jamhed/anki.git

ENV PERLLIB lib
ENV LANG en_US.UTF-8

WORKDIR /home/user/anki

ARG google_login
ARG google_password
ARG anki_login
ARG anki_password

RUN bin/make-cfg.pl $google_login $google_password $anki_login $anki_password > config.json

