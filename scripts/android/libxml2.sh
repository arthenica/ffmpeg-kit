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
LIB_NAME="libxml2"
set_toolchain_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
export CFLAGS=$(get_cflags ${LIB_NAME})
export CXXFLAGS=$(get_cxxflags ${LIB_NAME})
export LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

make distclean 2>/dev/null 1>/dev/null

# NOTE THAT PYTHON IS DISABLED DUE TO THE FOLLOWING ERROR
#
# .../include/python2.7/pyport.h:1029:2: error: #error "LONG_BIT definition appears wrong for platform (bad gcc/glibc config?)."
# #error "LONG_BIT definition appears wrong for platform (bad gcc/glibc config?)."
#

# ALWAYS RECONFIGURE
autoreconf_library ${LIB_NAME}

./configure \
    --prefix=${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME} \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot \
    --with-zlib \
    --with-iconv=${BASEDIR}/prebuilt/android-$(get_target_build)/libiconv/lib \
    --with-sax1 \
    --without-python \
    --without-debug \
    --without-lzma \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --host=${BUILD_HOST} || exit 1

make -j$(get_cpu_count) || exit 1

# CREATE PACKAGE CONFIG MANUALLY
create_libxml2_package_config "2.9.10"

make install || exit 1
