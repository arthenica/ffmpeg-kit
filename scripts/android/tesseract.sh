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

# WORKAROUND TO MANUALLY SET ENDIANNESS
export ac_cv_c_bigendian=no

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${ANDROID_SYSROOT}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-debug \
  --disable-graphics \
  --disable-cube \
  --disable-tessdata-prefix \
  --disable-largefile \
  --host="${HOST}" || return 1

# WORKAROUND TO DISABLE LINKING TO rt
${SED_INLINE} 's/\-lrt//g' "${BASEDIR}"/src/"${LIB_NAME}"/api/Makefile || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_tesseract_package_config "3.05.02" || return 1
