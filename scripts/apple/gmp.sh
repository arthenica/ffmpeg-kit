#!/bin/bash

# SET BUILD OPTIONS
unset gmp_cv_asm_w32
case ${ARCH} in
i386)
  HOST="x86-ios-darwin"
  ;;
x86-64-mac-catalyst)
  # Workaround for 'cannot determine how to define a 32-bit word' error
  export gmp_cv_asm_w32=".long"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_gmp} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

# UPDATE CONFIG FILES TO SUPPORT APPLE ARCHITECTURES
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.guess "${BASEDIR}"/src/"${LIB_NAME}"/config.guess || return 1
overwrite_file "${FFMPEG_KIT_TMPDIR}"/source/config/config.sub "${BASEDIR}"/src/"${LIB_NAME}"/config.sub || return 1

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --enable-static \
  --disable-assembly \
  --disable-shared \
  --disable-fast-install \
  --disable-maintainer-mode \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_gmp_package_config "6.2.1" || return 1
