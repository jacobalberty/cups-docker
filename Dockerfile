FROM debian:stretch-slim
MAINTAINER Jacob Alberty <jacob.alberty@foundigital.com>

ARG DEBIAN_FRONTEND=noninteractive
ARG CUPS_VERSION=2.2.6
ARG FILTERS_VERSION=1.17.9

ENV PREFIX=/usr/local/docker
ENV VOLUME=/config

COPY patches /home/patches

ADD build.sh ./build.sh

RUN chmod +x ./build.sh && \
    sync && \
    ./build.sh && \
    rm -f ./build.sh

VOLUME ["/config"]

EXPOSE 631/tcp 631/udp

ADD docker-entrypoint.sh ${PREFIX}/bin/docker-entrypoint.sh
ADD drivers ${PREFIX}/share/drivers
RUN chmod +x \
    ${PREFIX}/bin/docker-entrypoint.sh \
    ${PREFIX}/share/drivers/*.sh


ENTRYPOINT ${PREFIX}/bin/docker-entrypoint.sh /usr/sbin/cupsd -f
