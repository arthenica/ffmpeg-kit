#!/bin/bash

# UPDATE BUILD FLAGS
export LIBPNG_CFLAGS="-I${LIB_INSTALL_BASE}/libpng/include"
export LIBPNG_LIBS="-L${LIB_INSTALL_BASE}/libpng/lib"

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/builds/unix/configure ]] || [[ ${RECONF_freetype} -eq 1 ]]; then

  # NOTE THAT FREETYPE DOES NOT SUPPORT AUTORECONF BUT IT COMES WITH AN autogen.sh
  ./autogen.sh || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-zlib \
  --with-png \
  --with-sysroot="${ANDROID_SYSROOT}" \
  --without-harfbuzz \
  --without-bzip2 \
  --without-fsref \
  --without-quickdraw-toolbox \
  --without-quickdraw-carbon \
  --without-ats \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-mmap \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_freetype_package_config "25.0.19" || return 1
