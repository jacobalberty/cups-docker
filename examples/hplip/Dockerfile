FROM jacobalberty/cups:latest

ARG DEBIAN_FRONTEND=noninteractive

ARG HPLIP_VERSION=3.17.10

ARG BUILD_DEPS="\
    build-essential \
    curl \
    libdbus-1-dev \
    libjpeg62-turbo-dev \
    libsnmp-dev \
    libssl-dev \
    libusb-1.0-0-dev \
    python-dev"
# && equivs-build dbus \

RUN apt-get update \
 && apt-get -qy install ${BUILD_DEPS} \
    avahi-daemon \
    dbus \
    libsnmp30 \
    libusb-1.0-0 \
    python \
    python-dbus \
    python-gobject \
    wget \
 && mkdir -p /home/source/hplip \
 && cd /home/source/hplip \
 && curl -L -o hplip.tar.gz \
    "https://sourceforge.net/projects/hplip/files/hplip/${HPLIP_VERSION}/hplip-${HPLIP_VERSION}.tar.gz/download" \
 && cd /home/source/hplip \
 && tar --strip=1 -xf hplip.tar.gz \
 && PYTHON="$(which python)" \
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
    --disable-qt5 \
 && make -j$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)\
 && make install \
 && cd / \
 && apt-get -qy purge --auto-remove ${BUILD_DEPS} \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /home/source
#     --enable-policykit \
