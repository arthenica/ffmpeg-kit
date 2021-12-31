#!/bin/bash

cd "${LIB_NAME}" || return 1

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_lame} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${ANDROID_SYSROOT}" \
  --with-libiconv-prefix="${LIB_INSTALL_BASE}"/libiconv \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-maintainer-mode \
  --disable-frontend \
  --disable-efence \
  --disable-gtktest \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_libmp3lame_package_config "3.100" || return 1
