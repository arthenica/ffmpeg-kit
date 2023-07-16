#!/bin/bash

# NOTE THAT PYTHON IS DISABLED DUE TO THE FOLLOWING ERROR
#
# .../include/python2.7/pyport.h:1029:2: error: #error "LONG_BIT definition appears wrong for platform (bad gcc/glibc config?)."
# #error "LONG_BIT definition appears wrong for platform (bad gcc/glibc config?)."
#

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_libxml2} -eq 1 ]]; then
  ${SED_INLINE} 's|^AC_PREREQ|#AC_PREREQ|g' "${BASEDIR}"/src/"${LIB_NAME}"/configure.ac || return 1
  ${SED_INLINE} 's|AM_INIT_AUTOMAKE(\[[0-9.]* |AM_INIT_AUTOMAKE(\[|g' "${BASEDIR}"/src/"${LIB_NAME}"/configure.ac || return 1
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${ANDROID_SYSROOT}" \
  --with-zlib \
  --with-iconv="${LIB_INSTALL_BASE}/libiconv/lib" \
  --with-sax1 \
  --without-python \
  --without-debug \
  --without-lzma \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_libxml2_package_config "2.11.4" || return 1
