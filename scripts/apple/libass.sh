#!/bin/bash

# SET BUILD OPTIONS
ASM_OPTIONS="--enable-asm"
case ${ARCH} in
arm* | x86-64 | x86-64-mac-catalyst)
  ASM_OPTIONS="--disable-asm"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_libass} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --disable-libtool-lock \
  --enable-static \
  --disable-shared \
  --disable-require-system-font-provider \
  --disable-fast-install \
  --disable-test \
  --disable-profile \
  --disable-coretext \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
