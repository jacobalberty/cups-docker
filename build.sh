#!/bin/bash
set -e
CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)
CUPSURL=https://github.com/apple/cups/releases/download/v${CUPS_VERSION}/cups-${CUPS_VERSION}-source.tar.gz

apt-get update
apt-get install -qy --no-install-recommends \
    ca-certificates \
    curl \
    g++ \
    gcc \
    make
mkdir -p /home/cups
cd /home/cups
curl -o cups-source.tar.gz -L \
    "${CUPSURL}"
tar --strip=1 -xf cups-source.tar.gz
./configure \
    --prefix=${PREFIX}/ \
    --sysconfdir=/config
make -j${CPUC}
make install
cd /
rm -rf /home/cups
apt-get purge -qy --auto-remove \
    bzip2 \
    ca-certificates \
    curl \
    g++ \
    gcc \
    make
rm -rf /var/lib/apt/lists/*

