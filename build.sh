#!/bin/bash
set -e
SOURCEDIR=/home/source
CPUC=$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo)
CUPSURL=https://github.com/openprinting/cups/releases/download/v${CUPS_VERSION}/cups-${CUPS_VERSION}-source.tar.gz
FILTERSURL=http://openprinting.org/download/cups-filters/cups-filters-${FILTERS_VERSION}.tar.gz
QPDFURL=https://github.com/qpdf/qpdf/releases/download/release-qpdf-${QPDF_VERSION}/qpdf-${QPDF_VERSION}.tar.gz

BUILD_DEPS="
    autoconf \
    build-essential \
    curl \
    dpkg-dev \
    g++ \
    gcc \
    libavahi-client-dev \
    libavahi-glib-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libglib2.0-dev \
    libgnutls28-dev \
    libijs-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    liblcms2-dev \
    libnss-mdns \
    libpam-dev \
    libpng-dev \
    libpoppler-cpp-dev \
    libpoppler-dev \
    libpoppler-private-dev \
    libsystemd-dev \
    libtiff5-dev \
    libusb-1.0-0-dev \
    make \
    pkg-config \
    quilt \
    zlib1g-dev"

groupadd lpadmin
apt-get update
apt-get install -qy --no-install-recommends equivs
${PREFIX}/bin/fakePkg.sh "cups" "${CUPS_VERSION}"
${PREFIX}/bin/fakePkg.sh "cups-client" "${CUPS_VERSION}"
${PREFIX}/bin/fakePkg.sh "libcups2" "${CUPS_VERSION}"
${PREFIX}/bin/fakePkg.sh "libcupsimage2" "${CUPS_VERSION}"
${PREFIX}/bin/fakePkg.sh "cups-filters" "${FILTERS_VERSION}"
${PREFIX}/bin/fakePkg.sh "libcupsfilters1" "${FILTERS_VERSION}"
apt-get install -qy --no-install-recommends ${BUILD_DEPS} \
    ca-certificates \
    ghostscript \
    libatomic1 \
    libavahi-client3 \
    libavahi-glib1 \
    libfontconfig1 \
    libfreetype6 \
    libgnutls-openssl27 \
    libgnutlsxx28 \
    libgssapi-krb5-2 \
    libijs-0.35 \
    libjpeg62-turbo \
    liblcms2-2 \
    libpng16-16 \
    libpoppler102 \
    libpoppler-cpp0v5 \
    libtiff5 \
    mupdf-tools \
    poppler-utils
mkdir -p "${SOURCEDIR}"
cd "${SOURCEDIR}"

if [ -d "/usr/local/docker/pre_build/$(dpkg --print-architecture)" ]; then
    find "/usr/local/docker/pre_build/$(dpkg --print-architecture)" -type f -exec '{}' \;
fi

mkdir -p cups
cd cups
curl -o cups-source.tar.gz -L \
    "${CUPSURL}"
tar --strip=1 -xf cups-source.tar.gz
if [ -f /home/patches/cups/series ]; then
    mv /home/patches/cups ./patches
    quilt push -a
fi
./configure \
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
    --with-logdir=/config/log \
    --with-log-file-perm=0640 \
    --with-local_protocols='dnssd' \
    --with-systemd=/lib/systemd/system \
    --localstatedir=${VOLUME}/state
make -j${CPUC}
make install

cd "${SOURCEDIR}"
mkdir -p qpdf
cd qpdf
curl -o qpdf-source.tar.gz -L "${QPDFURL}"
tar --strip=1 -xf qpdf-source.tar.gz
./configure
make -j${CPUC}
make install

cd "${SOURCEDIR}"
mkdir -p filters
cd filters
curl -o filters-source.tar.gz -L "${FILTERSURL}"
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

# save /etc/cups to recreate it if needed.
mkdir -p "${PREFIX}/skel/cups"
mv /etc/cups "${PREFIX}/skel/cups/etc"

# Use symbolic links to redirect a few standard cups directories to the volume
ln -s "${VOLUME}/etc" /etc/cups
ln -s "${VOLUME}/log" /var/log/cups

# Remove backends that don't make sense in a container.
mkdir -p /usr/lib/cups/backend-available

mv /usr/lib/cups/backend/parallel /usr/lib/cups/backend-available/
mv /usr/lib/cups/backend/serial /usr/lib/cups/backend-available/
mv /usr/lib/cups/backend/cups-brf /usr/lib/cups/backend-available/
