#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS="--enable-asm"
case ${ARCH} in
i386)
  HOST="x86-ios-darwin"
  ;;
x86-64 | x86-64-mac-catalyst)
  ASM_OPTIONS="--disable-asm"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_kvazaar} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

# NOTE THAT kvazaar DOES NOT SUPPORT PARALLEL EXECUTION
make || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./src/kvazaar.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
