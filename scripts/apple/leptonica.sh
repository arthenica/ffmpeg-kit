#!/bin/bash

# UPDATE BUILD FLAGS
HOST=$(get_host)
export CFLAGS=$(get_cflags "${LIB_NAME}")
export CXXFLAGS=$(get_cxxflags "${LIB_NAME}")
export CPPFLAGS="-I${LIB_INSTALL_BASE}/giflib/include"
export LDFLAGS="$(get_ldflags "${LIB_NAME}") -L${LIB_INSTALL_BASE}/giflib/lib -lgif"

export LIBPNG_CFLAGS="$(pkg-config --cflags libpng)"
export LIBPNG_LIBS="$(pkg-config --libs --static libpng)"

export LIBWEBP_CFLAGS="$(pkg-config --cflags libwebp)"
export LIBWEBP_LIBS="$(pkg-config --libs --static libwebp)"

export LIBTIFF_CFLAGS="$(pkg-config --cflags libtiff-4)"
export LIBTIFF_LIBS="$(pkg-config --libs --static libtiff-4)"

export ZLIB_CFLAGS="$(pkg-config --cflags zlib)"
export ZLIB_LIBS="$(pkg-config --libs zlib)"

export JPEG_CFLAGS="$(pkg-config --cflags libjpeg)"
export JPEG_LIBS="$(pkg-config --libs --static libjpeg)"

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_leptonica} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-zlib \
  --with-libpng \
  --with-jpeg \
  --with-giflib \
  --with-libtiff \
  --with-libwebp \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-programs \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp lept.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
