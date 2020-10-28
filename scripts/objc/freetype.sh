#!/bin/bash

# ENABLE COMMON FUNCTIONS
source "${BASEDIR}"/scripts/function-${FFMPEG_KIT_BUILD_TYPE}.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="freetype"
set_toolchain_paths ${LIB_NAME}

# SET BUILD FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# OVERRIDE PKG-CONFIG
export LIBPNG_CFLAGS="-I${BASEDIR}/prebuilt/$(get_target_build_directory)/libpng/include"
export LIBPNG_LIBS="-L${BASEDIR}/prebuilt/$(get_target_build_directory)/libpng/lib"

./configure \
    --prefix=${BASEDIR}/prebuilt/$(get_target_build_directory)/${LIB_NAME} \
    --with-pic \
    --with-zlib \
    --with-png \
    --with-sysroot=${SDK_PATH} \
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
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_freetype_package_config "23.2.17"

make install || exit 1
