#!/bin/sh
# To add this repository please do:

set -eu

if [ "$(id -u)" -ne 0 ]; then
    SUDO=sudo
else
    SUDO=
fi

if [ -r /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    DISTRO_ID="${ID:-}"
    CODENAME="${VERSION_CODENAME:-}"
else
    DISTRO_ID=
    CODENAME=
fi

if [ -z "${DISTRO_ID}" ] || [ -z "${CODENAME}" ]; then
    echo "Unable to detect distro codename from /etc/os-release."
    echo "This repository supports Debian (buster, bullseye, bookworm, trixie) and Ubuntu (jammy, noble)."
    exit 1
fi

case "${DISTRO_ID}:${CODENAME}" in
    debian:buster|debian:bullseye|debian:bookworm|debian:trixie|ubuntu:jammy|ubuntu:noble)
        ;;
    *)
        echo "Unsupported distribution: ${DISTRO_ID}:${CODENAME}"
        echo "Supported releases: debian:{buster,bullseye,bookworm,trixie} ubuntu:{jammy,noble}"
        exit 1
        ;;
esac

${SUDO} apt-get update
${SUDO} apt-get -y install ca-certificates wget
${SUDO} wget -O /usr/share/keyrings/greensec.github.io-nsd-debian.key https://greensec.github.io/nsd-debian/public.key
echo "deb [signed-by=/usr/share/keyrings/greensec.github.io-nsd-debian.key] https://greensec.github.io/nsd-debian/repo ${CODENAME} main" | ${SUDO} tee /etc/apt/sources.list.d/nsd-debian.list
${SUDO} apt-get update
