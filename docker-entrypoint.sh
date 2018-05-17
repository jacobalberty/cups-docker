#!/bin/bash
set -e

# usage: replace conf var new_val
replace () {
    var=$2
    new_val=$3

    sed -i "s/^$var *= *.*/$var = $new_val/; s/^$var [^=]*$/$var $new_val/" "$1"
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local def="${2:-}"
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
        exit 1
    fi
    local val="$def"
    if [ "${!var:-}" ]; then
        val="${!var}"
    elif [ "${!fileVar:-}" ]; then
        val="$(< "${!fileVar}")"
    fi
    export "$var"="$val"
    unset "$fileVar"
}
if [[ ! -e "${VOLUME}/etc/" ]]; then
    cp -R "${PREFIX}/skel/cups/etc" "${VOLUME}/"
    if [[ "$LOGSTDERR" != "false" ]]; then
        replace "${VOLUME}/etc/cups-files.conf" AccessLog stderr
        replace "${VOLUME}/etc/cups-files.conf" ErrorLog stderr
        replace "${VOLUME}/etc/cups-files.conf" PageLog stderr
    fi
fi
if [ -d "/usr/local/docker/init.d" ]; then
    run-parts /usr/local/docker/init.d
fi

if [ -d ${VOLUME}/init.d ]; then
    run-parts ${VOLUME}/init.d
fi

# Ensure logdir exists and is owned by the correct group
if [[ ! -e "${VOLUME}/log" ]]; then
    mkdir -p "${VOLUME}/log"
    chgrp lp "${VOLUME}/log"
fi
$@
