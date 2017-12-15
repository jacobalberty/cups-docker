#!/usr/bin/env bash
# This script pulls and installs the specified version of the HPLIP drivers for cups
# While this script does install HPLIP, it is not ready for use yet as you must still run the
# `hp-plugin` script manually. This script installs a propriatary binary blob for the drivers
# and requires accepting a license agreement so it can not be automated.
#
# Supported variables
# `HPLIP_VERSION` (Default: 3.17.10) - Version of HPLIP to install
# `cleanup` (Default: true) - Remove build dependencies and source dir
#
# TODO: Optionally detect if HPLIP is already installed and refuse to install a second time

# Current version at this time is 3.17.11
HPLIP_VERSION="${HPLIP_VERSION:-3.17.11}"

BUILD_DEPS="\
    build-essential \
    curl \
    gawk \
    libdbus-1-dev \
    libjpeg62-turbo-dev \
    libsnmp-dev \
    libssl-dev \
    libusb-1.0-0-dev \
    python-dev"

DEPS="\
    avahi-daemon \
    dbus \
    libsnmp30 \
    libusb-1.0-0 \
    python \
    python-dbus \
    python-gobject \
    wget"


apt-get update
apt-get -qy install ${BUILD_DEPS} ${DEPS}

mkdir -p /home/source/hplip
cd /home/source/hplip
curl -L -o hplip.tar.gz \
    "https://sourceforge.net/projects/hplip/files/hplip/${HPLIP_VERSION}/hplip-${HPLIP_VERSION}.tar.gz/download"

cd /home/source/hplip
tar --strip=1 -xf hplip.tar.gz
PYTHON="$(which python)" \
    HPLIP_PPD_PATH=/usr/share/ppd \
    ./configure \
    --prefix=/usr \
    --config-cache \
    --with-cupsbackenddir=$(cups-config --serverbin)/backend \
    --with-cupsfilterdir=$(cups-config --serverbin)/filter \
    --docdir=/usr/share/doc/hplip \
    --with-docdir=/usr/share/doc/hplip \
    --with-htmldir=/usr/share/doc/hplip-doc \
    --disable-foomatic-rip-hplip-install \
    --with-drvdir=/usr/share/cups/drv \
    --with-hpppddir=/usr/share/ppd/hplip/HP \
    --datadir=/usr/share \
    --without-icondir \
    --enable-hpcups-install \
    --enable-cups-drv-install \
    --disable-hpijs-install \
    --disable-foomatic-drv-install \
    --disable-foomatic-ppd-install \
    --enable-network-build \
    --disable-scan-build \
    --disable-gui-build \
    --disable-fax-build \
    --disable-qt3 \
    --disable-qt4 \
    --disable-qt5

make -j$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)
make install

if [ "${cleanup:-true}" = true ]; then
    cd /
    apt-get -qy purge --auto-remove ${BUILD_DEPS}
    rm -rf /home/source
else
    echo "BUILD_DEPS_HPLIP=\"${BUILD_DEPS}\"" > /home/source/hplip.deps
    echo "DEPS_HPLIP=\"${DEPS}\"" >> /home/source/hplip.deps
fi
rm -rf /var/lib/apt/lists/*

