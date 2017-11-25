#!/bin/bash
set -e
SOURCEDIR=/home/source
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

BUILD_DEPS="
    curl \
    dpkg-dev \
    g++ \
    gcc \
    libavahi-client-dev \
    libavahi-glib-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libgnutls28-dev\
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
    pkg-config"

groupadd lpadmin
apt-get update
apt-get install -qy --no-install-recommends equivs
fakePkg "cups" "${CUPS_VERSION}"
fakePkg "libcups2" "${CUPS_VERSION}"
fakePkg "libcupsimage2" "${CUPS_VERSION}"
fakePkg "cups-filters" "${FILTERS_VERSION}"
fakePkg "libcupsfilters1" "${FILTERS_VERSION}"
apt-get install -qy --no-install-recommends ${BUILD_DEPS} \
    ca-certificates \
    ghostscript \
    libavahi-client3 \
    libavahi-glib1 \
    libfontconfig1 \
    libfreetype6 \
    libgnutls-openssl27 \
    libgnutlsxx28 \
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
    --sysconfdir=/config \
    --with-docdir=/usr/share/cups/doc-root \
    --localedir=/usr/share/cups/locale \
    --enable-libpaper \
    --enable-ssl \
    --enable-gnutls \
    --enable-threads \
    --enable-static \
    --disable-debug \
    --enable-dbus \
    --with-dbusdir=/etc/dbus-1 \
    --enable-gssapi \
    --enable-avahi \
    --disable-launchd \
    --with-cups-group=lp \
    --with-system-groups=lpadmin \
    --with-printcap=/var/run/cups/printcap \
    --with-log-file-perm=0640 \
    --with-local_protocols='dnssd' \
    --with-systemd=/lib/systemd/system
make -j${CPUC}
make install
cd "${SOURCEDIR}"
mkdir -p filters
cd filters
curl -o filters-source.tar.gz -l "${FILTERSURL}"
tar --strip=1 -xf filters-source.tar.gz
./configure \
    --with-shell=/bin/sh \
    --libdir=/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH) \
    --mandir=/usr/share/man \
    --enable-static \
    --enable-mutool \
    --with-mutool-path=/usr/bin/mutool \
    --with-test-font-path=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
make -j${CPUC}
make install
cd /
rm -rf "${SOURCEDIR}"
apt-get purge -qy --auto-remove ${BUILD_DEPS} equivs
rm -rf /var/lib/apt/lists/*

# Remove backends that don't make sense in a container.
mkdir -p /usr/lib/cups/backend-available

mv /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/
mv /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/
mv /usr/lib/cups/backend/cups-brf /usr/lib/cups/backend-available/
