#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$1"
TOOLS_INSTALL_DIR="$2"
TMP_DIR="/tmp/toolchain-install"

if [[ ${INSTALL_DIR} = "" ]]
then
  echo "Specify toolchain absolute install dir path as a first argument!" >&2
  exit 1
fi

if [[ ${TOOLS_INSTALL_DIR} = "" ]]
then
  echo "Specify tools install dir absolute path as a second argument!" >&2
  exit 1
fi

if ! [[ -d ${INSTALL_DIR} ]]
then
  echo "Install dir '${INSTALL_DIR}' does not exist"
fi



TOOLS_PACKAGE_URI="https://github.com/bacpack-system/packager/releases/download/v1.0.0/bringauto-packager-tools_v1.0.0_x86-64-linux.zip"

#
# Install our BringAuto Fleet
#
function install_toolchain() {
  if [[ -d ${TMP_DIR} ]]
  then
    echo "TMP dir '${TMP_DIR}' exist"
  fi
  mkdir -p "${TMP_DIR}"

  pushd "${TMP_DIR}"
    local toolchain_pack="/root/toolchain/oecore.sh"
    if ! [[ -f $toolchain_pack ]]
    then
      echo "Toolchain dir '${toolchain_pack}' DOES NOT exist" >&2
      echo "Manually download Toolchain by download_toolchain.sh script located docker/fleet-os-3" >&2
      exit 1
    fi

    mv "${toolchain_pack}" .

    toolchain_installer="$(echo ./*)"
    chmod +x "${toolchain_installer}"

    "${toolchain_installer}" -S -y -d "${INSTALL_DIR}" || echo ok
    echo ". ${INSTALL_DIR}/environment-setup-cortexa72-oe-linux" >> /environment.sh

    #
    # We need to overwrite default setting from Yocto Toolchain.
    #
    echo "set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH )" >> "${INSTALL_DIR}/sysroots/x86_64-oesdk-linux/usr/share/cmake/OEToolchainConfig.cmake"
    echo "set( CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH )" >> "${INSTALL_DIR}/sysroots/x86_64-oesdk-linux/usr/share/cmake/OEToolchainConfig.cmake"
    echo "set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH )" >> "${INSTALL_DIR}/sysroots/x86_64-oesdk-linux/usr/share/cmake/OEToolchainConfig.cmake"
  popd
  rm -r "${TMP_DIR}"
}


function install_tools() {
  if [[ -d ${TMP_DIR} ]]
  then
    echo "TMP dir '${TMP_DIR}' exist"
  fi
  mkdir -p "${TMP_DIR}"
  mkdir -p "${TOOLS_INSTALL_DIR}"

  pushd "${TMP_DIR}"
    wget ${TOOLS_PACKAGE_URI} \
      -O "bringauto-packager-tools.zip"
    unzip bringauto-packager-tools.zip
    rm bringauto-packager-tools.zip
    directory_name="$(echo ./*)"
    mv "${directory_name}"/* "${TOOLS_INSTALL_DIR}"
    rm -r "${directory_name}"
  popd
  rm -r "${TMP_DIR}"

  chmod +x "${TOOLS_INSTALL_DIR}/lsb_release"
  chmod +x "${TOOLS_INSTALL_DIR}/uname"
  echo 'PATH='"${TOOLS_INSTALL_DIR}"'/:$PATH' >> /root/.bashrc
}



install_toolchain
install_tools
