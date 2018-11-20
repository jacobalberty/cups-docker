FROM debian:stretch-slim
MAINTAINER Jacob Alberty <jacob.alberty@foundigital.com>

ARG DEBIAN_FRONTEND=noninteractive
ARG CUPS_VERSION=2.3b5
ARG FILTERS_VERSION=1.21.3
ARG QPDF_VERSION=8.2.1

ENV PREFIX=/usr/local/docker
ENV VOLUME=/config

COPY patches /home/patches

ADD build.sh ./build.sh
ADD fakePkg.sh ${PREFIX}/bin/fakePkg.sh

RUN chmod +x ./build.sh ${PREFIX}/bin/fakePkg.sh && \
    sync && \
    ./build.sh && \
    rm -f ./build.sh

VOLUME ["/config"]

EXPOSE 631/tcp 631/udp

ADD docker-entrypoint.sh ${PREFIX}/bin/docker-entrypoint.sh
ADD docker-healthcheck.sh ${PREFIX}/bin/docker-healthcheck.sh
ADD drivers ${PREFIX}/share/drivers
RUN chmod +x \
    ${PREFIX}/bin/docker-entrypoint.sh \
    ${PREFIX}/bin/docker-healthcheck.sh \
    ${PREFIX}/share/drivers/*.sh

HEALTHCHECK CMD ${PREFIX}/bin/docker-healthcheck.sh

ENTRYPOINT ${PREFIX}/bin/docker-entrypoint.sh /usr/sbin/cupsd -f
