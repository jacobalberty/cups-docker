#!/usr/bin/env bash
# This script pulls and installs the specified version of the Foomatic filter and db engine
#
# Supported variables
# `FOOMATIC_FILTERS_VERSION` (Default: 4.0.17) - Version of foomatic-filters to install
# `FOOMATIC_DB_ENGINE_VERSION` (Default: 4.0.13) - Version of foomatic-db-engine to install
# `cleanup` (Default: true) - Remove build dependencies and source dir

FOOMATIC_FILTERS_VERSION="${FOOMATIC_FILTERS_VERSION:-4.0.17}"
FOOMATIC_DB_ENGINE_VERSION="${FOOMATIC_DB_ENGINE_VERSION:-4.0.13}"

CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)

BUILD_DEPS="\
    build-essential \
    curl \
    file \
    libdbus-1-dev \
    libxml2-dev \
    "

DEPS="\
    dbus \
    libxml2 \
    "


apt-get update
apt-get -qy install ${BUILD_DEPS} ${DEPS}

mkdir -p /home/source/foomatic
cd /home/source/foomatic
curl -L -o foomatic-filters.tar.gz \
    "http://www.openprinting.org/download/foomatic/foomatic-filters-${FOOMATIC_FILTERS_VERSION}.tar.gz"
curl -L -o foomatic-db-engine.tar.gz \
    "http://www.openprinting.org/download/foomatic/foomatic-db-engine-${FOOMATIC_DB_ENGINE_VERSION}.tar.gz"

mkdir -p /home/source/foomatic/filters

cd /home/source/foomatic/filters
tar --strip=1 -xf ../foomatic-filters.tar.gz
./configure
make -j${CPUC}
make install

mkdir -p /home/source/foomatic/db-engine

cd /home/source/foomatic/db-engine
tar --strip=1 -xf ../foomatic-db-engine.tar.gz
./configure
make -j${CPUC}
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

