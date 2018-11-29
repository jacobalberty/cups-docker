#!/usr/bin/env bash

CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)

BUILD_DEPS="\
    curl \
    make \
    xz-utils \
    "

DEPS="\
    "


apt-get update
apt-get -qy install ${BUILD_DEPS} ${DEPS}

mkdir -p /home/source/foomatic
cd /home/source/foomatic
curl -L -o foomatic-db.tar.xz \
    "http://www.openprinting.org/download/foomatic/foomatic-db-4.0-current.tar.xz"
curl -L -o foomatic-db-nonfree.tar.gz \
    "http://www.openprinting.org/download/foomatic/foomatic-db-nonfree-current.tar.gz"

mkdir -p /home/source/foomatic/db

cd /home/source/foomatic/db
tar --strip=1 -xf ../foomatic-db.tar.xz
./configure
make install

mkdir -p /home/source/foomatic/db-nonfree

cd /home/source/foomatic/db-nonfree
tar --strip=1 -xf ../foomatic-db-nonfree.tar.gz
./configure
make install


cd /home/source/foomatic

if [ "${cleanup:-true}" = true ]; then
    cd /
    apt-get -qy purge --auto-remove ${BUILD_DEPS}
    rm -rf /home/source
else
    echo "BUILD_DEPS_FOOMATIC=\"${BUILD_DEPS}\"" > /home/source/foomatic.deps
    echo "DEPS_FOOMATIC=\"${DEPS}\"" >> /home/source/foomatic.deps
fi
rm -rf /var/lib/apt/lists/*

