#!/usr/bin/env bash

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
