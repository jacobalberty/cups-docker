#!/bin/bash
set -e
SOURCEDIR=/home/source
PATH=${PATH}:${PREFIX}/bin
CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)
CUPSURL=https://github.com/apple/cups/releases/download/v${CUPS_VERSION}/cups-${CUPS_VERSION}-source.tar.gz
FILTERSURL=http://openprinting.org/download/cups-filters/cups-filters-${FILTERS_VERSION}.tar.gz

fakePkg() {
    pkg="${1}"
    ver="${2}"
    tmpdir=$(mktemp -d)
    cwd=$(pwd)
    cd "${tmpdir}"
cat > "${pkg}" << EOF
Section: misc
Priority: optional
Standards-Version: 3.9.2

Package: ${pkg}
Version: ${ver}
Maintainer: Jacob Alberty <jacob.alberty@foundigital.com>
Architecture: all
Description: Blocking ${pkg} dependency
EOF
    equivs-build ${pkg}
    dpkg -i *.deb
    cd "${cwd}"
    rm -rf "${tmpdir}"
}


apt-get update
apt-get install -qy --no-install-recommends equivs
fakePkg "cups" "${CUPS_VERSION}"
fakePkg "libcups2" "${CUPS_VERSION}"
fakePkg "libcupsimage2" "${CUPS_VERSION}"
fakePkg "cups-filters" "${FILTERS_VERSION}"
fakePkg "libcupsfilters1" "${FILTERS_VERSION}"
apt-get purge -qy --auto-remove equivs
apt-get install -qy --no-install-recommends \
    ca-certificates \
    curl \
    g++ \
    gcc \
    libavahi-client-dev \
    libavahi-glib-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libijs-dev \
    libjpeg62-turbo-dev \
    liblcms2-dev \
    libpng-dev \
    libpoppler-cpp-dev \
    libpoppler-dev \
    libpoppler-private-dev \
    libqpdf-dev \
    libtiff5-dev \
    make \
    pkg-config
apt-get install -qy --no-install-recommends \
    ghostscript \
    libavahi-client3 \
    libavahi-glib1 \
    libfontconfig1 \
    libfreetype6 \
    libijs-0.35 \
    libjpeg62-turbo \
    liblcms2-2 \
    libpng16-16 \
    libpoppler64 \
    libpoppler-cpp0v5 \
    libqpdf17 \
    libtiff5 \
    mupdf-tools \
    poppler-utils
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"
mkdir -p cups
cd cups
curl -o cups-source.tar.gz -L \
    "${CUPSURL}"
tar --strip=1 -xf cups-source.tar.gz
./configure \
    --prefix=${PREFIX}/ \
    --sysconfdir=/config
make -j${CPUC}
make install
echo ${PREFIX}/lib/ > /etc/ld.so.conf.d/cups.conf
ldconfig
cd "${SOURCEDIR}"
mkdir -p filters
cd filters
curl -o filters-source.tar.gz -l "${FILTERSURL}"
tar --strip=1 -xf filters-source.tar.gz
CFLAGS=-I/usr/local/cups/include LDFLAGS=-L/usr/local/cups/lib ./configure --prefix=${PREFIX}
make -j${CPUC}
make install
cd /
rm -rf "${SOURCEDIR}"
apt-get purge -qy --auto-remove \
    ca-certificates \
    curl \
    equivs \
    g++ \
    gcc \
    libavahi-client-dev \
    libavahi-glib-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libijs-dev \
    libjpeg62-turbo-dev \
    liblcms2-dev \
    libpng-dev \
    libpoppler-cpp-dev \
    libpoppler-dev \
    libpoppler-private-dev \
    libqpdf-dev \
    libtiff5-dev \
    make \
    pkg-config
rm -rf /var/lib/apt/lists/*

echo /usr/local/cups/lib/ > /etc/ld.so.conf.d/cups.conf
ldconfig
