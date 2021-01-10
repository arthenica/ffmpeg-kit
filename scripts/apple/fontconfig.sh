#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_fontconfig} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}"
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-libiconv-prefix="${SDK_PATH}"/usr \
  --with-expat="${LIB_INSTALL_BASE}"/expat \
  --without-libintl-prefix \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-rpath \
  --disable-libxml2 \
  --disable-docs \
  --host="${HOST}" || return 1

# DISABLE IOS TESTS with system() calls - system() is deprecated for IOS
# 1. test-bz106632.c
overwrite_file "${BASEDIR}"/src/"${LIB_NAME}"/test/test-bz106618.c "${BASEDIR}"/src/"${LIB_NAME}"/test/test-bz106632.c

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_fontconfig_package_config "2.13.93" || return 1
