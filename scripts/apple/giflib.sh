#!/bin/bash

# UPDATE BUILD FLAGS
export CFLAGS=$(get_cflags "${LIB_NAME}")" -DS_IREAD=S_IRUSR -DS_IWRITE=S_IWUSR"

# COPY BUILD FILES
cp "${BASEDIR}"/tools/patch/make/giflib/* "${BASEDIR}"/src/"${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_giflib} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_giflib_package_config "5.2.1" || return 1
