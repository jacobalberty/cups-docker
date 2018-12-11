#!/usr/bin/env bash
source ${PREFIX}/functions

if ( ! isInst foomatic-db-engine ); then
    echo "This script requires foomatic-db-engine installed first"
    exit
fi
if (isInst foomatic-db && isInst foomatic-db-nonfree); then
    echo "foomatic-db and foomatic-db-nonfree are already installed"
    exit
fi

BUILD_DEPS="\
    curl \
    equivs \
    make \
    xz-utils \
    "

DEPS="\
    "


apt-get update
apt-get -qy install ${BUILD_DEPS} ${DEPS}

mkdir -p /home/source/foomatic
cd /home/source/foomatic

if ( ! isInst foomatic-db ); then
    mkdir -p /home/source/foomatic/db

    cd /home/source/foomatic/db
    curl -L -o foomatic-db.tar.xz \
        "http://www.openprinting.org/download/foomatic/foomatic-db-4.0-current.tar.xz"
    tar --strip=1 -xf foomatic-db.tar.xz
    ./configure
    make install
    fakePkg foomatic-db 4.0
fi

if ( ! isInst foomatic-db-nonfree ); then
    mkdir -p /home/source/foomatic/db-nonfree

    cd /home/source/foomatic/db-nonfree
    curl -L -o foomatic-db-nonfree.tar.gz \
        "http://www.openprinting.org/download/foomatic/foomatic-db-nonfree-current.tar.gz"
    tar --strip=1 -xf foomatic-db-nonfree.tar.gz
    ./configure
    make install
    fakePkg foomatic-db-nonfree 4.0
fi

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
