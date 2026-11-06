#!/usr/bin/env bash
# Works out which release, if any, a commit gets.
#
# Image versions follow CUPS: the first release on a CUPS version is tagged
# v<CUPS_VERSION>; every later release on the same CUPS version (other
# dependency bumps, fixes to the image itself) is tagged v<CUPS_VERSION>-N.
#
# Usage:
#   compute-version.sh          Push to main: tag the next release when CUPS
#                               changed or the image changed since the last
#                               release on this CUPS version.
#   compute-version.sh <tag>    A tag made by hand: check it matches the
#                               CUPS_VERSION in its own Dockerfile.
#
# Prints key=value lines (release, tag, previous_tag, cups_version, is_latest)
# and appends them to $GITHUB_OUTPUT when set.
set -euo pipefail

# Everything that ends up in the image. A change to any of these earns a
# release; docs, examples and CI changes do not.
IMAGE_PATHS=(
    Dockerfile
    build.sh
    docker-entrypoint.sh
    docker-healthcheck.sh
    fakePkg.sh
    functions
    drivers
    patches
    pre_build
)
TAG_RE='^v([0-9]+\.[0-9]+\.[0-9]+)(-([0-9]+))?$'

die() {
    echo "::error::$*" >&2
    exit 1
}

cups_version_at() {
    git show "$1:Dockerfile" | sed -n 's/^ARG CUPS_VERSION=//p'
}

# All release tags, oldest first. Older tag styles (2.2.13, v2.3.3op2) don't
# match TAG_RE and are ignored.
release_tags() {
    git tag --list 'v*' | grep -E "${TAG_RE}" | sort -V || true
}

# Release tags for one CUPS version, oldest first.
tags_for_cups() {
    grep -E "^v${1//./\\.}(-[0-9]+)?$" || true
}

# The release tag sorting just before $1 (empty if none).
previous_of() {
    { release_tags; echo "$1"; } | sort -uV | awk -v t="$1" '$0 == t { print p; exit } { p = $0 }'
}

newest_with() {
    { release_tags; echo "$1"; } | sort -uV | tail -n1
}

release=false
tag=""

if [ $# -ge 1 ] && [ -n "$1" ]; then
    tag="$1"
    [[ "${tag}" =~ ${TAG_RE} ]] || die "Release tag must be vX.Y.Z or vX.Y.Z-N, got ${tag}"
    base="${BASH_REMATCH[1]}"
    git rev-parse -q --verify "refs/tags/${tag}" >/dev/null || die "Tag ${tag} does not exist"
    cups="$(cups_version_at "refs/tags/${tag}")"
    [ -n "${cups}" ] || die "No ARG CUPS_VERSION in the Dockerfile at ${tag}"
    [ "${base}" = "${cups}" ] ||
        die "Tag ${tag} does not match CUPS_VERSION=${cups} in its Dockerfile; use v${cups} or v${cups}-N"
    release=true
else
    cups="$(cups_version_at HEAD)"
    [ -n "${cups}" ] || die "No ARG CUPS_VERSION in the Dockerfile"
    # A re-run after a failed build: HEAD already carries this release's tag.
    head_tag="$(git tag --points-at HEAD | tags_for_cups "${cups}" | sort -V | tail -n1)"
    last="$(release_tags | tags_for_cups "${cups}" | tail -n1)"
    if [ -n "${head_tag}" ]; then
        tag="${head_tag}"
        release=true
    elif [ -z "${last}" ]; then
        tag="v${cups}"
        release=true
    elif ! git diff --quiet "${last}" HEAD -- "${IMAGE_PATHS[@]}"; then
        rev="${last#"v${cups}"}"
        rev="${rev#-}"
        tag="v${cups}-$((${rev:-0} + 1))"
        release=true
    else
        echo "No image changes since ${last}; nothing to release." >&2
    fi
    if [ "${release}" = true ] && [ "$(newest_with "${tag}")" != "${tag}" ]; then
        die "${tag} would be older than the newest release $(release_tags | tail -n1); CUPS_VERSION=${cups} went backwards. Tag a release by hand if this is intended."
    fi
fi

previous_tag=""
is_latest=false
if [ "${release}" = true ]; then
    previous_tag="$(previous_of "${tag}")"
    [ "$(newest_with "${tag}")" = "${tag}" ] && is_latest=true
fi

out="release=${release}
tag=${tag}
previous_tag=${previous_tag}
cups_version=${cups}
is_latest=${is_latest}"
echo "${out}"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "${out}" >>"${GITHUB_OUTPUT}"
fi
