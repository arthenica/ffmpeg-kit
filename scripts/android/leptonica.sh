#!/bin/bash

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo -e "\n(*) ANDROID_NDK_ROOT not defined\n"
    exit 1
fi

if [[ -z ${ARCH} ]]; then
    echo -e "\n(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${API} ]]; then
    echo -e "\n(*) API not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "\n(*) BASEDIR not defined\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="leptonica"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export CPPFLAGS="-I${BASEDIR}/prebuilt/android-$(get_target_build)/giflib/include"
export LDFLAGS="$(get_ldflags ${LIB_NAME}) -L${BASEDIR}/prebuilt/android-$(get_target_build)/giflib/lib -lgif"
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

export LIBPNG_CFLAGS="$(pkg-config --cflags libpng)"
export LIBPNG_LIBS="$(pkg-config --libs --static libpng)"

export LIBWEBP_CFLAGS="$(pkg-config --cflags libwebp)"
export LIBWEBP_LIBS="$(pkg-config --libs --static libwebp)"

export LIBTIFF_CFLAGS="$(pkg-config --cflags libtiff-4)"
export LIBTIFF_LIBS="$(pkg-config --libs --static libtiff-4)"

export ZLIB_CFLAGS="$(pkg-config --cflags zlib)"
export ZLIB_LIBS="$(pkg-config --libs --static zlib)"

export JPEG_CFLAGS="$(pkg-config --cflags libjpeg)"
export JPEG_LIBS="$(pkg-config --libs --static libjpeg)"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# RECONFIGURE IF REQUESTED
if [[ ${RECONF_leptonica} -eq 1 ]]; then
    autoreconf_library ${LIB_NAME}
fi

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
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
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp lept.pc ${INSTALL_PKG_CONFIG_DIR} || exit 1

make install || exit 1
