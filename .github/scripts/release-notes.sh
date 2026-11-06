#!/usr/bin/env bash
# Prints the top of a release's notes: the image tag and a table of component
# versions, marking what changed since the previous release. The release
# workflow appends GitHub's generated list of merged pull requests below it.
#
# Usage: release-notes.sh <tag> <ref> [previous_tag]
set -euo pipefail

tag="$1"
ref="$2"
prev="${3:-}"
image="${DOCKER_IMAGE:-jacobalberty/cups}"

# name|Dockerfile ARG|upstream release URL (%s = version)
COMPONENTS=(
    "CUPS|CUPS_VERSION|https://github.com/OpenPrinting/cups/releases/tag/v%s"
    "libppd|LIBPPD_VERSION|https://github.com/OpenPrinting/libppd/releases/tag/%s"
    "libcupsfilters|LIBCUPSFILTERS_VERSION|https://github.com/OpenPrinting/libcupsfilters/releases/tag/%s"
    "cups-filters|FILTERS_VERSION|https://github.com/OpenPrinting/cups-filters/releases/tag/%s"
    "qpdf|QPDF_VERSION|https://github.com/qpdf/qpdf/releases/tag/v%s"
)

dockerfile_at() {
    git show "$1:Dockerfile" 2>/dev/null || true
}

arg_in() {
    sed -n "s/^ARG $2=//p" <<<"$1" | head -n1
}

base_in() {
    sed -n 's/^FROM //p' <<<"$1" | head -n1
}

change() {
    local old="$1" new="$2"
    if [ -z "${prev}" ]; then
        echo ""
    elif [ -z "${old}" ]; then
        echo "added"
    elif [ "${old}" != "${new}" ]; then
        echo "updated from ${old}"
    fi
}

cur="$(dockerfile_at "${ref}")"
old=""
[ -z "${prev}" ] || old="$(dockerfile_at "refs/tags/${prev}")"

echo "**Image:** \`${image}:${tag}\` (linux/amd64, linux/arm64)"
echo ""
echo "### Components"
echo ""
echo "| Component | Version | Change |"
echo "| --- | --- | --- |"
cups_changed=""
for c in "${COMPONENTS[@]}"; do
    IFS='|' read -r name arg url <<<"${c}"
    new_v="$(arg_in "${cur}" "${arg}")"
    old_v="$(arg_in "${old}" "${arg}")"
    [ -n "${new_v}" ] || continue
    # shellcheck disable=SC2059 # the URL template is the format string
    link="$(printf "${url}" "${new_v}")"
    ch="$(change "${old_v}" "${new_v}")"
    echo "| ${name} | [${new_v}](${link}) | ${ch} |"
    if [ "${name}" = CUPS ] && [ -n "${ch}" ]; then
        cups_changed="${link}"
    fi
done
new_base="$(base_in "${cur}")"
echo "| Base image | \`${new_base}\` | $(change "$(base_in "${old}")" "${new_base}") |"
echo ""
if [ -n "${cups_changed}" ]; then
    echo "CUPS changed in this release; see the [upstream CUPS release notes](${cups_changed})."
    echo ""
fi
