FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG CUPS_VERSION=2.4.14
ARG LIBPPD_VERSION=2.1.1
ARG LIBCUPSFILTERS_VERSION=2.1.1
ARG FILTERS_VERSION=2.0.1
ARG QPDF_VERSION=12.2.0

ENV PREFIX=/usr/local/docker
ENV VOLUME=/config

COPY patches /home/patches

COPY build.sh ./build.sh
COPY fakePkg.sh ${PREFIX}/bin/fakePkg.sh
COPY docker-entrypoint.sh ${PREFIX}/bin/docker-entrypoint.sh
COPY docker-healthcheck.sh ${PREFIX}/bin/docker-healthcheck.sh
COPY drivers ${PREFIX}/share/drivers
COPY functions ${PREFIX}/functions
COPY pre_build /usr/local/docker/pre_build
RUN chmod +x \
    ${PREFIX}/bin/docker-entrypoint.sh \
    ${PREFIX}/bin/docker-healthcheck.sh \
    ${PREFIX}/share/drivers/*.sh \
    ${PREFIX}/functions \
 && chmod -R +x /usr/local/docker/pre_build

RUN chmod +x ./build.sh ${PREFIX}/bin/fakePkg.sh && \
    sync && \
    ./build.sh && \
    rm -f ./build.sh

VOLUME ["/config"]

EXPOSE 631/tcp 631/udp


HEALTHCHECK CMD ${PREFIX}/bin/docker-healthcheck.sh

ENTRYPOINT ["/usr/local/docker/bin/docker-entrypoint.sh", "/usr/sbin/cupsd", "-f"]
