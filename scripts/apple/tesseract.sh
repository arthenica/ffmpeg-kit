#!/bin/bash

# UPDATE BUILD FLAGS
export LEPTONICA_CFLAGS="-I${LIB_INSTALL_BASE}/leptonica/include/leptonica"
export LEPTONICA_LIBS="-L${LIB_INSTALL_BASE}/leptonica/lib -llept"

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_tesseract} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-debug \
  --disable-graphics \
  --disable-cube \
  --disable-tessdata-prefix \
  --disable-largefile \
  --host="${HOST}" || return 1

# WORKAROUNDS
git checkout ${BASEDIR}/src/${LIB_NAME}/libtool 1>>"${BASEDIR}"/build.log 2>&1
if [[ ${FFMPEG_KIT_BUILD_TYPE} != "macos" ]]; then

  # WORKAROUND TO REMOVE -bind_at_load FLAG WHICH CAN NOT BE USED WHEN BITCODE IS ENABLED
  ${SED_INLINE} 's/$wl-bind_at_load//g' ${BASEDIR}/src/${LIB_NAME}/libtool
fi

# WORKAROUND TO DISABLE LINKING TO rt
${SED_INLINE} 's/-lrt//g' ${BASEDIR}/src/${LIB_NAME}/api/Makefile

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_tesseract_package_config "3.05.02" || return 1
