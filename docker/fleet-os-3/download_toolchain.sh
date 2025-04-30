#!/usr/bin/env bash

#
# This script does not work. Because of gitlab...
#
echo "DOES NOT WORK. DOWNLOAD MANUALLY BY CLICKING URI BELOW!" >&2
echo "THEN UNZIP/UNTAR and copy toolchain as toolchain/oecore.sh" >&2

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
FLEET_OS_VERSION="v3.0.0"

#
# Lets use cortex-a72 toolchain so the compile binaries
# can be run by cortex-a72 (rspi4) and cortex a76 (rspi5)
#
TOOLCHAIN_PACKAGE_URI="https://gitlab.bringauto.com/bringauto-customer-data/fleet-os-images/-/raw/${FLEET_OS_VERSION}/fleet-os-3/ba-raspberrypi4-64/fleet-os-3.toolchain.bringauto-image-compile.ba-raspberrypi4-64.zip"
echo "${TOOLCHAIN_PACKAGE_URI}" >&2
exit 1


#
# I let this in tack.
# It will be nice to DOWNLOAD it by script one day...
#

if [[ ${GITLAB_TOKEN} = "" ]]
then
  echo "Specify gitlab token as a first argument!" >&2
  exit 1
fi

function download_toolchain {
    if [[ -f ${SCRIPT_DIR}/toolchain/oecore.sh ]]
    then
        echo "Toolchain dir '${SCRIPT_DIR}/toolchain/oecore.sh' exist" >&2
        exit 1
    fi
    curl ${TOOLCHAIN_PACKAGE_URI} \
        --header "PRIVATE-TOKEN: ${GITLAB_TOKEN}" \
        -o "${SCRIPT_DIR}/toolchain/oecore.sh.zip"
}

download_toolchain
