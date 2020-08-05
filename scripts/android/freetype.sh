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
LIB_NAME="freetype"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# OVERRIDING PKG-CONFIG
export LIBPNG_CFLAGS="-I${BASEDIR}/prebuilt/android-$(get_target_build)/libpng/include"
export LIBPNG_LIBS="-L${BASEDIR}/prebuilt/android-$(get_target_build)/libpng/lib"

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-zlib \
    --with-png \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
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
